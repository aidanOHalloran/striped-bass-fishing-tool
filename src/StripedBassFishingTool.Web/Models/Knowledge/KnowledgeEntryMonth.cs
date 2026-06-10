using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryMonth
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int MonthId { get; set; }

    public Month Month { get; set; } = null!;
}