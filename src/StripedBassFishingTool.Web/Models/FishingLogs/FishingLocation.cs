using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class FishingLocation
{
    public long FishingLocationId { get; set; }

    public long BodyOfWaterId { get; set; }

    public BodyOfWater BodyOfWater { get; set; } = null!;

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public decimal? Latitude { get; set; }

    public decimal? Longitude { get; set; }

    public string? GeneralArea { get; set; }

    public bool IsSensitiveSpot { get; set; }

    public int? DefaultStructureTypeId { get; set; }

    public StructureType? DefaultStructureType { get; set; }

    public string? Notes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public ICollection<FishingSession> FishingSessions { get; } = [];
}
