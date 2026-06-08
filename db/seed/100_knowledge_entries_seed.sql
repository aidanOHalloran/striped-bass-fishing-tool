/*
    Durable knowledge seed data.
    This file is for personal fishing knowledge / reading notes that should
    survive database resets during early development.

    Run after:
    - db/init/001_create_schema.sql
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

INSERT INTO stripedbassfishingtool.knowledge_entry
    (
        title,
        summary,
        body,
        source_type,
        source_title,
        confidence_level,
        is_personal_observation
    )
SELECT
    'Summer Night Dock Light Pattern',
    'Warm-water night pattern where dock lights concentrate bait and feeding stripers.',
    'Warm water pushes ethical striper fishing toward low-light or night windows. Dock lights can concentrate plankton, threadfin shad, and feeding predators. Fish the edge of the light and shadow, and minimize fish handling during warm-water periods.',
    'personal observation',
    'Tim''s Ford notes',
    3,
    true
WHERE NOT EXISTS (
    SELECT 1
    FROM stripedbassfishingtool.knowledge_entry
    WHERE title = 'Summer Night Dock Light Pattern'
);

-- Attach season metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_season
    (knowledge_entry_id, season_id)
SELECT
    ke.knowledge_entry_id,
    s.season_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.season s
    ON s.name = 'Summer'
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;


-- Attach temperature band metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_temperature_band
    (knowledge_entry_id, water_temperature_band_id)
SELECT
    ke.knowledge_entry_id,
    wtb.water_temperature_band_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.water_temperature_band wtb
    ON wtb.name IN ('Warm', 'Hot / Stress Range')
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;


-- Attach structure metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_structure_type
    (knowledge_entry_id, structure_type_id)
SELECT
    ke.knowledge_entry_id,
    st.structure_type_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.structure_type st
    ON st.name IN ('Dock Light', 'Point')
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;


-- Attach technique metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_technique
    (knowledge_entry_id, technique_id)
SELECT
    ke.knowledge_entry_id,
    t.technique_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.technique t
    ON t.name IN ('Fly Retrieve', 'Topwater', 'Live Bait')
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;


-- Attach forage metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_forage_species
    (knowledge_entry_id, forage_species_id)
SELECT
    ke.knowledge_entry_id,
    fs.forage_species_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.forage_species fs
    ON fs.common_name = 'Threadfin Shad'
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;


-- Attach tag metadata
INSERT INTO stripedbassfishingtool.knowledge_entry_tag
    (knowledge_entry_id, tag_id)
SELECT
    ke.knowledge_entry_id,
    tag.tag_id
FROM stripedbassfishingtool.knowledge_entry ke
JOIN stripedbassfishingtool.tag tag
    ON tag.name IN ('low-light', 'dock-light', 'ethics')
WHERE ke.title = 'Summer Night Dock Light Pattern'
ON CONFLICT DO NOTHING;