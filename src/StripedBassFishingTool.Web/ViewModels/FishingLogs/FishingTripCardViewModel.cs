namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingTripCardViewModel
{
    public long FishingTripId { get; set; }

    public string Title { get; set; } = string.Empty;

    public DateOnly TripDate { get; set; }

    public string BodyOfWaterName { get; set; } = string.Empty;

    public string? State { get; set; }

    public string? TimeRange { get; set; }

    public string? Purpose { get; set; }

    public string? Summary { get; set; }

    public string? LessonsLearned { get; set; }

    public int? OverallSuccessRating { get; set; }

    public int SessionCount { get; set; }

    public int CatchCount { get; set; }

    public decimal? BestLengthInches { get; set; }

    public IReadOnlyList<string> Locations { get; set; } = [];

    public IReadOnlyList<string> TemperatureBands { get; set; } = [];

    public IReadOnlyList<string> WaterClarities { get; set; } = [];

    public IReadOnlyList<string> WeatherPatterns { get; set; } = [];

    public IReadOnlyList<string> LightConditions { get; set; } = [];

    public IReadOnlyList<string> Structures { get; set; } = [];

    public IReadOnlyList<string> Techniques { get; set; } = [];

    public IReadOnlyList<string> ForageSpecies { get; set; } = [];

    public string SuccessLabel => OverallSuccessRating is null
        ? "Unrated"
        : $"{OverallSuccessRating}/5";
}
