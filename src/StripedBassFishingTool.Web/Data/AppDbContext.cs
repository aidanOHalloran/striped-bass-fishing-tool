using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Models.Knowledge;
using StripedBassFishingTool.Web.Models.Media;
using StripedBassFishingTool.Web.Models.Reference;
using StripedBassFishingTool.Web.Models.UserProfile;

namespace StripedBassFishingTool.Web.Data;

public sealed class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<UserProfile> UserProfiles => Set<UserProfile>();
    public DbSet<KnowledgeEntry> KnowledgeEntries => Set<KnowledgeEntry>();

    public DbSet<Tag> Tags => Set<Tag>();

    public DbSet<Month> Months => Set<Month>();

    public DbSet<Season> Seasons => Set<Season>();

    public DbSet<WaterTemperatureBand> WaterTemperatureBands => Set<WaterTemperatureBand>();

    public DbSet<StructureType> StructureTypes => Set<StructureType>();

    public DbSet<Technique> Techniques => Set<Technique>();

    public DbSet<ForageSpecies> ForageSpecies => Set<ForageSpecies>();

    public DbSet<SeededImage> SeededImages => Set<SeededImage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("stripedbassfishingtool");

        ConfigureUserProfile(modelBuilder);
        ConfigureKnowledgeEntry(modelBuilder);
        ConfigureReferenceTables(modelBuilder);
        ConfigureKnowledgeRelationships(modelBuilder);
        ConfigureMedia(modelBuilder);

        base.OnModelCreating(modelBuilder);
    }

    private void ConfigureUserProfile(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserProfile>(entity =>
        {
            entity.ToTable("user_profile");

            entity.HasKey(e => e.UserProfileId);

            entity.Property(e => e.UserProfileId)
                .HasColumnName("user_profile_id");

            entity.Property(e => e.Username)
                .HasColumnName("username");

            entity.Property(e => e.Email)
                .HasColumnName("email");

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at");

            entity.Property(e => e.UpdatedAt)
                .HasColumnName("updated_at");
        });
    }

    private static void ConfigureKnowledgeEntry(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<KnowledgeEntry>(entity =>
        {
            entity.ToTable("knowledge_entry");

            entity.HasKey(e => e.KnowledgeEntryId);

            entity.Property(e => e.KnowledgeEntryId)
                .HasColumnName("knowledge_entry_id");

            entity.Property(e => e.Title)
                .HasColumnName("title");

            entity.Property(e => e.Summary)
                .HasColumnName("summary");

            entity.Property(e => e.Body)
                .HasColumnName("body");

            entity.Property(e => e.SourceType)
                .HasColumnName("source_type");

            entity.Property(e => e.SourceTitle)
                .HasColumnName("source_title");

            entity.Property(e => e.SourceAuthor)
                .HasColumnName("source_author");

            entity.Property(e => e.SourcePageStart)
                .HasColumnName("source_page_start");

            entity.Property(e => e.SourcePageEnd)
                .HasColumnName("source_page_end");

            entity.Property(e => e.ConfidenceLevel)
                .HasColumnName("confidence_level");

            entity.Property(e => e.IsPersonalObservation)
                .HasColumnName("is_personal_observation");

            entity.Property(e => e.CreatedAt)
                .HasColumnName("created_at");

            entity.Property(e => e.UpdatedAt)
                .HasColumnName("updated_at");
        });
    }

    private static void ConfigureMedia(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SeededImage>(entity =>
        {
            entity.ToTable("seeded_image");

            entity.HasKey(e => e.SeededImageId);

            entity.Property(e => e.SeededImageId).HasColumnName("seeded_image_id");
            entity.Property(e => e.Title).HasColumnName("title");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.ImageCategory).HasColumnName("image_category");
            entity.Property(e => e.ImagePath).HasColumnName("image_path");
            entity.Property(e => e.AltText).HasColumnName("alt_text");
            entity.Property(e => e.LinkedReferenceType).HasColumnName("linked_reference_type");
            entity.Property(e => e.LinkedReferenceKey).HasColumnName("linked_reference_key");
            entity.Property(e => e.SourceName).HasColumnName("source_name");
            entity.Property(e => e.SourceUrl).HasColumnName("source_url");
            entity.Property(e => e.AttributionNotes).HasColumnName("attribution_notes");
            entity.Property(e => e.IsActive).HasColumnName("is_active");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });
    }

    private static void ConfigureReferenceTables(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Tag>(entity =>
        {
            entity.ToTable("tag");

            entity.HasKey(e => e.TagId);

            entity.Property(e => e.TagId).HasColumnName("tag_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<Month>(entity =>
        {
            entity.ToTable("month");

            entity.HasKey(e => e.MonthId);

            entity.Property(e => e.MonthId).HasColumnName("month_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.ShortName).HasColumnName("short_name");
            entity.Property(e => e.DisplayOrder).HasColumnName("display_order");
        });

        modelBuilder.Entity<Season>(entity =>
        {
            entity.ToTable("season");

            entity.HasKey(e => e.SeasonId);

            entity.Property(e => e.SeasonId).HasColumnName("season_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.DisplayOrder).HasColumnName("display_order");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<WaterTemperatureBand>(entity =>
        {
            entity.ToTable("water_temperature_band");

            entity.HasKey(e => e.WaterTemperatureBandId);

            entity.Property(e => e.WaterTemperatureBandId).HasColumnName("water_temperature_band_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.MinTempF).HasColumnName("min_temp_f");
            entity.Property(e => e.MaxTempF).HasColumnName("max_temp_f");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.StriperBehaviorNotes).HasColumnName("striper_behavior_notes");
            entity.Property(e => e.EthicalCautionNotes).HasColumnName("ethical_caution_notes");
            entity.Property(e => e.DisplayOrder).HasColumnName("display_order");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<StructureType>(entity =>
        {
            entity.ToTable("structure_type");

            entity.HasKey(e => e.StructureTypeId);

            entity.Property(e => e.StructureTypeId).HasColumnName("structure_type_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.WaterbodyContext).HasColumnName("waterbody_context");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.WhyStripersUseIt).HasColumnName("why_stripers_use_it");
            entity.Property(e => e.HowToFishNotes).HasColumnName("how_to_fish_notes");
            entity.Property(e => e.DisplayOrder).HasColumnName("display_order");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<Technique>(entity =>
        {
            entity.ToTable("technique");

            entity.HasKey(e => e.TechniqueId);

            entity.Property(e => e.TechniqueId).HasColumnName("technique_id");
            entity.Property(e => e.Name).HasColumnName("name");
            entity.Property(e => e.Category).HasColumnName("category");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.WhenToUseNotes).HasColumnName("when_to_use_notes");
            entity.Property(e => e.CommonMistakesNotes).HasColumnName("common_mistakes_notes");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        modelBuilder.Entity<ForageSpecies>(entity =>
        {
            entity.ToTable("forage_species");

            entity.HasKey(e => e.ForageSpeciesId);

            entity.Property(e => e.ForageSpeciesId).HasColumnName("forage_species_id");
            entity.Property(e => e.CommonName).HasColumnName("common_name");
            entity.Property(e => e.ScientificName).HasColumnName("scientific_name");
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.PreferredTemperatureNotes).HasColumnName("preferred_temperature_notes");
            entity.Property(e => e.BehaviorNotes).HasColumnName("behavior_notes");
            entity.Property(e => e.BaitHandlingNotes).HasColumnName("bait_handling_notes");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });
    }

    private static void ConfigureKnowledgeRelationships(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<KnowledgeEntryTag>(entity =>
        {
            entity.ToTable("knowledge_entry_tag");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.TagId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.TagId).HasColumnName("tag_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryTags)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.Tag)
                .WithMany()
                .HasForeignKey(e => e.TagId);
        });

        modelBuilder.Entity<KnowledgeEntryMonth>(entity =>
        {
            entity.ToTable("knowledge_entry_month");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.MonthId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.MonthId).HasColumnName("month_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryMonths)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.Month)
                .WithMany()
                .HasForeignKey(e => e.MonthId);
        });

        modelBuilder.Entity<KnowledgeEntrySeason>(entity =>
        {
            entity.ToTable("knowledge_entry_season");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.SeasonId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.SeasonId).HasColumnName("season_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntrySeasons)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.Season)
                .WithMany()
                .HasForeignKey(e => e.SeasonId);
        });

        modelBuilder.Entity<KnowledgeEntryTemperatureBand>(entity =>
        {
            entity.ToTable("knowledge_entry_temperature_band");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.WaterTemperatureBandId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.WaterTemperatureBandId).HasColumnName("water_temperature_band_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryTemperatureBands)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.WaterTemperatureBand)
                .WithMany()
                .HasForeignKey(e => e.WaterTemperatureBandId);
        });

        modelBuilder.Entity<KnowledgeEntryStructureType>(entity =>
        {
            entity.ToTable("knowledge_entry_structure_type");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.StructureTypeId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.StructureTypeId).HasColumnName("structure_type_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryStructureTypes)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.StructureType)
                .WithMany()
                .HasForeignKey(e => e.StructureTypeId);
        });

        modelBuilder.Entity<KnowledgeEntryTechnique>(entity =>
        {
            entity.ToTable("knowledge_entry_technique");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.TechniqueId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.TechniqueId).HasColumnName("technique_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryTechniques)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.Technique)
                .WithMany()
                .HasForeignKey(e => e.TechniqueId);
        });

        modelBuilder.Entity<KnowledgeEntryForageSpecies>(entity =>
        {
            entity.ToTable("knowledge_entry_forage_species");

            entity.HasKey(e => new { e.KnowledgeEntryId, e.ForageSpeciesId });

            entity.Property(e => e.KnowledgeEntryId).HasColumnName("knowledge_entry_id");
            entity.Property(e => e.ForageSpeciesId).HasColumnName("forage_species_id");

            entity.HasOne(e => e.KnowledgeEntry)
                .WithMany(e => e.KnowledgeEntryForageSpecies)
                .HasForeignKey(e => e.KnowledgeEntryId);

            entity.HasOne(e => e.ForageSpecies)
                .WithMany()
                .HasForeignKey(e => e.ForageSpeciesId);
        });
    }
}