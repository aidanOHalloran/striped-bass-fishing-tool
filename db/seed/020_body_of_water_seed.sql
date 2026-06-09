INSERT INTO stripedbassfishingtool.body_of_water
    (
        name,
        waterbody_type,
        state,
        region,
        nearest_city,
        description,
        has_striped_bass,
        primary_forage_notes,
        thermocline_notes
    )
VALUES
    (
        'Tim''s Ford Lake',
        'reservoir',
        'TN',
        'Middle Tennessee',
        'Winchester',
        'Reservoir frequently discussed for landlocked striped bass fishing.',
        true,
        'Threadfin and gizzard shad are important forage species.',
        'Summer thermocline and warm-water stress considerations may be important.'
    )
ON CONFLICT (name, state) DO NOTHING;

INSERT INTO stripedbassfishingtool.fishing_location
    (
        body_of_water_id,
        name,
        description,
        general_area,
        is_sensitive_spot,
        default_structure_type_id,
        notes
    )
SELECT
    bow.body_of_water_id,
    'Generic Dock Light',
    'Placeholder location for night dock-light observations.',
    'Tim''s Ford Lake',
    true,
    st.structure_type_id,
    'Use this until specific locations are added through the app.'
FROM stripedbassfishingtool.body_of_water bow
JOIN stripedbassfishingtool.structure_type st
    ON st.name = 'Dock Light'
WHERE bow.name = 'Tim''s Ford Lake'
  AND bow.state = 'TN'
ON CONFLICT (body_of_water_id, name) DO NOTHING;