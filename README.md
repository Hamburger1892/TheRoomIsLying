# THE ROOM IS LYING — Blackthorn Horror

A walkable, atmospheric horror observation game. Explore Blackthorn Station, meet its masked attendants, and enter a private study or a shared manor. Memorize the displays, survive the blackout, vote on whether anything disappeared, then document every missing object for extra Mind Coins.

## Installed in your current Studio project

The current Studio place contains the lobby, both map previews, and the full game scripts. **Press Play** to start in the courtyard. **Save with Ctrl+S** to retain the place edits; no automated place save or public publication is claimed.

The previous observation prototype is disabled and preserved under `ServerStorage.TRILObservationBackup_*`, including the previous preview and a lighting backup. The earlier clue-puzzle backup is also retained. Only the new bootstrap and new client scripts should be enabled.

## What to do

1. Walk around the courtyard. Hold **E** or tap a proximity prompt to speak to an NPC.
2. **The Curator** runs the shop. The **Truth Lens costs exactly 1,000 Mind Coins**. The Bellkeeper opens map selection, and the Archivist explains investigations.
3. Use the gold **Play** button at the bottom to choose a map:
   - **The Keeper's Study:** a private solo investigation, 34×32 studs, with 12 display objects.
   - **Blackthorn Manor:** a 76×62-stud map with four chambers and a central gallery, containing 26 displays. Up to three players share the investigation. The queue starts when three join or after 15 seconds; a smaller party can therefore still play. Cancel the queue with the bottom button.
4. Explore on foot and memorize what belongs on each brass stand. The study gives 30 seconds; the manor gives 40.
5. During a two-second blackout, either nothing disappears (30% chance), or several objects disappear (70%). A changed study round removes 2–4 objects; a changed manor round removes 3–6.
6. Search for 60 seconds in the study or 90 in the manor. Vote **Something Is Missing** or **Nothing Is Missing**. You can continue exploring after your answer is locked.
7. Hold E/tap at an empty display spot to report a disappearance. Every different missing object pays **75 bonus Mind Coins** immediately, once per player. Finding the same object again pays nothing. Reporting a present object pays nothing.
8. Results last eight seconds. A correct main answer pays **60 Mind Coins**, plus a capped streak bonus, and awards points/XP. Evidence bonuses are separate and are not paid twice during results.
9. Three rounds complete an investigation. You return to the lobby with a **75-coin completion reward**. Return early with the HUD button if needed; bonuses already earned stay in your wallet, but an unfinished round's answer reward is not awarded.

## Controls

| Action | Desktop | Mobile |
| --- | --- | --- |
| Walk / look | WASD; normal Roblox camera/right-drag | Roblox movement and camera controls |
| Sprint | Hold Shift | Normal movement speed |
| Interact / report an empty display | Hold E | Tap/hold native prompt |
| Flashlight | F or HUD Light button | Light button |
| Missing / unchanged vote | 1 / 2 or the large buttons | Large buttons |
| Use owned Truth Lens | Q or lens button | Lens button |
| Open map selection in lobby | P or Play | Play |

The close walking camera keeps the mouse available for UI. The flashlight follows your viewing direction. Avatars are no longer anchored spectators; they physically explore the rooms. All players in a manor visit share the same changes, but votes and evidence credit are independent.

## The Truth Lens

The shop validates your proximity, wallet, and ownership on the server. Buying with fewer than 1,000 coins is rejected; repeat purchases cannot charge again. Ownership grants a modeled magnifying-glass Tool and its HUD action.

The lens reveals whether the room changed and the number of missing objects, **once per search round**. It does not identify their locations and grants no evidence bonus automatically. It is not consumed after use. The held model briefly appears and then stows so it does not block exploration.

## Visual design

The lobby includes an aged hotel facade, towers, iron fencing, paved paths, benches, graves, masked NPCs, an antique shop, climbing ivy, bare trees, mist, a cratered moon backdrop, cloud veils, and a native star sky. The rooms use brick, stone, marble, wood, fabric, brass, wall panels, cornices, ceiling beams, framed portraits, bookshelves, furniture, and recognizable artifact displays. Realistic lighting, warm lanterns, cool window light, restrained bloom, and a flashlight establish the horror mood.

All geometry is newly authored from native parts/materials. No Toolbox scripts, third-party packages, fabricated asset IDs, paid assets, or external uploads are required. Graphics quality still depends on the player's device and Roblox quality settings. This version has no licensed ambience/music yet; no working ambient audio is claimed.

## Code structure

```text
ServerScriptService / TheRoomIsLying
  Main              Script: lobby, queue, private visits, phases, remotes, rewards
  WorldBuilder      ModuleScript: courtyard, NPCs, both maps, reset/hide, lighting
  GameRules         ModuleScript: wallet transactions, vote/find/reward rules
  Profiles          ModuleScript: live profile loading, lease, autosave, shutdown
ReplicatedStorage / TRILShared
  Settings          ModuleScript: price, reward/pacing defaults, map capacities
StarterPlayer / StarterPlayerScripts / TRILClient
  Main              LocalScript: walking camera, flashlight, controls, evidence marks
  Interface         ModuleScript: lobby, shop, selection, voting, results, blackout
ServerStorage / TRILHorrorTests
  Validation        ModuleScript: detached environment and rule checks
Workspace / TRILHorrorPreview
  Edit-time previews (removed in the playtest copy)
```

The server creates `TRILHorrorNet` remotes and runtime lobby/private visit models. The selected missing objects remain server-local until results, except the deliberate private answer revealed to a lens owner. Every display's prompt is enabled during search, not just missing ones, so prompt availability is not the answer. Geometry necessarily replicates; this is not a guarantee against a modified client comparing scene geometry automatically.

## Saving

**Studio uses an in-memory wallet intentionally. Stopping Play resets Studio test coins and purchases. No live DataStore was accessed in these tests.** This prevents tests from writing the real economy.

On published live servers, `Profiles` uses `DataStoreService` with leased records, bounded retries, serialized saves, periodic autosaves, an immediate save attempt for purchases, and a shutdown save. It stores coins, score/streak records, XP, evidence totals, and lens ownership. A failed load falls back to session progress without overwriting the old record; permanent purchases are blocked when the live saved record is unavailable. A failed purchase save is reported as pending, with later save attempts.

Live persistence has **not** been verified and must be tested in a separate test experience before release. No API/security setting was automatically changed. Never advertise guaranteed saved purchases until load, purchase, reconnect, failure, and shutdown behavior have been checked on live test servers.

## Run elsewhere / Rojo

`default.project.json` maps the server folder, shared Settings, and client folder. With Rojo installed, use `rojo serve default.project.json`, or `rojo build default.project.json -o TheRoomIsLying.rbxlx` and open the resulting place. Rojo was not installed or executed here.

Without Rojo, create the exact folders/instances shown above and paste each corresponding source file. `*.server.luau` becomes a Script, `*.client.luau` a LocalScript, and other `.luau` files ModuleScripts. Names omit file extensions. Disable earlier server/UI bootstraps. Press Play; the world is generated automatically. The lobby is centered around `(0,8,0)`; private rooms occupy separated coordinates starting around `(980,48,0)`.

## Validation and testing helpers

See [docs/VALIDATION.md](docs/VALIDATION.md) for what was actually executed and what still needs testing.

Place `tests/Validation.luau` in `ServerStorage.TRILHorrorTests.Validation` and run this while stopped:

```lua
local server = game.ServerScriptService.TheRoomIsLying
print(require(game.ServerStorage.TRILHorrorTests.Validation)(
    require(server.WorldBuilder), require(server.GameRules),
    require(game.ReplicatedStorage.TRILShared.Settings)
))
```

For local Studio QA only, attributes on the Main Script can override `MemorizeSeconds`, `BlackoutSeconds`, `SearchSeconds`, `ResultsSeconds`, and `ForceChanged`. These are ignored on live servers and have been cleared in the installed project.

A Studio-only **server BindableFunction** in `ServerStorage.TRILHorrorQA` supports temporary coin setup and state inspection. It is not a client remote and is not created on live servers. Test balances existed only in the stopped playtest and were not saved. All normal players start from their own profile balance; no free lens or 1,000-coin grant is shipped.
