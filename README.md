# Monster's Shephard

Entry for **Godot India Community Game Jam 5** — a tier-based action-survival puzzle: trigger your monsters' charges with the horn that matches their color, funnel them into sink portals for score, and take the exit portal to face the next tier.

## How it plays

- The shepherd cycles a horn — red, green, orange, purple, brown. A monster charges when it hears its own color within range
- Monsters that land in a sink portal are cleared for score (+15 / +30); portal uses are limited and tracked on the HUD
- Enter the exit portal between tiers. Three tiers, three hearts, one completion screen that tallies the run
- Menu → instructions card → the run, with an intro video at the start and pixel-sprite presentation throughout

## Run it

The full Godot project is in the repo:

1. Open [`ms/project.godot`](ms/project.godot) in Godot 4.5
2. Run the project

The original jam submission zip (`Monster's Shephard.zip`) is kept at the repo root for provenance.

## Source layout (`ms/`)

- `scenes/` — world, menu, info, HUD, stats screen, enemies, horns
- `scripts/` — game flow systems: GameManager, player, enemies, portals
- `shaders/` — toon lighting, vignette, horn/world color work
- `assets/` — pixel sprites, tileset, horn sounds and music, intro video

## Status

Complete jam build packaged as submitted — a finished three-tier loop. Early-stage tooling means it runs from the Godot editor rather than a standalone launcher.
