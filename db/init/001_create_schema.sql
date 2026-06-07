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


/* ============================================================
   END OF INITIALIZATION SCRIPT
   ============================================================ */
