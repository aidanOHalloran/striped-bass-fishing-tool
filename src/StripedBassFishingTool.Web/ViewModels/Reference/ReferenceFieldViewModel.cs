namespace StripedBassFishingTool.Web.ViewModels.Reference;

public sealed class ReferenceFieldViewModel
{
    public string PropertyName { get; set; } = string.Empty;

    public string ColumnName { get; set; } = string.Empty;

    public string Label { get; set; } = string.Empty;

    public string? HelpText { get; set; }

    public string FieldType { get; set; } = "text";

    public bool IsRequired { get; set; }

    public bool IsTextArea { get; set; }

    public bool IsNumber { get; set; }

    public bool IsBoolean { get; set; }

    public string? Value { get; set; }
}