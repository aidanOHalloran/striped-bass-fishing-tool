using System.Text;
using StripedBassFishingTool.Web.ViewModels.Knowledge;
using Microsoft.Extensions.Options;
using StripedBassFishingTool.Web.Options;

namespace StripedBassFishingTool.Web.Services.Knowledge;

public sealed class KnowledgeEntrySeedWriter
{
    private readonly DurableSeedOptions _options;
    private readonly ILogger<KnowledgeEntrySeedWriter> _logger;

    public KnowledgeEntrySeedWriter(
        IOptions<DurableSeedOptions> options,
        ILogger<KnowledgeEntrySeedWriter> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public async Task<DurableSeedAppendResult> AppendKnowledgeEntryAsync(KnowledgeEntryFormViewModel form, KnowledgeEntryLookupViewModel lookups, CancellationToken cancellationToken = default)
    {
        if (!_options.AppendOnCreate)
        {
            return DurableSeedAppendResult.Skipped();
        }

        var configuredPath = _options.KnowledgeEntriesPath;

        if (string.IsNullOrWhiteSpace(configuredPath))
        {
            return DurableSeedAppendResult.Failed(
                "Durable seed append is enabled, but DurableSeed:KnowledgeEntriesPath is not configured.");
        }

        var filePath = Path.GetFullPath(configuredPath);
        var directoryPath = Path.GetDirectoryName(filePath);

        if (string.IsNullOrWhiteSpace(directoryPath))
        {
            return DurableSeedAppendResult.Failed(
                $"Could not determine directory for seed file path: {filePath}");
        }

        try
        {
            Directory.CreateDirectory(directoryPath);

            var sqlBlock = BuildSqlBlock(form, lookups);

            await File.AppendAllTextAsync(
                filePath,
                sqlBlock,
                Encoding.UTF8,
                cancellationToken);

            return DurableSeedAppendResult.Success(filePath);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to append knowledge entry to durable seed file.");

            return DurableSeedAppendResult.Failed(ex.Message);
        }
    }

    private static string BuildSqlBlock(
        KnowledgeEntryFormViewModel form,
        KnowledgeEntryLookupViewModel lookups)
    {
        var title = form.Title.Trim();

        var selectedSeasonNames = GetSelectedNames(lookups.Seasons, form.SelectedSeasonIds);
        var selectedMonthNames = GetSelectedNames(lookups.Months, form.SelectedMonthIds);
        var selectedWaterTemperatureBandNames = GetSelectedNames(lookups.WaterTemperatureBands, form.SelectedWaterTemperatureBandIds);
        var selectedStructureTypeNames = GetSelectedNames(lookups.StructureTypes, form.SelectedStructureTypeIds);
        var selectedTechniqueNames = GetSelectedNames(lookups.Techniques, form.SelectedTechniqueIds);
        var selectedForageSpeciesNames = GetSelectedNames(lookups.ForageSpecies, form.SelectedForageSpeciesIds);
        var selectedTagNames = GetSelectedNames(lookups.Tags, form.SelectedTagIds);

        var builder = new StringBuilder();

        builder.AppendLine();
        builder.AppendLine();
        builder.AppendLine("/* ============================================================");
        builder.AppendLine($"   Knowledge Entry: {title}");
        builder.AppendLine("   Added from Blazor create page");
        builder.AppendLine("   ============================================================ */");
        builder.AppendLine();

        builder.AppendLine("INSERT INTO stripedbassfishingtool.knowledge_entry");
        builder.AppendLine("    (");
        builder.AppendLine("        title,");
        builder.AppendLine("        summary,");
        builder.AppendLine("        body,");
        builder.AppendLine("        source_type,");
        builder.AppendLine("        source_title,");
        builder.AppendLine("        source_author,");
        builder.AppendLine("        source_page_start,");
        builder.AppendLine("        source_page_end,");
        builder.AppendLine("        confidence_level,");
        builder.AppendLine("        is_personal_observation");
        builder.AppendLine("    )");
        builder.AppendLine("SELECT");
        builder.AppendLine($"    {SqlString(title)},");
        builder.AppendLine($"    {SqlNullableString(form.Summary)},");
        builder.AppendLine($"    {SqlString(form.Body.Trim())},");
        builder.AppendLine($"    {SqlNullableString(form.SourceType)},");
        builder.AppendLine($"    {SqlNullableString(form.SourceTitle)},");
        builder.AppendLine($"    {SqlNullableString(form.SourceAuthor)},");
        builder.AppendLine($"    {SqlNullableInt(form.SourcePageStart)},");
        builder.AppendLine($"    {SqlNullableInt(form.SourcePageEnd)},");
        builder.AppendLine($"    {form.ConfidenceLevel},");
        builder.AppendLine($"    {SqlBool(form.IsPersonalObservation)}");
        builder.AppendLine("WHERE NOT EXISTS (");
        builder.AppendLine("    SELECT 1");
        builder.AppendLine("    FROM stripedbassfishingtool.knowledge_entry");
        builder.AppendLine($"    WHERE title = {SqlString(title)}");
        builder.AppendLine(");");

        AppendRelationshipBlock(
            builder,
            title,
            "Seasons",
            "knowledge_entry_season",
            "season_id",
            "season",
            "season_id",
            "name",
            selectedSeasonNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Months",
            "knowledge_entry_month",
            "month_id",
            "month",
            "month_id",
            "name",
            selectedMonthNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Water temperature bands",
            "knowledge_entry_temperature_band",
            "water_temperature_band_id",
            "water_temperature_band",
            "water_temperature_band_id",
            "name",
            selectedWaterTemperatureBandNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Structure types",
            "knowledge_entry_structure_type",
            "structure_type_id",
            "structure_type",
            "structure_type_id",
            "name",
            selectedStructureTypeNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Techniques",
            "knowledge_entry_technique",
            "technique_id",
            "technique",
            "technique_id",
            "name",
            selectedTechniqueNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Forage species",
            "knowledge_entry_forage_species",
            "forage_species_id",
            "forage_species",
            "forage_species_id",
            "common_name",
            selectedForageSpeciesNames);

        AppendRelationshipBlock(
            builder,
            title,
            "Tags",
            "knowledge_entry_tag",
            "tag_id",
            "tag",
            "tag_id",
            "name",
            selectedTagNames);

        return builder.ToString();
    }

    private static IReadOnlyList<string> GetSelectedNames(
        IReadOnlyList<LookupOptionViewModel> options,
        IReadOnlyCollection<int> selectedIds)
    {
        return options
            .Where(option => selectedIds.Contains(option.Id))
            .Select(option => option.Name)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .OrderBy(name => name)
            .ToList();
    }

    private static void AppendRelationshipBlock(
        StringBuilder builder,
        string title,
        string label,
        string bridgeTableName,
        string bridgeReferenceColumnName,
        string referenceTableName,
        string referenceIdColumnName,
        string referenceNameColumnName,
        IReadOnlyList<string> selectedNames)
    {
        if (selectedNames.Count == 0)
        {
            return;
        }

        builder.AppendLine();
        builder.AppendLine($"-- {label}");
        builder.AppendLine($"INSERT INTO stripedbassfishingtool.{bridgeTableName}");
        builder.AppendLine($"    (knowledge_entry_id, {bridgeReferenceColumnName})");
        builder.AppendLine("SELECT");
        builder.AppendLine("    ke.knowledge_entry_id,");
        builder.AppendLine($"    ref.{referenceIdColumnName}");
        builder.AppendLine("FROM stripedbassfishingtool.knowledge_entry ke");
        builder.AppendLine($"JOIN stripedbassfishingtool.{referenceTableName} ref");
        builder.AppendLine($"    ON ref.{referenceNameColumnName} IN ({SqlStringList(selectedNames)})");
        builder.AppendLine($"WHERE ke.title = {SqlString(title)}");
        builder.AppendLine("ON CONFLICT DO NOTHING;");
    }

    private static string SqlNullableString(string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? "NULL"
            : SqlString(value.Trim());
    }

    private static string SqlString(string value)
    {
        return $"'{value.Replace("'", "''")}'";
    }

    private static string SqlStringList(IReadOnlyList<string> values)
    {
        return string.Join(", ", values.Select(SqlString));
    }

    private static string SqlNullableInt(int? value)
    {
        return value?.ToString() ?? "NULL";
    }

    private static string SqlBool(bool value)
    {
        return value ? "true" : "false";
    }
}