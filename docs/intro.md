---
sidebar_position: 1
---

# Introduction

**CameraService** is a beginner-friendly, fully customizable alternative to Roblox's default camera system. It ships as a single `ModuleScript` you drop on the client — require it, pick a view, and you have first-person, shift-lock, cinematic, and dynamic-wobble cameras at your fingertips.

Originally released in September 2022, CameraService is used by **1,000+ Roblox developers** in shipped games, plugins, and game-jam projects.

## What you get

- **Five built-in views** — `FirstPerson`, `FirstPersonVariant`, `ThirdPerson`, `ShiftLock`, and `Cinematic` — plus the ability to define your own.
- **Smooth motion** via linear interpolation and damping, replacing Roblox's stiff default movement.
- **Effects** like screen shake, axis tilt, dynamic wobble, and animated cinematic letterboxing.
- **Pan locking** on the X/Y axes for 2D side-scrollers and fixed-angle games.
- **Cross-platform input** that handles PC, console, mobile, and tablet for you.

## Quick example

```lua
local CameraService = require(path.to.CameraService)

CameraService:SetCameraView("Cinematic")
CameraService:ChangeFOV(90)
CameraService:Shake(0.5, 3)
```

## Next steps

- Follow the **[Installation guide](./installation.md)** to drop the module into your game.
- Browse the **[built-in views](./built-in-views.md)** to see what ships out of the box.
- Skim the **[examples](./examples.md)** for drop-in recipes.
- Dig into the **[API Reference](/api/CameraService)** for every method and property.

:::note Client-side module
CameraService manipulates `workspace.CurrentCamera` for the local player, so it must run on the client. Place it somewhere a `LocalScript` can `require` it — `StarterPlayerScripts` is the typical home.
:::
