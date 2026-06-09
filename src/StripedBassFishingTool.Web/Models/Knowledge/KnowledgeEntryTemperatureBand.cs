using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.Knowledge;

public sealed class KnowledgeEntryTemperatureBand
{
    public long KnowledgeEntryId { get; set; }

    public KnowledgeEntry KnowledgeEntry { get; set; } = null!;

    public int WaterTemperatureBandId { get; set; }

    public WaterTemperatureBand WaterTemperatureBand { get; set; } = null!;
}