# Project Structure Issues Report

This report captures the most concerning technical issues currently visible in the Striped Bass Fishing Tool codebase. Each issue includes a plain-English explanation, a technical description, the practical risk, and recommended steps to resolve it.

The goal is to make these problems actionable one at a time without losing sight of how they relate to the larger application structure.

## Priority Summary

| Priority | Issue | Main Risk | Recommended First Action |
| --- | --- | --- | --- |
| 1 | Web app writes back into seed SQL files | Local-dev behavior could become unsafe or inconsistent | Restrict durable seed writes to development only |
| 2 | No single source of truth for schema | C# models and SQL schema can drift silently | Decide SQL-first or EF-migrations-first |
| 3 | Reference forms include generated identity columns | Some create flows may fail against PostgreSQL identity columns | Remove generated IDs from create forms/inserts |
| 4 | Database save and seed-file append are not atomic | Half-success states are possible | Treat seed append as dev-only best-effort logging |
| 5 | No authentication or authorization around mutation | Anyone with access can modify data | Add auth before shared deployment |
| 6 | No visible automated tests | Regressions are likely as the app grows | Add integration tests around schema, seed, and services |
| 7 | Local operations have portability rough edges | Setup/reset may fail on some developer machines | Replace PowerShell-only `wait-db` with POSIX shell |

## 1. Web App Writes Back Into Seed SQL Files

### Layman's Explanation

The app does not only save data into the database. In development mode, it can also edit the project's SQL seed files when someone creates records through the UI.

That is convenient because new fishing knowledge can survive a database reset. But it is also unusual for a web application. Normally, the web app writes to the database, and separate developer tooling exports or migrates data when needed.

If this behavior accidentally reaches a shared or production-like environment, the running website would be allowed to mutate project files on disk.

### Technical Description

The application has a "durable seed" pattern controlled by `DurableSeed:AppendOnCreate`.

Relevant files:

- `src/StripedBassFishingTool.Web/Components/Pages/Knowledge/KnowledgeCreate.razor`
- `src/StripedBassFishingTool.Web/Services/Knowledge/KnowledgeEntrySeedWriter.cs`
- `src/StripedBassFishingTool.Web/Services/Reference/ReferenceDataService.cs`
- `src/StripedBassFishingTool.Web/appsettings.Development.json`
- `docker-compose.yml`

In development, `AppendOnCreate` is enabled. When a knowledge entry or reference record is created, the app may append SQL to files such as:

- `db/seed/010_reference_seed.sql`
- `db/seed/100_knowledge_entries_seed.sql`

This creates a coupling between runtime application behavior and source-controlled seed files.

### Risk

- Concurrent writes could interleave or corrupt seed file output.
- A failed file append can leave the database changed but the seed file unchanged.
- A malformed generated SQL block could break future database resets.
- The web process needs filesystem write access to files that normally belong to development tooling.
- If deployed beyond local development, this becomes a security and operational concern.

### Recommended Resolution

1. Keep durable seed append strictly development-only.
2. Enforce that restriction in code, not only configuration.
3. Rename the behavior to make its purpose explicit, for example `DevelopmentSeedCaptureService`.
4. Treat seed-file append as a developer convenience, not part of the main save contract.
5. Add logging that clearly says when a seed append succeeds, fails, or is skipped.
6. Consider replacing this workflow with an explicit export command later.

### Suggested Implementation Steps

1. Inject `IHostEnvironment` into the seed-writing services.
2. If `!environment.IsDevelopment()`, skip seed writing even if configuration is accidentally enabled.
3. Change the UI message so it says this is a development-only capture mechanism.
4. Add file locking or serialize seed writes if the pattern remains.
5. Add tests for generated SQL output.

## 2. No Single Source Of Truth For Database Schema

### Layman's Explanation

The project currently describes the database in two places:

1. SQL files that create the actual PostgreSQL schema.
2. C# Entity Framework mappings that tell the app how to read and write tables.

If those two descriptions get out of sync, the app can compile successfully but fail at runtime.

### Technical Description

The schema is defined manually in:

- `db/init/001_create_schema.sql`

Entity Framework mappings are defined separately in:

- `src/StripedBassFishingTool.Web/Data/AppDbContext.cs`

The SQL schema is broader than the EF model. The database includes planned tables for fishing trips, sessions, locations, catches, environmental snapshots, and patterns. The current EF model maps only a subset of the schema.

That is not inherently wrong, but there is no visible automated check ensuring the mapped EF model still matches the SQL schema.

### Risk

- Column names can diverge between SQL and C#.
- Required fields can exist in SQL but not be populated by the app.
- New SQL constraints can break existing service methods.
- EF relationships can silently lag behind schema changes.
- Developers may assume a table is app-supported because it exists in SQL, even when no service/page maps it.

### Recommended Resolution

Pick a clear schema ownership model:

- Option A: SQL-first. Keep handcrafted SQL as the source of truth and add tests that verify the app can run against it.
- Option B: EF-migrations-first. Let EF migrations become the source of truth and reduce manual schema drift.

Given this project already has detailed SQL seed/init files, SQL-first is probably the smaller change for now.

### Suggested Implementation Steps

1. Document that `db/init/001_create_schema.sql` is the current source of truth.
2. Add an integration test project.
3. In tests, start or connect to PostgreSQL, apply `db/init`, apply seed files, and run service-level smoke tests.
4. Add a checklist for schema changes:
   - update SQL schema
   - update EF model if app needs the table
   - update reference registry if applicable
   - update seed data
   - update integration tests
5. Revisit EF migrations later if schema changes become frequent.

## 3. Reference Forms Include Generated Identity Columns

### Layman's Explanation

Some forms ask the user to enter database ID numbers that PostgreSQL is supposed to generate automatically.

That is like asking someone to hand-write the receipt number when the cash register is already designed to assign one.

This can cause saves to fail or create confusing behavior.

### Technical Description

Several reference table definitions include primary key fields as normal create-form fields in:

- `src/StripedBassFishingTool.Web/Services/Reference/ReferenceTableRegistry.cs`

Examples include generated identity columns such as:

- `season_id`
- `water_temperature_band_id`

But the SQL schema defines many of these as:

```sql
INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

For `GENERATED ALWAYS` identity columns, PostgreSQL normally rejects explicit values unless the insert uses `OVERRIDING SYSTEM VALUE`.

The reference service builds insert statements dynamically in:

- `src/StripedBassFishingTool.Web/Services/Reference/ReferenceDataService.cs`

If the registry includes an identity primary key as an insert field, the create flow can attempt to insert explicit values into a generated column.

### Risk

- Reference create pages may fail for identity-backed tables.
- Users may be asked for implementation details they should not need to know.
- Seed append output may include IDs that should be database-generated.
- Duplicate or conflicting IDs could be introduced if overrides are later added carelessly.

### Recommended Resolution

Do not expose generated identity columns in create forms. Only include manually assigned IDs for tables that are intentionally fixed, such as `month`.

### Suggested Implementation Steps

1. Add metadata to `ReferenceFieldViewModel`, such as:
   - `IsPrimaryKey`
   - `IsGenerated`
   - `IncludeOnCreate`
2. Update `ReferenceTableRegistry` so generated identity primary keys are not included in create fields.
3. Keep `month_id` editable because months intentionally use fixed values 1-12.
4. Update `ReferenceDataService.CreateRecordAsync` to insert only fields marked `IncludeOnCreate`.
5. Add tests for at least one generated-ID table and one manually keyed table.

## 4. Database Save And Seed-File Append Are Not Atomic

### Layman's Explanation

When saving a new knowledge entry, the app first saves it to the database. Then it separately tries to append that same entry to a seed SQL file.

If the database save works but the file write fails, the app is in a split state: the record exists in the database, but it will not survive a reset.

### Technical Description

Knowledge creation currently happens in two separate operations:

1. `KnowledgeEntryService.CreateKnowledgeEntryAsync(...)` saves to PostgreSQL.
2. `KnowledgeEntrySeedWriter.AppendKnowledgeEntryAsync(...)` appends SQL to a seed file.

These operations cannot be part of the same database transaction because one target is PostgreSQL and the other is the local filesystem.

The UI currently reports a seed append failure after the DB save has already succeeded.

### Risk

- Users may think the whole save failed even though the database row exists.
- Retrying the save may create duplicate or conflicting content.
- Seed files may not reflect actual database state.
- Title-based seed replay can be fragile if titles are edited or duplicated.

### Recommended Resolution

Treat seed append as best-effort development logging, not part of the main save. The main save should be considered successful when the database commit succeeds.

### Suggested Implementation Steps

1. Change the UI flow so a seed append failure appears as a warning, not a save failure.
2. Write a structured log event when seed append fails.
3. Consider storing generated seed SQL blocks in a review queue instead of writing directly to final seed files.
4. Add uniqueness rules if seed replay depends on title matching.
5. Long term, build an explicit export command that regenerates seed files from database state.

## 5. No Authentication Or Authorization Around Mutation

### Layman's Explanation

The app has pages that create or modify data, but there does not appear to be a login or permission system around those actions.

That is acceptable for a personal local tool. It is not acceptable if the app is reachable by other people on a network.

### Technical Description

The app includes concepts like `UserProfile`, but no visible authentication or authorization middleware is configured in:

- `src/StripedBassFishingTool.Web/Program.cs`

The create pages for knowledge and reference data are accessible by route. There are no visible authorization attributes or route guards.

### Risk

- Anyone who can reach the app can create reference data.
- Anyone who can reach the app can create knowledge entries.
- If durable seed append is enabled, anyone who can reach the app can indirectly append content to seed SQL files.
- Future trip/location data may include sensitive fishing spots.

### Recommended Resolution

If this remains a local-only app, document that assumption clearly. If it will run on a shared machine, home network, cloud host, or public server, add authentication before expanding mutation features.

### Suggested Implementation Steps

1. Decide the intended deployment model:
   - local-only personal tool
   - private network tool
   - public or cloud-hosted app
2. For local-only use, add a README warning.
3. For shared use, add ASP.NET Core authentication.
4. Protect create/edit/delete routes with authorization.
5. Later, connect created records to actual user identities.

## 6. No Visible Automated Tests

### Layman's Explanation

There are several moving parts: SQL schema, seed files, EF mappings, dynamic reference forms, and generated SQL append behavior. Right now, there are no visible automated tests to catch breakage.

That means a small change can break database reset, record creation, or page loading without being noticed until someone manually tries it.

### Technical Description

No test project is visible in the repository. Areas that especially need coverage:

- schema creation
- seed replay
- EF mappings
- reference table registry
- reference record creation
- knowledge entry creation
- generated seed SQL output
- basic page/service smoke tests

Because much of the application depends on PostgreSQL-specific behavior, unit tests alone are not enough. Integration tests are more valuable here.

### Risk

- Seed files can become invalid.
- EF mappings can drift from SQL.
- Reference registry definitions can point to nonexistent columns.
- Identity-column bugs can slip through.
- Future refactors will be risky.

### Recommended Resolution

Start with a small integration test suite rather than trying to test everything at once.

### Suggested Implementation Steps

1. Add a test project, for example `tests/StripedBassFishingTool.Web.Tests`.
2. Use a real PostgreSQL database for integration tests.
3. Test that `db/init/001_create_schema.sql` applies successfully.
4. Test that all seed files apply successfully in order.
5. Test that `ReferenceDataService.GetTableSummariesAsync()` works for every registered table.
6. Test creating a generated-ID reference record.
7. Test creating a knowledge entry with bridge-table relationships.
8. Add the test command to the Makefile.

## 7. Local Operations Have Portability Rough Edges

### Layman's Explanation

The project has helpful Makefile commands, but one command uses PowerShell. On macOS or Linux, PowerShell may not be installed by default.

Since this repo is being worked on from a Mac path, that could make database reset commands fail even when Docker and .NET are installed.

### Technical Description

The `wait-db` target in `Makefile` uses:

```make
powershell -NoProfile -Command "while ((docker exec $(DB_CONTAINER) pg_isready -U $(DB_USER) -d $(DB_NAME)) -notmatch 'accepting connections') { Start-Sleep -Seconds 1 }"
```

This creates an unnecessary dependency on PowerShell for a command that can be written with POSIX shell.

### Risk

- `make reset-db` may fail on machines without PowerShell.
- New contributors may think the app setup is broken.
- The Makefile is less portable than the rest of the Docker-based workflow.

### Recommended Resolution

Replace the PowerShell loop with a POSIX-compatible shell loop.

### Suggested Implementation Steps

1. Change `wait-db` to use `sh`.
2. Keep using `docker exec ... pg_isready`.
3. Add a timeout so the command fails clearly if PostgreSQL never becomes ready.
4. Update the README with setup prerequisites.

Example direction:

```make
wait-db:
	@until docker exec $(DB_CONTAINER) pg_isready -U $(DB_USER) -d $(DB_NAME) | grep -q "accepting connections"; do \
		sleep 1; \
	done
```

## Recommended Execution Plan

### Phase 1: Fix Immediate Breakage Risks

1. Remove generated identity IDs from reference create forms.
2. Make durable seed append development-only in code.
3. Change seed append failures from hard save failures to warnings.

### Phase 2: Add Safety Nets

1. Add integration tests for schema creation and seed replay.
2. Add service tests for reference summaries and knowledge entry creation.
3. Add generated SQL tests for durable seed append behavior.

### Phase 3: Clarify Architecture

1. Document SQL-first schema ownership.
2. Add a schema-change checklist.
3. Decide whether planned tables should be mapped into EF now or left as future schema only.

### Phase 4: Harden For Shared Use

1. Add authentication if the app will be reachable by anyone other than the local developer.
2. Add authorization to create/edit/delete routes.
3. Revisit user ownership and sensitive-location handling before building trip/location features.

## Suggested Definition Of Done

These issues can be considered under control when:

- Reference create pages no longer ask for generated IDs.
- The app cannot write seed files outside development.
- A failed seed append does not make a successful DB save look failed.
- There is at least one automated test path that creates schema, applies seeds, and exercises core services.
- The README explains the database lifecycle and local setup commands.
- The team has explicitly chosen SQL-first or EF-migrations-first schema ownership.

