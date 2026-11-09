# THE ROOM IS LYING — Observation Prototype

Memorize a cozy cartoon living room. Survive the blackout. Decide whether the room changed. This version implements Phase 1 of the supplied development brief and replaces the earlier two-door clue puzzle.

## What is implemented

- A programmatically built cutaway living room with **31 recognizable environmental objects** and roughly 150 anchored parts: sofa, cushions, coffee table, books, mug, fruit bowl, TV, cabinet, speaker, bookshelf, duck, painting, clock, window, curtains, plants, chair, ottoman, floor lamp, side table, vase, basket, slippers, and trophy.
- Synchronized repeating rounds: **15 seconds memorize → 2 seconds blackout → 10 seconds vote → 5 seconds results**. All players see the same room and round timer.
- **70% changed / 30% unchanged** probability. Nine change types: disappearance, color, movement, rotation, size, appearance, tilted painting, swapped cushions, and lamp color. Difficulty increases after rounds three and seven; movement, rotation, and size changes become smaller.
- Every round restores the original transforms, sizes, colors, transparency, collision settings, and lamp color before memorization.
- Fixed observation camera. Avatars remain backstage. Landscape phones use side controls; portrait and desktop use top/bottom panels. Countdown and timer bar use server time.
- Large Changed/Unchanged buttons; keyboard **1/2** and gamepad **X/Y** also vote. Server-side round, phase, time, type, eligibility, rate, and duplicate checks protect rewards.
- Results name and outline the changed object, including a wireframe at the old location when something disappears.
- Session points, streak, best streak, total correct answers, Mind Coins, lifetime coins, XP, and levels. In-game ranks panel plus Roblox leaderstats.
- Late joiners watch the current round and enter automatically at the next memorization. Disconnects release profile/connection state.

## In your current Studio project

The upgrade was installed directly into the connected Studio experience. The earlier puzzle scripts are disabled and retained in a timestamped `ServerStorage.TRILLegacyBackup_*` folder. The Baseplate and SpawnLocation remain in the place.

Press **Play**. You do not need to paste any code. The edit-time `Workspace.TRILRoomPreview` is replaced by the live shared room when a test starts, and returns when the test stops. **Save the place with Ctrl+S** to retain the Studio edits on disk/cloud; no automated save or publication is claimed.

## Project structure

```text
ServerScriptService
  TheRoomIsLying
    Main             Script
    RoomBuilder      ModuleScript
    Anomalies        ModuleScript
    RoundRules       ModuleScript
    Tuning           ModuleScript
ReplicatedStorage
  TRILShared
    Audio            ModuleScript
StarterPlayer / StarterPlayerScripts
  TRILClient
    Main             LocalScript
    ObservationUI    ModuleScript
ServerStorage
  TRILObservationTests
    Validation       ModuleScript
```

The server creates `ReplicatedStorage.TRILNet.Vote` and `TRILState` at runtime. It stores the selected anomaly and correct answer only in server-local variables. Replicated state includes anomaly details only during Results. Geometry necessarily replicates for players to observe it; this is not protection against a modified client automatically comparing geometry.

## Installing into a different place

Create the folders and instances shown above. Paste each file from `src/server`, `src/client`, and `src/shared` into the corresponding instance. `*.server.luau` is a Script, `*.client.luau` is a LocalScript, and other `.luau` source files are ModuleScripts. Names exclude those file extensions. Use a single active server bootstrap and client bootstrap. Disable/remove the earlier `RoomUI` LocalScript and earlier server scripts so they do not run beside this version.

The room is built around `(0, 48, 0)`, with a navy diorama backdrop. Use a fresh Baseplate or check that this space is clear in an existing map. No paid assets, third-party libraries, HTTP access, API keys, DataStore access, or audio uploads are needed for Phase 1.

For Rojo, `default.project.json` maps all runtime scripts; `rojo serve default.project.json` connects a Studio Rojo plugin. An alternative is `rojo build default.project.json -o TheRoomIsLying.rbxlx`, followed by opening that file in Studio. Rojo itself was not installed or executed during this task. The direct Studio installation was tested.

## Scoring and tuning

A correct answer gives 100 points plus a capped streak bonus and 10 Mind Coins plus a streak bonus. Every fifth consecutive correct answer adds 25 extra coins. Wrong or missing answers give no points and break the streak. Spectators are not rewarded or penalized. XP increases by 25 per correct answer, with one level per 100 XP.

Defaults live in `Tuning.luau`. Optional Experience Configs can be enabled with that module's `UseExperienceConfigs` attribute; keys use the `TRIL_` prefix. Values are bounded and read at round boundaries, with defaults when the service is unavailable. This is optional and disabled initially.

For faster **Studio-only** testing, add numeric attributes to the Tuning module: `MemorizeSeconds`, `BlackoutSeconds`, `VoteSeconds`, `ResultsSeconds`, or `ChangeChance`. A server-only `ForceKind` attribute on the Anomalies module can select `None`, `Disappeared`, `Color`, `Moved`, `Rotated`, `Resized`, `Appeared`, `Painting`, `Swapped`, or `Light`. These overrides are ignored outside Studio. Remove them before normal playtesting. The installed project has normal timings and random changes restored after validation.

## Audio and later phases

`Audio.luau` contains clearly marked **silent placeholders** for ticking, blackout, success, failure, streaks, and ambience. Insert approved audio IDs you have permission to use; empty values make no asset requests. No working sound effects are claimed.

Progress currently lasts **only for the server session**. DataStore persistence, cosmetic purchases, daily challenges, achievements, more room themes, rare changes, matchmaking, game icons, and public release work remain later phases. The prototype makes no persistence calls, so Studio API access does not need enabling. DataStore saving and error/retry handling must be implemented and tested before persistent rewards are advertised.

## Validation

See [docs/VALIDATION.md](docs/VALIDATION.md) for executed checks and remaining acceptance tests. To rerun the geometry/rules tests, put `tests/Validation.luau` into the `ServerStorage.TRILObservationTests.Validation` ModuleScript. In Studio's Command Bar while stopped:

```lua
local server = game.ServerScriptService.TheRoomIsLying
print(require(game.ServerStorage.TRILObservationTests.Validation)(
    require(server.RoomBuilder), require(server.Anomalies), require(server.RoundRules)
))
```

Restart the playtest after changing modules to avoid cached require results. The test creates a detached room and destroys it when finished.
