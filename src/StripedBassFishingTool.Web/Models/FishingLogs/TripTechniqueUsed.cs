using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class TripTechniqueUsed
{
    public long FishingSessionId { get; set; }

    public FishingSession FishingSession { get; set; } = null!;

    public int TechniqueId { get; set; }

    public Technique Technique { get; set; } = null!;

    public int? PresentationId { get; set; }

    public Presentation? Presentation { get; set; }

    public int? LureTypeId { get; set; }

    public LureType? LureType { get; set; }

    public int? FlyPatternId { get; set; }

    public FlyPattern? FlyPattern { get; set; }

    public int? EffectivenessRating { get; set; }

    public string? Notes { get; set; }
}
