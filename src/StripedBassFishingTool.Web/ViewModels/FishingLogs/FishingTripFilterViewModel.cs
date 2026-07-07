namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingTripFilterViewModel
{
    public long? BodyOfWaterId { get; set; }

    public int? MonthId { get; set; }

    public DateTime? DateFrom { get; set; }

    public DateTime? DateTo { get; set; }

    public int? WaterTemperatureBandId { get; set; }

    public int? WaterClarityId { get; set; }

    public int? WeatherPatternId { get; set; }

    public int? WindConditionId { get; set; }

    public int? LightConditionId { get; set; }

    public int? MoonPhaseId { get; set; }

    public int? StructureTypeId { get; set; }

    public int? TechniqueId { get; set; }

    public int? ForageSpeciesId { get; set; }

    public int? MinimumSuccessRating { get; set; }

    public bool HasActiveFilters =>
        BodyOfWaterId.HasValue
        || MonthId.HasValue
        || DateFrom.HasValue
        || DateTo.HasValue
        || WaterTemperatureBandId.HasValue
        || WaterClarityId.HasValue
        || WeatherPatternId.HasValue
        || WindConditionId.HasValue
        || LightConditionId.HasValue
        || MoonPhaseId.HasValue
        || StructureTypeId.HasValue
        || TechniqueId.HasValue
        || ForageSpeciesId.HasValue
        || MinimumSuccessRating.HasValue;
}
