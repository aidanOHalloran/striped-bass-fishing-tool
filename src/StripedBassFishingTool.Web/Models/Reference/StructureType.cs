namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class StructureType
{
    public int StructureTypeId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? WaterbodyContext { get; set; }

    public string? Description { get; set; }

    public string? WhyStripersUseIt { get; set; }

    public string? HowToFishNotes { get; set; }

    public int DisplayOrder { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}