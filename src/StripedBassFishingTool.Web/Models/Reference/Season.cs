namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class Season
{
    public int SeasonId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}