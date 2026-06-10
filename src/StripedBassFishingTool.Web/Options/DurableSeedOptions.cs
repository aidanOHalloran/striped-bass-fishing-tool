namespace StripedBassFishingTool.Web.Options;

public sealed class DurableSeedOptions
{
    public bool AppendOnCreate { get; set; }

    public string? KnowledgeEntriesPath { get; set; }

    public string? ReferenceDataPath { get; set; }
}