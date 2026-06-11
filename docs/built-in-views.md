---
sidebar_position: 3
---

# Built-in Views

CameraService ships with six pre-configured views. Pass any of these names to [`:SetCameraView()`](/api/CameraService#SetCameraView) to swap to them instantly.

```lua
CameraService:SetCameraView("FirstPerson")
CameraService:SetCameraView("ThirdPerson")
CameraService:SetCameraView("ShiftLock")
CameraService:SetCameraView("Cinematic")
CameraService:SetCameraView("FirstPersonVariant")
CameraService:SetCameraView("Default") -- restores Roblox's default camera
```

## Default

Hands control back to Roblox's stock camera.

| Behavior        | Value                    |
| --------------- | ------------------------ |
| `CameraType`    | `Enum.CameraType.Custom` |
| `MouseBehavior` | `Default`                |

## FirstPerson

CameraService's version of the classic Roblox first-person view, with smoother motion. Avatar rotates with the camera. Character itself is hidden from view.

| Property              | Value   |
| --------------------- | ------- |
| `CharacterVisibility` | `"None"`|
| `Smoothness`          | `1`     |
| `Zoom`                | `0`     |
| `AlignChar`           | `true`  |
| `LockMouse`           | `true`  |
| `BodyFollow`          | `true`  |
| `Wobble`              | `0.45`  |

## FirstPersonVariant
For more grounded experiences, a first-person view that has view of the avatar's torso and limbs. Good for games where you'd want to see the player in some manner.

| Property              | Value                       |
| --------------------- | --------------------------- |
| `CharacterVisibility` | `"Body"`                    |
| `Smoothness`          | `0.35`                      |
| `Offset`              | `CFrame.new(0, 0.2, 0.75)`  |
| `LockMouse`           | `true`                      |
| `Wobble`              | `2`                         |

## ThirdPerson

A polished version of Roblox's default third-person camera, with smoothing. It also includes
slight camera wobbling response to the avatar's movements, and the character itself looking towards the current cursor position (R15.

| Property              | Value    |
| --------------------- | -------- |
| `CharacterVisibility` | `"All"`  |
| `Smoothness`          | `0.7`    |
| `Zoom`                | `10`     |
| `MinZoom` / `MaxZoom` | `5` / `15` |
| `BodyFollow`          | `true`   |
| `Wobble`              | `0.4`    |

## ShiftLock
Over-the-shoulder shift-lock with the mouse pinned to the center. The character aligns to the camera. CameraService's version of the Roblox shift-lock view.
| Property              | Value                       |
| --------------------- | --------------------------- |
| `CharacterVisibility` | `"All"`                     |
| `Smoothness`          | `0.7`                       |
| `Zoom`                | `7.5`                       |
| `Offset`              | `CFrame.new(1.75, 0.5, 1)`  |
| `LockMouse`           | `true`                      |
| `AlignChar`           | `true`                      |

## Cinematic
The camera view you might see in the demo! Cool for a cutscene view template. Silky, slow camera motion. It also comes with UI gutters animating in at the top and bottom of the screen when set and animate out when you switch away.

| Property              | Value      |
| --------------------- | ---------- |
| `CharacterVisibility` | `"All"`    |
| `Smoothness`          | `5`        |
| `Zoom`                | `10` (locked) |
| `AlignChar`           | `false`    |
| `BodyFollow`          | `false`    |
| `Wobble`              | `0`        |

## Defining your own view
Use [`:CreateNewCameraView()`](/api/CameraService#CreateNewCameraView) to register a new view. Pass a settings table; anything you leave out is auto-filled with sensible defaults.

```lua
local info = {
    Smoothness = 3,
    CharacterVisibility = "All",
    MinZoom = 15,
    MaxZoom = 15,
    Zoom = 15,
    AlignChar = false,
    Offset = CFrame.new(0, 0, 0),
    LockMouse = false,
    BodyFollow = false,
}

CameraService:CreateNewCameraView("TopDown2D", info)
CameraService:SetCameraView("TopDown2D")

-- Lock both axes for an old-school 2D feel
CameraService:LockCameraPanning(true, true, 90, 0)
```

See the full list of tweakable properties on the [`CameraService` API page](/api/CameraService).
