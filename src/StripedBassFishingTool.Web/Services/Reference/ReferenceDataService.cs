using System.Data;
using System.Globalization;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Npgsql;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.Options;
using StripedBassFishingTool.Web.ViewModels.Reference;

namespace StripedBassFishingTool.Web.Services.Reference;

public sealed class ReferenceDataService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;
    private readonly ReferenceTableRegistry _registry;
    private readonly DurableSeedOptions _durableSeedOptions;
    private readonly ILogger<ReferenceDataService> _logger;

    public ReferenceDataService(
        IDbContextFactory<AppDbContext> dbContextFactory,
        ReferenceTableRegistry registry,
        IOptions<DurableSeedOptions> durableSeedOptions,
        ILogger<ReferenceDataService> logger)
    {
        _dbContextFactory = dbContextFactory;
        _registry = registry;
        _durableSeedOptions = durableSeedOptions.Value;
        _logger = logger;
    }

    public ReferenceTableViewModel? GetTableDefinition(string referenceType)
    {
        return _registry.GetByReferenceType(referenceType);
    }

    public async Task<IReadOnlyList<ReferenceTableSummaryViewModel>> GetTableSummariesAsync(
        CancellationToken cancellationToken = default)
    {
        var summaries = new List<ReferenceTableSummaryViewModel>();

        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        var connection = db.Database.GetDbConnection();

        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }

        foreach (var table in _registry.GetAll())
        {
            await using var command = connection.CreateCommand();
            command.CommandText = $"SELECT COUNT(*) FROM stripedbassfishingtool.{table.TableName};";

            var count = Convert.ToInt32(
                await command.ExecuteScalarAsync(cancellationToken),
                CultureInfo.InvariantCulture);

            summaries.Add(new ReferenceTableSummaryViewModel
            {
                ReferenceType = table.ReferenceType,
                DisplayName = table.DisplayName,
                PluralDisplayName = table.PluralDisplayName,
                Description = table.Description,
                RecordCount = count
            });
        }

        return summaries
            .OrderBy(x => x.PluralDisplayName)
            .ToList();
    }

    public async Task<IReadOnlyList<ReferenceRecordViewModel>> GetRecordsAsync(
        string referenceType,
        CancellationToken cancellationToken = default)
    {
        var table = _registry.GetByReferenceType(referenceType);

        if (table is null)
        {
            return [];
        }

        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        var connection = db.Database.GetDbConnection();

        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }

        var selectedColumns = new List<string>
        {
            table.PrimaryKeyColumn
        };

        selectedColumns.AddRange(table.Fields.Select(x => x.ColumnName));

        var columnList = string.Join(", ", selectedColumns.Distinct());

        var orderColumn = table.Fields.Any(x => x.ColumnName == "display_order")
            ? "display_order"
            : table.NaturalKeyColumn;

        await using var command = connection.CreateCommand();
        command.CommandText = $"""
            SELECT {columnList}
            FROM stripedbassfishingtool.{table.TableName}
            ORDER BY {orderColumn}, {table.NaturalKeyColumn};
            """;

        var records = new List<ReferenceRecordViewModel>();

        await using var reader = await command.ExecuteReaderAsync(cancellationToken);

        while (await reader.ReadAsync(cancellationToken))
        {
            var values = new Dictionary<string, string?>();

            foreach (var field in table.Fields)
            {
                var rawValue = reader[field.ColumnName];

                values[field.ColumnName] = rawValue == DBNull.Value
                    ? null
                    : Convert.ToString(rawValue, CultureInfo.InvariantCulture);
            }

            records.Add(new ReferenceRecordViewModel
            {
                Id = Convert.ToInt32(reader[table.PrimaryKeyColumn], CultureInfo.InvariantCulture),
                PrimaryLabel = Convert.ToString(reader[table.NaturalKeyColumn], CultureInfo.InvariantCulture) ?? "",
                SecondaryLabel = BuildSecondaryLabel(table, values),
                Values = values
            });
        }

        return records;
    }

    public async Task<int> CreateRecordAsync(
        string referenceType,
        Dictionary<string, string?> values,
        CancellationToken cancellationToken = default)
    {
        var table = _registry.GetByReferenceType(referenceType)
            ?? throw new InvalidOperationException($"Unknown reference type: {referenceType}");

        ValidateRequiredFields(table, values);

        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        var connection = (NpgsqlConnection)db.Database.GetDbConnection();

        if (connection.State != ConnectionState.Open)
        {
            await connection.OpenAsync(cancellationToken);
        }

        var insertFields = table.Fields
            .Where(field => ShouldIncludeField(field, values))
            .ToList();

        var columnList = string.Join(", ", insertFields.Select(x => x.ColumnName));
        var parameterList = string.Join(", ", insertFields.Select(x => "@" + x.PropertyName));

        await using var command = connection.CreateCommand();
        command.CommandText = $"""
            INSERT INTO stripedbassfishingtool.{table.TableName}
                ({columnList})
            VALUES
                ({parameterList})
            ON CONFLICT ({table.NaturalKeyColumn}) DO NOTHING
            RETURNING {table.PrimaryKeyColumn};
            """;

        foreach (var field in insertFields)
        {
            var value = values.GetValueOrDefault(field.PropertyName);

            command.Parameters.AddWithValue(
                "@" + field.PropertyName,
                ConvertValueForDatabase(field, value));
        }

        var result = await command.ExecuteScalarAsync(cancellationToken);

        int newId;

        if (result is null)
        {
            newId = await GetExistingIdAsync(connection, table, values, cancellationToken);
        }
        else
        {
            newId = Convert.ToInt32(result, CultureInfo.InvariantCulture);
        }

        await AppendReferenceSeedBlockIfEnabledAsync(
            table,
            values,
            cancellationToken);

        return newId;
    }

    private static void ValidateRequiredFields(
        ReferenceTableViewModel table,
        Dictionary<string, string?> values)
    {
        foreach (var field in table.Fields.Where(x => x.IsRequired))
        {
            if (string.IsNullOrWhiteSpace(values.GetValueOrDefault(field.PropertyName)))
            {
                throw new InvalidOperationException($"{field.Label} is required.");
            }
        }
    }

    private static bool ShouldIncludeField(
        ReferenceFieldViewModel field,
        Dictionary<string, string?> values)
    {
        if (!values.TryGetValue(field.PropertyName, out var value))
        {
            return false;
        }

        if (field.IsRequired)
        {
            return true;
        }

        return !string.IsNullOrWhiteSpace(value);
    }

    private static object ConvertValueForDatabase(
        ReferenceFieldViewModel field,
        string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return DBNull.Value;
        }

        if (field.IsNumber)
        {
            if (decimal.TryParse(value, NumberStyles.Number, CultureInfo.InvariantCulture, out var decimalValue))
            {
                return decimalValue;
            }

            throw new InvalidOperationException($"{field.Label} must be a valid number.");
        }

        if (field.IsBoolean)
        {
            if (bool.TryParse(value, out var boolValue))
            {
                return boolValue;
            }

            throw new InvalidOperationException($"{field.Label} must be true or false.");
        }

        return value.Trim();
    }

    private static async Task<int> GetExistingIdAsync(
        NpgsqlConnection connection,
        ReferenceTableViewModel table,
        Dictionary<string, string?> values,
        CancellationToken cancellationToken)
    {
        var naturalKeyValue = values.GetValueOrDefault(
            table.Fields.Single(x => x.ColumnName == table.NaturalKeyColumn).PropertyName);

        await using var command = connection.CreateCommand();
        command.CommandText = $"""
            SELECT {table.PrimaryKeyColumn}
            FROM stripedbassfishingtool.{table.TableName}
            WHERE {table.NaturalKeyColumn} = @naturalKeyValue;
            """;

        command.Parameters.AddWithValue("@naturalKeyValue", naturalKeyValue?.Trim() ?? "");

        var result = await command.ExecuteScalarAsync(cancellationToken);

        if (result is null)
        {
            throw new InvalidOperationException("The record was not inserted and an existing record could not be found.");
        }

        return Convert.ToInt32(result, CultureInfo.InvariantCulture);
    }

    private async Task AppendReferenceSeedBlockIfEnabledAsync(
        ReferenceTableViewModel table,
        Dictionary<string, string?> values,
        CancellationToken cancellationToken)
    {
        if (!_durableSeedOptions.AppendOnCreate)
        {
            return;
        }

        if (string.IsNullOrWhiteSpace(_durableSeedOptions.ReferenceDataPath))
        {
            throw new InvalidOperationException(
                "Durable seed append is enabled, but DurableSeed:ReferenceDataPath is not configured.");
        }

        var filePath = Path.GetFullPath(_durableSeedOptions.ReferenceDataPath);
        var directoryPath = Path.GetDirectoryName(filePath);

        if (string.IsNullOrWhiteSpace(directoryPath))
        {
            throw new InvalidOperationException($"Could not determine directory for seed file path: {filePath}");
        }

        Directory.CreateDirectory(directoryPath);

        var sqlBlock = BuildReferenceSeedBlock(table, values);

        try
        {
            await File.AppendAllTextAsync(
                filePath,
                sqlBlock,
                Encoding.UTF8,
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to append reference data to durable seed file.");
            throw;
        }
    }

    private static string BuildReferenceSeedBlock(
        ReferenceTableViewModel table,
        Dictionary<string, string?> values)
    {
        var includedFields = table.Fields
            .Where(field => ShouldIncludeField(field, values))
            .ToList();

        var naturalKeyField = table.Fields.Single(x => x.ColumnName == table.NaturalKeyColumn);
        var naturalKeyValue = values.GetValueOrDefault(naturalKeyField.PropertyName)?.Trim() ?? "";

        var builder = new StringBuilder();

        builder.AppendLine();
        builder.AppendLine();
        builder.AppendLine("/* ============================================================");
        builder.AppendLine($"   Reference Data: {table.DisplayName} - {naturalKeyValue}");
        builder.AppendLine("   Added from Blazor reference create page");
        builder.AppendLine("   ============================================================ */");
        builder.AppendLine();

        builder.AppendLine($"INSERT INTO stripedbassfishingtool.{table.TableName}");
        builder.AppendLine("    (");
        builder.AppendLine(string.Join("," + Environment.NewLine, includedFields.Select(x => $"        {x.ColumnName}")));
        builder.AppendLine("    )");
        builder.AppendLine("VALUES");
        builder.AppendLine("    (");
        builder.AppendLine(string.Join("," + Environment.NewLine, includedFields.Select(x => $"        {SqlValue(x, values.GetValueOrDefault(x.PropertyName))}")));
        builder.AppendLine("    )");
        builder.AppendLine($"ON CONFLICT ({table.NaturalKeyColumn}) DO NOTHING;");

        return builder.ToString();
    }

    private static string SqlValue(
        ReferenceFieldViewModel field,
        string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "NULL";
        }

        if (field.IsNumber)
        {
            return value.Trim();
        }

        if (field.IsBoolean)
        {
            return value.Trim().Equals("true", StringComparison.OrdinalIgnoreCase)
                ? "true"
                : "false";
        }

        return $"'{value.Trim().Replace("'", "''")}'";
    }

    private static string? BuildSecondaryLabel(
        ReferenceTableViewModel table,
        Dictionary<string, string?> values)
    {
        if (values.TryGetValue("description", out var description) &&
            !string.IsNullOrWhiteSpace(description))
        {
            return description.Length > 160
                ? description[..160] + "..."
                : description;
        }

        if (values.TryGetValue("category", out var category) &&
            !string.IsNullOrWhiteSpace(category))
        {
            return category;
        }

        if (values.TryGetValue("short_name", out var shortName) &&
            !string.IsNullOrWhiteSpace(shortName))
        {
            return shortName;
        }

        return null;
    }
}