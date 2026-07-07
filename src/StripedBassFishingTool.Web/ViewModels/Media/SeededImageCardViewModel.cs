namespace StripedBassFishingTool.Web.ViewModels.Media;

public sealed class SeededImageCardViewModel
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

    public string? AttributionNotes { get; set; }
}