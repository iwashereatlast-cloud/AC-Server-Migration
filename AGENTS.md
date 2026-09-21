# AGENTS.md — Briefing for the AI Mechanic

> Read this ENTIRE file before doing ANY work in this repo or on this server.
> If something in here conflicts with what the user asks for in chat, ask
> before acting. The user is an electronics tech, not a developer: explain
> in plain language, define any technical term the first time you use it,
> and never assume knowledge that isn't listed in the "User context" section.

## The point of all this

The server exists to be PLAYED, not managed. The owner wants a hired mechanic
(AI assistant), not a shop to run. Decisions should optimize for: less time
managing, more confidence that nothing breaks, and the owner understanding
*what* was done and *why* — in that order. Cheap, easy, done well.

## Server goals (in priority order)

1. **Run well** — stable, decent performance, single machine, Windows.
   Performance spec: worldserver tick time must stay AT or UNDER 50ms
   (the default tick length). Watch the MAX, not the average — spikes
   over 50 mean missed ticks. Measure via the WorldUpdateTime stat output.
2. **Playerbots** — the mod-playerbots module is the core of the experience.
   Load strategy: concentrate bot activity near the real player
   (RandomBotConcentrateInPlayerZone), not spread across the world —
   distant idle bots in unloaded grids cost RAM, not ticks.
3. **Current build spec: "Vanilla-plus"** — level 60 cap (MaxPlayerLevel,
   RandomBotMaxLevel), WotLK systems available by default (there is NO
   "Expansion" switch; AzerothCore is a WotLK core), power era capped at
   Vanilla by MATS GEOGRAPHY: blocked zones mean no Outland gems, no
   Northrend herbs/ink, no TBC/WotLK enchants from unreachable trainers.
   AH supports gemming/glyphs only up to what vanilla-zone mats can make.
4. **AH economy is bot-run** — ah-bot-plus RETIRED (pending removal at the
   next rebuild). Bots do the vending themselves: EnableRandomBotTrading,
   AltMaintenanceGemsEnchants, AltMaintenanceGlyphs. Era correctness comes
   from supply chains, not block lists. Expect a bootstrap period (the
   bot AH starts empty and fills over days/weeks).

## Server layout (vital facts)

- **OS:** Windows, drive `E:\`
- **Build dir:** `E:\Server Build\Build` (binaries in `bin\Release`)
- **Configs:** `bin\Release\configs\` (worldserver.conf) and
  `configs\modules\` (playerbots.conf, mod_ahbot.conf)
- **Core source:** the **Playerbots FORK** of AzerothCore
  (`mod-playerbots/azerothcore-wotlk`, branch `Playerbot`) — NOT standard
  AzerothCore. Building against the wrong core fails with hundreds of errors
- **Modules:** mod-playerbots (github.com/mod-playerbots/mod-playerbots),
  mod-ah-bot-plus (github.com/NathanHandley/mod-ah-bot-plus)
- **Build tool:** scripts/rebuild-server.ps1 — one command: stops server,
  backs up configs, pulls updates, rebuilds, merges old config values back in
- **MSVC quirk:** needs `/Zm500` compiler flag (already in the rebuild
  script) or compilation dies with heap errors
- **Data dirs:** maps/vmaps/mmaps/dbc live in `bin\Release`, enUS DBCs

## Standing orders — check BEFORE any update

When the user pulls a GitHub update or asks to update/rebuild, FIRST check
the module changelogs/releases for anything touching these CUSTOMIZED areas:

1. **Expansion / level limiting** — we hand-roll era limiting via:
   worldserver.conf (MaxPlayerLevel — NOTE: there is NO "Expansion"
   switch; AzerothCore is a WotLK core and all expansion systems are
   always on), playerbots.conf (RandomBotMinLevel/MaxLevel,
   LimitTalentsExpansion, RandomBotConcentrateInPlayerZone,
   DisableDeathKnightLogin), and classic-mode SQL (blocks Dark Portal
   to Outland, removes Northrend boats/NPCs). Config keys MUST be
   verified against conf/playerbots.conf.dist in the mod-playerbots
   repo — do not trust memory, other forks use different key names.
   If playerbots adds a NATIVE/official era-limiting feature, tell the
   user: we should adopt theirs, retire ours (to archive/), and log it.
2. **Config file structure** — our values get merged into fresh configs by
   the rebuild script (key-by-key merge, never full-file copy-paste).
   If a module renames/removes config keys we depend on, flag which of our
   settings are now dead.
3. **Era enforcement layers** — four layers, all SQL/config, no
   maintenance lists:
   a. Level caps (worldserver.conf MaxPlayerLevel, playerbots.conf
      RandomBotMaxLevel)
   b. Zone-block SQL (classic-mode up/down: blocks Dark Portal to
      Outland, removes Northrend boats/NPCs) — this doubles as the
      trainer/mat-access policy
   c. PENDING: DE-redirect SQL — level 58+ vanilla greens currently
      disenchant into TBC mats (Arcane Dust etc.). Redirect those
      item-level ranges to vanilla mats (Illusion Dust, Eternal
      Crystals). Build from what disenchant_loot_template actually
      says, not from memory.
   d. PENDING: loot-table pruning — delete TBC/WotLK gem/herb/ore/
      enchanting-mat item IDs from all *_loot_template tables, via a
      script, not by hand. Up/down pair required.
   When these SQL pairs get written, they live in sql/ as up/down pairs.
4. **Boost compatibility (Windows)** — Boost 1.87+ breaks some AC builds;
   1.78–1.83 is the known-good range. If an update requires a newer Boost,
   warn the user before building.
5. **Core/module version match** — core fork and modules MUST be updated
   together; mismatched versions cause compile errors or crashes.

After any rebuild, the assistant should report: what changed, what it means
for the above goals, and whether the current era setup survived intact.

## Rules of engagement

- Never run destructive git commands (`push --force`, `reset --hard`,
  deleting `.git`) without explicit approval
- Never modify databases without stating exactly what will change and
  getting a go-ahead
- Every meaningful change (config, SQL, structure, era switch, build) gets
  an entry in CHANGELOG.md with git commit hashes of core + modules
- SQL changes always come in up/down pairs — never apply one without
  confirming its undo partner exists
- When explaining something, one concept at a time, tied to a real file or
  task in THIS repo. The user learns by doing, not by lecture.

## Current known state

(Update this section after every significant change — see CHANGELOG.md for
the full history)

- Era: Vanilla-plus build (level 60 cap, WotLK systems on, vanilla power
  era via zone blocks) — see CHANGELOG.md
- Repo: sorted into drawers (scripts/sql/tiers/docs/archive); GitHub is the
  source of truth; Deck is the editing workbench; other machines pull-only
- Rebuild script: NOT yet tested (stage 3 pending) — do not assume it works
- ah-bot-plus: retirement decided, removal happens at first rebuild
- Era-enforcement SQL (DE-redirect, loot pruning): deferred by design
- Known good state: last "Result: working" entry in CHANGELOG.md
