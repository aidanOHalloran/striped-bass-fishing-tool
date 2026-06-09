using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryTag
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int TagId { get; set; }

    public Tag Tag { get; set; } = null!;
}