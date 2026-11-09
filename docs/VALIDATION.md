# Validation and remaining release work

## Executed during implementation

- Compiled all nine Luau files using the connected Studio executor. The final detached validation run passed **16,786 checks**.
- Executed all nine anomalies at all three difficulties on detached geometry. Checked baseline restoration after each operation, then checked unchanged geometry.
- Executed vote validation for early, stale, malformed, deadline, spectator, and duplicate submissions; checked reward arithmetic, wrong answers, timeouts, unchanged answers, and independent profiles.
- Ran the shared game loop in Studio Play mode. The runtime built 31 recognizable objects, placed the character backstage, and created the HUD and fixed camera.
- Used the actual UI to vote Changed in a forced color-change round. The server acknowledged the vote; an attempted contradictory duplicate did not overwrite it. Results awarded 100 points and 12 Mind Coins and outlined the cushion.
- Used the actual UI to vote Unchanged in a forced unchanged round. The server revealed no change, no reveal targets, and awarded the correct reward.
- Observed automatic transitions into subsequent rounds and timeout/streak reset behavior.
- Inspected desktop, iPhone 17 Pro landscape/portrait, and iPad Pro M5 screenshots. Moved landscape-phone HUD/controls to a side column to stop them covering observation targets. The game's `StarterGui.ScreenOrientation` remains Sensor; main HUD uses CoreUISafeInsets and the blackout overlay intentionally covers the full screen. Studio returned to its default viewport after device checks.
- Restored and read back the normal 15/2/10/5 timings and 70% change probability; observed a two-second blackout with no reveal fields sent to the client.

During the first run, the initial player could spectate an empty round because Player presence preceded profile initialization. The loop now waits for initialized profiles before capturing round eligibility. A subsequent run had one eligible player in round one.

Avatar asset-loading warnings appeared in Output. The prototype's own assets are native parts; its audio IDs are empty. No prototype runtime script error was observed in the tested flows.

## Not yet established

- Actual multi-client/local-server tests, including simultaneous votes, a second client joining during each phase, and disconnects at the reward boundary. Shared server state and pure profile-isolation tests do not replace these tests.
- Long-session soak testing and low-end device performance measurements.
- Screen-reader/accessibility, physical gamepad, and physical touchscreen tests. Simulator screenshots establish layout, not hardware input behavior.
- DataStore saving: intentionally absent from Phase 1.
- Rojo build: not executed.
- Audio playback: placeholders only.
- Public publication, moderation, monetization, or release readiness.

## Before public release

1. Start a local server with at least two clients. Confirm matching round/time/room geometry and independent votes/rewards; joining mid-round must spectate until the next Memorize phase.
2. Exercise every anomaly in live multiplayer. Confirm no hints or reveal data appear before Results, and baseline geometry returns before every Memorize phase.
3. Vote at the deadline and spam duplicates/malformed/stale votes. Verify no extra rewards.
4. Reset a character, leave/rejoin during Results, and run many rounds. Verify no duplicate GUI, reward, connection, or geometry growth.
5. Test small phone, tablet, and console layouts and real input. Check each change is noticeable at its intended difficulty.
6. Add approved sound assets, then test playback permission and loading behavior.
7. Implement and validate persistence separately before promising saved Mind Coins or unlocks.

## Official source references

- [Roblox client/server security](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/client-server-boundary.md): validate client requests and keep rewards server-authoritative.
- [Roblox script locations](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/locations.md): separate server-only rules from client presentation and shared non-secret settings.
- [Plant reference architecture](https://github.com/Roblox/creator-docs/blob/main/content/en-us/resources/plant-reference-project.md): modular entry points, state replication, and UI responsibilities.

All gameplay/environment code is newly written; no third-party game code or assets were copied.
