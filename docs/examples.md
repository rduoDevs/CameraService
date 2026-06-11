---
sidebar_position: 4
---

# Examples
Drop-in snippets for common camera setups. Each example assumes you've required the module on the client:

```lua
local CameraService = require(path.to.CameraService)
```

## Cinematic intro

Recreate the bordered, drifty look used in trailers — a fixed-zoom camera with high smoothing and bumped-up FOV.

```lua
local info = {
    Smoothness = 10,
    CharacterVisibility = "All",
    MinZoom = 10,
    MaxZoom = 10,
    Zoom = 10,
    AlignChar = false,
    Offset = CFrame.new(),
    LockMouse = false,
    BodyFollow = false,
    Wobble = 3,
}

CameraService:CreateNewCameraView("Cinema", info)
CameraService:SetCameraView("Cinema")
CameraService:ChangeFOV(90)
```

## Explosion shake

Trigger a heavy shake when the player walks onto a part. [`:Shake()`](/api/CameraService#Shake) yields, so wrap it in `task.spawn` if you need to keep going.

```lua
local player = game.Players.LocalPlayer
local debounce = false

CameraService:SetCameraView("ThirdPerson")

workspace.ExplosionPart.Touched:Connect(function(hit)
    if debounce then return end
    if not (hit and hit.Parent == player.Character) then return end
    debounce = true

    task.spawn(function()
        CameraService:Shake(1, 5)
        debounce = false
    end)
end)
```

## Spinning tilt

Roll the camera 360° and back. Useful for power-up effects, vehicle barrel rolls, or stylized respawns.

```lua
CameraService:SetCameraView("ShiftLock")

-- Spin forward
for i = 1, 180 do
    CameraService:Tilt(i + 1)
    task.wait(0.1)
end

task.wait(1)

-- Unwind
for i = 180, 1, -1 do
    CameraService:Tilt(i + 1)
    task.wait(0.1)
end
```

## 2D side-scroller

Lock both axes for a fixed-angle camera. Pair with a top-down or platformer view.

```lua
local info = {
    Smoothness = 1,
    CharacterVisibility = "All",
    MinZoom = 20,
    MaxZoom = 20,
    Zoom = 20,
    AlignChar = false,
    Offset = CFrame.new(0, 0, 0),
    LockMouse = false,
    BodyFollow = false,
}

CameraService:CreateNewCameraView("SideScroller", info)
CameraService:SetCameraView("SideScroller")
CameraService:LockCameraPanning(true, true, 90, 0)
```

## Sprint FOV bump

Animate the FOV up when sprinting and back down when stopping — the simplest "speed feel" trick in the book.

```lua
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or input.KeyCode ~= Enum.KeyCode.LeftShift then return end
    CameraService:ChangeFOV(95)
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode ~= Enum.KeyCode.LeftShift then return end
    CameraService:ChangeFOV(70)
end)
```

## Vehicle follow-cam

Use [`:SetCameraHost()`](/api/CameraService#SetCameraHost) to point the camera at a vehicle part instead of the character. Reset when the player exits.

```lua
local car = workspace.Car.Chassis
local seat = workspace.Car.DriverSeat

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
    local occupant = seat.Occupant
    local player = game.Players.LocalPlayer
    local isLocal = occupant
        and game.Players:GetPlayerFromCharacter(occupant.Parent) == player

    if isLocal then
        CameraService:SetCameraView("ThirdPerson")
        CameraService:SetCameraHost(car)
        CameraService:Change("Zoom", 20)
    elseif not occupant then
        CameraService:SetCameraHost() -- back to character
    end
end)
```

:::tip Share your snippet
Got an interesting use case? Open a PR against the [repo](https://github.com/rduoDevs/CameraService) and it might land here.
:::
