using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.Models.FishingLogs;
using StripedBassFishingTool.Web.ViewModels.FishingLogs;

namespace StripedBassFishingTool.Web.Services.FishingLogs;

public sealed class FishingLocationService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public FishingLocationService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }

    public async Task<IReadOnlyList<FishingLocationCardViewModel>> GetLocationCardsAsync(
        long? bodyOfWaterId = null,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var query = db.FishingLocations
            .AsNoTracking()
            .Include(x => x.BodyOfWater)
            .Include(x => x.DefaultStructureType)
            .AsQueryable();

        if (bodyOfWaterId.HasValue)
        {
            query = query.Where(x => x.BodyOfWaterId == bodyOfWaterId);
        }

        return await query
            .OrderBy(x => x.BodyOfWater.Name)
            .ThenBy(x => x.GeneralArea)
            .ThenBy(x => x.Name)
            .Select(x => new FishingLocationCardViewModel
            {
                FishingLocationId = x.FishingLocationId,
                Name = x.Name,
                BodyOfWaterName = x.BodyOfWater.Name,
                State = x.BodyOfWater.State,
                GeneralArea = x.GeneralArea,
                Description = x.Description,
                DefaultStructureTypeName = x.DefaultStructureType == null
                    ? null
                    : x.DefaultStructureType.Name,
                IsSensitiveSpot = x.IsSensitiveSpot,
                SessionCount = x.FishingSessions.Count,
                Notes = x.Notes
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<FishingLocationFormViewModel?> GetLocationFormAsync(
        long fishingLocationId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var location = await db.FishingLocations
            .AsNoTracking()
            .SingleOrDefaultAsync(x => x.FishingLocationId == fishingLocationId, cancellationToken);

        if (location is null)
        {
            return null;
        }

        return new FishingLocationFormViewModel
        {
            BodyOfWaterId = location.BodyOfWaterId,
            Name = location.Name,
            Description = location.Description,
            Latitude = location.Latitude,
            Longitude = location.Longitude,
            GeneralArea = location.GeneralArea,
            IsSensitiveSpot = location.IsSensitiveSpot,
            DefaultStructureTypeId = location.DefaultStructureTypeId,
            Notes = location.Notes
        };
    }

    public async Task<int> GetSessionCountAsync(
        long fishingLocationId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return await db.FishingSessions
            .AsNoTracking()
            .CountAsync(x => x.FishingLocationId == fishingLocationId, cancellationToken);
    }

    public async Task<long> CreateLocationAsync(
        FishingLocationFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        if (form.BodyOfWaterId is null)
        {
            throw new InvalidOperationException("A body of water is required.");
        }

        var location = new FishingLocation
        {
            BodyOfWaterId = form.BodyOfWaterId.Value,
            Name = form.Name.Trim(),
            Description = NormalizeOptionalText(form.Description),
            Latitude = form.Latitude,
            Longitude = form.Longitude,
            GeneralArea = NormalizeOptionalText(form.GeneralArea),
            IsSensitiveSpot = form.IsSensitiveSpot,
            DefaultStructureTypeId = form.DefaultStructureTypeId,
            Notes = NormalizeOptionalText(form.Notes),
            CreatedAt = DateTimeOffset.UtcNow
        };

        db.FishingLocations.Add(location);
        await db.SaveChangesAsync(cancellationToken);

        return location.FishingLocationId;
    }

    public async Task<bool> UpdateLocationAsync(
        long fishingLocationId,
        FishingLocationFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var location = await db.FishingLocations
            .SingleOrDefaultAsync(x => x.FishingLocationId == fishingLocationId, cancellationToken);

        if (location is null)
        {
            return false;
        }

        if (form.BodyOfWaterId is null)
        {
            throw new InvalidOperationException("A body of water is required.");
        }

        location.BodyOfWaterId = form.BodyOfWaterId.Value;
        location.Name = form.Name.Trim();
        location.Description = NormalizeOptionalText(form.Description);
        location.Latitude = form.Latitude;
        location.Longitude = form.Longitude;
        location.GeneralArea = NormalizeOptionalText(form.GeneralArea);
        location.IsSensitiveSpot = form.IsSensitiveSpot;
        location.DefaultStructureTypeId = form.DefaultStructureTypeId;
        location.Notes = NormalizeOptionalText(form.Notes);

        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> DeleteLocationAsync(
        long fishingLocationId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var location = await db.FishingLocations
            .SingleOrDefaultAsync(x => x.FishingLocationId == fishingLocationId, cancellationToken);

        if (location is null)
        {
            return false;
        }

        db.FishingLocations.Remove(location);
        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    private static string? NormalizeOptionalText(string? value)
        => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
