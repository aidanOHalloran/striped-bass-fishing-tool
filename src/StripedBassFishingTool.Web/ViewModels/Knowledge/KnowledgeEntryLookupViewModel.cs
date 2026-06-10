namespace StripedBassFishingTool.Web.ViewModels.Knowledge;

public sealed class KnowledgeEntryLookupViewModel
{
    public IReadOnlyList<LookupOptionViewModel> Seasons { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> Months { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> WaterTemperatureBands { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> StructureTypes { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> Techniques { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> ForageSpecies { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> Tags { get; set; } = [];
}

public sealed class LookupOptionViewModel
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }
}