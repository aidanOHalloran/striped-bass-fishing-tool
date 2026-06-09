namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class Technique
{
    public int TechniqueId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Category { get; set; }

    public string? Description { get; set; }

    public string? WhenToUseNotes { get; set; }

    public string? CommonMistakesNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}