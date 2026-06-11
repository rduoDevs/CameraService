---
sidebar_position: 2
---

# Installation
CameraService is readily available for installation via **GitHub** or **Roblox Creator Store**.

## Roblox Creator Store
1. Open [this](https://create.roblox.com/store/asset/10944075148/CameraService) and click **Get Model**.
2. In Roblox Studio, open the **Toolbox → Inventory** and insert CameraService into `StarterPlayerScripts`
3. Start scripting!

## GitHub
1. Download the latest [GitHub release](https://github.com/rduoDevs/CameraService/releases/latest).
2. You may port over the `CameraService.lua` contents akin to above, or to open the adjacent `.rbxm` file to play around with the demo.

:::note What Type of Script?
CameraService is stored as a ModuleScript on Roblox.
:::

## Your First Camera
Say you're building an exhibition showcase. You want the motion to be more smooth than typical.

Add a `LocalScript` alongside (or under) the module and require it:
```lua
-- LocalScript in StarterPlayerScripts
local CameraService = require(script.Parent.CameraService)

-- Switch to first-person on join
CameraService:SetCameraView("ThirdPerson")
```

That's it — you now have a smoothed, mouse-locked first-person camera. Switch views at runtime the same way:

```lua
CameraService:SetCameraView("ThirdPerson")
-- Other options: "FirstPerson", "FirstPersonVariant", "ShiftLock", "Cinematic", "Default"
```

Tweak a property on the fly with [`:Change()`](/api/CameraService#Change):

```lua
-- Bump the smoothing up for a dreamy feel
CameraService:Change("Smoothness", 4)
```

:::caution Disabling CameraService
While a view is active, CameraService sets `cam.CameraType` to `Scriptable`. Set the view to `"Default"` to hand control back to Roblox's default camera.
:::

## Next steps

- Browse the **[built-in views](./built-in-views.md)** to see what ships out of the box.
- Skim the **[examples](./examples.md)**.
- Dig into the **[API Reference](/api/CameraService)** for every property and method.