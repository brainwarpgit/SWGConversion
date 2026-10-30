# SWGConversion project instructions

## Authority and workspace

- Convert original NGE content to Core3 while preserving PRECU combat, professions,
  skills, progression and balance. Target PRECU 14.1 with compatible client assets.
- Writable target: `/home/swgemu/workspace/SWGConversion`, on its selected branch.
  Inspect current Git changes before work and preserve existing conversion work.
- Read-only original source: `/home/swgemu/workspace/swg-main` (including its
  nested repositories); original assets: `/home/swgemu/workspace/extracted-NGE`.
- Read-only compatibility references: `/home/swgemu/workspace/MTGServer` and
  `/home/swgemu/workspace/extracted-MTG`. Check relevant exact and analogous
  conversions, but use original NGE sources to establish intended behavior.
- Read-only client baseline: `/home/swgemu/workspace/extracted-PRECU/precu` and
  `/home/swgemu/workspace/tre`; original workspace ZIP archives are also read-only.
- Stay out of all old repositories and archived checkouts. Do not browse, search,
  read, copy from, modify or recover data from them, including through symlinks or
  broad filesystem searches. Use only the current target and the explicitly listed
  source, compatibility and client references above. If required information is
  unavailable within these boundaries, report the gap rather than accessing an
  old repository.
- Keep `MMOCoreORB/utils/engine3` and its submodule revision unchanged. Respect
  source permissions/licensing; do not import unrelated projects or upstream fixes.

## Small, complete slices

- Broad requests such as “convert this planet” require bounded, independently
  testable items. Select one item and its necessary dependencies at a time.
- Prefer a small playable end-to-end interaction over disconnected assets or
  unfinished scripts. Existing content needing no change is not conversion work.
- Do not expand scope silently. Record discovered work separately in the tracker;
  explain dependencies before touching unrelated systems. Avoid unrelated cleanup,
  broad refactoring, mass regeneration and replacement of working systems.

## Investigate before implementation

- Establish the source implementation, existing target behavior, actual conversion
  gap, direct/transitive server and client dependencies, and acceptance tests.
- Trace relevant scripts, data, dialogue, prerequisites, objectives, rewards,
  registrations, assets and world context; do not infer behavior from names.
- Check placement, terrain, cells, access, regions and surrounding content where
  they affect the selected interaction. A created file is not proof of registration,
  asset availability, client compatibility or correct placement.
- Reuse existing Core3 systems. Different internals may preserve original behavior;
  do not create a duplicate system or silently omit branches or functionality.
- For incompatibilities, investigate supported approaches and explain evidence,
  realistic options and tradeoffs. Do not invent requirements or substitute an
  unrelated feature simply to finish. Player-facing behavior changes and substantial
  shared-engine changes require user approval before implementation. Record approved
  adaptations and reasons on the item. Ask a focused question when investigation
  cannot resolve uncertainty affecting correctness.

## Protect work and verify honestly

- Never discard user changes, reset the repository, delete existing conversion
  work, stage/commit or push without explicit permission. Keep diffs reviewable.
- Preserve existing staged assets and archives; do not mass regenerate or deploy
  them. Identify exact required TRE rebuilds when assets change, or report None.
- The user handles all building and testing. Codex must not build, compile, link,
  install, start or run Core3/SWGConversion, including through wrappers, containers,
  GDB or test executables. Codex must not build TRE archives or perform runtime or
  in-game tests. Inspect source and review diffs; provide build/test instructions
  for the user instead of executing them. Do not create unnecessary tests or mocks.
- “Code written,” “build passed,” and “works in-game” are separate claims. Report
  exactly what ran and who observed results; never infer in-game success.
- Only mark Verified when the item's complete acceptance criteria have supporting
  in-game results approved by an admin. Record limitations and tested revision. Invalidate affected
  verification after changes that could invalidate a test; retain earlier results.

## TRE updates and asset staging

- All new, converted or copied client assets from NGE, MTG or Codex-created content
  must be staged under `/home/swgemu/workspace/SWGConversion/treupdates`, preserving
  their client-relative resource paths. Use these separate staging series:
  - `/home/swgemu/workspace/SWGConversion/treupdates/Core3_appearance_01`:
    appearance assets.
  - `/home/swgemu/workspace/SWGConversion/treupdates/Core3_texture_01`:
    texture assets.
  - `/home/swgemu/workspace/SWGConversion/treupdates/Core3_update_01`:
    all other client assets.
- Each resulting TRE archive must be no larger than 100 MB (100,000,000 bytes).
  Track the total staged bytes in each folder conservatively; before an addition
  would exceed that budget, continue that series in its next numbered folder
  (`02`, `03`, etc.). Do not treat 100 MB as a per-resource allowance or split an
  individual resource arbitrarily. Report oversized resources or archive overhead
  concerns to the user, who builds and checks the final archive sizes.
- Use the highest-numbered active folder in each series for new work. Preserve
  earlier numbered folders and archives; do not silently replace their contents.
- TRE files must also remain under the specified `treupdates` staging root, with
  the corresponding series name (for example, `Core3_update_01.tre`). Codex must
  not build, move or deploy them into the game/client TRE directories.
- In the effective TRE list in `MMOCoreORB/bin/conf/config.lua` or its
  `config-local.lua` override, higher numbers take priority within each series.
  Series priority is **update, then texture, then appearance**, highest priority
  first. For example: update_02, update_01, texture_02, texture_01,
  appearance_02, appearance_01, followed by the applicable base archives.
- Report staging folders changed, rotations and exact TRE archives the user needs
  to rebuild. Staged resources are not built or deployed archives.

## One simple tracker

- The conversion tracker is the sole source of truth for progress; this file is the
  source of truth for workflow. Do not create competing planning/progress documents.
- Inspect and reuse any existing tracker in the current target before changing it.
  If none is available, report that gap and propose a minimal next step; do not
  search old repositories for tracker code or data. Do not overwrite databases,
  feedback, audit trails or backups.
- Use one stable record per meaningful independently testable change, not per file,
  edit or test step. Keep ordinary fixes and notes on that same item.
- Use one visible status: Planned, In progress, Ready to test, Needs fixes, Verified.
  Keep build/commit references as evidence, not competing progress systems.
- Each item needs ID/title, planet/area, type, intended behavior, dependencies or
  blockers, source and change references, numbered in-game steps with expected
  results, notes/adaptations, and append-only test results (tester, date, tested
  build/revision, Pass/Fail and comments). Feedback must not overwrite requirements.
- Keep the list uncluttered, with search and planet/type/status filters; details and
  test steps belong on the item page. Testers should open Ready to test, select an
  item and submit Pass/Fail with comments. Preserve existing authentication,
  authorization and review protections when simplifying; do not expose secrets.
- Use game accounts for login; game admin level 15 grants tracker administration.
  Regular users may submit test evidence and bug reports, but only admins may edit
  items or approve submissions. Pending submissions never mark work completed.
  Browser game-account registrations activate immediately at admin level 0.
- No dashboards, elaborate hierarchies, speculative features or planet-wide
  inventories without demonstrated need and authorized scope.

## Session continuity

- Start by reading this file, inspecting Git changes and reading the selected
  tracker item; do not rely on prior chat context. Before editing, briefly state
  the item, intended changes and acceptance criteria.
- End by updating that same item with changes, checks, results, limitations and the
  next concrete action. If tracker access is unavailable, report the specific
  failure and handoff in chat; do not claim progress was synchronized.
- No tracker migration or gameplay change is authorized by this file.
