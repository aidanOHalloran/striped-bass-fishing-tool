namespace StripedBassFishingTool.Web.Services.Knowledge;

public sealed class DurableSeedAppendResult
{
    public bool WasAppended { get; set; }

    public bool WasSkipped { get; set; }

    public string? FilePath { get; set; }

    public string? ErrorMessage { get; set; }

    public static DurableSeedAppendResult Success(string filePath)
    {
        return new DurableSeedAppendResult
        {
            WasAppended = true,
            FilePath = filePath
        };
    }

    public static DurableSeedAppendResult Skipped()
    {
        return new DurableSeedAppendResult
        {
            WasSkipped = true
        };
    }

    public static DurableSeedAppendResult Failed(string errorMessage)
    {
        return new DurableSeedAppendResult
        {
            ErrorMessage = errorMessage
        };
    }
}