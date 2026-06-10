namespace StripedBassFishingTool.Web.ViewModels.Reference;

public sealed class ReferenceRecordViewModel
{
    public int Id { get; set; }

    public string PrimaryLabel { get; set; } = string.Empty;

    public string? SecondaryLabel { get; set; }

    public Dictionary<string, string?> Values { get; set; } = [];
}