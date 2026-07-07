namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class BodyOfWater
{
    public long BodyOfWaterId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string WaterbodyType { get; set; } = string.Empty;

    public string? State { get; set; }

    public string? Region { get; set; }

    public string? NearestCity { get; set; }

    public string? Description { get; set; }

    public bool HasStripedBass { get; set; }

    public bool HasHybridStripedBass { get; set; }

    public string? PrimaryForageNotes { get; set; }

    public string? ThermoclineNotes { get; set; }

    public string? CurrentGenerationNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public ICollection<FishingLocation> FishingLocations { get; } = [];

    public ICollection<FishingTrip> FishingTrips { get; } = [];
}
