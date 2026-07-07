using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.ViewModels.UserProfile;

namespace StripedBassFishingTool.Web.Services.UserProfile;

public sealed class UserProfileService
{
    private readonly IDbContextFactory<AppDbContext> _dbContextFactory;

    public UserProfileService(IDbContextFactory<AppDbContext> dbContextFactory)
    {
        _dbContextFactory = dbContextFactory;
    }

    public async Task<UserProfileEditViewModel> GetOrCreateProfileAsync(
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        await EnsureUserProfileSettingsSchemaAsync(db, cancellationToken);

        var profile = await db.UserProfiles
            .OrderBy(x => x.UserProfileId)
            .FirstOrDefaultAsync(cancellationToken);

        if (profile is null)
        {
            profile = new Models.UserProfile.UserProfile
            {
                Username = "Angler",
                Email = string.Empty,
                TimeFormat = "12-hour",
                DarkModeEnabled = false,
                CreatedAt = DateTimeOffset.UtcNow
            };

            db.UserProfiles.Add(profile);
            await db.SaveChangesAsync(cancellationToken);
        }

        return new UserProfileEditViewModel
        {
            UserProfileId = profile.UserProfileId,
            Username = profile.Username,
            Email = profile.Email,
            TimeFormat = NormalizeTimeFormat(profile.TimeFormat),
            DarkModeEnabled = profile.DarkModeEnabled
        };
    }

    public async Task<string> GetTimeFormatAsync(CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        await EnsureUserProfileSettingsSchemaAsync(db, cancellationToken);

        var timeFormat = await db.UserProfiles
            .AsNoTracking()
            .OrderBy(x => x.UserProfileId)
            .Select(x => x.TimeFormat)
            .FirstOrDefaultAsync(cancellationToken);

        return NormalizeTimeFormat(timeFormat);
    }

    public async Task UpdateProfileAsync(
        UserProfileEditViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);
        await EnsureUserProfileSettingsSchemaAsync(db, cancellationToken);

        var profile = await db.UserProfiles
            .SingleOrDefaultAsync(
                x => x.UserProfileId == form.UserProfileId,
                cancellationToken);

        if (profile is null)
        {
            profile = new Models.UserProfile.UserProfile
            {
                Username = form.Username.Trim(),
                Email = NormalizeEmail(form.Email),
                TimeFormat = NormalizeTimeFormat(form.TimeFormat),
                DarkModeEnabled = form.DarkModeEnabled,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            db.UserProfiles.Add(profile);
        }
        else
        {
            profile.Username = form.Username.Trim();
            profile.Email = NormalizeEmail(form.Email);
            profile.TimeFormat = NormalizeTimeFormat(form.TimeFormat);
            profile.DarkModeEnabled = form.DarkModeEnabled;
            profile.UpdatedAt = DateTimeOffset.UtcNow;
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    private static string NormalizeEmail(string? email)
    {
        return string.IsNullOrWhiteSpace(email)
            ? string.Empty
            : email.Trim();
    }

    private static string NormalizeTimeFormat(string? timeFormat)
    {
        return string.Equals(timeFormat, "24-hour", StringComparison.Ordinal)
            ? "24-hour"
            : "12-hour";
    }

    private static async Task EnsureUserProfileSettingsSchemaAsync(
        AppDbContext db,
        CancellationToken cancellationToken)
    {
        await db.Database.ExecuteSqlRawAsync(
            """
            ALTER TABLE stripedbassfishingtool.user_profile
            ADD COLUMN IF NOT EXISTS time_format TEXT NOT NULL DEFAULT '12-hour';

            ALTER TABLE stripedbassfishingtool.user_profile
            ADD COLUMN IF NOT EXISTS dark_mode_enabled BOOLEAN NOT NULL DEFAULT false;
            """,
            cancellationToken);
    }
}
