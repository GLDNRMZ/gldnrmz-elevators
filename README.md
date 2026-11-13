# gldnrmz-elevators

Configurable elevators and teleport points for FiveM. Walk up to a floor, press **E**, pick a destination from an ox_lib menu.

## ✨ Features

- Any number of elevators, each with any number of floors
- Per-floor access by job + minimum grade, items, and citizen ID
- Access is checked on the server (job, items, distance, cooldown), not trusted from the client
- Locked floors show greyed out with a lock icon (or can be hidden)
- Uses `lib.points`: no per-frame loop while you're away from an elevator
- Waits for collision to load before fading back in, so players don't fall through interiors
- Blocks use while in a vehicle, dead, cuffed, or ragdolled
- Prompt via community_bridge HelpText, ox_lib TextUI, or arp_ui
- Startup config check: warns about missing coords, single-floor elevators, and overlapping floors

## 📦 Requirements

| Dependency | Link |
|---|---|
| [OneSync](https://docs.fivem.net/docs/scripting-reference/onesync/) | enabled on the server |
| [ox_lib](https://github.com/overextended/ox_lib) (3.x) | https://github.com/overextended/ox_lib |
| [community_bridge](https://github.com/TheOrderFivem/community_bridge) **0.13.6+** ([Qbox](https://github.com/Qbox-project/qbx_core), [QBCore](https://github.com/qbcore-framework/qb-core) or [ESX](https://github.com/esx-framework/esx_core)) | https://github.com/TheOrderFivem/community_bridge |

## ⚡ Installation

1. Add your elevators to `Config.Elevators` in `config.lua` (see below). Any items used in access rules must exist in your inventory.
2. Start it after its dependencies:

```
ensure ox_lib
ensure community_bridge
ensure gldnrmz-elevators
```

## ⚙️ Configuration

Everything lives in [config.lua](config.lua).

| Option | Default | Description |
|---|---|---|
| `TextUI` | `"bridge"` | `"bridge"`, `"ox_lib"` or `"arp_ui"` |
| `WaitTime` | `2000` | Minimum ms the screen stays black during a trip |
| `DefaultRadius` | `1.0` | Interaction radius when a floor doesn't set one |
| `ShowLockedFloors` | `true` | Show locked floors greyed out instead of hiding them |
| `VersionCheck` | `true` | Check GitHub for a newer version on start |
| `Debug` | `false` | Log every trip to the server console |
| `Text` | | Prompt, menu title and error messages |

### Floors

```lua
Config.Elevators = {
    MyBuilding = {
        { coords = vec3(100.0, 200.0, 30.0), heading = 90.0, level = "Lobby", label = "Floor 0" },
        {
            coords = vec3(100.0, 200.0, 40.0), heading = 90.0, level = "Offices", label = "Floor 1",
            jobs = { police = 2 },
            items = { "office_key" },
            jobAndItem = true,
        },
    },
}
```

| Field | Type | Description |
|---|---|---|
| `coords` | vector3 | **Required.** Button location and arrival point |
| `heading` | number | Facing direction on arrival |
| `level` | string | Floor name shown in the menu |
| `label` | string | Extra text shown in the menu |
| `menuFormat` | string | `"floorTop"` (default) or `"labelTop"` to swap title and description |
| `prompt` | string | Help text when standing here |
| `radius` | number | Interaction radius |

### Access rules

A floor with no rules is open to everyone. Rules apply both to calling the elevator **from** a floor and travelling **to** it.

| Field | Meaning |
|---|---|
| `jobs = { police = 0 }` | Job name and minimum grade |
| `items = { "key_a", "key_b" }` | Any one of these items |
| `jobAndItem` | With both `jobs` and `items`: `false` = job **or** item, `true` = job **and** item |
| `citizenIDs = { "ABC12345" }` | If set, the player's citizen ID must also be in this list |

## ❗ Troubleshooting

| Issue | Fix |
|---|---|
| No prompt | Check the server console for config warnings and confirm the player meets the floor's access rules |
| Two prompts / wrong menu | Two floors overlap; the startup check names them |
| "You can't use the elevator right now" | Server thinks the player is too far away; raise that floor's `radius` |

## 📄 License

- Do not sell or redistribute for profit
- Do not remove author credit
- Modifications allowed for personal/server use
- Attribution required in all forks and derivatives

Script by GLDNRMZ. UI by [ox_lib](https://github.com/overextended/ox_lib).

<!-- gldnrmz-links -->
---

## 🔗 Links

<p align="center">
  <a href="https://discord.gg/7YHJ7774jA"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord" /></a>
  <a href="https://forum.cfx.re/u/gldnrmz/summary"><img src="https://img.shields.io/badge/Cfx.re-F40552?style=for-the-badge&logoColor=white" alt="Cfx.re forum" /></a>
  <a href="https://5metrics.dev/resources?search=gldnrmz"><img src="https://img.shields.io/badge/5Metrics-00BFFF?style=for-the-badge&logoColor=white" alt="5Metrics" /></a>
  <a href="https://gldnrmz.tebex.io"><img src="https://img.shields.io/badge/Tebex-FFD700?style=for-the-badge&logoColor=black" alt="Tebex store" /></a>
  <a href="https://www.buymeacoffee.com/gldnrmz"><img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-FF813F?style=for-the-badge&logo=buymeacoffee&logoColor=white" alt="Buy me a coffee" /></a>
</p>
