namespace StripedBassFishingTool.Web.Models.Media;

public sealed class SeededImage
{
    public long SeededImageId { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Description { get; set; }

    public string ImageCategory { get; set; } = string.Empty;

    public string ImagePath { get; set; } = string.Empty;

    public string AltText { get; set; } = string.Empty;

    public string? LinkedReferenceType { get; set; }

    public string? LinkedReferenceKey { get; set; }

    public string? SourceName { get; set; }

    public string? SourceUrl { get; set; }

    public string? AttributionNotes { get; set; }

    public bool IsActive { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}