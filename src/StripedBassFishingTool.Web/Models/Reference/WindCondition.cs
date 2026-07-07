namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class WindCondition
{
    public int WindConditionId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal? MinSpeedMph { get; set; }

    public decimal? MaxSpeedMph { get; set; }

    public string? Description { get; set; }

    public string? FishingNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
