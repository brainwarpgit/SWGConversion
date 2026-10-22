# Running Project Guidance

# CRITICAL: Minimize output token length to conserve API credits.
# No pleasantries. Output only diffs or targeted code blocks, never entire unchanged files unless explicitly requested.

## Project Objective

- SWGConversion is a PRECU Core3 server enhanced with NGE-era content.
- SWGConversion and its currently checked-out branch are the authoritative target.
- Preserve Core3 as the primary server engine.
- Preserve PRECU combat, professions, skills, and gameplay mechanics.
- Target the PRECU 14.1 client, enhanced with compatible NGE assets.
- Port as much NGE content as possible, including planets, objects, mobiles, NPCs, creatures, quests, conversations, collections, instances, dungeons, equipment, vehicles, world placements, and supporting systems.
- Adapt NGE content to Core3 rather than converting Core3 into an NGE server.
- Implement missing functionality using existing Core3 systems whenever possible.
- Extend Core3 C++ only when necessary for required functionality.
- Do not import NGE combat, professions, or unrelated gameplay systems unless explicitly requested or necessary for approved content.
- Preserve original NGE content behavior where compatible with PRECU mechanics.
- Prefer reusable conversion solutions over one-off implementations.
- Prioritize complete, playable content over simply loading assets or registering templates.
- Do not expand beyond the user-approved conversion scope.

**Success means original NGE content is functional and playable within the existing PRECU/Core3 architecture, not merely that NGE files have been copied, converted, or registered.**

# Workspace Paths

- Read/Write Primary: `/home/swgemu/workspace/SWGConversion`
- Read-Only Reference: `/home/swgemu/workspace/swg-main` (Never modify)
- Read-Only Converted Reference: `/home/swgemu/workspace/MTGServer` (Never modify)
- Read-Only Clients: `/home/swgemu/workspace/tre` (Never modify)
- TRE Staging Root: `/home/swgemu/workspace/SWGConversion/treupdates`
- Read-Only Extracted: `/home/swgemu/workspace/extracted-PRECU`
- Read-Only Extracted Reference: `/home/swgemu/workspace/extracted-NGE`
- Read-Only Converted Assets: `/home/swgemu/workspace/extracted-MTG` (Never modify)

## Workspace Boundaries

- Normal work must stay within `MMOCoreORB/bin` and `MMOCoreORB/src`.
- Permitted read/search exceptions: `swg-main`, `MTGServer`, `tre`, `extracted-PRECU`, `extracted-NGE`, `extracted-MTG`.
- Permitted read-only exceptions: all previously numbered TRE staging folders.
- Permitted read/write exceptions: the ACTIVE (highest-numbered) folder in each `Core3_appearance_XX`, `Core3_texture_XX`, and `Core3_update_XX` staging series.
- Permitted creation: the next sequential staging folder when rotation is required.
- Permitted read/write files: `AGENTS.md`, `UPDATES.md`, `UPDATESFULL.md`.
- Do not access other locations unless explicitly asked.
- Never modify read-only reference repositories, extracted assets, original TRE archives, or locked staging folders.
- Never change filesystem permissions to bypass workspace restrictions.

## Source Priority

1. **SWGConversion**
   - Authoritative target implementation.
   - Preserve existing functionality, architecture, APIs, and conventions.

2. **MTGServer / extracted-MTG**
   - Previously converted NGE content for Core3.
   - Check before attempting new conversions.
   - Reuse compatible conversion techniques and verified implementations when permitted.
   - Do not assume conversions are complete, correct, or compatible.

3. **swg-main / extracted-NGE**
   - Original NGE implementation and content references.
   - Use to establish intended behavior, original definitions, dependencies, and missing functionality.

4. **extracted-PRECU / tre**
   - Primary PRECU client compatibility baseline.
   - Use to determine supported asset formats, structures, dependencies, and client functionality.

### Source Rules

- Source priority determines implementation authority, not search order.
- Compare relevant sources before choosing an implementation.
- Preserve existing SWGConversion functionality unless the requested conversion requires modification.
- Do not replace existing implementations solely because NGE or MTG uses a different approach.
- Maintain applicable source permissions and Source Provenance restrictions.
- Never assume source compatibility from filenames, matching APIs, or similar directory structures alone.

## ModTheGalaxy Conversion Reference

- `MTGServer` is a READ-ONLY reference containing previously converted NGE content for Core3.
- `extracted-MTG` is a READ-ONLY reference containing client assets previously adapted for PRECU/Core3.
- These references may contain only a subset of NGE content.
- Before converting NGE content from scratch, search both MTG references for an existing conversion.
- Compare MTG conversions against original NGE implementations and assets.
- Prefer proven, compatible conversion approaches over recreating equivalent functionality.
- Validate MTGServer scripts against current SWGConversion APIs, managers, and conventions.
- Validate extracted-MTG assets against PRECU formats, structures, dependencies, and compatibility requirements.
- Use swg-main and extracted-NGE to verify original behavior and identify functionality missing from MTG conversions.
- Adapt compatible MTG implementations rather than blindly copying them.
- If MTG content is incomplete, outdated, or incompatible, use original NGE references to complete or correct the conversion.
- Preserve original NGE behavior when compatible with PRECU gameplay.
- Never modify MTGServer or extracted-MTG.
- Reference access does not independently authorize importing content.

## Content Dependency Resolution

- Treat NGE content as interconnected dependency graphs rather than isolated files.
- Identify direct and transitive dependencies before conversion.
- Dependencies may include:
  - Client objects, appearances, textures, shaders, skeletons, animations, and effects.
  - Server templates, Lua scripts, C++ implementations, managers, and datatables.
  - Mobiles, creatures, NPCs, AI, loot, and equipment.
  - Conversations, quests, prerequisites, objectives, triggers, and rewards.
  - Terrain, world placements, snapshots, buildouts, cells, and containment relationships.
  - Collections, instances, dungeons, and specialized gameplay functionality.
- Check existing SWGConversion functionality before creating dependencies.
- Search MTGServer and extracted-MTG for previously converted dependencies.
- Use original NGE references to identify missing or altered dependencies.
- Prefer compatible existing dependencies over duplicate implementations.
- Preserve identifiers and client-relative paths where required.
- Detect missing references, duplicate definitions, conflicting registrations, circular dependencies, and incompatible versions.
- Do not fabricate gameplay behavior or create placeholder implementations to conceal missing dependencies.
- Report unresolved dependencies and unsupported functionality.
- Never classify content as complete while required dependencies remain unresolved.

## Reusable Conversion Strategy

- Before converting repeated content, identify common source formats, structures, and transformation patterns.
- Prefer deterministic, reusable conversion logic over manually converting large numbers of similar files.
- Use existing Core3 managers, Lua systems, templates, and registration conventions whenever possible.
- Prefer existing conversion patterns demonstrated by compatible MTG implementations.
- Preserve original source identifiers, relationships, and dependencies where necessary.
- Avoid hardcoded assumptions specific to a single NPC, quest, planet, or asset.
- Keep generated content separate from manually maintained compatibility logic when practical.
- Ensure repeated conversion does not overwrite custom changes.
- Make repeated conversions predictable and safe to rerun.
- Do not introduce duplicate conversion systems when existing Core3 mechanisms are sufficient.
- Do not create standalone conversion utilities, databases, inventories, or generated tracking files outside authorized locations without explicit permission.
- Do not generate unnecessary analysis artifacts, mock data, test files, or reports.
- Use targeted source changes rather than broad architectural rewrites.
- If a repeated incompatibility requires a common solution, prefer resolving it once rather than implementing numerous individual workarounds.

## Conversion Scope and Progression

- Convert content incrementally by functional category and dependency group.
- Establish basic client asset compatibility before relying on imported client resources.
- Prefer small complete content groups over unrelated bulk imports.
- A content group should contain all dependencies necessary for its intended functionality.
- Complete at least one representative playable content group before expanding a new conversion approach broadly.
- Identify reusable conversion patterns before scaling to additional content.
- Avoid large-scale conversions while foundational compatibility problems remain unresolved.
- Preserve existing PRECU content and gameplay while adding NGE content.
- Do not expand beyond the approved scope.
- Report systemic incompatibilities separately from individual content issues.

### Recommended Conversion Order

1. Asset compatibility and dependency resolution.
2. Client objects, appearances, equipment, mobiles, and creatures.
3. Terrain, buildings, world snapshots, buildouts, and static placements.
4. World populations, spawns, patrols, encounters, and lairs.
5. Conversations, interactions, quest infrastructure, and prerequisite systems.
6. Complete quests, objectives, rewards, and progression.
7. Collections, instances, dungeons, and specialized NGE functionality.
8. Integration and in-game validation performed by the user.

- This order is guidance, not a requirement to finish entire categories before proceeding.
- Once foundational compatibility is established, complete small playable content groups through all required stages.
- Do not perform runtime or in-game testing without explicit authorization.

## Conversion Status

Use the following states when reporting significant content conversion progress:

- `DISCOVERED` — Source content identified.
- `ANALYZED` — Dependencies and compatibility assessed.
- `BLOCKED` — Required dependency or functionality unavailable.
- `READY` — Conversion plan prepared and approved.
- `CONVERTED` — Target files created or adapted.
- `STATIC_VALIDATED` — Permitted static checks passed.
- `BUILD_VALIDATED` — Compilation/build success confirmed by the user.
- `RUNTIME_VALIDATED` — Server execution confirmed by the user.
- `GAME_VALIDATED` — Intended in-game functionality confirmed by the user.

### Status Rules

- Never classify generated content as playable simply because files exist or static checks pass.
- Never claim build, runtime, or game validation without actual verification results.
- Do not infer successful validation from the absence of reported errors.
- Record significant blockers, completed milestones, and validation outcomes in `UPDATESFULL.md`.
- Do not create separate tracking databases or files unless explicitly authorized.
- Distinguish generated, validated, blocked, and incomplete content.

## Client Asset Staging

- TRE staging root: `/home/swgemu/workspace/SWGConversion/treupdates`
- Three independent staging series:
  - `Core3_appearance_XX` — appearance assets.
  - `Core3_texture_XX` — texture assets.
  - `Core3_update_XX` — all other client assets.
- `XX` is a sequential, zero-padded number starting at `01`.
- Each series has exactly ONE active writable folder: the highest-numbered existing folder in that series.
- All earlier numbered folders are permanently READ-ONLY.
- Never modify, delete, overwrite, rename, or reorganize files in previous folders.
- Do not reopen earlier folders to fix assets. Stage corrected assets in the active folder instead.
- Preserve original client-relative paths inside staging folders.
- Never stage client assets directly under `MMOCoreORB/bin`.
- Server Lua scripts and source changes belong in `MMOCoreORB/bin/scripts` and `MMOCoreORB/src`.
- Stage only assets required for the approved conversion scope.
- Prefer referencing existing compatible PRECU assets rather than duplicating them.
- Use converted MTG assets when verified compatible and authorized.
- Never assume original NGE assets are directly compatible with the PRECU client.

### Automatic Folder Rotation

- Maximum target folder size: 100 MiB (104857600 bytes).
- Check the active folder's total size before adding assets.
- If adding assets would exceed 100 MiB, create the next sequential folder for that series.
- If an individual asset exceeds 100 MiB, place it alone in a new folder and report the exception.
- New folders become the ONLY writable folder for their series immediately upon creation.
- All previous folders become READ-ONLY immediately.
- Never rotate another series unless that series requires it.
- Do not move existing files between numbered folders.
- Use a numbered suffix greater than `99` if necessary; never reuse numbers.
- Treat the active folder as logically writable even if filesystem permissions differ.
- Never change filesystem permissions to bypass a read-only restriction.
- Never automatically delete previous staging folders.

### TRE Configuration

- Keep every existing numbered staging TRE registered in `config.lua` and `config-local.lua`, subject to verified loader requirements.
- Add new TRE archive entries to both configuration files when required, using the correct existing configuration syntax.
- Newer staging TREs must take precedence over older TREs.
- Maintain staging series order:
  1. `Core3_appearance_XX`
  2. `Core3_texture_XX`
  3. `Core3_update_XX`
- Within each series, list higher numbers before lower numbers.
- Preserve all existing base/client TRE entries.
- Verify actual TRE loading and override precedence before changing configuration.
- Follow verified loader precedence if it differs from the assumed list order.
- Never remove earlier TRE entries simply because their folders are locked.
- Creating or rotating a staging folder does not mean its TRE archive has been built.
- Do not register a staging directory as an archive unless the actual TRE archive exists and the configuration supports it.
- Never register nonexistent TRE archives.
- Distinguish planned, staged, built, and registered TRE archives.
- If a new TRE archive has not been built, report its configuration changes as pending.
- Do not change configuration files outside the approved implementation scope.

## Client Asset Compatibility

- Original NGE assets are NOT assumed compatible with SWGConversion/PRECU.
- MTG-converted assets are NOT automatically assumed compatible.
- Inspect source assets before staging.
- Compare NGE and MTG assets against existing PRECU formats, structures, versions, and conventions.
- Validate client dependencies, including referenced objects, appearances, textures, shaders, skeletons, animations, effects, and other IFF resources.
- Inspect IFF versions, chunks, data structures, and unsupported client features.
- Examine asset dependency chains rather than individual files in isolation.
- Compare original NGE assets with MTG-converted equivalents when available.
- Prefer compatible existing PRECU assets when they satisfy the required functionality.
- Prefer existing verified conversion techniques over inventing new formats.
- Adapt incompatible assets to PRECU-supported formats when possible.
- Preserve intended appearance and behavior as closely as client compatibility allows.
- Preserve original client-relative paths and filenames when compatibility requires overriding existing assets.
- Never modify original TRE archives or read-only extracted assets.
- Stage corrected assets only in the appropriate ACTIVE writable staging folder.
- Check corrected assets for server-side dependencies and compatibility.
- Do not assume an asset is compatible merely because it exists in a TRE archive.
- Do not treat successful parsing as proof of correct rendering or behavior.
- If compatibility cannot be determined statically, report validation as pending.
- If an asset requires unsupported client functionality, report the limitation before implementing major changes.
- Never modify locked staging folders. Stage corrected versions in the current active folder instead.
- Identify all TRE archives requiring rebuilding after asset modifications.

## Server and Gameplay Compatibility

- SWGConversion is the authoritative server implementation.
- `swg-main` is an original NGE reference, not a drop-in source.
- `MTGServer` is a previously converted Core3 reference, not a drop-in replacement.
- Never assume Lua, C++, screenplay, template, quest, or manager implementations are directly compatible.
- Examine equivalent functionality in SWGConversion before porting.
- Identify missing APIs, changed method signatures, incompatible structures, and missing managers.
- Adapt source implementations to existing SWGConversion APIs and conventions.
- Prefer existing Core3 gameplay systems over importing duplicate NGE systems.
- Do not overwrite existing functionality solely to match NGE behavior.
- Preserve PRECU combat, professions, skills, and gameplay unless an approved feature explicitly requires modification.
- Use client asset changes for client-side content and compatible data definitions.
- Use Core3 Lua for gameplay logic supported by existing APIs.
- Use Core3 C++ for functionality unavailable through Lua or existing server systems.
- Do not attempt to implement authoritative server behavior through client assets alone.
- Select the implementation layer based on functionality, compatibility, and maintainability.
- Implement necessary compatibility changes only in authorized SWGConversion locations.
- Avoid importing unrelated upstream changes.
- If a feature requires major architectural changes, stop and report the incompatibility before implementing.

## World and Quest Compatibility

- Treat client scenery, static server objects, interactive objects, mobiles, and spawn populations as separate conversion concerns.
- Identify original NGE terrain, world placements, snapshots, buildouts, containment relationships, cell IDs, and coordinates.
- Preserve interior/exterior relationships and building cell assignments.
- Identify server-controlled objects requiring gameplay logic or persistence.
- Detect conflicts with existing Core3 world populations and placements.
- Do not assume NGE world-placement systems directly match Core3 static spawn scripts.
- Preserve original NGE quests, conversations, prerequisites, objectives, triggers, rewards, and completion behavior where compatible with PRECU.
- Maintain quest dependency chains and progression relationships.
- Translate unsupported NGE mechanics into existing PRECU mechanics when possible without changing quest intent.
- Prefer reusable Core3 quest handlers for standard objectives.
- Implement specialized behavior only when necessary.
- Do not silently remove objectives, conditions, rewards, or interactions because Core3 lacks an equivalent.
- Report unsupported quest requirements and required server/client changes.
- Never classify a quest as fully playable until its complete objective chain and rewards have been verified in-game.

## TRE Rebuild Requirements

- Whenever client assets are added, replaced, or removed, explicitly identify every TRE archive requiring rebuilding.
- Map each modified staging folder to its corresponding TRE archive.
- Report exact archive names, not just asset categories.
- Example:
  - `Core3_appearance_02.tre` — REBUILD
  - `Core3_texture_01.tre` — REBUILD
  - `Core3_update_03.tre` — REBUILD
- Do not list unchanged TRE archives as requiring rebuilding.
- If no client assets changed, explicitly state: `TRE rebuilds: None`.
- Distinguish staged asset changes from completed TRE archive rebuilds.
- Never claim a TRE has been rebuilt unless it actually has.
- Do not automatically rebuild TRE archives without explicit user authorization.
- Report the complete rebuild list in `UPDATESFULL.md`.
- Include required TRE rebuilds in the final implementation summary.
- If new TRE archives are introduced, verify required configuration entries and loading order when those archives exist.
- Treat the 100 MiB limit as a staging-folder limit, not a guarantee of compressed TRE archive size.

## Protected Dependencies

- `MMOCoreORB/utils/engine3` submodule is immutable.
- Never edit, patch, format, replace, or generate files within it.
- Never change its submodule revision as a workaround.
- Implement source fixes outside the submodule.
- If functionality requires protected dependency changes, report the blocker rather than modifying the dependency.

## Source Provenance

- Do not import fixes or content from unauthorized projects or branches.
- `swg-main` is authorized for comparison and porting. Keep it read-only.
- `MTGServer` and `extracted-MTG` are authorized as read-only conversion references.
- Reuse source or assets only when compatible with applicable permissions and licensing.
- Develop fixes from the currently checked-out SWGConversion branch.
- Do not replace SWGConversion implementations wholesale without comparing compatibility.
- Do not import unrelated upstream changes.
- Maintain separation between original NGE assets, MTG-converted references, and SWGConversion implementation changes.

## Git Commits

- Do not create commits unless explicitly asked.
- Do not automatically stage or commit untracked files.
- `AGENTS.md` may be edited but must not be staged or committed unless explicitly requested.
- Before committing, unless verification is skipped by the user, review changes against verification records.
- Provide a concrete checklist of remaining validation (static, build, runtime, in-game).
- Wait for passing results or explicit bypass.
- Do not commit while verification is pending or failing.
- If the user requests to skip verification, proceed immediately without a checklist.
- Record verification as "skipped", not "passed".

## Building, Running, and Testing

- CRITICAL TOKEN DEFENSE: Do not automatically write unit tests, test scripts, or mock data files for generated code.
- Only write functional logic, scripts, or targeted diffs.
- Never create test files unless the user explicitly uses the phrase "write a test script for this".
- Do not compile Core3, link/install a rebuilt executable, or run `core3` (including GDB/`runUnitTests`) unless explicitly requested.
- Perform maximum permitted static validation within authorized locations.
- Static validation may include syntax checks, reference inspection, diff review, whitespace checks, and dependency verification.
- Do not represent static checks as successful build or runtime validation.
- The user is responsible for compilation, runtime testing, and in-game verification unless explicitly delegated.
- Use client asset changes for client-side content.
- Use Lua for supported gameplay functionality and C++ where necessary.
- Never create unnecessary tests or mock implementations.

## Maintaining History & Guidance

- Update this file when standing project guidance changes.
- Keep `UPDATES.md` (short, plain-language updates) and `UPDATESFULL.md` (expanded high-level history with context/reasons) current.
- Update both in the same change as an implementation.
- Distinguish committed from uncommitted changes.
- Do not present proposals as completed.
- User testing, verification results, and other user feedback belong in `UPDATESFULL.md`, never in `UPDATES.md`.
- Record required TRE rebuilds in `UPDATESFULL.md`.
- Record newly created staging folders and folder rotations in `UPDATESFULL.md`.
- Record significant conversion blockers and completed milestones in `UPDATESFULL.md`.
- Do not create history entries for routine investigation without implementation changes, meaningful decisions, or verification outcomes.
- Avoid unnecessary verbosity and repeated entries.

# Porting Workflow (NGE / MTG to SWGConversion)

## Phase 1: Analysis and Planning

1. Locate the original NGE content and relevant implementation in `swg-main` and `extracted-NGE`.
2. Search `MTGServer` and `extracted-MTG` for previously converted implementations and assets.
3. Identify corresponding functionality already present in SWGConversion.
4. Identify all direct and transitive server/client dependencies.
5. Compare original NGE behavior against existing Core3 and MTG implementations.
6. Compare client asset formats, versions, internal references, and dependency relationships against PRECU compatibility requirements.
7. Identify reusable conversion patterns and existing compatible implementations.
8. Identify missing functionality, incompatible APIs, unsupported assets, and required adaptations.
9. Determine necessary Lua, C++, client asset, world placement, quest, and configuration changes.
10. Identify proposed staging folders, expected rotations, and TRE rebuild requirements.
11. Identify blockers, unresolved dependencies, and validation limitations.
12. STOP and present a concise implementation proposal.
13. Wait for explicit user approval before modifying implementation files or staging assets.

## Phase 2: Implementation

14. Implement only the approved conversion scope.
15. Reuse compatible existing Core3 functionality and verified conversion approaches.
16. Stage required client assets in the appropriate ACTIVE writable staging folders.
17. Apply staging folder rotation when necessary.
18. Never modify previous staging folders, original TRE archives, or read-only references.
19. Create or adapt necessary Lua scripts and C++ source files within authorized SWGConversion locations.
20. Resolve approved dependencies and compatibility changes.
21. Preserve existing PRECU functionality and avoid unrelated changes.
22. Perform permitted static validation.
23. Identify exact TRE archives requiring rebuilding.
24. Identify required configuration changes and apply only those permitted by the approved scope.
25. Update `UPDATES.md` and `UPDATESFULL.md`.
26. Report implementation results, outstanding blockers, validation status, TRE rebuilds, and Git status.
27. Do not compile, run, rebuild TRE archives, or commit unless explicitly requested.

## Phase 3: User Verification

28. Wait for user-provided compilation, runtime, and in-game validation results.
29. Record verification results in `UPDATESFULL.md` when provided.
30. Investigate reported issues using the same dependency and compatibility rules.
31. Apply corrections only within authorized locations and approved scope.
32. Stage corrected client assets only in currently ACTIVE folders.
33. Identify any additional TRE rebuilds required by corrections.
34. Do not mark content fully playable until in-game verification confirms intended functionality.

# Implementation Reporting

After implementation, provide only:

- Changed server files and a brief summary.
- Client assets staged, grouped by staging folder.
- New staging folders created, if any.
- Previous staging folders now locked, if any.
- Exact TRE archives requiring rebuilding, or `None`.
- Configuration changes required or completed.
- Compatibility issues, unresolved dependencies, or blockers.
- Conversion status and validation status.
- Git status: committed or uncommitted.

Do not include lengthy explanations or unchanged file contents.
