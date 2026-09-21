# AC-Server-Migration

Home of all scripts, configs, and docs for my AzerothCore + playerbots server.
Read AGENTS.md before doing any work here.

## Layout
- scripts/   — do-a-job files (rebuild, start/stop, tier switchers)
- sql/       — database changes, always in up/down pairs, never separated
- tiers/     — era settings lists (Vanilla / TBC / WotLK)
- docs/      — knowledge files (guides, how-tos, notes)
- archive/   — retired tools, kept with a note on what replaced them

## The rules
- GitHub is the source of truth. Pull before editing, push when done.
- Every meaningful change gets a CHANGELOG.md entry.
- SQL always comes in up/down pairs.

## Quick start
- Rebuild the server: scripts/rebuild-server.ps1
- Current era: see CHANGELOG.md latest entry
