using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.ViewModels.Media;

namespace StripedBassFishingTool.Web.Services.Media;

public sealed class SeededImageService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public SeededImageService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }

    public async Task<IReadOnlyList<SeededImageCardViewModel>> GetActiveImagesAsync(
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return await db.SeededImages
            .AsNoTracking()
            .Where(x => x.IsActive)
            .OrderBy(x => x.ImageCategory)
            .ThenBy(x => x.Title)
            .Select(x => new SeededImageCardViewModel
            {
                SeededImageId = x.SeededImageId,
                Title = x.Title,
                Description = x.Description,
                ImageCategory = x.ImageCategory,
                ImagePath = x.ImagePath,
                AltText = x.AltText,
                SourceName = x.SourceName,
                AttributionNotes = x.AttributionNotes
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<SeededImageCardViewModel>> GetActiveImagesByCategoryAsync(
        string imageCategory,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return await db.SeededImages
            .AsNoTracking()
            .Where(x => x.IsActive && x.ImageCategory == imageCategory)
            .OrderBy(x => x.Title)
            .Select(x => new SeededImageCardViewModel
            {
                SeededImageId = x.SeededImageId,
                Title = x.Title,
                Description = x.Description,
                ImageCategory = x.ImageCategory,
                ImagePath = x.ImagePath,
                AltText = x.AltText,
                SourceName = x.SourceName,
                AttributionNotes = x.AttributionNotes
            })
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyDictionary<string, IReadOnlyList<SeededImageCardViewModel>>> GetImagesForReferenceRecordsAsync(
    string referenceType,
    IReadOnlyCollection<string> referenceKeys,
    CancellationToken cancellationToken = default)
    {
        if (referenceKeys.Count == 0)
        {
            return new Dictionary<string, IReadOnlyList<SeededImageCardViewModel>>();
        }

        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var normalizedKeys = referenceKeys
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => x.Trim())
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .ToList();

        var images = await db.SeededImages
            .AsNoTracking()
            .Where(x =>
                x.IsActive &&
                x.LinkedReferenceType == referenceType &&
                x.LinkedReferenceKey != null &&
                normalizedKeys.Contains(x.LinkedReferenceKey))
            .OrderBy(x => x.Title)
            .Select(x => new SeededImageCardViewModel
            {
                SeededImageId = x.SeededImageId,
                Title = x.Title,
                Description = x.Description,
                ImageCategory = x.ImageCategory,
                ImagePath = x.ImagePath,
                AltText = x.AltText,
                LinkedReferenceType = x.LinkedReferenceType,
                LinkedReferenceKey = x.LinkedReferenceKey,
                SourceName = x.SourceName,
                AttributionNotes = x.AttributionNotes
            })
            .ToListAsync(cancellationToken);

        return images
            .Where(x => !string.IsNullOrWhiteSpace(x.LinkedReferenceKey))
            .GroupBy(x => x.LinkedReferenceKey!, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(
                group => group.Key,
                group => (IReadOnlyList<SeededImageCardViewModel>)group.ToList(),
                StringComparer.OrdinalIgnoreCase);
    }
}