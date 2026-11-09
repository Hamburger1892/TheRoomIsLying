# Prototype review — November 8, 2026 (America/Phoenix)

## Repository inspection

Inspected [Hamburger1892/TheRoomIsLying](https://github.com/Hamburger1892/TheRoomIsLying) directly after its URL was supplied. The initial `main` head was [`310b908`](https://github.com/Hamburger1892/TheRoomIsLying/commit/310b9081305f2aa125ea9b96bb39ea766c9112ca), containing only a title README. There were no gameplay scripts, existing pull requests, issues, or Actions runs at inspection time. There was no existing application code to reuse or repair.

The initial installed-repository listing returned no repositories, and scoped account search returned a GitHub 422 visibility/search error. Direct repository access subsequently succeeded with push permission. Those discovery failures were not CI failures.

## Reuse and improvements

The implementation is newly written Luau. These official source references informed its patterns; no third-party game code or assets were copied:

- [Roblox proximity-prompt framework](https://github.com/Roblox/creator-docs/blob/main/content/en-us/ui/proximity-prompts.md): native prompts provide input hints for keyboard, gamepad, and touch. This prototype connects only its registered prompt objects to server callbacks, avoiding one script per prop.
- [Roblox client/server security guidance](https://github.com/Roblox/creator-docs/blob/main/content/en-us/scripting/security/client-server-boundary.md): a prompt's client-visible settings are insufficient authorization. Added ownership, phase, health, anchored target, distance, obstruction, and rate checks around progression.
- [Plant reference architecture and UI](https://github.com/Roblox/creator-docs/blob/main/content/en-us/resources/plant-reference-project.md): reused the architectural idea of small modules with one server and one client entry point. A complete replicated attribute snapshot keeps the HUD synchronized for late startup and respawns without an extra networking dependency.

`RoomBuilder` can later clone Studio-authored room templates for easier art iteration. Keep `Puzzle` independent of geometry and keep its answer state server-only. A larger UI can become an artist-authored StarterGui template while retaining the snapshot renderer. Additional room types should provide new puzzle rules rather than only recoloring this majority puzzle.

## Validation performed

- All five Luau files compiled through the connected Studio's Luau executor. This is a syntax check, not a Script Analysis/typecheck or full playtest.
- All **93 puzzle assertions passed**, covering all six puzzle configurations and state isolation.
- Detached `RoomBuilder` execution passed checks for anchored geometry, three clues, two doors, disabled initial replay, six prompts, prompt ranges/visibility, no answer attribute, and non-queryable decorative parts. Test objects were destroyed; the open place was not modified.
- Detached UI execution passed actual instance/property construction plus initial snapshot, notebook, win-state, and invalid-JSON rendering checks. A fake player supplied snapshots; these checks do not establish on-screen layout or live replication behavior.
- The Rojo project JSON was parsed locally, and all source paths were checked.

No failing project checks were present at initial inspection because the repository had no check runs or Actions workflows. This change does not add a CI workflow. Studio validation above was run during preparation and is not a GitHub check badge.

## Playtest still required

The existing open Studio document was named `Place1` and was not confirmed as this project. It was not modified, started, or published. Full server/client play, Script Analysis, UI visuals, gamepad/touch behavior, and Rojo build remain unverified.

In a fresh place, use this acceptance checklist before merging/publishing:

- [ ] Press Play: one room appears, character stands on its floor, HUD shows room 1 and zero clues, and Output/Script Analysis show no errors.
- [ ] Inspect each prop: notebook updates once per distinct clue; repeat inspection does not increase the count.
- [ ] Choose an exit before all three clues: the door is rejected with notebook feedback.
- [ ] Choose the minority exit after three clues: a two-second failure result appears, progress stays on the same round, and clues remain available for retry.
- [ ] Choose the majority exit: only one round advance occurs, the notebook clears, and the next puzzle begins.
- [ ] Solve three rounds: win message appears, clue/door interactions stop, Encore starts round one with an empty notebook.
- [ ] Reset character in both exploration and resolution: character returns to its own room; HUD and current puzzle survive.
- [ ] Test with two Studio clients: distinct rooms, independent notebooks/progression, no interactions with the other player's room. Leave/rejoin during a transition and verify cleanup and slot reuse.
- [ ] Test phone portrait/landscape and gamepad: read labels and feedback, collapse/expand the notebook, and activate all six prompts. Check text at small screen sizes.
- [ ] Stop and Play again: one server bootstrap and one HUD, no leftover rooms or duplicate listeners.

This is a three-round demonstration of one puzzle mechanic. It has no saved progress, matchmaking, monetization, sound, commissioned art, or automated end-to-end gameplay coverage.
