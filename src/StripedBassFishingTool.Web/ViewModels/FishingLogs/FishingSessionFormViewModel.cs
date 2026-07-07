using System.ComponentModel.DataAnnotations;

namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingSessionFormViewModel
{
    public long? FishingLocationId { get; set; }

    public bool CreateNewLocation { get; set; }

    public string? NewLocationName { get; set; }

    public string? NewLocationGeneralArea { get; set; }

    public bool NewLocationIsSensitiveSpot { get; set; } = true;

    public int? NewLocationDefaultStructureTypeId { get; set; }

    public string? SessionName { get; set; }

    public string? StartTime { get; set; }

    public string? EndTime { get; set; }

    public int? LightConditionId { get; set; }

    public int? WaterClarityId { get; set; }

    public int? MoonPhaseId { get; set; }

    public int? WaterTemperatureBandId { get; set; }

    public decimal? WaterTemperatureF { get; set; }

    public int? WeatherPatternId { get; set; }

    public int? WindConditionId { get; set; }

    public string? WindDirection { get; set; }

    public decimal? WindSpeedMph { get; set; }

    public string? CurrentFlowNotes { get; set; }

    public string? GenerationStatus { get; set; }

    public decimal? ThermoclineDepthFt { get; set; }

    public bool? BaitVisible { get; set; }

    public bool? SurfaceActivity { get; set; }

    public bool? BirdActivity { get; set; }

    [Range(1, 5)]
    public int? SuccessRating { get; set; }

    public string? Notes { get; set; }

    public List<int> SelectedTechniqueIds { get; set; } = [];

    public List<int> SelectedStructureTypeIds { get; set; } = [];

    public List<int> SelectedForageSpeciesIds { get; set; } = [];
}
