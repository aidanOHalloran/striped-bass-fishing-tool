using StripedBassFishingTool.Web.ViewModels.Reference;

namespace StripedBassFishingTool.Web.Services.Reference;

public sealed class ReferenceTableRegistry
{
    private readonly Dictionary<string, ReferenceTableViewModel> _tables;

    public ReferenceTableRegistry()
    {
        _tables = BuildTables()
            .ToDictionary(x => x.ReferenceType, StringComparer.OrdinalIgnoreCase);
    }

    public IReadOnlyList<ReferenceTableViewModel> GetAll()
    {
        return _tables.Values
            .OrderBy(x => x.PluralDisplayName)
            .ToList();
    }

    public ReferenceTableViewModel? GetByReferenceType(string referenceType)
    {
        return _tables.TryGetValue(referenceType, out var table)
            ? table
            : null;
    }

    private static IReadOnlyList<ReferenceTableViewModel> BuildTables()
    {
        return
        [
            new()
            {
                ReferenceType = "season",
                TableName = "season",
                DisplayName = "Season",
                PluralDisplayName = "Seasons",
                Description = "Major seasonal periods used to classify striped bass behavior.",
                PrimaryKeyColumn = "season_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "month",
                TableName = "month",
                DisplayName = "Month",
                PluralDisplayName = "Months",
                Description = "Calendar months used for filtering knowledge, trips, and patterns.",
                PrimaryKeyColumn = "month_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Number("month_id", "month_id", "Month Number", required: true),
                    Text("name", "name", "Name", required: true),
                    Text("short_name", "short_name", "Short Name", required: true),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "water-temperature-band",
                TableName = "water_temperature_band",
                DisplayName = "Water Temperature Band",
                PluralDisplayName = "Water Temperature Bands",
                Description = "Temperature ranges that affect striper location, stress, and presentation choice.",
                PrimaryKeyColumn = "water_temperature_band_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Number("min_temp_f", "min_temp_f", "Minimum Temp °F"),
                    Number("max_temp_f", "max_temp_f", "Maximum Temp °F"),
                    TextArea("description", "description", "Description"),
                    TextArea("striper_behavior_notes", "striper_behavior_notes", "Striper Behavior Notes"),
                    TextArea("ethical_caution_notes", "ethical_caution_notes", "Ethical Caution Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "water-clarity",
                TableName = "water_clarity",
                DisplayName = "Water Clarity",
                PluralDisplayName = "Water Clarity",
                Description = "Visibility and stain conditions used to interpret feeding behavior and lure choice.",
                PrimaryKeyColumn = "water_clarity_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    TextArea("fishing_implication_notes", "fishing_implication_notes", "Fishing Implication Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "weather-pattern",
                TableName = "weather_pattern",
                DisplayName = "Weather Pattern",
                PluralDisplayName = "Weather Patterns",
                Description = "Weather situations that influence bait movement, light, wind, and feeding windows.",
                PrimaryKeyColumn = "weather_pattern_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    TextArea("fishing_implication_notes", "fishing_implication_notes", "Fishing Implication Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "moon-phase",
                TableName = "moon_phase",
                DisplayName = "Moon Phase",
                PluralDisplayName = "Moon Phases",
                Description = "Moon phase categories for night fishing and low-light observations.",
                PrimaryKeyColumn = "moon_phase_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    TextArea("night_fishing_notes", "night_fishing_notes", "Night Fishing Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "wind-condition",
                TableName = "wind_condition",
                DisplayName = "Wind Condition",
                PluralDisplayName = "Wind Conditions",
                Description = "Wind conditions that affect bait positioning, casting, chop, and current-like movement.",
                PrimaryKeyColumn = "wind_condition_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    TextArea("fishing_implication_notes", "fishing_implication_notes", "Fishing Implication Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "light-condition",
                TableName = "light_condition",
                DisplayName = "Light Condition",
                PluralDisplayName = "Light Conditions",
                Description = "Light levels such as dawn, dusk, night, dock light, cloudy, or bright sun.",
                PrimaryKeyColumn = "light_condition_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description"),
                    TextArea("fishing_implication_notes", "fishing_implication_notes", "Fishing Implication Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "forage-species",
                TableName = "forage_species",
                DisplayName = "Forage Species",
                PluralDisplayName = "Forage Species",
                Description = "Baitfish and forage species that striped bass relate to.",
                PrimaryKeyColumn = "forage_species_id",
                NaturalKeyColumn = "common_name",
                Fields =
                [
                    Text("common_name", "common_name", "Common Name", required: true),
                    Text("scientific_name", "scientific_name", "Scientific Name"),
                    TextArea("description", "description", "Description"),
                    TextArea("preferred_temperature_notes", "preferred_temperature_notes", "Preferred Temperature Notes"),
                    TextArea("behavior_notes", "behavior_notes", "Behavior Notes"),
                    TextArea("bait_handling_notes", "bait_handling_notes", "Bait Handling Notes")
                ]
            },

            new()
            {
                ReferenceType = "structure-type",
                TableName = "structure_type",
                DisplayName = "Structure Type",
                PluralDisplayName = "Structure Types",
                Description = "Physical lake, river, and reservoir features used by stripers.",
                PrimaryKeyColumn = "structure_type_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Text("waterbody_context", "waterbody_context", "Waterbody Context"),
                    TextArea("description", "description", "Description"),
                    TextArea("why_stripers_use_it", "why_stripers_use_it", "Why Stripers Use It"),
                    TextArea("how_to_fish_notes", "how_to_fish_notes", "How To Fish Notes"),
                    Number("display_order", "display_order", "Display Order")
                ]
            },

            new()
            {
                ReferenceType = "technique",
                TableName = "technique",
                DisplayName = "Technique",
                PluralDisplayName = "Techniques",
                Description = "Fishing methods such as trolling, topwater, fly retrieve, live bait, or vertical jigging.",
                PrimaryKeyColumn = "technique_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Text("category", "category", "Category"),
                    TextArea("description", "description", "Description"),
                    TextArea("when_to_use_notes", "when_to_use_notes", "When To Use Notes"),
                    TextArea("common_mistakes_notes", "common_mistakes_notes", "Common Mistakes Notes")
                ]
            },

            new()
            {
                ReferenceType = "presentation",
                TableName = "presentation",
                DisplayName = "Presentation",
                PluralDisplayName = "Presentations",
                Description = "How a lure, fly, or bait is presented to the fish.",
                PrimaryKeyColumn = "presentation_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Text("category", "category", "Category"),
                    TextArea("description", "description", "Description"),
                    TextArea("when_to_use_notes", "when_to_use_notes", "When To Use Notes")
                ]
            },

            new()
            {
                ReferenceType = "lure-type",
                TableName = "lure_type",
                DisplayName = "Lure Type",
                PluralDisplayName = "Lure Types",
                Description = "Artificial lure categories used to imitate bait and trigger strikes.",
                PrimaryKeyColumn = "lure_type_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Text("category", "category", "Category"),
                    TextArea("description", "description", "Description"),
                    TextArea("best_conditions_notes", "best_conditions_notes", "Best Conditions Notes")
                ]
            },

            new()
            {
                ReferenceType = "fly-pattern",
                TableName = "fly_pattern",
                DisplayName = "Fly Pattern",
                PluralDisplayName = "Fly Patterns",
                Description = "Fly patterns used to imitate threadfin, gizzard shad, and other forage.",
                PrimaryKeyColumn = "fly_pattern_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    Text("pattern_type", "pattern_type", "Pattern Type"),
                    TextArea("description", "description", "Description"),
                    TextArea("imitates_notes", "imitates_notes", "Imitates Notes"),
                    TextArea("when_to_use_notes", "when_to_use_notes", "When To Use Notes")
                ]
            },

            new()
            {
                ReferenceType = "tag",
                TableName = "tag",
                DisplayName = "Tag",
                PluralDisplayName = "Tags",
                Description = "Flexible labels used to classify knowledge entries and patterns.",
                PrimaryKeyColumn = "tag_id",
                NaturalKeyColumn = "name",
                Fields =
                [
                    Text("name", "name", "Name", required: true),
                    TextArea("description", "description", "Description")
                ]
            }
        ];
    }

    private static ReferenceFieldViewModel Text(
        string propertyName,
        string columnName,
        string label,
        bool required = false)
    {
        return new ReferenceFieldViewModel
        {
            PropertyName = propertyName,
            ColumnName = columnName,
            Label = label,
            FieldType = "text",
            IsRequired = required
        };
    }

    private static ReferenceFieldViewModel TextArea(
        string propertyName,
        string columnName,
        string label,
        bool required = false)
    {
        return new ReferenceFieldViewModel
        {
            PropertyName = propertyName,
            ColumnName = columnName,
            Label = label,
            FieldType = "textarea",
            IsTextArea = true,
            IsRequired = required
        };
    }

    private static ReferenceFieldViewModel Number(
        string propertyName,
        string columnName,
        string label,
        bool required = false)
    {
        return new ReferenceFieldViewModel
        {
            PropertyName = propertyName,
            ColumnName = columnName,
            Label = label,
            FieldType = "number",
            IsNumber = true,
            IsRequired = required
        };
    }
}