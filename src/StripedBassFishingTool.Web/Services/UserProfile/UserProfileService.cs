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

        var profile = await db.UserProfiles
            .OrderBy(x => x.UserProfileId)
            .FirstOrDefaultAsync(cancellationToken);

        if (profile is null)
        {
            profile = new Models.UserProfile.UserProfile
            {
                Username = "Angler",
                Email = string.Empty,
                CreatedAt = DateTimeOffset.UtcNow
            };

            db.UserProfiles.Add(profile);
            await db.SaveChangesAsync(cancellationToken);
        }

        return new UserProfileEditViewModel
        {
            UserProfileId = profile.UserProfileId,
            Username = profile.Username,
            Email = profile.Email
        };
    }

    public async Task UpdateProfileAsync(
        UserProfileEditViewModel form,
        CancellationToken cancellationToken = default)
    {
        await using var db = await _dbContextFactory.CreateDbContextAsync(cancellationToken);

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
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow
            };

            db.UserProfiles.Add(profile);
        }
        else
        {
            profile.Username = form.Username.Trim();
            profile.Email = NormalizeEmail(form.Email);
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
}