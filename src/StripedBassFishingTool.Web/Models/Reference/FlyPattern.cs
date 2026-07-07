namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class FlyPattern
{
    public int FlyPatternId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? BaitfishImitation { get; set; }

    public string? TypicalSizeRange { get; set; }

    public string? SinkBehavior { get; set; }

    public string? BestConditionsNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
