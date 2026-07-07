using StripedBassFishingTool.Web.Models.Reference;

namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class EnvironmentSnapshot
{
    public long EnvironmentSnapshotId { get; set; }

    public long FishingSessionId { get; set; }

    public FishingSession FishingSession { get; set; } = null!;

    public DateTimeOffset ObservedAt { get; set; }

    public decimal? WaterTemperatureF { get; set; }

    public decimal? AirTemperatureF { get; set; }

    public int? WaterTemperatureBandId { get; set; }

    public WaterTemperatureBand? WaterTemperatureBand { get; set; }

    public int? WeatherPatternId { get; set; }

    public WeatherPattern? WeatherPattern { get; set; }

    public int? WindConditionId { get; set; }

    public WindCondition? WindCondition { get; set; }

    public string? WindDirection { get; set; }

    public decimal? WindSpeedMph { get; set; }

    public decimal? BarometricPressureInhg { get; set; }

    public string? PressureTrend { get; set; }

    public decimal? CloudCoverPercent { get; set; }

    public string? PrecipitationNotes { get; set; }

    public string? CurrentFlowNotes { get; set; }

    public string? GenerationStatus { get; set; }

    public decimal? ThermoclineDepthFt { get; set; }

    public string? DissolvedOxygenNotes { get; set; }

    public bool? BaitVisible { get; set; }

    public bool? SurfaceActivity { get; set; }

    public bool? BirdActivity { get; set; }

    public string? Notes { get; set; }

    public DateTimeOffset CreatedAt { get; set; }
}
