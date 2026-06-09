namespace StripedBassFishingTool.Web.ViewModels.Knowledge;

public sealed class KnowledgeEntryCardViewModel
{
    public long KnowledgeEntryId { get; set; }

    public string Title { get; set; } = string.Empty;

    public string? Summary { get; set; }

    public string? SourceType { get; set; }

    public string? SourceTitle { get; set; }

    public string? SourceAuthor { get; set; }

    public int? SourcePageStart { get; set; }

    public int? SourcePageEnd { get; set; }

    public int ConfidenceLevel { get; set; }

    public bool IsPersonalObservation { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public IReadOnlyList<string> Seasons { get; set; } = [];

    public IReadOnlyList<string> TemperatureBands { get; set; } = [];

    public IReadOnlyList<string> Structures { get; set; } = [];

    public IReadOnlyList<string> Techniques { get; set; } = [];

    public IReadOnlyList<string> ForageSpecies { get; set; } = [];

    public IReadOnlyList<string> Tags { get; set; } = [];

    public string SourceLabel
    {
        get
        {
            if (!string.IsNullOrWhiteSpace(SourceTitle) && !string.IsNullOrWhiteSpace(SourceAuthor))
            {
                return $"{SourceTitle} — {SourceAuthor}";
            }

            if (!string.IsNullOrWhiteSpace(SourceTitle))
            {
                return SourceTitle;
            }

            if (!string.IsNullOrWhiteSpace(SourceType))
            {
                return SourceType;
            }

            return "Unspecified source";
        }
    }

    public string PageLabel
    {
        get
        {
            if (SourcePageStart is null && SourcePageEnd is null)
            {
                return string.Empty;
            }

            if (SourcePageStart is not null && SourcePageEnd is not null && SourcePageStart != SourcePageEnd)
            {
                return $"pp. {SourcePageStart}-{SourcePageEnd}";
            }

            return $"p. {SourcePageStart ?? SourcePageEnd}";
        }
    }

    public string ConfidenceLabel => ConfidenceLevel switch
    {
        1 => "Weak",
        2 => "Possible",
        3 => "Useful",
        4 => "Strong",
        5 => "Verified",
        _ => "Unknown"
    };
}