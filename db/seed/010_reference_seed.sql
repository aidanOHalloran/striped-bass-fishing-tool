/* ============================================================
   SEED DATA
   ============================================================ */

INSERT INTO stripedbassfishingtool.month
    (month_id, name, short_name, display_order)
VALUES
    (1, 'January', 'Jan', 1),
    (2, 'February', 'Feb', 2),
    (3, 'March', 'Mar', 3),
    (4, 'April', 'Apr', 4),
    (5, 'May', 'May', 5),
    (6, 'June', 'Jun', 6),
    (7, 'July', 'Jul', 7),
    (8, 'August', 'Aug', 8),
    (9, 'September', 'Sep', 9),
    (10, 'October', 'Oct', 10),
    (11, 'November', 'Nov', 11),
    (12, 'December', 'Dec', 12)
ON CONFLICT (month_id) DO NOTHING;

INSERT INTO stripedbassfishingtool.season
    (name, description, display_order)
VALUES
    ('Winter', 'Cold-water period. Fish may relate to deep bait, channels, and slower presentations.', 1),
    ('Pre-Spawn', 'Warming transition when fish may move toward river arms, creeks, or staging areas.', 2),
    ('Spawn / Spawning Run', 'Period when striped bass may attempt spawning movements in rivers or current areas.', 3),
    ('Post-Spawn', 'Recovery and transition period after spawning activity. Fish may scatter and feed irregularly.', 4),
    ('Summer', 'Warm-water period. Oxygen, thermocline, low-light feeding windows, and fish stress become important.', 5),
    ('Fall', 'Cooling period. Bait movement and schooling activity often become more important.', 6)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.water_temperature_band
    (name, min_temp_f, max_temp_f, description, striper_behavior_notes, ethical_caution_notes, display_order)
VALUES
    ('Cold', 32, 45, 'Cold winter water.', 'Stripers may be deeper and less aggressive. Slow presentations can matter.', NULL, 1),
    ('Cool', 45.01, 55, 'Cool transitional water.', 'Fish may begin moving and feeding more predictably as conditions stabilize.', NULL, 2),
    ('Prime Spring', 55.01, 68, 'Often a strong feeding and movement range.', 'Can support active feeding, spawning movements, and shallow opportunities.', NULL, 3),
    ('Warming', 68.01, 75, 'Late spring to early summer transition.', 'Fish may still feed actively but may begin shifting toward deeper/cooler water.', NULL, 4),
    ('Warm', 75.01, 82, 'Warm summer range.', 'Low-light periods, current, bait, oxygen, and thermocline become more important.', 'Handle fish carefully. Minimize fight and air exposure.', 5),
    ('Hot / Stress Range', 82.01, 100, 'Very warm water range.', 'Fish may be compressed into oxygen/temperature refuges and may be vulnerable to stress.', 'Consider avoiding catch-and-release striper fishing in hot water, especially deep fish.', 6)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.water_clarity
    (name, visibility_min_ft, visibility_max_ft, description, fishing_notes, display_order)
VALUES
    ('Muddy', 0, 1, 'Very low visibility.', 'Use vibration, contrast, scent/live bait, and slower presentations.', 1),
    ('Stained', 1.01, 3, 'Reduced visibility but fish can still feed visually.', 'Good for moving baits, contrast colors, and shallower ambush activity.', 2),
    ('Clear', 3.01, 8, 'Good visibility.', 'Natural colors, longer casts, lighter leaders, and realistic profiles may help.', 3),
    ('Very Clear', 8.01, NULL, 'High visibility.', 'Fish may be spooky. Low light, depth, long casts, and subtle presentations can matter.', 4)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.weather_pattern
    (name, description, fishing_notes, display_order)
VALUES
    ('Stable', 'Consistent weather over several days.', 'Patterns may hold better during stable conditions.', 1),
    ('Approaching Front', 'Weather changing ahead of a front.', 'Can trigger feeding windows before conditions deteriorate.', 2),
    ('Post-Front', 'High pressure or changing conditions after a front.', 'Can make fish less aggressive or push bait/fish deeper.', 3),
    ('Rain', 'Rain or recent rainfall.', 'Can add inflow, stain, current, oxygen, and cooler surface water.', 4),
    ('Overcast', 'Cloudy skies with reduced light.', 'May extend shallow or surface feeding windows.', 5),
    ('Bright Sun', 'Clear, bright conditions.', 'Fish may move deeper, tighter to structure, or feed during shorter windows.', 6)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.moon_phase
    (name, illumination_min_percent, illumination_max_percent, description, fishing_notes, display_order)
VALUES
    ('New Moon', 0, 10, 'Little moon illumination.', 'Dark nights may increase importance of lights, silhouette, and vibration.', 1),
    ('Waxing Crescent', 10.01, 40, 'Increasing moon illumination.', 'Can influence night visibility and bait movement.', 2),
    ('First Quarter', 40.01, 60, 'Half-moon phase.', 'Useful to track in night fishing logs.', 3),
    ('Waxing Gibbous', 60.01, 90, 'Increasing toward full moon.', 'More natural night light may spread bait/fish out.', 4),
    ('Full Moon', 90.01, 100, 'High illumination.', 'Can change night feeding windows and reduce dependence on artificial lights.', 5),
    ('Waning Gibbous', 60.01, 90, 'Decreasing from full moon.', 'Track alongside observed night activity.', 6),
    ('Last Quarter', 40.01, 60, 'Half-moon phase after full.', 'Useful historical variable.', 7),
    ('Waning Crescent', 10.01, 40, 'Decreasing toward new moon.', 'Can affect night visibility and dock-light concentration.', 8)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.wind_condition
    (name, min_speed_mph, max_speed_mph, description, fishing_notes, display_order)
VALUES
    ('Calm', 0, 2, 'Little to no wind.', 'Can make fish spooky in clear water but helps see surface activity.', 1),
    ('Light Wind', 2.01, 7, 'Manageable wind.', 'Can add ripple and push bait without ruining boat control.', 2),
    ('Moderate Wind', 7.01, 15, 'Noticeable wind.', 'Can activate windblown points and banks but complicates casting/boat position.', 3),
    ('Strong Wind', 15.01, 25, 'Difficult wind.', 'Can concentrate bait but may make small-boat fishing unsafe.', 4),
    ('Unsafe Wind', 25.01, NULL, 'Potentially unsafe wind.', 'Avoid exposed water, especially in small craft.', 5)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.light_condition
    (name, description, fishing_notes, display_order)
VALUES
    ('Dark Night', 'Night with little natural light.', 'Dock lights and bait concentration can become important.', 1),
    ('Dock Light', 'Artificial light concentrating plankton and baitfish.', 'Can attract bait and feeding stripers, especially at night.', 2),
    ('Dawn', 'First light period.', 'Prime low-light feeding window.', 3),
    ('Morning', 'After dawn but before midday.', 'Can remain productive if bait and conditions hold.', 4),
    ('Midday', 'Bright middle of the day.', 'Fish may move deeper or relate tighter to structure.', 5),
    ('Dusk', 'Evening low-light period.', 'Prime feeding window, especially in warm weather.', 6),
    ('Overcast Daylight', 'Daylight with reduced sun penetration.', 'May extend feeding and shallow activity.', 7)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.forage_species
    (common_name, scientific_name, description, preferred_temperature_notes, behavior_notes, bait_handling_notes)
VALUES
    ('Threadfin Shad', 'Dorosoma petenense', 'Small schooling shad commonly eaten by reservoir stripers.', 'Often associated with warmer reservoirs and surface/light activity.', 'Can school near lights, plankton, and wind/current seams.', 'Fragile in livewells; require excellent aeration and gentle handling.'),
    ('Gizzard Shad', 'Dorosoma cepedianum', 'Larger, hardier shad species.', 'Tolerates a wider range than threadfin.', 'Larger individuals may relate deeper or to flats/channels.', 'Generally hardier than threadfin but large sizes may be too big for some fish.'),
    ('Alewife', 'Alosa pseudoharengus', 'Open-water baitfish important in some reservoirs.', 'Often associated with pelagic/open-water patterns.', 'Can suspend over deep water and drive schooling behavior.', NULL),
    ('Blueback Herring', 'Alosa aestivalis', 'Open-water herring species in some southeastern reservoirs.', 'Often linked to offshore and schooling patterns.', 'Can keep stripers roaming and suspended.', 'Not found in all regions; check local forage base.'),
    ('Skipjack Herring', 'Alosa chrysochloris', 'River/current-associated forage species.', 'Important in some river and tailwater systems.', 'Often found around current, dams, and river channels.', 'Not found in all regions; check local forage base.')
ON CONFLICT (common_name) DO NOTHING;

INSERT INTO stripedbassfishingtool.structure_type
    (name, waterbody_context, description, why_stripers_use_it, how_to_fish_notes, display_order)
VALUES
    ('Point', 'both', 'Land or underwater feature extending into the water.', 'Funnels bait and gives stripers an ambush edge.', 'Fish uphill/downhill, across the point, or along wind/current sides.', 1),
    ('Hump', 'reservoir', 'Offshore high spot surrounded by deeper water.', 'Can concentrate bait and provide feeding shelves near deep escape water.', 'Use electronics, countdown methods, vertical presentations, or topwater during schooling.', 2),
    ('Saddle', 'reservoir', 'Low area between two higher pieces of structure.', 'Can act as a travel lane for bait and stripers.', 'Fish during movement windows, wind, and low light.', 3),
    ('Creek Mouth', 'reservoir', 'Where a creek arm enters the main lake or river channel.', 'Bait and fish often transition through these areas seasonally.', 'Check during seasonal migrations, rain inflow, and bait movement.', 4),
    ('Channel Edge / Ledge', 'both', 'Drop or edge along a creek, river, or old channel.', 'Provides depth change and travel routes.', 'Follow bait along the edge and fish suspended depths.', 5),
    ('Dock Light', 'reservoir', 'Artificial light source around docks or marinas.', 'Lights attract plankton, baitfish, and predators.', 'Approach quietly; fish edges of light and shadow.', 6),
    ('Dam / Tailrace', 'both', 'Dam or outflow area with current and oxygen.', 'Current can concentrate bait and feeding fish.', 'Prioritize safety; fish seams, eddies, and generation windows.', 7),
    ('Shoal', 'river', 'Shallow rocky or fast-water area.', 'Creates current breaks and feeding lanes.', 'Fish seams, pockets, and downstream edges.', 8)
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.technique
    (name, category, description, when_to_use_notes, common_mistakes_notes)
VALUES
    ('Topwater', 'artificial', 'Surface lures used to imitate fleeing baitfish.', 'Best during low light, schooling activity, wind chop, and surface feeding.', 'Do not work too fast when fish are short striking.'),
    ('Swimbait', 'artificial', 'Soft or hard baitfish imitation retrieved through the water column.', 'Useful around bait schools, points, humps, and suspended fish.', 'Wrong depth is often worse than wrong color.'),
    ('Spoon', 'artificial', 'Metal lure fished vertically or cast/retrieved.', 'Useful for deep or schooling fish seen on sonar.', 'Avoid dropping below active fish if they are suspended.'),
    ('Live Bait', 'live bait', 'Using live shad, herring, or other baitfish.', 'Strong when fish are selective, suspended, or relating to bait schools.', 'Poor bait health can ruin the presentation.'),
    ('Trolling', 'artificial', 'Pulling lures or rigs behind the boat.', 'Useful for covering water and finding scattered fish.', 'Speed and depth control are critical.'),
    ('Fly Retrieve', 'fly fishing', 'Retrieving baitfish flies with strips, pauses, or countdowns.', 'Useful around feeding fish, lights, shallow points, and bait schools.', 'Not counting down long enough can keep the fly above fish.'),
    ('Countdown Method', 'artificial', 'Counting lure or fly sink time to target specific depth.', 'Useful for suspended fish and repeatable depth control.', 'Changing retrieve before reaching target depth causes inconsistency.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.presentation
    (name, description, retrieve_speed, depth_zone, fishing_notes)
VALUES
    ('Walk-the-dog', 'Side-to-side surface retrieve.', 'medium', 'surface', 'Good for topwater schooling or low-light fish.'),
    ('Slow Steady Retrieve', 'Consistent slow retrieve.', 'slow', 'subsurface', 'Useful in cool water or when fish trail bait.'),
    ('Burn Retrieve', 'Fast retrieve to trigger reaction strikes.', 'fast', 'subsurface', 'Useful when fish are actively chasing.'),
    ('Countdown Retrieve', 'Let lure/fly sink for a counted duration before retrieving.', 'variable', 'suspended', 'Useful for repeatable depth targeting.'),
    ('Vertical Jigging', 'Fishing directly below the boat.', 'variable', 'deep', 'Useful when fish are stacked under bait or visible on sonar.'),
    ('Free-lined Live Bait', 'Live bait without heavy weight.', 'natural', 'variable', 'Good around lights, surface bait, and shallow feeding fish.'),
    ('Downline Live Bait', 'Live bait held at a controlled depth.', 'natural', 'suspended', 'Useful for deeper suspended stripers.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.lure_type
    (name, category, description, best_conditions_notes)
VALUES
    ('Walking Topwater Plug', 'topwater', 'Surface plug worked side-to-side.', 'Low light, schooling fish, wind chop, points, flats.'),
    ('Soft Plastic Fluke', 'soft plastic', 'Baitfish-shaped soft plastic jerkbait.', 'Surface or subsurface baitfish activity.'),
    ('Paddle Tail Swimbait', 'soft plastic', 'Soft swimbait with vibrating tail.', 'Covering water and matching shad profiles.'),
    ('Bucktail Jig', 'jig', 'Hair jig that imitates baitfish.', 'Current, vertical fishing, casting to feeding fish.'),
    ('Flutter Spoon', 'spoon', 'Metal spoon with falling/wobbling action.', 'Deep fish, vertical presentations, schooling fish.'),
    ('Umbrella Rig', 'trolling/casting', 'Multi-bait rig imitating a bait school.', 'Covering water and targeting fish feeding on schools of bait.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.fly_pattern
    (name, description, baitfish_imitation, typical_size_range, sink_behavior, best_conditions_notes)
VALUES
    ('Clouser Minnow', 'Weighted baitfish fly.', 'shad, minnows, small baitfish', '2-6 inches', 'sinks jigging/nose-down', 'Good general-purpose striper fly.'),
    ('Lefty''s Deceiver', 'Classic baitfish profile fly.', 'larger baitfish', '4-8 inches', 'depends on materials/line', 'Good when fish want a longer bait profile.'),
    ('Game Changer', 'Articulated baitfish fly with realistic movement.', 'shad, herring', '3-8 inches', 'usually neutral to slow sink', 'Good for visual feeders and clear water.'),
    ('Surf Candy', 'Slim epoxy/synthetic baitfish fly.', 'small baitfish', '2-5 inches', 'slow to moderate sink', 'Good for small bait and clear water.')
ON CONFLICT (name) DO NOTHING;

INSERT INTO stripedbassfishingtool.tag
    (name, description)
VALUES
    ('thermocline', 'Temperature boundary that can influence summer fish depth and oxygen availability.'),
    ('low-light', 'Dawn, dusk, night, overcast, or dock-light-related behavior.'),
    ('dock-light', 'Artificial light pattern involving bait concentration around lights.'),
    ('schooling', 'Surface or subsurface schooling activity.'),
    ('bait-ball', 'Concentrated forage observed visually or on sonar.'),
    ('current', 'Flow-related positioning or feeding.'),
    ('ethics', 'Handling, release, or warm-water caution notes.'),
    ('sonar', 'Electronics or fish-finder interpretation.'),
    ('fly-fishing', 'Fly-specific notes and tactics.')
ON CONFLICT (name) DO NOTHING;

