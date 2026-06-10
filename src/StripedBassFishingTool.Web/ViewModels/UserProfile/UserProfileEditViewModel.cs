using System.ComponentModel.DataAnnotations;

namespace StripedBassFishingTool.Web.ViewModels.UserProfile;

public sealed class UserProfileEditViewModel
{
    public long UserProfileId { get; set; }

    [Required]
    [StringLength(100)]
    public string Username { get; set; } = string.Empty;

    [EmailAddress]
    [StringLength(250)]
    public string Email { get; set; } = string.Empty;
}