/*
    Striped Bass Fishing Tool - Initial Database Schema
    ---------------------------------------------------

    Purpose:
    - Creates the full relational foundation for the Blazor/PostgreSQL app.
    - Organizes data into reference data, knowledge entries, fishing logs,
      and reusable fishing patterns.

    Docker/PostgreSQL note:
    - Files in /docker-entrypoint-initdb.d only run automatically when the
      PostgreSQL data volume is initialized for the first time.
    - If you change this file and want Docker to rerun it from scratch:
          docker compose down -v --remove-orphans
          docker compose up -d
*/

CREATE SCHEMA IF NOT EXISTS stripedbassfishingtool;

SET search_path TO stripedbassfishingtool, public;


/* ============================================================
   REFERENCE TABLES
   ============================================================ */

/*
    user_profile
    Developer:
    A normalized lookup table for user profiles.

    Fisherman:
    If multiple people are logging trips and sharing knowledge, this table
    can help track who observed what, and let you filter by your own notes vs.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.user_profile (
    user_profile_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    time_format TEXT NOT NULL DEFAULT '12-hour',
    dark_mode_enabled BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_user_profile_time_format
        CHECK (time_format IN ('12-hour', '24-hour'))
);

-- add placeholder user for now to avoid nulls in created_by fields
INSERT INTO stripedbassfishingtool.user_profile (username, email)
VALUES ('default_user', 'default_user@example.com');


/*
    season
    Developer:
    A normalized lookup table for broad seasonal phases.

    Fisherman:
    Stripers often behave by seasonal phase more than by calendar date alone.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.season (
    season_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    month
    Developer:
    Fixed calendar lookup table. Uses month_id 1-12 instead of identity.

    Fisherman:
    Month is useful for browsing notes and historical patterns, even when
    water temperature is the better behavioral trigger.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.month (
    month_id INT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    short_name TEXT NOT NULL UNIQUE,
    display_order INT NOT NULL,

    CONSTRAINT ck_month_id CHECK (month_id BETWEEN 1 AND 12)
);

/*
    water_temperature_band
    Developer:
    Turns raw water temperatures into queryable behavior bands.

    Fisherman:
    Water temperature affects striper depth, feeding, oxygen comfort,
    handling stress, and seasonal movement.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.water_temperature_band (
    water_temperature_band_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    min_temp_f NUMERIC(5,2),
    max_temp_f NUMERIC(5,2),
    description TEXT,
    striper_behavior_notes TEXT,
    ethical_caution_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_water_temperature_band_range
        CHECK (
            min_temp_f IS NULL
            OR max_temp_f IS NULL
            OR min_temp_f <= max_temp_f
        )
);

/*
    water_clarity
    Developer:
    Normalizes visibility conditions for sessions and later filtering.

    Fisherman:
    Clarity changes lure color, leader choice, retrieve speed, and how far
    fish can visually track bait.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.water_clarity (
    water_clarity_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    visibility_min_ft NUMERIC(5,2),
    visibility_max_ft NUMERIC(5,2),
    description TEXT,
    fishing_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_water_clarity_range
        CHECK (
            visibility_min_ft IS NULL
            OR visibility_max_ft IS NULL
            OR visibility_min_ft <= visibility_max_ft
        )
);

/*
    weather_pattern
    Developer:
    Lookup table for weather categories associated with fishing sessions.

    Fisherman:
    Weather affects light, bait movement, current, runoff, pressure,
    and feeding windows.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.weather_pattern (
    weather_pattern_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    fishing_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    moon_phase
    Developer:
    Normalizes moon phase for night-fishing logs.

    Fisherman:
    Moon phase can affect night visibility, dock-light concentration,
    and bait movement.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.moon_phase (
    moon_phase_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    illumination_min_percent NUMERIC(5,2),
    illumination_max_percent NUMERIC(5,2),
    description TEXT,
    fishing_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_moon_phase_illumination
        CHECK (
            illumination_min_percent IS NULL
            OR illumination_max_percent IS NULL
            OR illumination_min_percent <= illumination_max_percent
        )
);

/*
    wind_condition
    Developer:
    Stores reusable named wind categories while environment_snapshot can store
    the exact measured wind speed/direction.

    Fisherman:
    Wind can activate points, push bait, add surface chop, and affect safety.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.wind_condition (
    wind_condition_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    min_speed_mph NUMERIC(5,2),
    max_speed_mph NUMERIC(5,2),
    description TEXT,
    fishing_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_wind_condition_speed
        CHECK (
            min_speed_mph IS NULL
            OR max_speed_mph IS NULL
            OR min_speed_mph <= max_speed_mph
        )
);

/*
    light_condition
    Developer:
    Normalizes fishing light periods.

    Fisherman:
    Stripers often feed better during low-light periods such as dawn, dusk,
    night, overcast conditions, and dock lights.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.light_condition (
    light_condition_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    fishing_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    forage_species
    Developer:
    Reference table for baitfish/forage used by knowledge entries,
    sessions, catches, and patterns.

    Fisherman:
    Striper behavior is heavily tied to forage. Matching threadfin, gizzard
    shad, herring, alewives, or other bait can define the whole approach.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.forage_species (
    forage_species_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    common_name TEXT NOT NULL UNIQUE,
    scientific_name TEXT,
    description TEXT,
    preferred_temperature_notes TEXT,
    behavior_notes TEXT,
    bait_handling_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    structure_type
    Developer:
    Reference table for structural features attached to knowledge,
    locations, trips, and patterns.

    Fisherman:
    Points, humps, saddles, channels, docks, creek mouths, and tailraces
    help explain where stripers are likely to position.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.structure_type (
    structure_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    waterbody_context TEXT,
    description TEXT,
    why_stripers_use_it TEXT,
    how_to_fish_notes TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    technique
    Developer:
    Stores high-level fishing methods.

    Fisherman:
    Technique describes the overall approach: topwater, swimbait, live bait,
    trolling, spooning, fly retrieve, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.technique (
    technique_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    category TEXT,
    description TEXT,
    when_to_use_notes TEXT,
    common_mistakes_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    presentation
    Developer:
    Separates how something is fished from what lure/fly/bait is used.

    Fisherman:
    The same lure can behave completely differently depending on retrieve,
    depth, countdown, drift, speed, or pause cadence.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.presentation (
    presentation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    retrieve_speed TEXT,
    depth_zone TEXT,
    fishing_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    lure_type
    Developer:
    Stores artificial lure categories. Specific brand/model inventory can be
    added later as a separate table.

    Fisherman:
    Topwater plugs, flukes, swimbaits, spoons, bucktails, and umbrella rigs
    serve different situations and depth zones.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.lure_type (
    lure_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    category TEXT,
    description TEXT,
    best_conditions_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    fly_pattern
    Developer:
    Keeps fly-fishing patterns separate from general lure categories.

    Fisherman:
    Fly pattern matters for bait profile, size, sink behavior, and retrieve.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fly_pattern (
    fly_pattern_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    baitfish_imitation TEXT,
    typical_size_range TEXT,
    sink_behavior TEXT,
    best_conditions_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

/*
    tag
    Developer:
    Flexible lightweight labels for filtering and grouping notes.

    Fisherman:
    Useful for concepts that do not need their own table yet, like
    thermocline, dock light, current, sonar, schooling, or ethics.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.tag (
    tag_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


/* ============================================================
   KNOWLEDGE TABLES
   ============================================================ */

/*
    knowledge_entry
    Developer:
    Stores reading notes, observations, book/video/article notes, and concepts.

    Fisherman:
    This is where you capture reusable striper knowledge before connecting it
    to seasons, temp bands, structures, techniques, forage, and tags.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry (
    knowledge_entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title TEXT NOT NULL,
    summary TEXT,
    body TEXT NOT NULL,
    source_type TEXT,
    source_title TEXT,
    source_author TEXT,
    source_page_start INT,
    source_page_end INT,
    confidence_level INT NOT NULL DEFAULT 3,
    is_personal_observation BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,

    CONSTRAINT ck_knowledge_entry_confidence
        CHECK (confidence_level BETWEEN 1 AND 5),

    CONSTRAINT ck_knowledge_entry_pages
        CHECK (
            source_page_start IS NULL
            OR source_page_end IS NULL
            OR source_page_start <= source_page_end
        )
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_season (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    season_id INT NOT NULL
        REFERENCES stripedbassfishingtool.season(season_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, season_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_month (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    month_id INT NOT NULL
        REFERENCES stripedbassfishingtool.month(month_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, month_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_temperature_band (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    water_temperature_band_id INT NOT NULL
        REFERENCES stripedbassfishingtool.water_temperature_band(water_temperature_band_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, water_temperature_band_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_structure_type (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    structure_type_id INT NOT NULL
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, structure_type_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_technique (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    technique_id INT NOT NULL
        REFERENCES stripedbassfishingtool.technique(technique_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, technique_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_forage_species (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    forage_species_id INT NOT NULL
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, forage_species_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_tag (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,
    tag_id INT NOT NULL
        REFERENCES stripedbassfishingtool.tag(tag_id)
        ON DELETE CASCADE,
    PRIMARY KEY (knowledge_entry_id, tag_id)
);


/* ============================================================
   FISHING LOG TABLES
   ============================================================ */

/*
    body_of_water
    Developer:
    Stores lakes, reservoirs, rivers, tailwaters, and other fisheries.

    Fisherman:
    Each waterbody has its own forage, thermocline behavior, seasonal timing,
    current/generation, access points, and local striper population.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.body_of_water (
    body_of_water_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL,
    waterbody_type TEXT NOT NULL,
    state TEXT,
    region TEXT,
    nearest_city TEXT,
    description TEXT,
    has_striped_bass BOOLEAN NOT NULL DEFAULT true,
    has_hybrid_striped_bass BOOLEAN NOT NULL DEFAULT false,
    primary_forage_notes TEXT,
    thermocline_notes TEXT,
    current_generation_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_body_of_water_name_state
        UNIQUE (name, state)
);

/*
    fishing_location
    Developer:
    Stores named places within a body of water.

    Fisherman:
    These can be exact spots or general areas: dock light, main-lake point,
    creek mouth, hump, saddle, tailrace, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_location (
    fishing_location_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    body_of_water_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.body_of_water(body_of_water_id)
        ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    general_area TEXT,
    is_sensitive_spot BOOLEAN NOT NULL DEFAULT false,
    default_structure_type_id INT
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_fishing_location_body_name
        UNIQUE (body_of_water_id, name),

    CONSTRAINT ck_fishing_location_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),

    CONSTRAINT ck_fishing_location_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

/*
    fishing_trip
    Developer:
    A high-level outing that can contain one or more sessions.

    Fisherman:
    A single trip can have different windows: dawn, midday scouting,
    evening, or night dock-light fishing.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_trip (
    fishing_trip_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    body_of_water_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.body_of_water(body_of_water_id)
        ON DELETE RESTRICT,
    trip_name TEXT,
    trip_date DATE NOT NULL,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    purpose TEXT,
    overall_success_rating INT,
    summary TEXT,
    lessons_learned TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_fishing_trip_success
        CHECK (
            overall_success_rating IS NULL
            OR overall_success_rating BETWEEN 1 AND 5
        ),

    CONSTRAINT ck_fishing_trip_time_range
        CHECK (
            start_time IS NULL
            OR end_time IS NULL
            OR start_time <= end_time
        )
);

/*
    fishing_session
    Developer:
    A focused window within a trip.

    Fisherman:
    Conditions and fish behavior can change completely between dawn,
    midday, dusk, and night.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_session (
    fishing_session_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fishing_trip_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_trip(fishing_trip_id)
        ON DELETE CASCADE,
    fishing_location_id BIGINT
        REFERENCES stripedbassfishingtool.fishing_location(fishing_location_id)
        ON DELETE SET NULL,
    session_name TEXT,
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    light_condition_id INT
        REFERENCES stripedbassfishingtool.light_condition(light_condition_id)
        ON DELETE SET NULL,
    water_clarity_id INT
        REFERENCES stripedbassfishingtool.water_clarity(water_clarity_id)
        ON DELETE SET NULL,
    moon_phase_id INT
        REFERENCES stripedbassfishingtool.moon_phase(moon_phase_id)
        ON DELETE SET NULL,
    notes TEXT,
    success_rating INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_fishing_session_success
        CHECK (
            success_rating IS NULL
            OR success_rating BETWEEN 1 AND 5
        ),

    CONSTRAINT ck_fishing_session_time_range
        CHECK (
            start_time IS NULL
            OR end_time IS NULL
            OR start_time <= end_time
        )
);

/*
    environment_snapshot
    Developer:
    Stores measured/observed conditions for a session.

    Fisherman:
    This captures the context behind the bite: water temp, wind, weather,
    thermocline, bait visibility, surface activity, current, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.environment_snapshot (
    environment_snapshot_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,
    observed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    water_temperature_f NUMERIC(5,2),
    air_temperature_f NUMERIC(5,2),
    water_temperature_band_id INT
        REFERENCES stripedbassfishingtool.water_temperature_band(water_temperature_band_id)
        ON DELETE SET NULL,
    weather_pattern_id INT
        REFERENCES stripedbassfishingtool.weather_pattern(weather_pattern_id)
        ON DELETE SET NULL,
    wind_condition_id INT
        REFERENCES stripedbassfishingtool.wind_condition(wind_condition_id)
        ON DELETE SET NULL,
    wind_direction TEXT,
    wind_speed_mph NUMERIC(5,2),
    barometric_pressure_inhg NUMERIC(6,3),
    pressure_trend TEXT,
    cloud_cover_percent NUMERIC(5,2),
    precipitation_notes TEXT,
    current_flow_notes TEXT,
    generation_status TEXT,
    thermocline_depth_ft NUMERIC(6,2),
    dissolved_oxygen_notes TEXT,
    bait_visible BOOLEAN,
    surface_activity BOOLEAN,
    bird_activity BOOLEAN,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_environment_cloud_cover
        CHECK (
            cloud_cover_percent IS NULL
            OR cloud_cover_percent BETWEEN 0 AND 100
        ),

    CONSTRAINT ck_environment_wind_speed
        CHECK (
            wind_speed_mph IS NULL
            OR wind_speed_mph >= 0
        )
);

/*
    catch_record
    Developer:
    Stores each catch as an individual record.

    Fisherman:
    Lets you compare what actually caught fish against what was tried.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.catch_record (
    catch_record_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,
    caught_at TIMESTAMPTZ,
    species TEXT NOT NULL DEFAULT 'Striped Bass',
    length_inches NUMERIC(5,2),
    weight_lbs NUMERIC(6,2),
    estimated_weight BOOLEAN NOT NULL DEFAULT false,
    depth_caught_ft NUMERIC(6,2),
    fish_depth_observed_ft NUMERIC(6,2),
    bottom_depth_ft NUMERIC(6,2),
    technique_id INT
        REFERENCES stripedbassfishingtool.technique(technique_id)
        ON DELETE SET NULL,
    presentation_id INT
        REFERENCES stripedbassfishingtool.presentation(presentation_id)
        ON DELETE SET NULL,
    lure_type_id INT
        REFERENCES stripedbassfishingtool.lure_type(lure_type_id)
        ON DELETE SET NULL,
    fly_pattern_id INT
        REFERENCES stripedbassfishingtool.fly_pattern(fly_pattern_id)
        ON DELETE SET NULL,
    forage_species_id INT
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE SET NULL,
    was_released BOOLEAN,
    release_condition TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_catch_length
        CHECK (length_inches IS NULL OR length_inches > 0),

    CONSTRAINT ck_catch_weight
        CHECK (weight_lbs IS NULL OR weight_lbs > 0)
);

/*
    trip_technique_used
    Developer:
    Records all techniques tried during a session, successful or not.

    Fisherman:
    Failed attempts are useful pattern data.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.trip_technique_used (
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,
    technique_id INT NOT NULL
        REFERENCES stripedbassfishingtool.technique(technique_id)
        ON DELETE CASCADE,
    presentation_id INT
        REFERENCES stripedbassfishingtool.presentation(presentation_id)
        ON DELETE SET NULL,
    lure_type_id INT
        REFERENCES stripedbassfishingtool.lure_type(lure_type_id)
        ON DELETE SET NULL,
    fly_pattern_id INT
        REFERENCES stripedbassfishingtool.fly_pattern(fly_pattern_id)
        ON DELETE SET NULL,
    effectiveness_rating INT,
    notes TEXT,

    PRIMARY KEY (fishing_session_id, technique_id),

    CONSTRAINT ck_trip_technique_effectiveness
        CHECK (
            effectiveness_rating IS NULL
            OR effectiveness_rating BETWEEN 1 AND 5
        )
);

/*
    trip_structure_fished
    Developer:
    Records structures fished during a session.

    Fisherman:
    Lets you compare points, humps, saddles, docks, channels, and other
    areas within actual fishing conditions.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.trip_structure_fished (
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,
    structure_type_id INT NOT NULL
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE CASCADE,
    effectiveness_rating INT,
    notes TEXT,

    PRIMARY KEY (fishing_session_id, structure_type_id),

    CONSTRAINT ck_trip_structure_effectiveness
        CHECK (
            effectiveness_rating IS NULL
            OR effectiveness_rating BETWEEN 1 AND 5
        )
);

/*
    seeded_image
    Developer:
    Stores images that can be associated with knowledge entries, trips, and sessions.

    Fisherman:
    Images can help illustrate conditions, techniques, structures, and catches.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.seeded_image
(
    seeded_image_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    title VARCHAR(200) NOT NULL,
    description TEXT,

    image_category VARCHAR(100) NOT NULL,
    image_path TEXT NOT NULL,

    alt_text VARCHAR(300) NOT NULL,

    linked_reference_type VARCHAR(100),
    linked_reference_key VARCHAR(200),

    source_name VARCHAR(200),
    source_url TEXT,
    attribution_notes TEXT,

    is_active BOOLEAN NOT NULL DEFAULT true,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT uq_seeded_image_path UNIQUE (image_path)
);

/*
    trip_forage_observed
    Developer:
    Records forage observed during a session.

    Fisherman:
    Seeing bait is one of the biggest clues. This stores bait species,
    abundance, observation method, and depth.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.trip_forage_observed (
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,
    forage_species_id INT NOT NULL
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE CASCADE,
    observation_method TEXT,
    estimated_abundance TEXT,
    depth_observed_ft NUMERIC(6,2),
    notes TEXT,

    PRIMARY KEY (fishing_session_id, forage_species_id)
);


/* ============================================================
   RECOMMENDATION / PATTERN TABLES
   ============================================================ */

/*
    fishing_pattern
    Developer:
    Stores reusable recommendation patterns independent of any one trip.

    Fisherman:
    A pattern connects conditions to likely locations and tactics.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern (
    fishing_pattern_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    summary TEXT NOT NULL,
    detailed_notes TEXT,
    confidence_level INT NOT NULL DEFAULT 3,
    priority_score INT NOT NULL DEFAULT 0,
    recommended_depth_min_ft NUMERIC(6,2),
    recommended_depth_max_ft NUMERIC(6,2),
    recommended_time_of_day TEXT,
    safety_or_ethics_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ,

    CONSTRAINT ck_fishing_pattern_confidence
        CHECK (confidence_level BETWEEN 1 AND 5),

    CONSTRAINT ck_fishing_pattern_depth_range
        CHECK (
            recommended_depth_min_ft IS NULL
            OR recommended_depth_max_ft IS NULL
            OR recommended_depth_min_ft <= recommended_depth_max_ft
        )
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_season (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,
    season_id INT NOT NULL
        REFERENCES stripedbassfishingtool.season(season_id)
        ON DELETE CASCADE,
    PRIMARY KEY (fishing_pattern_id, season_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_temperature_band (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,
    water_temperature_band_id INT NOT NULL
        REFERENCES stripedbassfishingtool.water_temperature_band(water_temperature_band_id)
        ON DELETE CASCADE,
    PRIMARY KEY (fishing_pattern_id, water_temperature_band_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_structure_type (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,
    structure_type_id INT NOT NULL
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE CASCADE,
    PRIMARY KEY (fishing_pattern_id, structure_type_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_technique (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,
    technique_id INT NOT NULL
        REFERENCES stripedbassfishingtool.technique(technique_id)
        ON DELETE CASCADE,
    presentation_id INT
        REFERENCES stripedbassfishingtool.presentation(presentation_id)
        ON DELETE SET NULL,
    lure_type_id INT
        REFERENCES stripedbassfishingtool.lure_type(lure_type_id)
        ON DELETE SET NULL,
    fly_pattern_id INT
        REFERENCES stripedbassfishingtool.fly_pattern(fly_pattern_id)
        ON DELETE SET NULL,
    notes TEXT,

    PRIMARY KEY (fishing_pattern_id, technique_id)
);

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_forage_species (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,
    forage_species_id INT NOT NULL
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE CASCADE,
    PRIMARY KEY (fishing_pattern_id, forage_species_id)
);


/* ============================================================
   INDEXES
   ============================================================ */

CREATE INDEX IF NOT EXISTS ix_knowledge_entry_title
    ON stripedbassfishingtool.knowledge_entry (title);

CREATE INDEX IF NOT EXISTS ix_fishing_trip_body_date
    ON stripedbassfishingtool.fishing_trip (body_of_water_id, trip_date);

CREATE INDEX IF NOT EXISTS ix_fishing_session_trip
    ON stripedbassfishingtool.fishing_session (fishing_trip_id);

CREATE INDEX IF NOT EXISTS ix_environment_snapshot_session
    ON stripedbassfishingtool.environment_snapshot (fishing_session_id);

CREATE INDEX IF NOT EXISTS ix_catch_record_session
    ON stripedbassfishingtool.catch_record (fishing_session_id);

CREATE INDEX IF NOT EXISTS ix_fishing_location_body
    ON stripedbassfishingtool.fishing_location (body_of_water_id);





/* ============================================================
   END OF INITIALIZATION SCRIPT
   ============================================================ */
