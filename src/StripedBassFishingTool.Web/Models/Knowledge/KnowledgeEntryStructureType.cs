using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryStructureType
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int StructureTypeId { get; set; }

    public StructureType StructureType { get; set; } = null!;
}