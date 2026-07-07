namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class WeatherPattern
{
    public int WeatherPatternId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? FishingNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
