namespace StripedBassFishingTool.Web.Models.Reference;

public sealed class Month
{
    public int MonthId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string ShortName { get; set; } = string.Empty;

    public int DisplayOrder { get; set; }
}