namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class WaterTemperatureBand
{
    public int WaterTemperatureBandId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal? MinTempF { get; set; }

    public decimal? MaxTempF { get; set; }

    public string? Description { get; set; }

    public string? StriperBehaviorNotes { get; set; }

    public string? EthicalCautionNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}