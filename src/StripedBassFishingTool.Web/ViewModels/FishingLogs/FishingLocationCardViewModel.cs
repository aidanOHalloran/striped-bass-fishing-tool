namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingLocationCardViewModel
{
    public long FishingLocationId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string BodyOfWaterName { get; set; } = string.Empty;

    public string? State { get; set; }

    public string? GeneralArea { get; set; }

    public string? Description { get; set; }

    public string? DefaultStructureTypeName { get; set; }

    public bool IsSensitiveSpot { get; set; }

    public int SessionCount { get; set; }

    public string? Notes { get; set; }
}
