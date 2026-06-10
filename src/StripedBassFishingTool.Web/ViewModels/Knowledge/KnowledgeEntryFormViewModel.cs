using System.ComponentModel.DataAnnotations;

namespace StripedBassFishingTool.Web.ViewModels.Knowledge;

public sealed class KnowledgeEntryFormViewModel
{
    [Required]
    [StringLength(300)]
    public string Title { get; set; } = string.Empty;

    [StringLength(1000)]
    public string? Summary { get; set; }

    [Required]
    public string Body { get; set; } = string.Empty;

    [StringLength(100)]
    public string? SourceType { get; set; }

    [StringLength(300)]
    public string? SourceTitle { get; set; }

    [StringLength(200)]
    public string? SourceAuthor { get; set; }

    public int? SourcePageStart { get; set; }

    public int? SourcePageEnd { get; set; }

    [Range(1, 5)]
    public int ConfidenceLevel { get; set; } = 3;

    public bool IsPersonalObservation { get; set; } = false;

    public List<int> SelectedSeasonIds { get; set; } = [];

    public List<int> SelectedMonthIds { get; set; } = [];

    public List<int> SelectedWaterTemperatureBandIds { get; set; } = [];

    public List<int> SelectedStructureTypeIds { get; set; } = [];

    public List<int> SelectedTechniqueIds { get; set; } = [];

    public List<int> SelectedForageSpeciesIds { get; set; } = [];

    public List<int> SelectedTagIds { get; set; } = [];
}