namespace StripedBassFishingTool.Web.Models.UserProfile;

public sealed class UserProfile
{
    public long UserProfileId { get; set; }

    public string Username { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string TimeFormat { get; set; } = "12-hour";

    public DateTimeOffset CreatedAt { get; set; }

    public DateTimeOffset? UpdatedAt { get; set; }
}
