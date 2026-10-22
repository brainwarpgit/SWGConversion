# Implementation and verification history

## 2026-10-22 — Mos Eisley Legacy introduction

Git status: uncommitted. Scope approved by the user: A Speeder For Me, Talk to Pall, Bib's Offer, and If It Helps, ending at Mayor Guh'rantt's acknowledgment.

### Implementation

- Added the Lua `LegacyMosEisley` screenplay and a small reusable CRC-journal task adapter. Existing Core3 APIs handle conversations, persistent journal state, waypoints, inventory transfers, timers, and radial interactions. A subsequent entry-point revision adds one invitation through the existing C++ character-creation welcome-mail hook; no new engine APIs.
- Original identities and task indices remain separate: `quest/speeder_quest` (9), `quest/find_majolnir` (4), `quest/tatooine_eisley_legacy` (4), and `quest/tatooine_eisley_gotomayor` (4).
- Han Solo offers the local opt-in entry in the Mos Eisley cantina's `alcove1`, with Chewbacca beside him. Vourk at approximately (3521, -4822) keeps his later Bib's Offer role and directs unstarted players to Han. Existing characters and all PRECU professions may participate. Character creation adds only the invitation mail; the PRECU tutorial, starting items, skill progression, and combat systems are unchanged.
- The original NGE level-1 metadata and Vourk's level-10 routing threshold are retained only as source reference. No level, skill-box, or profession gate replaces them. Only the approved Mayor route is implemented; direct Niko progression remains an unconverted scope boundary, not a character unlock.
- Original salvage interactions grant per-player objective credit rather than physical component items. Each checks the active objective, exact spawned source object/template, proximity, and player state. Source locations and object rotations are retained.
- Three fixed PRECU novice Tusken scavengers protect the chassis. Statistics use the existing local level-4 slaver profile, with Tusken appearance/weapons and no player-level scaling. The original NGE encounter was level 4; there is no kill-count requirement.
- Original Han/Bib communications use informational SUI message boxes. Closing a message does not advance objectives. Source delays are retained: Pall 20–22 seconds, Bib's Offer 20–21 seconds, If It Helps 5–9 seconds. Persistent deadlines and journal progress restore through the normal player login hook; logout cancels transient callbacks.
- Pall requires reaching his location and speaking to him. The kit request completes only after successful reward delivery. Inventory failures leave the final objective available for retry. Persistent reward flags prevent repeated conversation/event callbacks from paying again.
- The separate XP-38 deed/control device uses Core3 vehicle behavior. Pall's kit reuses Core3 vehicle customization with exactly two uses. The existing X31 starting gift is preserved. These four quests award no additional XP, credits, faction, or badges.
- The mayor spawns in the existing Commerce Hall mainroom, resolved by cell name from building 1279956. Static PRECU snapshot/POB inspection identifies mainroom as cell 1279960. His acknowledgment completes the fourth quest; no unconverted mayor, Niko, or pilot quests are granted.
- Adapted tutorial-only abduction/rescue claims in Vourk dialogue and the Bib's Offer journal description to the local introduction. Other in-scope original dialogue and communication text are retained.
- Startup checks require all four compatible journal task tables and all required spawns; missing data disables quest entry rather than exposing a partial chain.

### Client compatibility and staging

- New active folders: `Core3_appearance_01`, `Core3_texture_01`, and `Core3_update_01`. No older folders existed, no rotation occurred, and no previous folders were locked or modified.
- `Core3_update_01`: 38 files, 1,593,840 bytes. Four PRECU-format quest list/task pairs, quest/conversation/reward strings, minimally merged quest/object CRC tables, NPC shared templates/outfits, salvage templates, XP-38 vehicle/deed/control-device data, vehicle shaders, salvage electrical effect, and a customization-manager extension.
- `Core3_appearance_01`: nine files, 412,194 bytes. XP-38 appearance, skeletal model, skeleton, LOD, and mesh dependencies.
- `Core3_texture_01`: seven XP-38 textures, 640,112 bytes.
- The PRECU XP-38 template was discovered to contain placeholder art, despite the server already registering a vehicle template. Actual model dependencies were therefore required. MTG conversions were compared against original NGE resources and PRECU-supported format versions.
- NPC templates use PRECU schemas and existing compatible wearable resources. XP-38 audio uses existing PRECU sounds. NGE portrait communications remain unverified; the screenplay uses existing PRECU SUI instead.
- XP-38 paint support adds eight asset CRC mappings and two customization nodes to the effective PRECU customization manager. Existing records are preserved. The vehicle uses existing PRECU Luke-speeder physics declarations and the original two XP-38 paint palettes; unsupported NGE movement variables are not imported.
- Quest data targets the existing CRC journal system, not the older numeric `datatables/player/quests.iff` system. Original NGE quest-list schemas are not copied wholesale. Journal coordinate metadata uses integer-compatible values; Lua retains precise source positions.
- All staging folders must remain below 100 MiB. No original TRE, reference repository, extracted source asset, or engine3 file was modified.

### TRE rebuilds and configuration

- `Core3_appearance_01.tre` — REBUILD / initial archive build required.
- `Core3_texture_01.tre` — REBUILD / initial archive build required.
- `Core3_update_01.tre` — REBUILD / initial archive build required.

Assets are staged; no TRE archives have been built by the agent. At the user's subsequent explicit request, added all three archive names to both `config.lua` and `config-local.lua`, before `default_patch.tre`, in update/texture/appearance priority order. This request authorizes preparing the entries before the archives exist. Standing guidance now requires separate resource paths across the three series, with no appearance or texture resources in update archives. All existing base entries and each configuration's `TrePath` are preserved. Archive build and installation in the applicable `TrePath`, plus corresponding PRECU client configuration, remain pending; no matching archives were found under the configured local TRE directory during this change.

Override precedence was verified in the target source: `DataArchiveStore::loadTres` loads entries in list order, `TreeArchive::addRecord` inserts them into `TreeDirectory`, and `TreeDirectory` rejects duplicate record insertions. Therefore earlier entries take precedence over later base archives. The server also checks loose files before archives; deployment must account for any intentional loose overrides.

### Validation

- Lua syntax and source/API/task-transition review: passed, without executing gameplay code or creating test/mock files.
- Client IFF chunk bounds, resource dependencies, journal string references, CRC preservation, format compatibility comparisons, and staging size checks: passed. Existing 756 quest and 15,792 object CRC mappings remain; only four quest and nine object identities were added.
- Updated configuration priority: update, texture, appearance. Both Lua configurations pass syntax/order checks. All 54 staged resource paths are separate across series: update has no appearance/texture paths, and the appearance/texture folders contain only their respective resource categories.
- Compilation outcome is not separately confirmed. The first user-reported server run failed loading the three Legacy conversation templates; see the correction below. Corrected runtime loading, TRE archive loading, rendering, driving, customization, and in-game quest validation remain pending. The agent has not compiled or executed the server.
- Current conversion state: STATIC_VALIDATED, limited to the checks above. No claim of playable or GAME_VALIDATED status.

User verification should cover:

1. Build/install all three TRE archives in the server's configured `TrePath`, configure the client to use them, then verify startup succeeds with all four journal tables and required spawns. The server archive list entries are already added; no successful archive loading has been claimed.
2. After compiling the invitation-mail change, create a character and verify one Han invitation arrives alongside welcome mail with a usable cantina waypoint. Speak to Han in the cantina to accept with both a new and an existing character; verify all professions are eligible and the X31 starting gift is unchanged. Existing characters receive no retroactive invitation mail but may speak to Han directly.
3. Retrieve wiring, power, steering, and chassis in order. Verify wrong objects/out-of-order actions do not advance objectives; guards do not create a kill gate.
4. Receive exactly one XP-38 deed, generate the vehicle, drive it, store/recall it, and verify the correct model renders.
5. Reach Pall, receive one two-use customization kit, and verify paint changes and charge consumption on the XP-38.
6. Follow Han/Bib communications, accept Vourk's offer, speak to Mayor Guh'rantt indoors, and verify all four quests complete with no unavailable follow-up quest granted.
7. Logout/reconnect and restart between stages, including during delays; verify progress, messages, and waypoints recover without duplicate rewards.
8. Fill inventory before each item reward, confirm delivery is deferred without losing progress, then make space and retry through the quest contact.

### First-run conversation loading correction

- User-reported runtime validation: FAILED. All three Legacy conversation files raised `attempt to index a nil value (global 'ConvoTemplate')` during screenplay loading at approximately 11 seconds. This confirms a failed startup attempt, not successful build or gameplay validation.
- Cause: the new files combined conversation handlers with template construction. DirectorManager's screenplay Lua context supplies handlers and gameplay APIs; CreatureTemplateManager's separate mobile Lua context supplies `ConvoTemplate`, `ConvoScreen`, and native `addConversationTemplate` registration.
- Correction: kept handlers in `screenplays/legacy/conversations/legacy_{pall,vourk,mayor}.lua`. Moved their unchanged template/screen definitions into `custom_scripts/mobile/conversations/legacy_{pall,vourk,mayor}_conv.lua`, registered through the custom mobile `serverobjects.lua` hook before the NPC definitions. The existing mobile loader initializes the conversation base classes before this hook.
- Validation: Lua syntax, whitespace, include paths, registration names, native template fields, and loader-context separation passed static checks. Corrected runtime loading requires a user restart/rerun. No test/mock files, C++ changes, server execution, or compilation by the agent.
- TRE rebuilds: None for this correction; no client assets changed.
- Git status: uncommitted.

### Steering-array camp restoration

- Approved correction: restored the original camp around steering `(3978.75, -4795.92)`. The coherent scenery cluster ends within 123.1 metres; the 150-metre selection includes 234 missing exterior roots (226 static props and eight buildings) plus seven child cells. Unrelated Imperial scenery, collections, profession objects, and other quests were excluded.
- Staged `Core3_update_01/snapshot/tatooine.ws`, minimally merging original NGE roots into the effective PRECU snapshot from `patch_14_00.tre`. All 16,514 existing nodes remain byte-identical; original added IDs, transforms, and containment are retained, with template-name indices remapped only. IDs do not collide with any extracted PRECU planet snapshot. Existing scripted population, including nearby rockmites, is retained.
- The camp uses existing PRECU art and 106 already-registered server templates. Three required supply-pallet templates (`object/static/structure/general/shared_palette_supply_03.iff`, `_04.iff`, `_05.iff`) had misspelled `clientDataFile` references; staged minimal PRECU-format corrections from `client_shared_plalette_supply_0X.cdf` to the existing `client_shared_palette_supply_0X.cdf`. No other template fields changed. All 1,494 effective resource dependencies resolve. An unused Jawa ancestor appearance typo is overridden by each concrete tent and needs no change.
- Added 11 original buildout Tusken zealot groups, three members each: 33 new actors, separate from the existing three chassis scavengers. Group centers, headings, circular spawn radii, and per-life respawn ranges are preserved. New actors reuse the existing fixed PRECU novice combat profile without level restrictions or player scaling. Source four-metre aggression and assistance are retained; bounded Lua assistance uses native combat/line-of-sight APIs and excludes leashing actors. Native PACK assistance would reach 25.04 metres and is disabled only for the new zealots.
- Compatibility adaptations: new zealots use normal PRECU pursuit rather than importing incompatible NGE stalking behavior. Respawn delays begin after Core3 corpse cleanup rather than NGE incapacitation. Slot ownership, despawn observers, bounded spawn-point attempts, rollback cleanup, and recursion guards prevent duplicate or relayed population. Kills remain optional for salvage progression.
- Startup requires the restored camp anchor before enabling the chain. Core3's existing snapshot loader creates scenery/buildings/cells; no extra registrations, C++ changes, or server compilation are needed for this correction.
- Updated `AGENTS.md` at the user's request: every quest analysis/conversion/correction must inspect surrounding snapshots/buildouts, buildings/cells/containment, interactive objects, and populations. Required world dependencies must be included before reporting completion.
- Static validation: Lua load-only syntax, native API/lifecycle review, independent camp code review, IFF/schema/dependency checks, source placement comparison, and whitespace checks passed. Snapshot rendering, cell access, collision/pathing, Tusken combat/respawns, and salvage access require user runtime/in-game verification. Status: STATIC_VALIDATED; no agent compilation or server execution.
- Camp staging adds four files to `Core3_update_01` (42 files, 3,053,914 bytes at this revision). No appearance/texture changes, new staging folders, rotations, or newly locked folders. Both server configurations already register the required archive in the verified priority order; no configuration edits required.
- TRE rebuilds: `Core3_update_01.tre` — REBUILD. Install the rebuilt archive on server and client, then restart both. No archive was rebuilt by the agent. Git status: uncommitted.

### XP-38 reward verification — invisible generated vehicle

- User completed A Speeder For Me, received its XP-38 deed, and generated the vehicle. Targeting, entering/exiting, and storing the vehicle work, but its model is invisible. This confirms the first quest's completion/reward path and vehicle interactions; vehicle rendering FAILED in-game. It does not validate later quests, paint customization, or the complete chain.
- Investigated the effective client template, appearance/skeleton/mesh/shader dependency chain, built archive payloads, and active client TRE search priorities. The missing body mappings identified below are a confirmed static dependency gap; a successful rendering correction remains unverified in-game.
- User supplied the active client entries: `maxSearchPriority=30`; update at `searchTree_00_28`, texture at `_00_27`, appearance at `_00_26`, then default patch at `_00_25`. These entries include all three archives in the expected relative order. The response did not separately confirm a full client restart.
- Static diagnosis found the visible-body attachment mapping missing from the effective PRECU mount tables. The XP-38 skeletal appearance is the rider rig; the visible body is attached through the logical-saddle and saddle-appearance lookups. All built XP-38 appearance/texture payloads matched staging. The body art was present, but none of the four XP-38 mount-table registrations were staged or in the built update archive.
- Staged minimal PRECU-format merges in `Core3_update_01/datatables/mount`: `logical_saddle_name_map.iff` (54 to 55 rows), `saddle_appearance_map.iff` (13 to 14), `rider_pose_map.iff` (16 to 17), and `valid_scale_range.iff` (35 to 36). Each adds only its XP-38 row; existing row bytes, column definitions, and types are unchanged. Mappings connect `appearance/pv_speeder_xp_38.sat` through `lookup/speeder_xp_38` to `appearance/speeder_xp_38.apt`, the existing vehicle client data, `vehicle_landspeeder` rider pose, and compatible scale bounds.
- Used the MTG-compatible single-seat mapping to match existing PRECU/Core3 vehicle behavior; the original NGE two-seat setting is not imported. No quest progress, deed, vehicle identity, server source, appearance, or texture changes are required by this correction.
- Cleared the XP-38 root template's redundant `clientDataFile` override, matching PRECU Luke and the MTG/NGE XP-38. The saddle mapping supplies that data on the visible body, preserving the existing PRECU ownership of vehicle effects. Other root-template fields remain unchanged.
- Independent static review passed for all four PRECU table schemas, preserved baseline row bytes, appended XP-38 records, root-template field preservation, the complete body/pose/scale dependency chain, and the unchanged existing-vehicle identity. Status: STATIC_VALIDATED; corrected rendering remains unverified.
- Combined camp and vehicle staging now totals 46 files and 3,061,203 bytes in `Core3_update_01`. No new folders, rotations, or locked folders; no configuration changes required. TRE rebuilds: `Core3_update_01.tre` — REBUILD. Neither appearance nor texture archives need rebuilding. The agent has not rebuilt archives or run the server/client. Rendering remains pending user verification after deploying the updated archive, fully restarting, and recalling the existing vehicle; no quest reset is required.
- Subsequent user verification: the XP-38 appearance now works. Vehicle rendering is GAME_VALIDATED for the reported generated vehicle; the complete four-quest chain and customization remain unverified.
- User then reached the Talk to Pall waypoint but found no NPC visible at the indicated location. Pall interaction is FAILED/pending investigation; this report alone does not distinguish a missing server spawn from an invisible model or incorrect placement. Later quest progression is not validated.

### Initial quest text localization check

- User confirmed reaching Han and accepting the opening quest. A first message and waypoint were created, but the client displayed `[quest/ground/speeder_quest]:task00_comm_message_text` and `[quest/ground/speeder_quest]:task01_waypoint_name` instead of localized text. Retrieval and later progression were not yet confirmed.
- Read-only inspection of the built `Core3_update_01.tre` in the server TRE directory found the exact `string/en/quest/ground/speeder_quest.stf` entry. Its 4,311-byte payload matches staging; all 29 strings decode, including the original Han opening message and the waypoint label `Wiring`. Archive CRC/compression/MD5 checks passed. The Lua string references match existing Core3 conventions.
- User subsequently identified a probable client search-priority mistake that excluded `Core3_update_01.tre` and began retesting. Successful text resolution remains pending user confirmation; no quest reset or source workaround was applied.
- TRE rebuilds: None for this investigation. No client assets or quest logic changed.

### Steering-array camp dependency gap

- User recalled huts, buildings, and Tuskens around `(3977, -4795)`. Read-only comparison confirms the steering array sits in an NGE snapshot scrapyard/camp that is absent from the PRECU baseline. Original placement records are in `swg-main/dsrc/sku.0/sys.server/compiled/game/datatables/buildout/tatooine/tatooine_6_2_ws.tab`, including the stone hovel at `(3974.364, -4796.929)`, large Jawa tent `(3981.662, -4800.231)`, Watto-style shed `(3984.066, -4790.497)`, and nearby tent houses/ruins/debris. Most nearby MTG snapshot placements match original NGE records exactly.
- Original server buildout data also places multiple Tusken zealot groups around the camp; the nearest spawner is `(3990, -4806)`, about 15 metres from the steering array. These differ from the separate three scavengers already added at the chassis, approximately 96 metres away.
- The first conversion omitted the surrounding snapshot scenery and most camp population. This world-content gap was subsequently corrected in the camp restoration recorded above; completion of salvage objectives alone does not verify the camp environment.
- Initial recommendation was to restore the quest-area camp layout and relevant Tusken encounters, preserving existing PRECU placements and excluding unrelated nearby content. The user subsequently approved that correction; see the implementation and validation details above.
- TRE rebuilds: None for this investigation. Implementation requirements remain to be assessed before staging changes.

### Cantina entry and new-character invitation

- User feedback: a newly created character reached Mos Eisley without receiving a quest. The previous implementation intentionally required opt-in through Vourk, but lacked the requested new-player invitation. This feedback confirms character creation and travel only, not successful quest or reward validation.
- At the user's request, moved quest acceptance to a distinct noncombat Han Solo in Chalmun's cantina, with a separate noncombat Chewbacca beside him. Existing Lok Han/Chewbacca definitions are preserved. Both reuse existing PRECU models; no client asset changes.
- Static placement evidence: PRECU snapshot building `1082874`, cell `1082878` named `alcove1`. Han local position `(20, -0.895, -15)` and Chewbacca `(21.8, -0.895, -15)`, both heading 0, lie on the room's floor triangles. The target's scripted NPC placements do not occupy this cell. Runtime appearance, placement, and accessibility remain pending.
- Added separate Han template registration in the mobile loader and a Han handler in the Director screenplay context. Acceptance validates proximity to Han and retains the original quest identities, task order, rewards, and existing character progress. Vourk can no longer grant the opening quest; his unstarted-player dialogue directs players to Han.
- Added one invitation at the existing successful-character-creation welcome-mail hook in `PlayerCreationManager.cpp`. Sender: Han Solo; subject: A Speeder For Me. The attachment marks the verified exterior cantina entrance at Tatooine `(3467.8815, 5, -4852.2944)`. The body directs players farther inside to Han and Chewbacca. Existing welcome/JTL mail remains intact. This is creation-only, not a repeated login notification, and does not automatically grant a quest.
- Han's remote updates remain the existing informational SUI messages. No hologram/portrait is implemented. No evidence requires replacing those updates with repeated return-to-Han objectives, so the original quest step strings and progression remain unchanged. Only the new entry/invitation and Vourk's former starting dialogue need new server text.
- Validation: Lua load-only syntax, whitespace, conversation registration/context checks, Han-only activation, mail-overload/attachment ownership, and placement reference review passed. C++ compilation, server execution, email delivery, and in-game quest checks remain pending; none were performed by the agent. The C++ mail addition requires a user rebuild; the Lua entry changes require a server restart. Existing characters may start by speaking to Han without receiving retroactive mail.
- TRE rebuilds: None for this revision; no new staging folders, client assets, or configuration changes.
- Git status: uncommitted.

### Arrival popup and stationary quest contacts

- User feedback confirmed the original entry implementation sends mail and its waypoint but no arrival popup. Added the requested one-time informational popup for newly created characters when they first reach Mos Eisley. The quest still starts only by speaking to Han.
- Successful character creation now stores `LegacyMosEisley/arrivalInvitation=pending` alongside the existing Han email. Characters created before this revision have no marker and receive no retroactive popup. No age, level, profession, or tutorial requirement was added.
- Reused the existing Mos Eisley city region and its `ENTEREDAREA` observer. Login also checks pending invitations, covering characters already inside town. Region world coordinates include the starport and other interiors. A single five-second event rechecks location, online state, the client loading screen, death/incapacitation, combat, quest state, and chain readiness. Loading/busy or failed waypoint/SUI delivery retries while the character remains eligible in town; logout cancels the event and retains pending state.
- Added a read-only Lua binding for the existing `PlayerObject::isOnLoadScreen()` getter. This avoids displaying the popup before the client confirms scene readiness. The binding exposes the existing loading flag without changing scene-loading behavior or engine3. Native changes are limited to `PlayerCreationManager.cpp` and `LuaPlayerObject.cpp/.h`.
- A successful nonzero SUI page ID persists the shown marker. The popup adds one separately tracked active waypoint to the existing cantina entrance. Accepting Han's quest removes only that invitation waypoint and cancels any queued invitation; email attachments and quest-task waypoints are preserved. Dismissing the popup does not accept a quest or change progression.
- Increased only `legacy_chewbacca` from scale 1.0 to 1.27 through the existing creature-template scale field. This matches the original NGE Chewbacca/Han relative scale and stays within the PRECU male Wookiee scale range; the other contacts remain at scale 1.0. Existing Lok Chewbacca and all client assets are unchanged.
- User initially found no NPC at Pall's waypoint, then confirmed `/tar Pall` selects him and that he wanders. Vourk also wanders. These observations supersede the missing-spawn hypothesis. Pall's model/CDF and direct dependencies resolve; no appearance change is justified. Original NGE Pall uses behavior 1/SENTINEL, whose AI handler stops the NPC.
- Applied existing Core3 `AI_STATIC` to all five placed contacts: Han, Chewbacca, Pall, Vourk, and the mayor. They retain their intended contact positions instead of wandering beyond waypoint/interaction radii. Tusken encounters are unchanged.
- User subsequently confirmed the mayor was already standing still inside the building. His indoor placement/stationary behavior is GAME_VALIDATED for that observation; his coordinates are unchanged. The explicit static flag preserves that behavior. This does not independently verify the mayor's conversation or quest completion.
- Static validation: independent native API, SUI return/persistence, event lifecycle, city/scene-loading, waypoint ownership, NPC scale, and AI flag review passed; Lua load-only syntax and whitespace checks passed. Status: STATIC_VALIDATED. User compilation of the C++ changes and a server restart are required; no build/runtime/in-game testing was performed by the agent. Verify the popup using a character created after that rebuild.
- TRE rebuilds: None for the popup, NPC scale, or stationary-contact changes. No client assets, staging folders, rotations, or configuration changes. Git status: uncommitted.

### Vourk placement conflict and milestone endpoint

- User reported a starship crafting station at Vourk's waypoint. The original NGE Vourk location `(3520.7, 5, -4822.18)` overlaps the authoritative PRECU city's public space-crafting station at `(3520.67, 5, -4822.73)`. This conflict was missed in the earlier placement review. The station and all other PRECU placements are preserved.
- Moved Vourk and his Lua quest waypoint to `(3524, 5, -4812)`, retaining heading 20.25 degrees. Static placement checks find approximately 11.23 metres from the station center, beyond its 2.55-metre bounding sphere, and clearance from nearby building bounds, scenery, and NPC spawns. In-game accessibility remains pending.
- Updated only zero-based row 2 `LOCATION_X/Y/Z` in staged `Core3_update_01/datatables/questtask/quest/tatooine_eisley_legacy.iff` to `3524/5/-4812`, matching the new server placement. Exactly four bytes differ; all other rows, fields, schemas, task names, signals, and quest identities are preserved.
- The reusable quest runtime's waypoint cache now includes the destination planet and coordinates, so existing active quest waypoints refresh on resume/login after placement corrections. Quest/task identities, timers, progression, and rewards are unchanged; no quest reset is required.
- User reached the mayor's "I don't have another assignment available" line. Source review confirms this is the intentional endpoint after If It Helps, not a missing next quest within the approved milestone. Later mayor jobs remain outside the converted scope. This observation does not independently verify every reward/customization or journal state.
- Client staging remains 46 files and 3,061,203 bytes in active `Core3_update_01`; no new folders, rotations, newly locked folders, or configuration changes. TRE rebuilds for the combined revision: `Core3_update_01.tre` — REBUILD. No appearance or texture archive changes. The archive was not rebuilt by the agent.
- Native arrival-invitation changes require a user Core3 rebuild, followed by a server restart for stationary contacts, Vourk placement, Chewbacca's scale, and invitation logic. Deploy the rebuilt update archive to server/client and restart the client for the journal-coordinate correction. Git status: uncommitted; runtime/in-game verification remains pending for these corrections.
- Final static validation passed: three modified Lua files parse without execution, native getter declaration/registration matches the existing API, the Vourk client table parses with its original schema and unchanged non-coordinate content, destination-aware waypoint caching preserves timers/progress, and whitespace/staging size/category checks pass. Independent code/data review passed. Status: STATIC_VALIDATED; no agent compilation, server execution, TRE rebuild, or test/mock files.

### Cantina seating and arrival city lookup correction

- User tested a character created after rebuilding Core3, but no arrival popup appeared. Source inspection found getRegion only searches RegionMap ordinary regions, while Mos Eisley is registered in the separate city map. Added a fallback in DirectorManager.cpp to return a city's first underlying Region; existing ordinary-region lookup retains priority. This fixes the missing arrival trigger dependency without changing city placements or adding another area.
- Moved Han to local (14.7, -0.9, -19.8) in the existing cantina alcove, using the established npc_sitting_chair mood. Chewbacca stands beside him at (16.5, -0.9, -19.8); both remain static. Seating alignment/facing requires user in-game verification.
- Popup remains creation-marker-only, approximately five seconds after loading/busy checks permit delivery in Mos Eisley. Previously created pending characters may retry on login after the correction; characters already on the quest do not receive it.
- STATIC_VALIDATED: Lua load-only syntax, native city lookup signatures/includes, and whitespace checked. Core3 compilation and runtime/game validation pending; not performed by agent. Rebuild Core3 and restart the server. TRE rebuilds: None. No client assets, staging folders, or configuration changes. Git status: uncommitted.

### Arrival popup verified and cantina alignment refined

- User confirmed the arrival popup works: GAME_VALIDATED for the reported invitation delivery.
- At the user's requested alignment, seated Han retains local (14.7, -0.9, -19.8) and now faces 62 degrees. Chewbacca moves to local (15.7, -0.9, -21), facing 26 degrees. spawnMobile headings use degrees; chair mood and static behavior are retained.
- STATIC_VALIDATED: Lua load-only syntax and whitespace checked. Updated facing/placement awaits user in-game verification after server restart; no Core3 compilation required for this Lua-only revision. TRE rebuilds: None. No client assets, staging folders, or configuration changes. Git status: uncommitted.

### Cantina placement verification

- User confirmed Han and Chewbacca look good after the alignment revision. Their cantina placement, facing, and displayed poses are GAME_VALIDATED for this observation. No implementation or client asset changes. TRE rebuilds: None.

### Legacy quest contact markers

- Added Core3's existing INTERESTING options bit to only the four conversational custom Legacy contacts: Han, Pall, Vourk, and the mayor. Chewbacca and Tusken encounters are unchanged. Existing PRECU example: mobile/misc/imo_vledmo.lua; CreatureTemplateManager already exports the flag. No client resources or new marker system.
- This is a shared NPC interest marker, not a per-player availability/turn-in indicator; it remains after quest completion. Dynamic player-specific markers are not implemented by this revision.
- STATIC_VALIDATED: Lua load-only syntax, flag registration and target scope inspected; whitespace checked. Server restart required. Marker appearance remains pending user in-game confirmation. TRE rebuilds: None. No client assets, staging folders, configuration or C++ changes. Git status: uncommitted.

### Pall and Vourk placement verification

- User confirmed Pall and Vourk waypoints are correct and both NPCs remain stationary. Their waypoint alignment and stationary behavior are GAME_VALIDATED for this observation. No implementation changes. TRE rebuilds: None.

### Legacy milestone verification and commit

- User confirmed all work through the current Legacy quest endpoint is verified and requested a commit. The implemented four-quest milestone and its delivered corrections are GAME_VALIDATED on that confirmation, superseding earlier pending verification notes for this scope. No remaining validation checklist for this milestone; future quests and proposed per-player markers are outside it.
- Committing the approved server changes, client staging assets, and update histories. AGENTS.md is excluded under its explicit-inclusion rule; ignored config-local.lua remains local. No server/compiler/TRE build was performed by the agent. TRE rebuilds: None newly required by this verification/commit operation.
