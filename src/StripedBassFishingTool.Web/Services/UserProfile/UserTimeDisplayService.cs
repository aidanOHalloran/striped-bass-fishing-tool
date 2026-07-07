namespace StripedBassFishingTool.Web.Services.UserProfile;

public sealed class UserTimeDisplayService
{
    private readonly UserProfileService _userProfileService;

    public UserTimeDisplayService(UserProfileService userProfileService)
    {
        _userProfileService = userProfileService;
    }

    public async Task<string> GetTimeFormatAsync(CancellationToken cancellationToken = default)
    {
        return await _userProfileService.GetTimeFormatAsync(cancellationToken);
    }

    public async Task<string?> FormatTimeAsync(
        DateTimeOffset? value,
        CancellationToken cancellationToken = default)
    {
        var timeFormat = await GetTimeFormatAsync(cancellationToken);

        return FormatTime(value, timeFormat);
    }

    public static string? FormatTime(DateTimeOffset? value, string timeFormat)
    {
        if (value is null)
        {
            return null;
        }

        return Is24Hour(timeFormat)
            ? value.Value.LocalDateTime.ToString("HH:mm")
            : value.Value.LocalDateTime.ToString("h:mm tt");
    }

    public static string? FormatTimeRange(
        DateTimeOffset? start,
        DateTimeOffset? end,
        string timeFormat)
    {
        if (start is null && end is null)
        {
            return null;
        }

        var startText = FormatTime(start, timeFormat);
        var endText = FormatTime(end, timeFormat);

        if (startText is not null && endText is not null)
        {
            return $"{startText} - {endText}";
        }

        return startText ?? endText;
    }

    public static string FormatDateTime(DateTimeOffset value, string timeFormat)
    {
        return Is24Hour(timeFormat)
            ? value.LocalDateTime.ToString("MMM d, yyyy HH:mm")
            : value.LocalDateTime.ToString("MMM d, yyyy h:mm tt");
    }

    private static bool Is24Hour(string timeFormat)
    {
        return string.Equals(timeFormat, "24-hour", StringComparison.Ordinal);
    }
}
