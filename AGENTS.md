# Repository Guidelines

## Project Overview

Last Horizon is a Processing 4.5.6 Java sketch for a 2D resource-management and platform-exploration game. The player controls a technician inside a spaceship for a ten-day trip from Earth to Mars, balancing energy, oxygen, water, food, parts, morale, events, tasks, and survivor losses.

`last_horizon/` is a functional prototype, not the final art build. Before changing gameplay, vocabulary, architecture, controls, or narrative decisions, read `SESSION_START.md`. It records the current Wayfinder boundary, authority order, confirmed decisions, open decisions, and known conflicts. Do not resolve design conflicts silently.

## Architecture & Data Flow

- Processing combines all `.pde` tabs into one sketch class. The code intentionally uses flat globals, short functions, and no class hierarchy.
- `last_horizon/last_horizon.pde` owns setup, the main draw loop, global state, constants, input queues, viewport scaling, and shared rendering state.
- The frame loop is approximately: `updateViewport()` → `updateInput()` → `updateRoom()` for room screens → `drawBase()` → window/cursor rendering → `updateCapture()`.
- The base render target is a 640×360 `PGraphics`; the resizable 1280×720 window displays it with integer scaling and centered letterboxing.
- `screen` is the effective screen state. `current_room` mirrors room entry state but is not the primary screen-flow source.
- `screens.pde` renders menus, vignette, pause, victory, defeat, and modal layers, and dispatches integer `ACTION_*` commands through `doAction()`.
- `ship.pde` renders four rooms connected by physical doors plus the consult-only map overlay, and defines platforms, ladders, NPCs, stations, interaction points, and room transitions.
- `game.pde` owns the day cycle, consumption previews, resource consumption, event choices, engine state, switch effects, and end conditions.
- `tasks.pde` stores eight tasks as parallel arrays and owns the command-room briefing console, task progression, costs, and effects. Tasks remain data; `applyTaskEffect()` handles effect behavior.
- `hud.pde` renders resources, the compact next-action strip, and the footer. `ui.pde` owns modal panels, procedural portraits, buttons, AABB hit-testing, coordinate conversion, text wrapping, and cursors.
- Input is queued by Processing callbacks and consumed once per frame. Map, dialogue, technical, event, end-day, and pause layers block room movement and interaction.
- The normal flow is: reset → three-page vignette → command room → choose a task at the briefing console → traverse rooms through doors → complete one task → return to the technician's bunk in the dormitory → confirm the consumption preview → next day and modal event.

## Key Directories

- `last_horizon/` — Processing sketch source, `data/m5x7.ttf`, and generated `output/` evidence.
- `code/` — implementation architecture and runbook, especially `SKETCH_ARCHITECTURE.md`.
- `interface/` — screen flow, HUD, room layout, menus, typography, controls, and UI contracts.
- `mechanics/` — authoritative gameplay numbers and costs; `mechanics/ACTIONS.md` is the single numeric source.
- `events/` — event descriptions and alternatives; values belong in `mechanics/ACTIONS.md`.
- `characters/` — player and survivor domain descriptions; survivor records are under `characters/npcs/`.
- `history/` — narrative context and domain vocabulary.
- `assets/concept_arts/` — visual references only; the current sketch does not load these images.
- `SESSION_START.md` — mandatory session handoff, decisions, boundaries, and verification history.

## Development Commands

Run from the repository root. The supported launcher is the embedded Processing CLI:

```powershell
& "C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run
& "C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --capture
& "C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --hit-test
& "C:\Program Files\Processing\Processing.exe" cli --sketch=".\last_horizon" --run --ladder-test
```

- `--run` launches the interactive sketch.
- `--capture` walks 23 visual states and verifies navigation, map state, task selection, dialogue, one-task-per-day gating, end-day preview, events, and failure rules.
- `--hit-test` checks the four consultable room cards and letterbox coordinate conversion in a 1400×900 window.
- `--ladder-test` checks ladder exit/traversal/re-entry behavior and writes `last_horizon/output/ladder_middle_exit.png`.
- Do not substitute `processing-java`, a manually selected Java runtime, or package-manager scripts; none is confirmed for this repository. No standalone export command is documented.

## Code Conventions & Common Patterns

- Keep source identifiers and comments in English. User-facing UI and domain documents are in PT-BR.
- Preserve the flat Processing style: no unnecessary classes, inheritance, or abstraction layers; keep functions short and separate `update*` from `draw*` responsibilities.
- Use `UPPER_SNAKE_CASE` for rule constants. Rule constants in `last_horizon/last_horizon.pde` mirror `mechanics/ACTIONS.md`; update both when an approved numeric rule changes.
- Keep shared state in the existing global sections. Screens read/write the same globals rather than receiving state parameters.
- Preserve the 640×360 base canvas, `PGraphics` rendering, `noSmooth()`, `pixelDensity(1)`, integer scaling, and no-camera room layout.
- Extend tasks through the declarative arrays in `tasks.pde` and a corresponding room station. Add code in the effect dispatcher only for genuinely new effect behavior.
- Preserve the interaction invariant: movement and preparation steps are free; only the final task action charges its cost and sets `action_used`. A second task cannot be selected that day.
- Preserve one carried item across rooms and day rollover unless the domain contract changes explicitly.
- Keep final assets portable under the sketch's `data/` area. The documented future convention is one PNG per frame named `entidade_frame_N.png`, with the source `.aseprite` alongside the sketch.
- Do not treat concept-art labels such as `ARES-7` as canonical game vocabulary. Confirmed project language says the spaceship has no name.

## Important Files

- `SESSION_START.md` — read first; current decisions, Wayfinder issue boundary, authority hierarchy, and known limitations.
- `README.md` — product scope, rooms, resources, events, and win/loss conditions.
- `mechanics/ACTIONS.md` — authoritative resource ranges, costs, day-cycle rules, task gates, event consequences, and end conditions.
- `interface/FLOW.md` — screen graph, navigation, controls, and daily cycle.
- `interface/ROOMS.md` — room geometry, interaction points, task chains, and station contracts.
- `interface/HUD.md` and `interface/TEXT_FONTS.md` — persistent UI, alerts, typography, and pixel-grid constraints.
- `code/SKETCH_ARCHITECTURE.md` — tab responsibilities, state model, viewport, run commands, and known limitations.
- `last_horizon/last_horizon.pde` — sketch entry points, global state, constants, viewport, and input.
- `last_horizon/tasks.pde` — task data tables, step progression, costs, and effect dispatch.
- `last_horizon/game.pde` — daily simulation, events, consumption, and end conditions.
- `last_horizon/ship.pde` — macro map, rooms, platforms, ladders, NPCs, and interaction points.
- `last_horizon/screens.pde` — menus, vignette, pause, victory, and defeat text/rendering.
- `last_horizon/capture.pde` — capture and smoke-verification harness.
- `last_horizon/data/m5x7.ttf` — bundled pixel font used by the sketch.

## Runtime/Tooling Preferences

- Required runtime: Processing 4.5.6 in Java mode, using `.pde` tabs.
- The sketch targets 60 FPS, starts at 1280×720, remains resizable, and renders internally at 640×360.
- The only confirmed runtime dependency is Processing core plus `last_horizon/data/m5x7.ttf`. Do not add a library for the current prototype without an explicit requirement.
- Audio is not implemented. The documented future approach is offline `javax.sound.sampled` with 16-bit PCM WAV files under `data/`; do not assume OGG, float WAV, or external audio libraries work.
- There is no package manifest or package manager configuration in the repository. `.obsidian/` contains vault configuration, not build configuration.
- Final sprites and `.aseprite` sources are not present; current room/HUD visuals are procedural geometry and panels.
- For Wayfinder issue work, use the authenticated GitHub CLI when available, for example `gh issue view 1 --repo shelldonryan/gtd_example`. Verify issue state and blockers instead of trusting an old boundary paragraph.

## Testing & QA

There is no unit-test, integration-test, coverage, formatter, or linter suite. QA is provided by the versioned Processing harness in `last_horizon/capture.pde`:

- `--capture` produces 23 state screenshots and checks connected-door entry, consult-only map state, explicit briefing selection, NPC dialogue, one task per day, end-day cancellation and consumption prediction, modal events, and failure draw rules.
- `--hit-test` verifies all four map room cards and one letterbox click after window-to-base conversion.
- `--ladder-test` verifies five ladder cases: lateral exit, traversal, held vertical input not re-entering, re-arming after release, and nearby-deck snapping.
- Expected console results contain `OK`; checks print `OK/FALHOU` but do not provide a test-framework assertion aggregate or reliable failure exit code. Inspect stdout and the generated PNGs.
- `last_horizon/output/` mixes current and historical artifacts. Select the relevant recent capture set rather than assuming every PNG belongs to one run.
- The documented CLI can emit `display count needs to be implemented for non-AWT` and `AWT disabled`; these are known non-fatal warnings. Headless execution has not been validated.

Known gaps: resource limits, every event branch, every task/room combination, multiple aspect ratios, and full gameplay replays are not covered by the harness. Some victory/defeat summary fields also remain pending.

## Github
- Use gh CLI commands to manipulate issues on github.
