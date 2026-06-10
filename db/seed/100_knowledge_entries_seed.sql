/*
    Durable knowledge seed data.
    This file is for personal fishing knowledge / reading notes that should
    survive database resets during early development.

    Run after:
    - db/init/001_create_schema.sql

    Developer notes:
    - Run this after schema + reference seed data.
    - Keep each entry idempotent using WHERE NOT EXISTS and ON CONFLICT DO NOTHING.
    - Use the title as the temporary stable natural key while the app is young.
    - Later, the Blazor UI will become the primary way to enter these.

    Fisherman notes:
    - Each entry should represent one useful fishing idea.
    - The relationship inserts make the note searchable by season, temp, structure,
      technique, forage, and tag.
*/

-- 1. Insert the knowledge entry
-- 2. Attach seasons
-- 3. Attach months
-- 4. Attach temperature bands
-- 5. Attach structures
-- 6. Attach techniques
-- 7. Attach forage species
-- 8. Attach tags

-- ============================================================
-- Knowledge Entry: Summer Night Dock Light Pattern
-- ============================================================

/* ============================================================
   TEMPLATE ENTRY - Copy this block for new notes
   ============================================================ */

/*
-- ============================================================
-- Knowledge Entry: REPLACE_WITH_TITLE
-- ============================================================

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'REPLACE_WITH_TITLE',
    'One-sentence summary of the idea.',
    'Full note body goes here. Capture the fishing idea in plain language. Include what condition triggers the pattern, where fish are likely positioned, and what presentation may work.',
    'book',
    'REPLACE_WITH_SOURCE_TITLE',
    'REPLACE_WITH_AUTHOR',
    NULL,
    NULL,
    3,
    false
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'REPLACE_WITH_TITLE'
);

-- Seasons
INSERT INTO stripedbassfishingtool.knowledge_entry_season
    (knowledge_entry_id, season_id)
SELECT ke.knowledge_entry_id, s.season_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.season s
    ON s.name IN ('Summer')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Months
INSERT INTO stripedbassfishingtool.knowledge_entry_month
    (knowledge_entry_id, month_id)
SELECT ke.knowledge_entry_id, m.month_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.month m
    ON m.name IN ('June', 'July', 'August')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Water temperature bands
INSERT INTO stripedbassfishingtool.knowledge_entry_temperature_band
    (knowledge_entry_id, water_temperature_band_id)
SELECT ke.knowledge_entry_id, wtb.water_temperature_band_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.water_temperature_band wtb
    ON wtb.name IN ('Warm')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Structure types
INSERT INTO stripedbassfishingtool.knowledge_entry_structure_type
    (knowledge_entry_id, structure_type_id)
SELECT ke.knowledge_entry_id, st.structure_type_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.structure_type st
    ON st.name IN ('Point')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Techniques
INSERT INTO stripedbassfishingtool.knowledge_entry_technique
    (knowledge_entry_id, technique_id)
SELECT ke.knowledge_entry_id, t.technique_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.technique t
    ON t.name IN ('Swimbait')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Forage species
INSERT INTO stripedbassfishingtool.knowledge_entry_forage_species
    (knowledge_entry_id, forage_species_id)
SELECT ke.knowledge_entry_id, fs.forage_species_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.forage_species fs
    ON fs.common_name IN ('Threadfin Shad')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;

-- Tags
INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('low-light', 'bait-ball')
WHERE ke.title = 'REPLACE_WITH_TITLE'
ON CONFLICT DO NOTHING;
*/


/* ============================================================
   Placeholder 1: Summer Low-Light Behavior
   ============================================================ */

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Summer Low-Light Feeding Windows',
    'During warm-water periods, low-light windows may concentrate safer and more active striper feeding opportunities.',
    'In warm water, striped bass may avoid prolonged shallow activity during bright daylight and instead feed during dawn, dusk, night, or cloudy conditions. This note is a placeholder for observations about how summer light level affects feeding location, presentation choice, and catch-and-release caution.',
    'placeholder',
    'Personal Reading Notes',
    NULL,
    NULL,
    NULL,
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Summer Low-Light Feeding Windows'
);

INSERT INTO stripedbassfishingtool.knowledge_entry_season
    (knowledge_entry_id, season_id)
SELECT ke.knowledge_entry_id, s.season_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.season s
    ON s.name IN ('Summer')
WHERE ke.title = 'Summer Low-Light Feeding Windows'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_month
    (knowledge_entry_id, month_id)
SELECT ke.knowledge_entry_id, m.month_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.month m
    ON m.name IN ('June', 'July', 'August')
WHERE ke.title = 'Summer Low-Light Feeding Windows'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_temperature_band
    (knowledge_entry_id, water_temperature_band_id)
SELECT ke.knowledge_entry_id, wtb.water_temperature_band_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.water_temperature_band wtb
    ON wtb.name IN ('Warm', 'Hot / Stress Range')
WHERE ke.title = 'Summer Low-Light Feeding Windows'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('low-light', 'ethics')
WHERE ke.title = 'Summer Low-Light Feeding Windows'
ON CONFLICT DO NOTHING;


/* ============================================================
   Placeholder 2: Dock Light Bait Concentration
   ============================================================ */

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Dock Light Bait Concentration Pattern',
    'Dock lights can concentrate plankton, baitfish, and predators, creating a repeatable night pattern.',
    'Dock lights may attract plankton and small baitfish, especially threadfin shad. Stripers may hold outside the brightest part of the light and feed along the edge or shadow line. This placeholder should be expanded with notes about approach angle, casting distance, fly/lure choice, and whether fish prefer the lit area or the dark edge.',
    'placeholder',
    'Personal Reading Notes',
    NULL,
    NULL,
    NULL,
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Dock Light Bait Concentration Pattern'
);

INSERT INTO stripedbassfishingtool.knowledge_entry_structure_type
    (knowledge_entry_id, structure_type_id)
SELECT ke.knowledge_entry_id, st.structure_type_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.structure_type st
    ON st.name IN ('Dock Light')
WHERE ke.title = 'Dock Light Bait Concentration Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_technique
    (knowledge_entry_id, technique_id)
SELECT ke.knowledge_entry_id, t.technique_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.technique t
    ON t.name IN ('Fly Retrieve', 'Live Bait', 'Swimbait')
WHERE ke.title = 'Dock Light Bait Concentration Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_forage_species
    (knowledge_entry_id, forage_species_id)
SELECT ke.knowledge_entry_id, fs.forage_species_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.forage_species fs
    ON fs.common_name IN ('Threadfin Shad')
WHERE ke.title = 'Dock Light Bait Concentration Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('dock-light', 'low-light')
WHERE ke.title = 'Dock Light Bait Concentration Pattern'
ON CONFLICT DO NOTHING;


/* ============================================================
   Placeholder 3: Wind-Blown Points
   ============================================================ */

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Wind-Blown Point Pattern',
    'Wind can push bait against points and create feeding opportunities for stripers.',
    'Wind blowing into or across a point may concentrate plankton and baitfish, add surface chop, reduce visibility, and make predators more comfortable feeding shallow. This placeholder should be expanded with observations about wind direction, casting angle, lure speed, and whether fish position on the windward side, leeward side, or tip.',
    'placeholder',
    'Personal Reading Notes',
    NULL,
    NULL,
    NULL,
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Wind-Blown Point Pattern'
);

INSERT INTO stripedbassfishingtool.knowledge_entry_structure_type
    (knowledge_entry_id, structure_type_id)
SELECT ke.knowledge_entry_id, st.structure_type_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.structure_type st
    ON st.name IN ('Point')
WHERE ke.title = 'Wind-Blown Point Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_technique
    (knowledge_entry_id, technique_id)
SELECT ke.knowledge_entry_id, t.technique_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.technique t
    ON t.name IN ('Topwater', 'Swimbait', 'Fly Retrieve')
WHERE ke.title = 'Wind-Blown Point Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('current', 'bait-ball')
WHERE ke.title = 'Wind-Blown Point Pattern'
ON CONFLICT DO NOTHING;


/* ============================================================
   Placeholder 4: Thermocline and Summer Depth
   ============================================================ */

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Thermocline and Summer Depth Pattern',
    'In summer, striper depth may be constrained by temperature, oxygen, forage, and the thermocline.',
    'Summer striper location is not just about depth. Fish may be limited by a combination of preferred temperature, available oxygen, forage location, and thermocline position. This placeholder should be expanded with notes about finding the thermocline on electronics, identifying bait depth, and avoiding unethical catch-and-release situations when fish are stressed.',
    'placeholder',
    'Personal Reading Notes',
    NULL,
    NULL,
    NULL,
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Thermocline and Summer Depth Pattern'
);

INSERT INTO stripedbassfishingtool.knowledge_entry_season
    (knowledge_entry_id, season_id)
SELECT ke.knowledge_entry_id, s.season_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.season s
    ON s.name IN ('Summer')
WHERE ke.title = 'Thermocline and Summer Depth Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_temperature_band
    (knowledge_entry_id, water_temperature_band_id)
SELECT ke.knowledge_entry_id, wtb.water_temperature_band_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.water_temperature_band wtb
    ON wtb.name IN ('Warm', 'Hot / Stress Range')
WHERE ke.title = 'Thermocline and Summer Depth Pattern'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('thermocline', 'ethics', 'sonar')
WHERE ke.title = 'Thermocline and Summer Depth Pattern'
ON CONFLICT DO NOTHING;


/* ============================================================
   Placeholder 5: Matching Threadfin Shad
   ============================================================ */

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        source_author,
        source_page_start,
        source_page_end,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Matching Threadfin Shad',
    'When stripers are feeding on threadfin shad, smaller baitfish profiles and careful presentation depth may matter.',
    'Threadfin shad are often smaller and more fragile than gizzard shad. When stripers are keyed on threadfin, the app should track lure/fly size, retrieve speed, light level, and whether the bait is at the surface, under lights, or suspended. This placeholder should be expanded with notes from readings and actual trips.',
    'placeholder',
    'Personal Reading Notes',
    NULL,
    NULL,
    NULL,
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Matching Threadfin Shad'
);

INSERT INTO stripedbassfishingtool.knowledge_entry_forage_species
    (knowledge_entry_id, forage_species_id)
SELECT ke.knowledge_entry_id, fs.forage_species_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.forage_species fs
    ON fs.common_name IN ('Threadfin Shad')
WHERE ke.title = 'Matching Threadfin Shad'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_technique
    (knowledge_entry_id, technique_id)
SELECT ke.knowledge_entry_id, t.technique_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.technique t
    ON t.name IN ('Fly Retrieve', 'Swimbait', 'Live Bait')
WHERE ke.title = 'Matching Threadfin Shad'
ON CONFLICT DO NOTHING;

INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT ke.knowledge_entry_id, tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('bait-ball', 'fly-fishing')
WHERE ke.title = 'Matching Threadfin Shad'
ON CONFLICT DO NOTHING;
