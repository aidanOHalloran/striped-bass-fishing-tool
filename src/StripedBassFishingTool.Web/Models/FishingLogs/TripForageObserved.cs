using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class TripForageObserved
{
    public long FishingSessionId { get; set; }

    public FishingSession FishingSession { get; set; } = null!;

    public int ForageSpeciesId { get; set; }

    public ForageSpecies ForageSpecies { get; set; } = null!;

    public string? ObservationMethod { get; set; }

    public string? EstimatedAbundance { get; set; }

    public decimal? DepthObservedFt { get; set; }

    public string? Notes { get; set; }
}
