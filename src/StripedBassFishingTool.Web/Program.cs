using Microsoft.EntityFrameworkCore;
using StripedBassFishingTool.Web.Components;
using StripedBassFishingTool.Web.Data;
using StripedBassFishingTool.Web.Components;
using StripedBassFishingTool.Web.Services.UserProfile;
using StripedBassFishingTool.Web.Services.Knowledge;
using StripedBassFishingTool.Web.Services.Media;
using StripedBassFishingTool.Web.Options;
using StripedBassFishingTool.Web.Services.Reference;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddDbContextFactory<AppDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

    options.UseNpgsql(connectionString);
});

// register application services

// user options
builder.Services.Configure<DurableSeedOptions>(
    builder.Configuration.GetSection("DurableSeed"));

builder.Services.AddScoped<UserProfileService>();


// Knowledge services
builder.Services.AddScoped<KnowledgeEntryService>();
builder.Services.AddScoped<KnowledgeEntrySeedWriter>();

// Reference data services
builder.Services.AddSingleton<ReferenceTableRegistry>();
builder.Services.AddScoped<ReferenceDataService>();

// Media services
builder.Services.AddScoped<SeededImageService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/not-found", createScopeForStatusCodePages: true);
app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
