using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class CatchRecord
{
    public long CatchRecordId { get; set; }

    public long FishingSessionId { get; set; }

    public FishingSession FishingSession { get; set; } = null!;

    public DateTimeOffset? CaughtAt { get; set; }

    public string Species { get; set; } = "Striped Bass";

    public decimal? LengthInches { get; set; }

    public decimal? WeightLbs { get; set; }

    public bool EstimatedWeight { get; set; }

    public decimal? DepthCaughtFt { get; set; }

    public decimal? FishDepthObservedFt { get; set; }

    public decimal? BottomDepthFt { get; set; }

    public int? TechniqueId { get; set; }

    public Technique? Technique { get; set; }

    public int? PresentationId { get; set; }

    public Presentation? Presentation { get; set; }

    public int? LureTypeId { get; set; }

    public LureType? LureType { get; set; }

    public int? FlyPatternId { get; set; }

    public FlyPattern? FlyPattern { get; set; }

    public int? ForageSpeciesId { get; set; }

    public ForageSpecies? ForageSpecies { get; set; }

    public bool? WasReleased { get; set; }

    public string? ReleaseCondition { get; set; }

    public string? Notes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
