using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class FishingSession
{
    public long FishingSessionId { get; set; }

    public long FishingTripId { get; set; }

    public FishingTrip FishingTrip { get; set; } = null!;

    public long? FishingLocationId { get; set; }

    public FishingLocation? FishingLocation { get; set; }

    public string? SessionName { get; set; }

    public DateTimeOffset? StartTime { get; set; }

    public DateTimeOffset? EndTime { get; set; }

    public int? LightConditionId { get; set; }

    public LightCondition? LightCondition { get; set; }

    public int? WaterClarityId { get; set; }

    public WaterClarity? WaterClarity { get; set; }

    public int? MoonPhaseId { get; set; }

    public MoonPhase? MoonPhase { get; set; }

    public string? Notes { get; set; }

    public int? SuccessRating { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public ICollection<EnvironmentSnapshot> EnvironmentSnapshots { get; } = [];

    public ICollection<CatchRecord> CatchRecords { get; } = [];

    public ICollection<TripTechniqueUsed> TripTechniquesUsed { get; } = [];

    public ICollection<TripStructureFished> TripStructuresFished { get; } = [];

    public ICollection<TripForageObserved> TripForageObserved { get; } = [];
}
