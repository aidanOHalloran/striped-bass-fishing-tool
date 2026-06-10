namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntry
{
    public long KnowledgeEntryId { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Summary { get; set; }

    public string Body { get; set; } = string.Empty;

    public string? SourceType { get; set; }

    public string? SourceTitle { get; set; }

    public string? SourceAuthor { get; set; }

    public int? SourcePageStart { get; set; }

    public int? SourcePageEnd { get; set; }

    public int ConfidenceLevel { get; set; }

    public bool IsPersonalObservation { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset? UpdatedAt { get; set; }

    public ICollection<KnowledgeEntryTag> KnowledgeEntryTags { get; set; } = [];

    public ICollection<KnowledgeEntryMonth> KnowledgeEntryMonths { get; set; } = [];

    public ICollection<KnowledgeEntrySeason> KnowledgeEntrySeasons { get; set; } = [];

    public ICollection<KnowledgeEntryTemperatureBand> KnowledgeEntryTemperatureBands { get; set; } = [];

    public ICollection<KnowledgeEntryStructureType> KnowledgeEntryStructureTypes { get; set; } = [];

    public ICollection<KnowledgeEntryTechnique> KnowledgeEntryTechniques { get; set; } = [];

    public ICollection<KnowledgeEntryForageSpecies> KnowledgeEntryForageSpecies { get; set; } = [];
}