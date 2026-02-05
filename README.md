# gldnrmz-elevators

A standalone FiveM resource for server owners and developers, providing highly configurable elevator systems for any map or framework. Designed for performance, flexibility, and easy integration.

---

## ✨ Features

- Fully standalone; no framework dependency
- Simple, modular elevator creation via config
- Supports multiple floors, custom icons, and blip settings
- Optimized for low resource usage
- Optional integration with ox_lib for UI prompts
- Easy to extend and customize
- Debug mode for troubleshooting

---

## 📦 Requirements

| Dependency         | Required | Link                                                                 |
|-------------------|----------|----------------------------------------------------------------------|
| community_bridge  | Required | [github.com/TheOrderFivem/community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) |
| ox_lib            | Optional | [github.com/overextended/ox_lib](https://github.com/overextended/ox_lib) |

Both dependencies should be installed for full functionality. ox_lib is recommended for enhanced UI prompts.

---

## ⚙️ Installation

1. Download or clone this repository into your resources folder:
   ```
   [scripts]/[gldnrmz]/gldnrmz-elevators
   ```
2. Download and install [community_bridge](https://github.com/TheOrderFivem/community_bridge/releases) (required).
3. (Optional) Download and install [ox_lib](https://github.com/overextended/ox_lib) if you want UI prompts.
4. Add the following to your `server.cfg`:
   ```
   ensure community_bridge
   ensure ox_lib
   ensure gldnrmz-elevators
   ```
   *community_bridge must start before gldnrmz-elevators. If using ox_lib, ensure it starts before gldnrmz-elevators as well.*

---

## 🛠️ Configuration

All configuration is handled in [config.lua](config.lua). Define elevators, floors, icons, and blip settings.

**Example:**
```lua
Elevators = {
  {
    name = "Maze Bank",
    floors = {
      { label = "Lobby", coords = vector3(-75.0, -818.0, 243.0), icon = "fa-building" },
      { label = "Roof", coords = vector3(-75.0, -818.0, 300.0), icon = "fa-arrow-up" }
    },
    blip = { sprite = 357, color = 2, scale = 0.8 }
  }
}
```

- `name`: Display name for the elevator
- `floors`: Array of floor objects
  - `label`: Name shown in UI
  - `coords`: Teleport location (vector3)
  - `icon`: FontAwesome icon name (if using ox_lib)
- `blip`: (optional) Map blip settings

---

## 📘 Advanced Documentation

| Field   | Type      | Description                       |
|---------|-----------|-----------------------------------|
| name    | string    | Elevator display name             |
| floors  | table     | List of floor objects             |
| blip    | table     | Blip settings (sprite, color, scale) |

**Icon Reference:**  
Use any [FontAwesome](https://fontawesome.com/icons) icon name if ox_lib is enabled.

**Validation Notes:**  
- Ensure all `coords` are valid vector3 values.
- Blip settings are optional; omit for no map marker.

---

## ❗ Troubleshooting

| Issue                        | Cause                          | Solution                       |
|------------------------------|-------------------------------|-------------------------------|
| Elevator not showing         | Config error or missing coords | Check `config.lua` for typos   |
| UI prompt not appearing      | ox_lib not installed           | Install and ensure ox_lib      |
| Teleport fails               | Invalid vector3                | Verify coordinates             |
| Debug info missing           | Debug mode off                 | Set `Config.Debug = true`      |

---

## 📄 License / Usage Rules

- Do not sell or redistribute for profit
- Do not remove author credit
- Modifications allowed for personal/server use only
- Attribution required in all forks and derivatives

---

## 🙏 Credit

- Script by gldnrmz
- UI enhancements via [ox_lib](https://github.com/overextended/ox_lib)
- Inspired by the FiveM developer community

---

## 📑 License Footer

Attribution is required. Redistribution is permitted for non-commercial use only. Do not remove credit or sell this resource.
