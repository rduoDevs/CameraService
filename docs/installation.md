---
sidebar_position: 2
---

# Installation

CameraService is a single `ModuleScript`. There are two easy ways to get it into your game.

## Option 1 — From GitHub

1. Grab the latest [`CameraService.lua`](https://github.com/rduoDevs/CameraService/blob/main/CameraService.lua) from the repo.
2. In Roblox Studio, insert a `ModuleScript` into `StarterPlayer → StarterPlayerScripts`.
3. Rename it to `CameraService` and paste the source in.

## Option 2 — From the Roblox Library

Grab the model directly from the [DevForum thread](https://devforum.roblox.com/t/cameraservice-a-new-camera-for-a-new-roblox/1988655) and drag it into `StarterPlayerScripts`.

## Your first camera

Add a `LocalScript` alongside (or under) the module and require it:

```lua
-- LocalScript in StarterPlayerScripts
local CameraService = require(script.Parent.CameraService)

-- Switch to first-person on join
CameraService:SetCameraView("FirstPerson")
```

That's it — you now have a smoothed, mouse-locked first-person camera. To switch views at runtime:

```lua
CameraService:SetCameraView("ThirdPerson")
-- or "FirstPerson", "FirstPersonVariant", "ShiftLock", "Cinematic", "Default"
```

Want to tweak something on the fly? Use [`:Change()`](/api/CameraService#Change):

```lua
-- Bump the smoothing way up for a dreamy feel
CameraService:Change("Smoothness", 4)

-- Or temporarily lock the mouse to the center
CameraService:Change("LockMouse", true)
```

:::caution Camera control
CameraService takes over `cam.CameraType` and sets it to `Scriptable` while a view is active. Set the view to `"Default"` to release control back to Roblox's stock camera.
:::
