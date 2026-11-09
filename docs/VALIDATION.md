# Blackthorn horror upgrade — validation

## Executed checks

- Compiled all eight Luau files through the connected Studio executor.
- Ran **809 detached checks** covering exact-price purchases, insufficient funds, duplicate purchases, vote types/rounds/deadlines, duplicate voting, multiple post-vote evidence finds, independent player records, reward breakdown, unchanged answers, both maps, display reset, reachable inspection anchors, and all three lobby NPCs.
- Started the installed game in Studio. Confirmed a walkable lobby, unanchored character, normal camera, flashlight, HUD, and all three NPC models.
- Activated the Curator through the actual E-key prompt. Insufficient funds were rejected. A temporary, server-only Studio test wallet of exactly 1,000 coins bought the lens and left zero coins; a repeat purchase did not charge again. The Tool was granted.
- Launched a solo investigation. Used Q to reveal the correct missing-object count through the owned lens. Used the actual voting button to lock a Missing answer.
- Reported **two separate missing displays after voting**, through their native prompt input. The wallet received exactly **150 bonus coins**. A duplicate report paid nothing. The correct main answer then added **60 coins**, producing **210 total** with no duplicate evidence payout.
- Launched the larger manor through its 15-second queue, with one real client. Confirmed 26 displays and walking movement. In a controlled unchanged round, the Unchanged UI vote earned 60 coins and a present-object report paid nothing. No missing targets were revealed.
- Observed three-round visit completion and its 75-coin reward, automatic lobby return, early return, and queue cancellation.
- Inspected night-lobby, interior, and sky screenshots. Adjusted the Curator's display to remove an obstructed NPC sightline, replaced round distant silhouettes, reduced lantern glare, moved entry spawns away from walls, added a shoulder camera offset, and scaled/stowed the held lens to keep the view clear.
- Inspected iPhone 17 Pro landscape and portrait layouts. Fixed the modal safe-area overflow and made long instructions scrollable. Measured that the final map selector stays inside the safe GUI area in both orientations. Studio was reset to its default viewport afterward.

Some first automated attempts reached short test voting windows too late. The controlled manor test was repeated with adequate remaining time and passed. These command assertions were distinct from game-script runtime errors. Avatar accessory asset-loading warnings appeared; the new environments and tools do not request those avatar assets.

## Final state

- Normal pacing restored: solo memorize/search 30/60 seconds; manor 40/90; two-second blackout; eight-second results; three rounds per visit.
- Normal 70% changed / 30% unchanged selection restored.
- Studio test attributes cleared. Test balances and ownership were not saved.
- The earlier prototype and lighting are retained in a disabled ServerStorage backup.
- The current Studio place contains the code and edit-time previews. Place saving/publication is not claimed.

## Not yet verified

- **Three actual simultaneous clients.** The map/queue enforce capacities 1 and 3 and player evidence records are tested independently, but a one-client test cannot establish all multiplayer behavior.
- Cross-player voting, individual evidence marks, disconnects/rejoins during creation/blackout/results, and simultaneous full-queue joins.
- Live DataStore loading, lease contention, purchase saves, reconnects, autosave failure/retry, and shutdown behavior. Studio intentionally did not access live data.
- Physical mobile/gamepad input; simulator screenshots establish layout, not hardware input.
- Long-session cleanup/soak testing, many concurrent private visits, and low-end-device performance profiling.
- Rojo build and public publication.
- Licensed ambient audio, sound mix, music, and final launch art.

## Before release

1. Run a local server with three clients. Confirm the queue never admits a fourth member and each player sees the same missing objects in a shared manor.
2. Have all three report the same disappearance. Each should be paid once; nobody should receive another person's vote or lens hint.
3. Exercise no-change rounds, duplicate/stale/deadline votes, wrong reports, respawns, early exits, and all players leaving during map creation and blackout.
4. Buy the lens with 999, 1,000, and more than 1,000 coins; repeat purchase requests; use it twice in one round and once in a new round. Verify no extra deductions or evidence awards.
5. Test saving in a separate published test experience. Confirm load failure never overwrites good data and permanent ownership survives purchase/reconnect/shutdown.
6. Run many visits and watch instance/connection counts, frame time, and light/shadow quality on a low-end phone. Tune atmosphere and lighting without making missing displays unreadable.

## Official references

- [Roblox client/server security](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/client-server-boundary.md)
- [Roblox script locations](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/locations.md)
- [Roblox Lighting API](https://create.roblox.com/docs/reference/engine/classes/Lighting)
- [Roblox Sky API](https://create.roblox.com/docs/reference/engine/classes/Sky)

No third-party gameplay code or assets were copied.
