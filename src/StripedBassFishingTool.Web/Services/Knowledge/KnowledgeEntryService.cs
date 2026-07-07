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

    public async Task<KnowledgeEntryFormViewModel?> GetKnowledgeEntryFormAsync(
        long knowledgeEntryId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var entry = await db.KnowledgeEntries
            .AsNoTracking()
            .Include(e => e.KnowledgeEntrySeasons)
            .Include(e => e.KnowledgeEntryMonths)
            .Include(e => e.KnowledgeEntryTemperatureBands)
            .Include(e => e.KnowledgeEntryStructureTypes)
            .Include(e => e.KnowledgeEntryTechniques)
            .Include(e => e.KnowledgeEntryForageSpecies)
            .Include(e => e.KnowledgeEntryTags)
            .SingleOrDefaultAsync(
                e => e.KnowledgeEntryId == knowledgeEntryId,
                cancellationToken);

        if (entry is null)
        {
            return null;
        }

        return new KnowledgeEntryFormViewModel
        {
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

            SelectedSeasonIds = entry.KnowledgeEntrySeasons
                .Select(x => x.SeasonId)
                .ToList(),

            SelectedMonthIds = entry.KnowledgeEntryMonths
                .Select(x => x.MonthId)
                .ToList(),

            SelectedWaterTemperatureBandIds = entry.KnowledgeEntryTemperatureBands
                .Select(x => x.WaterTemperatureBandId)
                .ToList(),

            SelectedStructureTypeIds = entry.KnowledgeEntryStructureTypes
                .Select(x => x.StructureTypeId)
                .ToList(),

            SelectedTechniqueIds = entry.KnowledgeEntryTechniques
                .Select(x => x.TechniqueId)
                .ToList(),

            SelectedForageSpeciesIds = entry.KnowledgeEntryForageSpecies
                .Select(x => x.ForageSpeciesId)
                .ToList(),

            SelectedTagIds = entry.KnowledgeEntryTags
                .Select(x => x.TagId)
                .ToList()
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

    public async Task<bool> UpdateKnowledgeEntryAsync(
        long knowledgeEntryId,
        KnowledgeEntryFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var entry = await db.KnowledgeEntries
            .Include(e => e.KnowledgeEntrySeasons)
            .Include(e => e.KnowledgeEntryMonths)
            .Include(e => e.KnowledgeEntryTemperatureBands)
            .Include(e => e.KnowledgeEntryStructureTypes)
            .Include(e => e.KnowledgeEntryTechniques)
            .Include(e => e.KnowledgeEntryForageSpecies)
            .Include(e => e.KnowledgeEntryTags)
            .SingleOrDefaultAsync(
                e => e.KnowledgeEntryId == knowledgeEntryId,
                cancellationToken);

        if (entry is null)
        {
            return false;
        }

        entry.Title = form.Title.Trim();
        entry.Summary = NormalizeOptionalText(form.Summary);
        entry.Body = form.Body.Trim();
        entry.SourceType = NormalizeOptionalText(form.SourceType);
        entry.SourceTitle = NormalizeOptionalText(form.SourceTitle);
        entry.SourceAuthor = NormalizeOptionalText(form.SourceAuthor);
        entry.SourcePageStart = form.SourcePageStart;
        entry.SourcePageEnd = form.SourcePageEnd;
        entry.ConfidenceLevel = form.ConfidenceLevel;
        entry.IsPersonalObservation = form.IsPersonalObservation;
        entry.UpdatedAt = DateTimeOffset.UtcNow;

        SyncRelationships(
            entry.KnowledgeEntrySeasons,
            form.SelectedSeasonIds,
            x => x.SeasonId,
            seasonId => new KnowledgeEntrySeason
            {
                KnowledgeEntryId = knowledgeEntryId,
                SeasonId = seasonId
            });

        SyncRelationships(
            entry.KnowledgeEntryMonths,
            form.SelectedMonthIds,
            x => x.MonthId,
            monthId => new KnowledgeEntryMonth
            {
                KnowledgeEntryId = knowledgeEntryId,
                MonthId = monthId
            });

        SyncRelationships(
            entry.KnowledgeEntryTemperatureBands,
            form.SelectedWaterTemperatureBandIds,
            x => x.WaterTemperatureBandId,
            waterTemperatureBandId => new KnowledgeEntryTemperatureBand
            {
                KnowledgeEntryId = knowledgeEntryId,
                WaterTemperatureBandId = waterTemperatureBandId
            });

        SyncRelationships(
            entry.KnowledgeEntryStructureTypes,
            form.SelectedStructureTypeIds,
            x => x.StructureTypeId,
            structureTypeId => new KnowledgeEntryStructureType
            {
                KnowledgeEntryId = knowledgeEntryId,
                StructureTypeId = structureTypeId
            });

        SyncRelationships(
            entry.KnowledgeEntryTechniques,
            form.SelectedTechniqueIds,
            x => x.TechniqueId,
            techniqueId => new KnowledgeEntryTechnique
            {
                KnowledgeEntryId = knowledgeEntryId,
                TechniqueId = techniqueId
            });

        SyncRelationships(
            entry.KnowledgeEntryForageSpecies,
            form.SelectedForageSpeciesIds,
            x => x.ForageSpeciesId,
            forageSpeciesId => new KnowledgeEntryForageSpecies
            {
                KnowledgeEntryId = knowledgeEntryId,
                ForageSpeciesId = forageSpeciesId
            });

        SyncRelationships(
            entry.KnowledgeEntryTags,
            form.SelectedTagIds,
            x => x.TagId,
            tagId => new KnowledgeEntryTag
            {
                KnowledgeEntryId = knowledgeEntryId,
                TagId = tagId
            });

        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    private static string? NormalizeOptionalText(string? value)
    {
        return string.IsNullOrWhiteSpace(value)
            ? null
            : value.Trim();
    }

    private static void SyncRelationships<TJoin>(
        ICollection<TJoin> relationships,
        IEnumerable<int> selectedIds,
        Func<TJoin, int> getId,
        Func<int, TJoin> createRelationship)
    {
        var selectedIdSet = selectedIds
            .Distinct()
            .ToHashSet();

        foreach (var relationship in relationships
            .Where(x => !selectedIdSet.Contains(getId(x)))
            .ToList())
        {
            relationships.Remove(relationship);
        }

        var existingIdSet = relationships
            .Select(getId)
            .ToHashSet();

        foreach (var selectedId in selectedIdSet.Except(existingIdSet))
        {
            relationships.Add(createRelationship(selectedId));
        }
    }

}
