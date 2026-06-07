using Microsoft.EntityFrameworkCore;

namespace StripedBassFishingTool.Web.Data;

public sealed class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("stripedbassfishingtool");

        base.OnModelCreating(modelBuilder);
    }
}