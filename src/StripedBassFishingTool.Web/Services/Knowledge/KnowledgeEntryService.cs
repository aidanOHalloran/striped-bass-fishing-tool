using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.ViewModels.Knowledge;
using StripedBassFishingTool.Web.Models.Knowledge;

namespace StripedBassFishingTool.Web.Services.Knowledge;

public sealed class KnowledgeEntryService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public KnowledgeEntryService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }


    public async Task<IReadOnlyList<KnowledgeEntryCardViewModel>> GetKnowledgeEntryCardsAsync(CancellationToken cancellationToken = default)
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

    public async Task<KnowledgeEntryDetailViewModel?> GetKnowledgeEntryDetailAsync(long knowledgeEntryId, CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var entry = await db.KnowledgeEntries
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
            .SingleOrDefaultAsync(
                e => e.KnowledgeEntryId == knowledgeEntryId,
                cancellationToken);

        if (entry is null)
        {
            return null;
        }

        return new KnowledgeEntryDetailViewModel
        {
            KnowledgeEntryId = entry.KnowledgeEntryId,
            Title = entry.Title,
            Summary = entry.Summary,
            Body = entry.Body,
            SourceType = entry.SourceType,
            SourceTitle = entry.SourceTitle,
            SourceAuthor = entry.SourceAuthor,
            SourcePageStart = entry.SourcePageStart,
            SourcePageEnd = entry.SourcePageEnd,
            ConfidenceLevel = entry.ConfidenceLevel,
            IsPersonalObservation = entry.IsPersonalObservation,
            CreatedAt = entry.CreatedAt,
            UpdatedAt = entry.UpdatedAt,

            Seasons = entry.KnowledgeEntrySeasons
                .Select(x => x.Season.Name)
                .OrderBy(x => x)
                .ToList(),

            TemperatureBands = entry.KnowledgeEntryTemperatureBands
                .Select(x => x.WaterTemperatureBand.Name)
                .OrderBy(x => x)
                .ToList(),

            Structures = entry.KnowledgeEntryStructureTypes
                .Select(x => x.StructureType.Name)
                .OrderBy(x => x)
                .ToList(),

            Techniques = entry.KnowledgeEntryTechniques
                .Select(x => x.Technique.Name)
                .OrderBy(x => x)
                .ToList(),

            ForageSpecies = entry.KnowledgeEntryForageSpecies
                .Select(x => x.ForageSpecies.CommonName)
                .OrderBy(x => x)
                .ToList(),

            Tags = entry.KnowledgeEntryTags
                .Select(x => x.Tag.Name)
                .OrderBy(x => x)
                .ToList()
        };
    }

    public async Task<KnowledgeEntryLookupViewModel> GetCreateLookupsAsync(
    CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return new KnowledgeEntryLookupViewModel
        {
            Seasons = await db.Seasons
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.SeasonId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            Months = await db.Months
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.MonthId,
                    Name = x.Name,
                    Description = x.ShortName
                })
                .ToListAsync(cancellationToken),

            WaterTemperatureBands = await db.WaterTemperatureBands
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.WaterTemperatureBandId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            StructureTypes = await db.StructureTypes
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.StructureTypeId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            Techniques = await db.Techniques
                .AsNoTracking()
                .OrderBy(x => x.Category)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.TechniqueId,
                    Name = x.Name,
                    Description = x.Category
                })
                .ToListAsync(cancellationToken),

            ForageSpecies = await db.ForageSpecies
                .AsNoTracking()
                .OrderBy(x => x.CommonName)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.ForageSpeciesId,
                    Name = x.CommonName,
                    Description = x.ScientificName
                })
                .ToListAsync(cancellationToken),

            Tags = await db.Tags
                .AsNoTracking()
                .OrderBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.TagId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken)
        };
    }

    public async Task<long> CreateKnowledgeEntryAsync(
    KnowledgeEntryFormViewModel form,
    CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var entry = new KnowledgeEntry
        {
            Title = form.Title.Trim(),
            Summary = NormalizeOptionalText(form.Summary),
            Body = form.Body.Trim(),
            SourceType = NormalizeOptionalText(form.SourceType),
            SourceTitle = NormalizeOptionalText(form.SourceTitle),
            SourceAuthor = NormalizeOptionalText(form.SourceAuthor),
            SourcePageStart = form.SourcePageStart,
            SourcePageEnd = form.SourcePageEnd,
            ConfidenceLevel = form.ConfidenceLevel,
            IsPersonalObservation = form.IsPersonalObservation,
            CreatedAt = DateTimeOffset.UtcNow
        };

        foreach (var seasonId in form.SelectedSeasonIds.Distinct())
        {
            entry.KnowledgeEntrySeasons.Add(new KnowledgeEntrySeason
            {
                SeasonId = seasonId
            });
        }

        foreach (var monthId in form.SelectedMonthIds.Distinct())
        {
            entry.KnowledgeEntryMonths.Add(new KnowledgeEntryMonth
            {
                MonthId = monthId
            });
        }

        foreach (var waterTemperatureBandId in form.SelectedWaterTemperatureBandIds.Distinct())
        {
            entry.KnowledgeEntryTemperatureBands.Add(new KnowledgeEntryTemperatureBand
            {
                WaterTemperatureBandId = waterTemperatureBandId
            });
        }

        foreach (var structureTypeId in form.SelectedStructureTypeIds.Distinct())
        {
            entry.KnowledgeEntryStructureTypes.Add(new KnowledgeEntryStructureType
            {
                StructureTypeId = structureTypeId
            });
        }

        foreach (var techniqueId in form.SelectedTechniqueIds.Distinct())
        {
            entry.KnowledgeEntryTechniques.Add(new KnowledgeEntryTechnique
            {
                TechniqueId = techniqueId
            });
        }

        foreach (var forageSpeciesId in form.SelectedForageSpeciesIds.Distinct())
        {
            entry.KnowledgeEntryForageSpecies.Add(new KnowledgeEntryForageSpecies
            {
                ForageSpeciesId = forageSpeciesId
            });
        }

        foreach (var tagId in form.SelectedTagIds.Distinct())
        {
            entry.KnowledgeEntryTags.Add(new KnowledgeEntryTag
            {
                TagId = tagId
            });
        }

        db.KnowledgeEntries.Add(entry);

        await db.SaveChangesAsync(cancellationToken);

        return entry.KnowledgeEntryId;
    }

    private static string? NormalizeOptionalText(string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim();
    }

}