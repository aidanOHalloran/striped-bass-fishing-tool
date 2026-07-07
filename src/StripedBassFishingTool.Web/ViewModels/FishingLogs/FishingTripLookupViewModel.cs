using StripedBassFishingTool.Web.ViewModels.Knowledge;

namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingTripLookupViewModel
{
    public IReadOnlyList<LookupOptionViewModel> BodiesOfWater { get; set; } = [];

    public IReadOnlyList<FishingLocationLookupViewModel> Locations { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> Months { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> WaterTemperatureBands { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> WaterClarities { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> WeatherPatterns { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> WindConditions { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> LightConditions { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> MoonPhases { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> StructureTypes { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> Techniques { get; set; } = [];

    public IReadOnlyList<LookupOptionViewModel> ForageSpecies { get; set; } = [];
}

public sealed class FishingLocationLookupViewModel
{
    public long Id { get; set; }

    public long BodyOfWaterId { get; set; }

    public string Name { get; set; } = string.Empty;

    public string? GeneralArea { get; set; }

    public bool IsSensitiveSpot { get; set; }

    public string DisplayName => string.IsNullOrWhiteSpace(GeneralArea)
        ? Name
        : $"{Name} - {GeneralArea}";
}
