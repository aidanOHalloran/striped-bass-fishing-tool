using System.ComponentModel.DataAnnotations;

namespace StripedBassFishingTool.Web.ViewModels.FishingLogs;

public sealed class FishingLocationFormViewModel
{
    [Required]
    public long? BodyOfWaterId { get; set; }

    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Range(-90, 90)]
    public decimal? Latitude { get; set; }

    [Range(-180, 180)]
    public decimal? Longitude { get; set; }

    public string? GeneralArea { get; set; }

    public bool IsSensitiveSpot { get; set; } = true;

    public int? DefaultStructureTypeId { get; set; }

    public string? Notes { get; set; }
}
