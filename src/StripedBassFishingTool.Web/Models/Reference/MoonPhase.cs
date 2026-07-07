namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class MoonPhase
{
    public int MoonPhaseId { get; set; }

    public string Name { get; set; } = string.Empty;

    public decimal? IlluminationMinPercent { get; set; }

    public decimal? IlluminationMaxPercent { get; set; }

    public string? Description { get; set; }

    public string? FishingNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
