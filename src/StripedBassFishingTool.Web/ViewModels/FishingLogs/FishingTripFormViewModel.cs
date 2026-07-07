using System.ComponentModel.DataAnnotations;

namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingTripFormViewModel
{
    [Required]
    public long? BodyOfWaterId { get; set; }

    public long? FishingLocationId { get; set; }

    public bool CreateNewLocation { get; set; }

    public string? NewLocationName { get; set; }

    public string? NewLocationGeneralArea { get; set; }

    public bool NewLocationIsSensitiveSpot { get; set; } = true;

    public int? NewLocationDefaultStructureTypeId { get; set; }

    public string? TripName { get; set; }

    [Required]
    public DateTime? TripDate { get; set; } = DateTime.Today;

    public string? StartTime { get; set; }

    public string? EndTime { get; set; }

    public string? Purpose { get; set; }

    [Range(1, 5)]
    public int? OverallSuccessRating { get; set; }

    public string? Summary { get; set; }

    public string? LessonsLearned { get; set; }

    public string? InitialSessionName { get; set; }

    public int? LightConditionId { get; set; }

    public int? WaterClarityId { get; set; }

    public int? MoonPhaseId { get; set; }

    public int? WaterTemperatureBandId { get; set; }

    public decimal? WaterTemperatureF { get; set; }

    public int? WeatherPatternId { get; set; }

    public int? WindConditionId { get; set; }

    public string? SessionNotes { get; set; }
}
