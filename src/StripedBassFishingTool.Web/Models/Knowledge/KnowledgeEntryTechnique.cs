using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryTechnique
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int TechniqueId { get; set; }

    public Technique Technique { get; set; } = null!;
}