# The Room Is Lying

A first playable Roblox prototype: inspect three chatty props, catch the liar, and pick the safe exit in a bright cartoon room. Two props tell the truth and one lies. The majority points to the safe door. Solve three rounds, then use the Encore button to replay.

This first puzzle is intentionally simple so the interaction loop is easy to evaluate. All three rounds currently use the same room and rule with randomized answers and liar positions. New puzzle types, room layouts, animations, sound, and a narrative reveal are future work.

## Open in Roblox Studio (no extra tools)

1. Create a fresh **Baseplate** place in Studio. Open **Explorer**, **Properties**, and **Output**.
2. Under `ServerScriptService`, create a **Folder** named `TheRoomIsLying`.
3. Inside that folder create these instances, and paste the corresponding files into their Source:

   | Instance name | Instance type | Source file |
   | --- | --- | --- |
   | `Main` | Script | `src/server/Main.server.luau` |
   | `Puzzle` | ModuleScript | `src/server/Puzzle.luau` |
   | `RoomBuilder` | ModuleScript | `src/server/RoomBuilder.luau` |

   Leave `Main.RunContext` as **Legacy** (the default); its location makes it run on the server. Keep exactly one copy of Main.
4. Under `StarterPlayer > StarterPlayerScripts`, create a **LocalScript** named `RoomUI` and paste `src/client/RoomUI.client.luau`. A LocalScript does not have a RunContext property.
5. Press **Play**. The server creates `Workspace.TRILRooms` and moves your character into your room. Use **E**, **gamepad X**, or tap/click a prompt to inspect props and choose an exit. The HUD provides the rule, notebook, and result; the notebook can be collapsed on small screens.
6. Inspect Tick Tock, Fernando, and Smug Portrait. Pick the exit named by two of them. A wrong answer keeps the same clues and allows a retry after two seconds. A correct answer starts the next round after two seconds. After round three, use the Encore button near the doors.
7. Stop the playtest before editing scripts. Runtime rooms disappear when the test stops. No asset uploads, HTTP access, API keys, data stores, or paid plugins are required.

The room floor is at Y=48, clear of a default Baseplate. Use a fresh place to avoid overlap with an existing map. For a published prototype, configure **Max Players to 12 or fewer**; the script has twelve room slots and refuses additional joins. Progress lasts only for the current session.

## Optional Rojo workflow

`default.project.json` maps the same instances and includes the test ModuleScript in `ServerStorage.TRILTests.PuzzleSpec`. With Rojo installed, run `rojo serve default.project.json` and connect Studio's Rojo plugin to the local server. Alternatively, build a place with:

```sh
rojo build default.project.json -o TheRoomIsLying.rbxlx
```

Open the generated place in Studio and press Play. The Rojo build path has not been executed during this review; the manual Studio setup above does not depend on Rojo.

## Code to review

| File | Responsibility |
| --- | --- |
| `Puzzle.luau` | Pure puzzle rules: exactly one liar, unique clue discovery, exit gating, and answer evaluation. Answers stay in server-only storage. |
| `RoomBuilder.luau` | Detached, anchored room geometry, bright primitive props, labeled exits, six native interaction prompts. Can later be replaced by cloned artist-authored templates without changing puzzle rules. |
| `Main.server.luau` | Per-player rooms and rounds, server validation, action cooldown, delayed transitions, respawn positioning, replay, disconnect cleanup. |
| `RoomUI.client.luau` | Client HUD and notebook driven by a complete server snapshot in one player attribute. Connects before reading the initial value, so a late client still renders current state. |

Interactions verify room ownership, live character, enabled prompt, distance, visibility, phase, and a 0.25-second cooldown. Round resolution locks before scheduling a transition. Delayed work verifies the original session/version; leaving a server cannot advance a replacement session. Clients never send an answer or choose which room/prompt the server processes.

Native prompts are used for built-in keyboard, gamepad, and touch support. Geometry and enabled prompts replicate to clients; these are not secrets. The safe answer and undiscovered clue contents stay in server session tables. Discovered notebook contents are sent as a player attribute, which is replicated and is **not private from other clients**. Separate rooms isolate progression and interactions, not visual or network secrecy.

## Validation

See [docs/REVIEW.md](docs/REVIEW.md) for inspected GitHub sources, results, limitations, and the manual acceptance checklist.

To rerun puzzle tests with the manual setup, create a ModuleScript named `PuzzleSpec` inside `ServerStorage > TRILTests` and paste `tests/Puzzle.spec.luau`. In Studio's Command Bar, while stopped, run:

```lua
print(require(game.ServerStorage.TRILTests.PuzzleSpec)(require(game.ServerScriptService.TheRoomIsLying.Puzzle)))
```

Expected: `Puzzle: 93 assertions passed across all six puzzle configurations`. The tests cover the two exits crossed with all three liar positions, clue uniqueness, incomplete notebooks, invalid indices/exits, retry state, and session isolation. Rerun after changing puzzle logic; restart Studio's test session to clear cached module results as needed.
