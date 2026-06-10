namespace StripedBassFishingTool.Web.ViewModels.Reference;

public sealed class ReferenceTableSummaryViewModel
{
    public string ReferenceType { get; set; } = string.Empty;

    public string DisplayName { get; set; } = string.Empty;

    public string PluralDisplayName { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public int RecordCount { get; set; }
}