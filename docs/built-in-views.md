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

Hands control back to Roblox's stock camera. Useful for menus, cutscenes, or when you simply want CameraService out of the way.

| Behavior        | Value                    |
| --------------- | ------------------------ |
| `CameraType`    | `Enum.CameraType.Custom` |
| `CameraSubject` | `Humanoid`               |
| `MouseBehavior` | `Default`                |

## FirstPerson

Mouse-locked, body-hidden classic first-person. The character rotates with the camera and the head is hidden so the player doesn't see their own face.

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

An over-the-shoulder twist on first-person — the head is hidden but the body is visible, with a slight forward offset. Good for survival or horror experiences where players want to feel embodied.

| Property              | Value                       |
| --------------------- | --------------------------- |
| `CharacterVisibility` | `"Body"`                    |
| `Smoothness`          | `0.35`                      |
| `Offset`              | `CFrame.new(0, 0.2, 0.75)`  |
| `LockMouse`           | `true`                      |
| `Wobble`              | `2`                         |

## ThirdPerson

A polished version of Roblox's default third-person camera, with smoothing and a wider zoom envelope.

| Property              | Value    |
| --------------------- | -------- |
| `CharacterVisibility` | `"All"`  |
| `Smoothness`          | `0.7`    |
| `Zoom`                | `10`     |
| `MinZoom` / `MaxZoom` | `5` / `15` |
| `BodyFollow`          | `true`   |
| `Wobble`              | `0.4`    |

## ShiftLock

Over-the-shoulder shift-lock with the mouse pinned to the center. The character aligns to the camera, which is what most action games expect.

| Property              | Value                       |
| --------------------- | --------------------------- |
| `CharacterVisibility` | `"All"`                     |
| `Smoothness`          | `0.7`                       |
| `Zoom`                | `7.5`                       |
| `Offset`              | `CFrame.new(1.75, 0.5, 1)`  |
| `LockMouse`           | `true`                      |
| `AlignChar`           | `true`                      |

## Cinematic

Letterboxed, high-smoothness, fixed-zoom view used for cutscenes and trailers. Black bars animate in at the top and bottom of the screen the moment the view is set and animate out when you switch away.

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
