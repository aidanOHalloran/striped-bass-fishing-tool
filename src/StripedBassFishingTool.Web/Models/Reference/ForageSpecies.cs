namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class ForageSpecies
{
    public int ForageSpeciesId { get; set; }

    public string CommonName { get; set; } = string.Empty;

    public string? ScientificName { get; set; }

    public string? Description { get; set; }

    public string? PreferredTemperatureNotes { get; set; }

    public string? BehaviorNotes { get; set; }

    public string? BaitHandlingNotes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}