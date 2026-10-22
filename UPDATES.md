# Project updates

## 2026-10-22 — Mos Eisley Legacy introduction (milestone commit)

- Added the first four Legacy quests, from gathering speeder parts through the mayor's acknowledgment.
- Han Solo offers the optional starting quest inside Mos Eisley's cantina, with Chewbacca beside him. Every profession is eligible without tutorial or character-level requirements.
- Newly created characters receive Han's invitation mail and a one-time Mos Eisley arrival popup with a cantina waypoint.
- Added the XP-38 quest reward, Pall's two-use customization kit, conversations, salvage interactions, and chassis guards.
- Staged PRECU client assets in three folders and registered their archives in both server configurations.
- Set archive priority to update, texture, appearance, keeping resource paths separate across those series.
- Separated Legacy conversation template registration from screenplay handlers to use Core3's mobile loader.
- Restored the steering-array camp's original scenery and building cells, with nearby Tusken groups adapted to PRECU combat.
- Corrected three camp supply-pallet client-data references and added missing XP-38 body, rider-pose, and scale mappings to the PRECU vehicle tables. Rebuild `Core3_update_01.tre` for these changes and the camp additions.
- Required snapshot, buildout, containment, and population checks whenever working on quests in `AGENTS.md`.
- Anchored Han, Chewbacca, Pall, Vourk, and the mayor at their quest contact positions, and increased the cantina Chewbacca's scale by 27%.
- Moved Vourk clear of the existing starship crafting station and updated his waypoint; saved quest waypoints now refresh when their destination changes.

- Seated Han at the requested cantina chair with Chewbacca beside him; corrected city-region lookup for arrival invitations.

- Adjusted seated Han to heading 62 degrees and Chewbacca to local (15.7, -0.9, -21), heading 26 degrees.

- Added the existing PRECU overhead interest marker to the four conversational Legacy quest contacts.

- Added opt-in player-specific completion markers for Han, Pall, Vourk, and the mayor; other NPC marker behavior is preserved.

- Excluded the local PRECU game client inspection folder from Git.
