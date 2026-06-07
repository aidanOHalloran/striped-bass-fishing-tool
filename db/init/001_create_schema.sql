/*
    If you already pasted the previous block, make sure the structure_type table
    uses why_stripers_use_it, not why_strip ers_use_it.
*/

CREATE TABLE IF NOT EXISTS stripedbassfishingtool.technique (
    technique_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL UNIQUE,

    category TEXT,
    /*
        Examples:
        - live bait
        - artificial
        - fly fishing
        - trolling
        - vertical
        - topwater
    */

    description TEXT,

    when_to_use_notes TEXT,

    common_mistakes_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


/*
    presentation
    ------------

    Developer:
    Separates the method of presenting a lure/bait from the lure or fly itself.
    This prevents duplication such as "fluke slow retrieve", "fluke fast retrieve",
    "clouser slow retrieve", etc.

    Fisherman:
    The same lure can fish completely differently depending on retrieve,
    depth, speed, countdown, drift, or trolling path.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.presentation (
    presentation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL UNIQUE,

    description TEXT,

    retrieve_speed TEXT,
    /*
        Examples:
        - deadstick
        - slow
        - medium
        - fast
        - burn
        - erratic
    */

    depth_zone TEXT,
    /*
        Examples:
        - surface
        - subsurface
        - mid-column
        - bottom
        - suspended
    */

    fishing_notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);


/*
    lure_type
    ---------

    Developer:
    Stores artificial lure categories. Specific brands/models can be added later
    in a separate lure table if desired.

    Fisherman:
    Lure type matters because stripers respond differently to topwater plugs,
    swimbaits, spoons, bucktails, jerkbaits, umbrella rigs, etc.
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
    -----------

    Developer:
    Stores fly-specific patterns separately from general lure types.
    This lets the app support conventional and fly-fishing workflows cleanly.

    Fisherman:
    Fly pattern matters when matching baitfish profile, water clarity, sink rate,
    and retrieve style. Examples: Clouser, Deceiver, Game Changer, Surf Candy.
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
    ---

    Developer:
    Flexible labeling system for knowledge entries and later UI filtering.
    Tags allow lightweight categorization without creating a new table for
    every possible idea.

    Fisherman:
    Useful for concepts like:
    - thermocline
    - summer stress
    - dock light
    - schooling fish
    - bait balls
    - current seam
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
    ---------------

    Developer:
    Stores structured fishing knowledge from books, personal notes, videos,
    articles, or field observations that are not necessarily tied to one trip.

    Fisherman:
    This is where you capture concepts such as:
    - how water temperature affects stripers
    - how to fish a hump
    - how to find forage
    - what summer night patterns look like
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry (
    knowledge_entry_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    title TEXT NOT NULL,

    summary TEXT,

    body TEXT NOT NULL,

    source_type TEXT,
    /*
        Examples:
        - book
        - personal observation
        - article
        - video
        - guide advice
        - state agency report
    */

    source_title TEXT,

    source_author TEXT,

    source_page_start INT,

    source_page_end INT,

    confidence_level INT NOT NULL DEFAULT 3,
    /*
        1 = weak/anecdotal
        2 = possible
        3 = generally useful
        4 = strong
        5 = repeatedly verified
    */

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


/*
    knowledge_entry_season
    ----------------------

    Developer:
    Many-to-many bridge between knowledge and seasons.

    Fisherman:
    A single concept can apply to multiple seasonal phases.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_season (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    season_id INT NOT NULL
        REFERENCES stripedbassfishingtool.season(season_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, season_id)
);


/*
    knowledge_entry_month
    ---------------------

    Developer:
    Many-to-many bridge between knowledge and months.

    Fisherman:
    Some notes are calendar-specific, such as "November and December can
    produce schooling fish on bait."
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_month (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    month_id INT NOT NULL
        REFERENCES stripedbassfishingtool.month(month_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, month_id)
);


/*
    knowledge_entry_temperature_band
    --------------------------------

    Developer:
    Links knowledge to one or more water temperature bands.

    Fisherman:
    This is more portable than month alone. A "60-68 degree pattern" may happen
    in different months depending on the lake, year, and region.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_temperature_band (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    water_temperature_band_id INT NOT NULL
        REFERENCES stripedbassfishingtool.water_temperature_band(water_temperature_band_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, water_temperature_band_id)
);


/*
    knowledge_entry_structure_type
    ------------------------------

    Developer:
    Links knowledge to physical fish-holding features.

    Fisherman:
    Allows querying all notes about points, humps, saddles, creek channels,
    docks, dams, shoals, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_structure_type (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    structure_type_id INT NOT NULL
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, structure_type_id)
);


/*
    knowledge_entry_technique
    -------------------------

    Developer:
    Links knowledge to fishing methods.

    Fisherman:
    Allows the app to find all notes connected to trolling, live bait,
    topwater, fly retrieve, countdown method, vertical jigging, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_technique (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    technique_id INT NOT NULL
        REFERENCES stripedbassfishingtool.technique(technique_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, technique_id)
);


/*
    knowledge_entry_forage_species
    ------------------------------

    Developer:
    Links knowledge to baitfish/forage.

    Fisherman:
    Allows notes like "threadfin on surface under lights" or
    "large gizzard shad on main lake flats" to be queried cleanly.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.knowledge_entry_forage_species (
    knowledge_entry_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.knowledge_entry(knowledge_entry_id)
        ON DELETE CASCADE,

    forage_species_id INT NOT NULL
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE CASCADE,

    PRIMARY KEY (knowledge_entry_id, forage_species_id)
);


/*
    knowledge_entry_tag
    -------------------

    Developer:
    Flexible many-to-many label bridge.

    Fisherman:
    Lets you group ideas that do not deserve their own formal table yet.
*/
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
    -------------

    Developer:
    Stores lakes, rivers, reservoirs, tailwaters, and coastal systems.
    Trips and locations reference this table.

    Fisherman:
    Each lake or river has its own personality: forage base, stocking,
    thermocline behavior, current, oxygen, ramps, and seasonal timing.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.body_of_water (
    body_of_water_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL,

    waterbody_type TEXT NOT NULL,
    /*
        Examples:
        - reservoir
        - river
        - tailwater
        - lake
        - bay
    */

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
    ----------------

    Developer:
    Stores named spots within a body of water. This can be as specific or
    general as you want. GPS fields are optional.

    Fisherman:
    A location might be:
    - main lake point
    - dock light
    - saddle near channel
    - creek mouth
    - hump
    - dam tailrace
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
    ------------

    Developer:
    A trip is the larger outing. It can contain multiple sessions.
    Example: one trip to Tim's Ford may include a dawn session, midday
    scouting session, and night dock-light session.

    Fisherman:
    This helps separate the overall outing from specific fishing windows.
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
    /*
        Examples:
        - scouting
        - live bait trip
        - fly fishing
        - night dock light
        - trolling
        - learning electronics
    */

    overall_success_rating INT,
    /*
        1 = poor
        2 = slow
        3 = okay
        4 = good
        5 = excellent
    */

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
    ---------------

    Developer:
    A session is a focused period within a trip. Most conditions, techniques,
    catches, and observations should attach to a session.

    Fisherman:
    The bite can change completely between dawn, midday, dusk, and night.
    This lets you track each window separately.
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
    --------------------

    Developer:
    Stores measured/observed environmental conditions for a fishing session.
    This is intentionally separate from fishing_session so you can later support
    multiple snapshots per session if desired.

    Fisherman:
    This captures the actual "why" behind the bite:
    water temp, air temp, wind, pressure, cloud cover, current, generation,
    surface activity, bait presence, thermocline depth, etc.
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
    /*
        Examples:
        - rising
        - falling
        - steady
    */

    cloud_cover_percent NUMERIC(5,2),

    precipitation_notes TEXT,

    current_flow_notes TEXT,

    generation_status TEXT,
    /*
        Examples:
        - none
        - light generation
        - active generation
        - spillway flow
        - unknown
    */

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
    ------------

    Developer:
    Stores individual fish catches. This allows later reporting by time,
    location, bait, technique, size, release outcome, and conditions.

    Fisherman:
    This helps identify what actually worked, not just what seemed promising.
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
    /*
        Examples:
        - strong
        - slow
        - stressed
        - harvested
        - unknown
    */

    notes TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT ck_catch_length
        CHECK (length_inches IS NULL OR length_inches > 0),

    CONSTRAINT ck_catch_weight
        CHECK (weight_lbs IS NULL OR weight_lbs > 0)
);


/*
    trip_technique_used
    -------------------

    Developer:
    Many-to-many bridge between a session and the techniques attempted.
    This records what was tried, not only what caught fish.

    Fisherman:
    Failed methods are valuable. Knowing "we tried topwater and it did not work"
    is useful pattern intelligence.
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
    /*
        1 = poor
        2 = weak
        3 = neutral
        4 = good
        5 = excellent
    */

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
    ---------------------

    Developer:
    Many-to-many bridge between sessions and structures fished.

    Fisherman:
    You may fish several structures during one session:
    point, saddle, hump, dock light, creek mouth, channel edge.
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
    --------------------

    Developer:
    Many-to-many bridge between sessions and forage species observed.

    Fisherman:
    Seeing bait is one of the biggest clues. This table lets you log:
    threadfin at surface, gizzard shad deep, bait balls on sonar, etc.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.trip_forage_observed (
    fishing_session_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_session(fishing_session_id)
        ON DELETE CASCADE,

    forage_species_id INT NOT NULL
        REFERENCES stripedbassfishingtool.forage_species(forage_species_id)
        ON DELETE CASCADE,

    observation_method TEXT,
    /*
        Examples:
        - visible surface
        - sonar
        - cast net
        - birds
        - dock light
        - stomach contents
    */

    estimated_abundance TEXT,
    /*
        Examples:
        - none
        - sparse
        - moderate
        - heavy
        - massive schools
    */

    depth_observed_ft NUMERIC(6,2),

    notes TEXT,

    PRIMARY KEY (fishing_session_id, forage_species_id)
);


/* ============================================================
   RECOMMENDATION / PATTERN TABLES
   ============================================================ */


/*
    fishing_pattern
    ---------------

    Developer:
    Represents a reusable rule/pattern that the app can surface later.
    This is the bridge between static knowledge and field recommendations.

    Fisherman:
    A pattern is something like:
    - Summer low-light point bite
    - Winter deep bait schools
    - Fall schooling fish over flats
    - Night dock light threadfin pattern
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern (
    fishing_pattern_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    name TEXT NOT NULL UNIQUE,

    summary TEXT NOT NULL,

    detailed_notes TEXT,

    confidence_level INT NOT NULL DEFAULT 3,

    priority_score INT NOT NULL DEFAULT 0,
    /*
        Higher score = more likely to show near the top in the app.
    */

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


/*
    fishing_pattern_season
    ----------------------

    Developer:
    Many-to-many relationship between patterns and seasons.

    Fisherman:
    A pattern may apply to more than one season, especially transitions.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_season (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,

    season_id INT NOT NULL
        REFERENCES stripedbassfishingtool.season(season_id)
        ON DELETE CASCADE,

    PRIMARY KEY (fishing_pattern_id, season_id)
);


/*
    fishing_pattern_temperature_band
    --------------------------------

    Developer:
    Links patterns to water temperature bands.

    Fisherman:
    This lets the app recommend by actual water temperature rather than
    calendar assumptions.
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_temperature_band (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,

    water_temperature_band_id INT NOT NULL
        REFERENCES stripedbassfishingtool.water_temperature_band(water_temperature_band_id)
        ON DELETE CASCADE,

    PRIMARY KEY (fishing_pattern_id, water_temperature_band_id)
);


/*
    fishing_pattern_structure_type
    ------------------------------

    Developer:
    Links patterns to fish-holding structures.

    Fisherman:
    This makes queries possible such as:
    "Show me all warm-water patterns involving points and saddles."
*/
CREATE TABLE IF NOT EXISTS stripedbassfishingtool.fishing_pattern_structure_type (
    fishing_pattern_id BIGINT NOT NULL
        REFERENCES stripedbassfishingtool.fishing_pattern(fishing_pattern_id)
        ON DELETE CASCADE,

    structure_type_id INT NOT NULL
        REFERENCES stripedbassfishingtool.structure_type(structure_type_id)
        ON DELETE CASCADE,

    PRIMARY KEY (fishing_pattern_id, structure_type_id)
);


/*
    fishing_pattern_technique
    -------------------------

    Developer:
    Links patterns to recommended techniques.

    Fisherman:
    A single pattern may support multiple methods:
    topwater, live bait, trolling, fly retrieve, vertical jigging.
*/
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


/*
    fishing_pattern_forage_species
    ------------------------------

    Developer:
    Links patterns to forage species.

    Fisherman:
    Lets the app recommend tactics based on bait:
    threadfin near surface, gizzard shad deeper, alewives over open water, etc.
*/
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


/*
    Seed reference data.
    These inserts are written with ON CONFLICT DO NOTHING so they are safe
    to run more than once.
*/

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


/* ============================================================
   OPTIONAL STARTER WATERBODY
   ============================================================ */

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