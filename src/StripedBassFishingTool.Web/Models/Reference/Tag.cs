namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class Tag
{
    public int TagId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}