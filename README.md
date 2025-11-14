# Baimless UI Library

> A modern, CS2-inspired UI library for Roblox with clean design and smooth animations.

![Baimless UI](https://img.shields.io/badge/version-1.0.0-purple?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Roblox-blue?style=for-the-badge)

## Features

- **Modern Design** - Sharp corners, minimal borders, purple accent theme
- **Login System** - Credential screen with remember-me checkbox
- **Category Navigation** - Sidebar with 8 pre-built categories
- **Component Library** - Checkboxes, toggles, sliders, dropdowns, color pickers
- **Smooth Animations** - Fade-in, slide-up, shake effects
- **Clean Code** - No hallucinated functions, real Roblox APIs only

## Installation

```lua
local Baimless = loadstring(game:HttpGet('https://raw.githubusercontent.com/axzaxzz/baimless/main/src/Baimless.lua'))()
```

## Quick Start

### Show Login Screen

```lua
Baimless:ShowLogin(function(username, password)
    -- Your authentication logic
    if username == "admin" and password == "password" then
        return true  -- Proceed to main UI
    end
    return false  -- Show error (shake animation)
end)
```

### Create Main UI Directly

```lua
local UI = Baimless:CreateWindow()
```

## Categories

The library includes 8 pre-built categories:

- 🎯 **aimbot** - Aim assistance features
- ⚡ **ragebot** - Aggressive targeting
- 👁️ **visuals** - ESP and visual enhancements
- 🌍 **world** - Environment modifications
- 🎒 **inventory changer** - Item customization
- ⚙️ **misc** - Miscellaneous settings
- 💣 **grenade helper** - Projectile assistance
- 📁 **configs** - Configuration management

## Theme

### Colors

```lua
Background:  #0C0C0F (12, 12, 15)
Panel:       #1A1A21 (26, 26, 33)
Accent:      #BC46FF (188, 70, 255)
AccentSoft:  #D27BFF (210, 123, 255)
Text:        #EAEAEA (234, 234, 234)
```

### Design Language

- **Corner Radius**: 4px (sharp but not harsh)
- **Border**: 1px, subtle dark stroke
- **Padding**: 12-16px for comfortable spacing
- **Animations**: 0.25s Quad easing

## Components

### Checkbox

```lua
local section = Baimless:AddSection(window, "Settings")
Baimless:AddCheckbox(section, "Enable Feature", false)
```

### Input Field

```lua
local inputFrame = Baimless:CreateInput(parent, "placeholder", UDim2.new(0, 0, 0, 0))
```

## Animations

All animations use `TweenService` with consistent timing:

- **Fade In**: 0.3s opacity transition
- **Slide Up**: 10-15px upward motion on entrance
- **Shake**: 0.3s shake on validation errors
- **Hover**: 0.15s color transitions

## Architecture

```
src/
└── Baimless.lua     # Main library file (all-in-one)
```

The library is intentionally kept as a single file to avoid:
- Imaginary module references
- Broken require() chains
- File structure hallucinations

All functionality (Theme, Components, Animations) is embedded in the main file.

## Design Philosophy

1. **No Hallucinations** - Only real Roblox APIs and services
2. **Single Source of Truth** - One file prevents module confusion
3. **Minimal Dependencies** - Core Roblox services only
4. **Clean Visuals** - Sharp, modern, CS2-inspired aesthetic

## Support

For issues or questions, open a GitHub issue at [axzaxzz/baimless](https://github.com/axzaxzz/baimless).

## License

MIT License - Free to use and modify

---

**Created with strict no-hallucination rules** ✓