using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class TripStructureFished
{
    public long FishingSessionId { get; set; }

    public FishingSession FishingSession { get; set; } = null!;

    public int StructureTypeId { get; set; }

    public StructureType StructureType { get; set; } = null!;

    public int? EffectivenessRating { get; set; }

    public string? Notes { get; set; }
}
