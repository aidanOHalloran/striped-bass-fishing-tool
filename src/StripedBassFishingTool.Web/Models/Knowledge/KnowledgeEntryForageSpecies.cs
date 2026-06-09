using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryForageSpecies
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int ForageSpeciesId { get; set; }

    public ForageSpecies ForageSpecies { get; set; } = null!;
}   