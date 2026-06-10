namespace StripedBassFishingTool.Web.ViewModels.Reference;

public sealed class ReferenceTableViewModel
{
    public string ReferenceType { get; set; } = string.Empty;

    public string TableName { get; set; } = string.Empty;

    public string DisplayName { get; set; } = string.Empty;

    public string PluralDisplayName { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public string PrimaryKeyColumn { get; set; } = string.Empty;

    public string NaturalKeyColumn { get; set; } = string.Empty;

    public IReadOnlyList<ReferenceFieldViewModel> Fields { get; set; } = [];
}