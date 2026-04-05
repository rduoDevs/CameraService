--\\----- [EXAMPLES FOR CAMERASERVICE] -----//--
--[[
	Script for the demo place, showcasing how one can use CameraService.
	By @Lugical
--]]

local CameraService = require(script.Parent:WaitForChild("CameraService"))

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local ui = playerGui:WaitForChild("ScreenGui")
local uiButton = ui.TextButton
local function resetToNormal()
	uiButton.Visible = false
	game.Lighting.DepthOfField.Enabled = false
	game.Lighting.ColorCorrection.Saturation = -0.2
	game.Lighting.ColorCorrection.Contrast = 0.2
	CameraService:LockCameraPanning(false, false)
	CameraService:ChangeSensitivity(1)
	if player.Character then
		player.Character.Humanoid.WalkSpeed = 16
	end
	CameraService:ChangeFOV(70, false)
end


CameraService:SetCameraHost()
CameraService:SetCameraView("ThirdPerson")
resetToNormal()

--[[ 2D platformer
local info = {
	Smoothness = 3,
	CharacterVisibility = "All",
	MinZoom = 15,
	MaxZoom = 15,
	Zoom = 15,
	AlignChar = false,
	Offset = CFrame.new(0,0,0),
	LockMouse = false,
	BodyFollow = false
}

CameraService:CreateNewCameraView("2D_test", info) --> Uses info to create a new camera view!
CameraService:LockCameraPanning(true, true, 90, 0)
]]

uiButton.MouseButton1Click:Connect(function()
	resetToNormal()
	uiButton.Visible = false
	CameraService:SetCameraView("ThirdPerson")
	CameraService:SetCameraHost() --> Leaving blank will set it back to your character
end)

workspace.WatchPart.ProximityPrompt.Triggered:Connect(function()
	resetToNormal()
	CameraService:SetCameraHost(workspace.WATCHER)
	CameraService:SetCameraView("FirstPerson")
	CameraService:Change("LockMouse", false, false)
	uiButton.Visible = true
end)

workspace.ThirdPart.ProximityPrompt.Triggered:Connect(function()
	resetToNormal()
	CameraService:SetCameraView("ThirdPerson")
end)

workspace.DefaultPart.ProximityPrompt.Triggered:Connect(function()
	resetToNormal()
	CameraService:SetCameraView("Default")
end)


workspace.FirstPart.ProximityPrompt.Triggered:Connect(function()
	resetToNormal()
	CameraService:SetCameraView("FirstPerson")
end)

workspace.ShakePart.ProximityPrompt.Triggered:Connect(function()
	CameraService:Shake(0.5, 5)
end)

workspace.CinematicPart.ProximityPrompt.Triggered:Connect(function()
	CameraService:SetCameraView("Cinematic")
	CameraService:ChangeSensitivity(0.333)
	if player.Character then
		player.Character.Humanoid.WalkSpeed = 12
	end
	game.Lighting.ColorCorrection.Saturation = -0.45
	game.Lighting.ColorCorrection.Contrast = 0.45
	game.Lighting.DepthOfField.Enabled = true
	CameraService:ChangeFOV(90, false)
end)

workspace.ShiftPart.ProximityPrompt.Triggered:Connect(function()
	resetToNormal()
	CameraService:SetCameraView("ShiftLock")
end)

workspace.TiltPart.ProximityPrompt.Triggered:Connect(function()
	CameraService:Tilt(30)
	task.wait(5)
	CameraService:Tilt(0)
end)

workspace.RotatePart.ProximityPrompt.Triggered:Connect(function()
	for i = 1, 360 do
		CameraService:Tilt(i)
		game:GetService("RunService").PreSimulation:Wait()
	end
	CameraService:Tilt(0)
end)