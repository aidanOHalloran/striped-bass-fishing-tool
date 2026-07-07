namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingTripDetailViewModel
{
    public long FishingTripId { get; set; }

    public string Title { get; set; } = string.Empty;

    public DateOnly TripDate { get; set; }

    public string BodyOfWaterName { get; set; } = string.Empty;

    public string? State { get; set; }

    public string? TimeRange { get; set; }

    public string? Purpose { get; set; }

    public int? OverallSuccessRating { get; set; }

    public string? Summary { get; set; }

    public string? LessonsLearned { get; set; }

    public IReadOnlyList<FishingSessionSummaryViewModel> Sessions { get; set; } = [];
}

public sealed class FishingSessionSummaryViewModel
{
    public string Title { get; set; } = string.Empty;

    public string? LocationName { get; set; }

    public string? TimeRange { get; set; }

    public string? LightCondition { get; set; }

    public string? WaterClarity { get; set; }

    public string? MoonPhase { get; set; }

    public string? WaterTemperatureBand { get; set; }

    public decimal? WaterTemperatureF { get; set; }

    public string? WeatherPattern { get; set; }

    public string? WindCondition { get; set; }

    public int CatchCount { get; set; }

    public IReadOnlyList<string> Techniques { get; set; } = [];

    public IReadOnlyList<string> Structures { get; set; } = [];

    public IReadOnlyList<string> ForageSpecies { get; set; } = [];

    public string? Notes { get; set; }
}
