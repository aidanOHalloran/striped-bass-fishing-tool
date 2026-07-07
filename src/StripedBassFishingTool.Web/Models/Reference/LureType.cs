namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class LureType
{
    public int LureTypeId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Category { get; set; }

    public string? Description { get; set; }

    public string? BestConditionsNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
