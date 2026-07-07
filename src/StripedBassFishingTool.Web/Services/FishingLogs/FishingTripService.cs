using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.Models.FishingLogs;
using StripedBassFishingTool.Web.ViewModels.FishingLogs;
using StripedBassFishingTool.Web.ViewModels.Knowledge;

namespace StripedBassFishingTool.Web.Services.FishingLogs;

public sealed class FishingTripService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public FishingTripService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }

    public async Task<FishingTripLookupViewModel> GetLookupsAsync(CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return new FishingTripLookupViewModel
        {
            BodiesOfWater = await db.BodiesOfWater
                .AsNoTracking()
                .OrderBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = (int)x.BodyOfWaterId,
                    Name = x.State == null ? x.Name : $"{x.Name}, {x.State}",
                    Description = x.WaterbodyType
                })
                .ToListAsync(cancellationToken),

            Locations = await db.FishingLocations
                .AsNoTracking()
                .OrderBy(x => x.BodyOfWater.Name)
                .ThenBy(x => x.Name)
                .Select(x => new FishingLocationLookupViewModel
                {
                    Id = x.FishingLocationId,
                    BodyOfWaterId = x.BodyOfWaterId,
                    Name = x.Name,
                    GeneralArea = x.GeneralArea,
                    IsSensitiveSpot = x.IsSensitiveSpot
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

            WaterClarities = await db.WaterClarities
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.WaterClarityId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            WeatherPatterns = await db.WeatherPatterns
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.WeatherPatternId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            WindConditions = await db.WindConditions
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.WindConditionId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            LightConditions = await db.LightConditions
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.LightConditionId,
                    Name = x.Name,
                    Description = x.Description
                })
                .ToListAsync(cancellationToken),

            MoonPhases = await db.MoonPhases
                .AsNoTracking()
                .OrderBy(x => x.DisplayOrder)
                .ThenBy(x => x.Name)
                .Select(x => new LookupOptionViewModel
                {
                    Id = x.MoonPhaseId,
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
                .ToListAsync(cancellationToken)
        };
    }

    public async Task<IReadOnlyList<FishingTripCardViewModel>> GetTripCardsAsync(
        FishingTripFilterViewModel filter,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var query = BuildTripQuery(db.FishingTrips.AsNoTracking(), filter);

        var trips = await query
            .Include(x => x.BodyOfWater)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.FishingLocation)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.LightCondition)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.WaterClarity)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.EnvironmentSnapshots)
                    .ThenInclude(x => x.WaterTemperatureBand)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.EnvironmentSnapshots)
                    .ThenInclude(x => x.WeatherPattern)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.CatchRecords)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripTechniquesUsed)
                    .ThenInclude(x => x.Technique)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripStructuresFished)
                    .ThenInclude(x => x.StructureType)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripForageObserved)
                    .ThenInclude(x => x.ForageSpecies)
            .OrderByDescending(x => x.TripDate)
            .ThenByDescending(x => x.StartTime)
            .Take(100)
            .ToListAsync(cancellationToken);

        return trips.Select(ToCard).ToList();
    }

    public async Task<FishingTripDetailViewModel?> GetTripDetailAsync(
        long fishingTripId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var trip = await db.FishingTrips
            .AsNoTracking()
            .Include(x => x.BodyOfWater)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.FishingLocation)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.LightCondition)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.WaterClarity)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.MoonPhase)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.EnvironmentSnapshots)
                    .ThenInclude(x => x.WaterTemperatureBand)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.EnvironmentSnapshots)
                    .ThenInclude(x => x.WeatherPattern)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.EnvironmentSnapshots)
                    .ThenInclude(x => x.WindCondition)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.CatchRecords)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripTechniquesUsed)
                    .ThenInclude(x => x.Technique)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripStructuresFished)
                    .ThenInclude(x => x.StructureType)
            .Include(x => x.FishingSessions)
                .ThenInclude(x => x.TripForageObserved)
                    .ThenInclude(x => x.ForageSpecies)
            .SingleOrDefaultAsync(x => x.FishingTripId == fishingTripId, cancellationToken);

        if (trip is null)
        {
            return null;
        }

        return new FishingTripDetailViewModel
        {
            FishingTripId = trip.FishingTripId,
            Title = GetTripTitle(trip),
            TripDate = trip.TripDate,
            BodyOfWaterName = trip.BodyOfWater.Name,
            State = trip.BodyOfWater.State,
            TimeRange = FormatTimeRange(trip.StartTime, trip.EndTime),
            Purpose = trip.Purpose,
            OverallSuccessRating = trip.OverallSuccessRating,
            Summary = trip.Summary,
            LessonsLearned = trip.LessonsLearned,
            Sessions = trip.FishingSessions
                .OrderBy(x => x.StartTime)
                .ThenBy(x => x.SessionName)
                .Select(ToSessionSummary)
                .ToList()
        };
    }

    public async Task<long?> GetTripBodyOfWaterIdAsync(
        long fishingTripId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        return await db.FishingTrips
            .AsNoTracking()
            .Where(x => x.FishingTripId == fishingTripId)
            .Select(x => (long?)x.BodyOfWaterId)
            .SingleOrDefaultAsync(cancellationToken);
    }

    public async Task<long> CreateTripAsync(
        FishingTripFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        if (form.BodyOfWaterId is null || form.TripDate is null)
        {
            throw new InvalidOperationException("A body of water and trip date are required.");
        }

        var tripDate = DateOnly.FromDateTime(form.TripDate.Value);
        var startTime = CreateDateTimeOffset(tripDate, form.StartTime);
        var endTime = CreateDateTimeOffset(tripDate, form.EndTime);

        var locationId = form.FishingLocationId;

        if (form.CreateNewLocation)
        {
            if (string.IsNullOrWhiteSpace(form.NewLocationName))
            {
                throw new InvalidOperationException("A new location needs a name.");
            }

            var location = new FishingLocation
            {
                BodyOfWaterId = form.BodyOfWaterId.Value,
                Name = form.NewLocationName.Trim(),
                GeneralArea = NormalizeOptionalText(form.NewLocationGeneralArea),
                IsSensitiveSpot = form.NewLocationIsSensitiveSpot,
                DefaultStructureTypeId = form.NewLocationDefaultStructureTypeId,
                CreatedAt = DateTimeOffset.UtcNow
            };

            db.FishingLocations.Add(location);
            await db.SaveChangesAsync(cancellationToken);
            locationId = location.FishingLocationId;
        }

        var trip = new FishingTrip
        {
            BodyOfWaterId = form.BodyOfWaterId.Value,
            TripName = NormalizeOptionalText(form.TripName),
            TripDate = tripDate,
            StartTime = startTime,
            EndTime = endTime,
            Purpose = NormalizeOptionalText(form.Purpose),
            OverallSuccessRating = form.OverallSuccessRating,
            Summary = NormalizeOptionalText(form.Summary),
            LessonsLearned = NormalizeOptionalText(form.LessonsLearned),
            CreatedAt = DateTimeOffset.UtcNow
        };

        var session = new FishingSession
        {
            FishingLocationId = locationId,
            SessionName = NormalizeOptionalText(form.InitialSessionName),
            StartTime = startTime,
            EndTime = endTime,
            LightConditionId = form.LightConditionId,
            WaterClarityId = form.WaterClarityId,
            MoonPhaseId = form.MoonPhaseId,
            Notes = NormalizeOptionalText(form.SessionNotes),
            SuccessRating = form.OverallSuccessRating,
            CreatedAt = DateTimeOffset.UtcNow
        };

        if (HasEnvironmentSnapshot(form))
        {
            session.EnvironmentSnapshots.Add(new EnvironmentSnapshot
            {
                ObservedAt = startTime ?? DateTimeOffset.UtcNow,
                WaterTemperatureF = form.WaterTemperatureF,
                WaterTemperatureBandId = form.WaterTemperatureBandId,
                WeatherPatternId = form.WeatherPatternId,
                WindConditionId = form.WindConditionId,
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        trip.FishingSessions.Add(session);
        db.FishingTrips.Add(trip);

        await db.SaveChangesAsync(cancellationToken);

        return trip.FishingTripId;
    }

    public async Task<FishingTripFormViewModel?> GetTripFormAsync(
        long fishingTripId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var trip = await db.FishingTrips
            .AsNoTracking()
            .SingleOrDefaultAsync(x => x.FishingTripId == fishingTripId, cancellationToken);

        if (trip is null)
        {
            return null;
        }

        return new FishingTripFormViewModel
        {
            BodyOfWaterId = trip.BodyOfWaterId,
            TripName = trip.TripName,
            TripDate = trip.TripDate.ToDateTime(TimeOnly.MinValue),
            StartTime = FormatTimeInput(trip.StartTime),
            EndTime = FormatTimeInput(trip.EndTime),
            Purpose = trip.Purpose,
            OverallSuccessRating = trip.OverallSuccessRating,
            Summary = trip.Summary,
            LessonsLearned = trip.LessonsLearned
        };
    }

    public async Task<bool> UpdateTripAsync(
        long fishingTripId,
        FishingTripFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var trip = await db.FishingTrips
            .SingleOrDefaultAsync(x => x.FishingTripId == fishingTripId, cancellationToken);

        if (trip is null)
        {
            return false;
        }

        if (form.BodyOfWaterId is null || form.TripDate is null)
        {
            throw new InvalidOperationException("A body of water and trip date are required.");
        }

        var tripDate = DateOnly.FromDateTime(form.TripDate.Value);

        trip.BodyOfWaterId = form.BodyOfWaterId.Value;
        trip.TripName = NormalizeOptionalText(form.TripName);
        trip.TripDate = tripDate;
        trip.StartTime = CreateDateTimeOffset(tripDate, form.StartTime);
        trip.EndTime = CreateDateTimeOffset(tripDate, form.EndTime);
        trip.Purpose = NormalizeOptionalText(form.Purpose);
        trip.OverallSuccessRating = form.OverallSuccessRating;
        trip.Summary = NormalizeOptionalText(form.Summary);
        trip.LessonsLearned = NormalizeOptionalText(form.LessonsLearned);

        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> DeleteTripAsync(
        long fishingTripId,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var trip = await db.FishingTrips
            .SingleOrDefaultAsync(x => x.FishingTripId == fishingTripId, cancellationToken);

        if (trip is null)
        {
            return false;
        }

        db.FishingTrips.Remove(trip);
        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    public async Task<bool> AddSessionAsync(
        long fishingTripId,
        FishingSessionFormViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

        var trip = await db.FishingTrips
            .AsNoTracking()
            .SingleOrDefaultAsync(x => x.FishingTripId == fishingTripId, cancellationToken);

        if (trip is null)
        {
            return false;
        }

        var locationId = form.FishingLocationId;

        if (form.CreateNewLocation)
        {
            if (string.IsNullOrWhiteSpace(form.NewLocationName))
            {
                throw new InvalidOperationException("A new location needs a name.");
            }

            var location = new FishingLocation
            {
                BodyOfWaterId = trip.BodyOfWaterId,
                Name = form.NewLocationName.Trim(),
                GeneralArea = NormalizeOptionalText(form.NewLocationGeneralArea),
                IsSensitiveSpot = form.NewLocationIsSensitiveSpot,
                DefaultStructureTypeId = form.NewLocationDefaultStructureTypeId,
                CreatedAt = DateTimeOffset.UtcNow
            };

            db.FishingLocations.Add(location);
            await db.SaveChangesAsync(cancellationToken);
            locationId = location.FishingLocationId;
        }

        var startTime = CreateDateTimeOffset(trip.TripDate, form.StartTime);
        var endTime = CreateDateTimeOffset(trip.TripDate, form.EndTime);

        var session = new FishingSession
        {
            FishingTripId = fishingTripId,
            FishingLocationId = locationId,
            SessionName = NormalizeOptionalText(form.SessionName),
            StartTime = startTime,
            EndTime = endTime,
            LightConditionId = form.LightConditionId,
            WaterClarityId = form.WaterClarityId,
            MoonPhaseId = form.MoonPhaseId,
            Notes = NormalizeOptionalText(form.Notes),
            SuccessRating = form.SuccessRating,
            CreatedAt = DateTimeOffset.UtcNow
        };

        if (HasEnvironmentSnapshot(form))
        {
            session.EnvironmentSnapshots.Add(new EnvironmentSnapshot
            {
                ObservedAt = startTime ?? DateTimeOffset.UtcNow,
                WaterTemperatureF = form.WaterTemperatureF,
                WaterTemperatureBandId = form.WaterTemperatureBandId,
                WeatherPatternId = form.WeatherPatternId,
                WindConditionId = form.WindConditionId,
                WindDirection = NormalizeOptionalText(form.WindDirection),
                WindSpeedMph = form.WindSpeedMph,
                CurrentFlowNotes = NormalizeOptionalText(form.CurrentFlowNotes),
                GenerationStatus = NormalizeOptionalText(form.GenerationStatus),
                ThermoclineDepthFt = form.ThermoclineDepthFt,
                BaitVisible = form.BaitVisible,
                SurfaceActivity = form.SurfaceActivity,
                BirdActivity = form.BirdActivity,
                CreatedAt = DateTimeOffset.UtcNow
            });
        }

        foreach (var techniqueId in form.SelectedTechniqueIds.Distinct())
        {
            session.TripTechniquesUsed.Add(new TripTechniqueUsed
            {
                TechniqueId = techniqueId
            });
        }

        foreach (var structureTypeId in form.SelectedStructureTypeIds.Distinct())
        {
            session.TripStructuresFished.Add(new TripStructureFished
            {
                StructureTypeId = structureTypeId
            });
        }

        foreach (var forageSpeciesId in form.SelectedForageSpeciesIds.Distinct())
        {
            session.TripForageObserved.Add(new TripForageObserved
            {
                ForageSpeciesId = forageSpeciesId
            });
        }

        db.FishingSessions.Add(session);
        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    private static IQueryable<FishingTrip> BuildTripQuery(
        IQueryable<FishingTrip> query,
        FishingTripFilterViewModel filter)
    {
        if (filter.BodyOfWaterId.HasValue)
        {
            query = query.Where(x => x.BodyOfWaterId == filter.BodyOfWaterId);
        }

        if (filter.MonthId.HasValue)
        {
            query = query.Where(x => x.TripDate.Month == filter.MonthId);
        }

        if (filter.DateFrom.HasValue)
        {
            var dateFrom = DateOnly.FromDateTime(filter.DateFrom.Value);
            query = query.Where(x => x.TripDate >= dateFrom);
        }

        if (filter.DateTo.HasValue)
        {
            var dateTo = DateOnly.FromDateTime(filter.DateTo.Value);
            query = query.Where(x => x.TripDate <= dateTo);
        }

        if (filter.MinimumSuccessRating.HasValue)
        {
            query = query.Where(x => x.OverallSuccessRating >= filter.MinimumSuccessRating);
        }

        if (filter.WaterClarityId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s => s.WaterClarityId == filter.WaterClarityId));
        }

        if (filter.LightConditionId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s => s.LightConditionId == filter.LightConditionId));
        }

        if (filter.MoonPhaseId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s => s.MoonPhaseId == filter.MoonPhaseId));
        }

        if (filter.WaterTemperatureBandId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.EnvironmentSnapshots.Any(e => e.WaterTemperatureBandId == filter.WaterTemperatureBandId)));
        }

        if (filter.WeatherPatternId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.EnvironmentSnapshots.Any(e => e.WeatherPatternId == filter.WeatherPatternId)));
        }

        if (filter.WindConditionId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.EnvironmentSnapshots.Any(e => e.WindConditionId == filter.WindConditionId)));
        }

        if (filter.StructureTypeId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.TripStructuresFished.Any(e => e.StructureTypeId == filter.StructureTypeId)));
        }

        if (filter.TechniqueId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.TripTechniquesUsed.Any(e => e.TechniqueId == filter.TechniqueId)
                || s.CatchRecords.Any(c => c.TechniqueId == filter.TechniqueId)));
        }

        if (filter.ForageSpeciesId.HasValue)
        {
            query = query.Where(x => x.FishingSessions.Any(s =>
                s.TripForageObserved.Any(e => e.ForageSpeciesId == filter.ForageSpeciesId)
                || s.CatchRecords.Any(c => c.ForageSpeciesId == filter.ForageSpeciesId)));
        }

        return query;
    }

    private static FishingTripCardViewModel ToCard(FishingTrip trip)
    {
        var sessions = trip.FishingSessions.ToList();
        var catches = sessions.SelectMany(x => x.CatchRecords).ToList();

        return new FishingTripCardViewModel
        {
            FishingTripId = trip.FishingTripId,
            Title = GetTripTitle(trip),
            TripDate = trip.TripDate,
            BodyOfWaterName = trip.BodyOfWater.Name,
            State = trip.BodyOfWater.State,
            TimeRange = FormatTimeRange(trip.StartTime, trip.EndTime),
            Purpose = trip.Purpose,
            Summary = trip.Summary,
            LessonsLearned = trip.LessonsLearned,
            OverallSuccessRating = trip.OverallSuccessRating,
            SessionCount = sessions.Count,
            CatchCount = catches.Count,
            BestLengthInches = catches.Select(x => x.LengthInches).Where(x => x.HasValue).Max(),
            Locations = sessions
                .Select(x => x.FishingLocation?.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()!,
            TemperatureBands = sessions
                .SelectMany(x => x.EnvironmentSnapshots)
                .Select(x => x.WaterTemperatureBand?.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()!,
            WaterClarities = sessions
                .Select(x => x.WaterClarity?.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()!,
            WeatherPatterns = sessions
                .SelectMany(x => x.EnvironmentSnapshots)
                .Select(x => x.WeatherPattern?.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()!,
            LightConditions = sessions
                .Select(x => x.LightCondition?.Name)
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()!,
            Structures = sessions
                .SelectMany(x => x.TripStructuresFished)
                .Select(x => x.StructureType.Name)
                .Distinct()
                .OrderBy(x => x)
                .ToList(),
            Techniques = sessions
                .SelectMany(x => x.TripTechniquesUsed.Select(t => t.Technique.Name)
                    .Concat(x.CatchRecords.Select(c => c.Technique?.Name ?? string.Empty)))
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList(),
            ForageSpecies = sessions
                .SelectMany(x => x.TripForageObserved.Select(f => f.ForageSpecies.CommonName)
                    .Concat(x.CatchRecords.Select(c => c.ForageSpecies?.CommonName ?? string.Empty)))
                .Where(x => !string.IsNullOrWhiteSpace(x))
                .Distinct()
                .OrderBy(x => x)
                .ToList()
        };
    }

    private static FishingSessionSummaryViewModel ToSessionSummary(FishingSession session)
    {
        var environment = session.EnvironmentSnapshots
            .OrderBy(x => x.ObservedAt)
            .FirstOrDefault();

        return new FishingSessionSummaryViewModel
        {
            Title = string.IsNullOrWhiteSpace(session.SessionName) ? "Session" : session.SessionName,
            LocationName = session.FishingLocation?.Name,
            TimeRange = FormatTimeRange(session.StartTime, session.EndTime),
            LightCondition = session.LightCondition?.Name,
            WaterClarity = session.WaterClarity?.Name,
            MoonPhase = session.MoonPhase?.Name,
            WaterTemperatureBand = environment?.WaterTemperatureBand?.Name,
            WaterTemperatureF = environment?.WaterTemperatureF,
            WeatherPattern = environment?.WeatherPattern?.Name,
            WindCondition = environment?.WindCondition?.Name,
            CatchCount = session.CatchRecords.Count,
            Techniques = session.TripTechniquesUsed
                .Select(x => x.Technique.Name)
                .Distinct()
                .OrderBy(x => x)
                .ToList(),
            Structures = session.TripStructuresFished
                .Select(x => x.StructureType.Name)
                .Distinct()
                .OrderBy(x => x)
                .ToList(),
            ForageSpecies = session.TripForageObserved
                .Select(x => x.ForageSpecies.CommonName)
                .Distinct()
                .OrderBy(x => x)
                .ToList(),
            Notes = session.Notes
        };
    }

    private static string GetTripTitle(FishingTrip trip)
        => string.IsNullOrWhiteSpace(trip.TripName)
            ? $"{trip.BodyOfWater.Name} - {trip.TripDate:MMM d, yyyy}"
            : trip.TripName;

    private static string? FormatTimeRange(DateTimeOffset? start, DateTimeOffset? end)
    {
        if (start is null && end is null)
        {
            return null;
        }

        if (start is not null && end is not null)
        {
            return $"{start.Value.LocalDateTime:t} - {end.Value.LocalDateTime:t}";
        }

        return start?.LocalDateTime.ToString("t") ?? end?.LocalDateTime.ToString("t");
    }

    private static bool HasEnvironmentSnapshot(FishingTripFormViewModel form)
        => form.WaterTemperatureF.HasValue
            || form.WaterTemperatureBandId.HasValue
            || form.WeatherPatternId.HasValue
            || form.WindConditionId.HasValue;

    private static bool HasEnvironmentSnapshot(FishingSessionFormViewModel form)
        => form.WaterTemperatureF.HasValue
            || form.WaterTemperatureBandId.HasValue
            || form.WeatherPatternId.HasValue
            || form.WindConditionId.HasValue
            || !string.IsNullOrWhiteSpace(form.WindDirection)
            || form.WindSpeedMph.HasValue
            || !string.IsNullOrWhiteSpace(form.CurrentFlowNotes)
            || !string.IsNullOrWhiteSpace(form.GenerationStatus)
            || form.ThermoclineDepthFt.HasValue
            || form.BaitVisible.HasValue
            || form.SurfaceActivity.HasValue
            || form.BirdActivity.HasValue;

    private static DateTimeOffset? CreateDateTimeOffset(DateOnly tripDate, string? timeValue)
    {
        if (string.IsNullOrWhiteSpace(timeValue) || !TimeOnly.TryParse(timeValue, out var time))
        {
            return null;
        }

        var localDateTime = tripDate.ToDateTime(time);
        var offset = TimeZoneInfo.Local.GetUtcOffset(localDateTime);

        return new DateTimeOffset(localDateTime, offset);
    }

    private static string? FormatTimeInput(DateTimeOffset? value)
        => value?.LocalDateTime.ToString("HH:mm");

    private static string? NormalizeOptionalText(string? value)
        => string.IsNullOrWhiteSpace(value) ? null : value.Trim();
}
