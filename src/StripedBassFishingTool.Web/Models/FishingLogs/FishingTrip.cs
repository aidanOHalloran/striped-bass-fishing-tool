namespace StripedBassFishingTool.Web.Models.FishingLogs;

public sealed class FishingTrip
{
    public long FishingTripId { get; set; }

    public long BodyOfWaterId { get; set; }

    public BodyOfWater BodyOfWater { get; set; } = null!;

    public string? TripName { get; set; }

    public DateOnly TripDate { get; set; }

    public DateTimeOffset? StartTime { get; set; }

    public DateTimeOffset? EndTime { get; set; }

    public string? Purpose { get; set; }

    public int? OverallSuccessRating { get; set; }

    public string? Summary { get; set; }

    public string? LessonsLearned { get; set; }

    public DateTimeOffset CreatedAt { get; set; }

    public ICollection<FishingSession> FishingSessions { get; } = [];
}
