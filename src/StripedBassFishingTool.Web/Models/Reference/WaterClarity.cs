namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class WaterClarity
{
    public int WaterClarityId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal? VisibilityMinFt { get; set; }

    public decimal? VisibilityMaxFt { get; set; }

    public string? Description { get; set; }

    public string? FishingNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
