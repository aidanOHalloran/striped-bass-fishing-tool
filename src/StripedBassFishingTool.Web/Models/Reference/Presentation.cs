namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class Presentation
{
    public int PresentationId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string? RetrieveSpeed { get; set; }

    public string? DepthZone { get; set; }

    public string? FishingNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
