using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.ViewModels.Knowledge;

namespace StripedBassFishingTool.Web.Services.Knowledge;

public sealed class KnowledgeEntryService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public KnowledgeEntryService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }

    public async Task<IReadOnlyList<KnowledgeEntryCardViewModel>> GetKnowledgeEntryCardsAsync(
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var entries = await db.KnowledgeEntries
            .AsNoTracking()
            .Include(e => e.KnowledgeEntrySeasons)
                .ThenInclude(x => x.Season)
            .Include(e => e.KnowledgeEntryTemperatureBands)
                .ThenInclude(x => x.WaterTemperatureBand)
            .Include(e => e.KnowledgeEntryStructureTypes)
                .ThenInclude(x => x.StructureType)
            .Include(e => e.KnowledgeEntryTechniques)
                .ThenInclude(x => x.Technique)
            .Include(e => e.KnowledgeEntryForageSpecies)
                .ThenInclude(x => x.ForageSpecies)
            .Include(e => e.KnowledgeEntryTags)
                .ThenInclude(x => x.Tag)
            .OrderByDescending(e => e.CreatedAt)
            .ThenBy(e => e.Title)
            .ToListAsync(cancellationToken);

        return entries
            .Select(e => new KnowledgeEntryCardViewModel
            {
                KnowledgeEntryId = e.KnowledgeEntryId,
                Title = e.Title,
                Summary = e.Summary,
                SourceType = e.SourceType,
                SourceTitle = e.SourceTitle,
                SourceAuthor = e.SourceAuthor,
                SourcePageStart = e.SourcePageStart,
                SourcePageEnd = e.SourcePageEnd,
                ConfidenceLevel = e.ConfidenceLevel,
                IsPersonalObservation = e.IsPersonalObservation,
                CreatedAt = e.CreatedAt,

                Seasons = e.KnowledgeEntrySeasons
                    .Select(x => x.Season.Name)
                    .OrderBy(x => x)
                    .ToList(),

                TemperatureBands = e.KnowledgeEntryTemperatureBands
                    .Select(x => x.WaterTemperatureBand.Name)
                    .OrderBy(x => x)
                    .ToList(),

                Structures = e.KnowledgeEntryStructureTypes
                    .Select(x => x.StructureType.Name)
                    .OrderBy(x => x)
                    .ToList(),

                Techniques = e.KnowledgeEntryTechniques
                    .Select(x => x.Technique.Name)
                    .OrderBy(x => x)
                    .ToList(),

                ForageSpecies = e.KnowledgeEntryForageSpecies
                    .Select(x => x.ForageSpecies.CommonName)
                    .OrderBy(x => x)
                    .ToList(),

                Tags = e.KnowledgeEntryTags
                    .Select(x => x.Tag.Name)
                    .OrderBy(x => x)
                    .ToList()
            })
            .ToList();
    }
}