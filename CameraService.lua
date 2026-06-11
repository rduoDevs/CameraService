--\\----- [CAMERA SERVICE] -----//--
--[[
    Open-sourced, custom camera system for Roblox experiences.
    Find more ease in implementing beautiful, breath-taking camera effects into your place.
	
	DevForums Post: https://devforum.roblox.com/t/cameraservice-a-new-camera-for-a-new-roblox/1988655/
	GitHub Link: https://github.com/rduoDevs/CameraService

    API REFERENCE:
    > :SetCameraView(__type: string)
    Sets the camera to a certain view, such as first person, shift-lock, or some other.
    Will error if CameraService cannot find the camera view.

    > :CreateNewCameraView(id: string, settingsArray: table)
    Adds a new camera view that the camera can be set to.
    settingsArray should have values for camera view properties as seen below.
    If no value is provided, a default one will be placed within.

    > :LockCameraPanning(xAxis: boolean, yAxis: boolean, lockAtX: number, lockAtY: number)
    Locks camera movement from right-to-left (x-axis) or up-down (y-axis)
	3rd and 4th parameters are optional. If the camera is locked, it'll lock at the rotation of those parameters.
	Input should be in degrees for that.

    > :SetCameraHost(newHost: BasePart)
    Has the camera focus in on the input part. Must be a BASEPART (not a model).
    To reset the host back to the player's character, you can leave the parameters blank.

    > :Change(property: string, val: any, changeDefaultProperty: boolean)
    Properties include:
        "CharacterVisibility" (string): Determines what part of the character is visible.
        when it's the host. "All" shows all parts, "Body" hides the head, & "None" hides the whole body.
        "MinZoom" (number): Determines how close the player can zoom in. In studs.
        "MaxZoom" (number): Determines how far the player can zoom out. In studs.
        "Zoom" (number): The current distance the camera is away from the host.
        "Smoothness" (number): Determines how smooth the camera movement is.
        	Intervals from 0-1 are suggested. Intervals higher could be used to create a "cinematic" effect.
        "Offset" (CFrame): Determines the offset/positioning away from the camera host.
        	Can be used to simulate shift-lock.
		"Wobble" (number): Adjusts the factor for dynamic wobbling. Same functionality as :SetWobbling
        "LockMouse" (boolean): Has the mouse locked in at the center.
		"AlignChar" (boolean): If set to true, the character will rotate itself based off the camera (highly advised for shift-locks and first person)
		"BodyFollow" (boolean): If AlignChar is NOT enabled, BodyFollow allows for an effect that has the upper body slightly rotate based off the mouse location.

    > :ChangeSensitivity(val: number)
    Changes the rate at which the camera moves. 
    Merely adjusts the UserInputServiceService.MouseDeltaSensitivity property. 
    NOTICE: Players CAN change this themselves manually through the Roblox menu.

    > :ChangeFOV(val: number, instant: boolean)
    Gradually changes the field-of-view of the current camera.
    If you want the change to be instantaneous, add a second parameter marked true. 
    Changing FOV directly with the actual camera object is still possible.

    > :Shake(intensity: number, duration: number) (YIELDING FUNCTION)
    Creates a shaking camera effect in which the screen is, well, shaking. Like an earthquake. 
    Intensity should be a number greater than 0, preferably in the 0-1 range. Duration is in seconds.

    > :Tilt(degree: number)
    Tilts the camera across the z-axis on whatever object it is currently focusing on. 
    Useful for creating camera effects. Input a number in degrees.

    > :TiltAllAxes(y: number, x: number, z: number)
    Like :Tilt, but allows you to adjust all 3 axes. Most likely use-case would be for creating camera effects.
    Inputs in Y, X, Z order.

    > :SetWobbling(value: number)
    Changes the wobble value of the given Camera property.  This is equivalent to - CameraService:Change("Wobble", value, false)
    Input a number.

    > :SetVerticalRange(angle: number)
    Changes the vertical range of motion (i.e. how far up and down a player can look).
    Input a number in degrees from 0 (least range of motion) to 89 (most).

    Created by @Lugical | Relased September, 2022
    Version 2.4.0 | April 2026
--]]

math.randomseed(tick())
-- > Services < --
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- > Player & Camera Objects < --
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera or workspace:WaitForChild("Camera")

-- > Camera System Variables < --
local TWEEN_INFO = TweenInfo.new(.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local currentCamPosition = Vector3.zero
local cameraRotation = Vector2.zero
local currentCharacter = player.Character or player.CharacterAdded:Wait()
local offset = Vector3.zero
local updateShake = 0
local delta = 0;
local differenceVector = Vector2.zero;
local waistCache;
local wobbleAngle = 0;
local neckCache;

--> Built-in camera views
local cameraSettings = { 
	["Default"] = {},
	["FirstPerson"] = {
		Wobble = .45, 
		CharacterVisibility = "None", 
		Smoothness = 1, 
		RotSmoothness = 0, 
		Zoom = 0, 
		AlignChar = true, 
		Offset = CFrame.new(0,0,0), 
		LockMouse = true, 
		MinZoom = 0, 
		MaxZoom = 0, 
		BodyFollow = true
	},
	
	["FirstPersonVariant"] = {
		Wobble = 2, 
		CharacterVisibility = "Body", 
		Smoothness = .35, 
		RotSmoothness = 0, 
		Zoom = 0, 
		AlignChar = true, 
		Offset = CFrame.new(0,0.2,.75), 
		LockMouse = true, 
		MinZoom = 0, 
		MaxZoom = 0, 
		BodyFollow = true},
	
	["ThirdPerson"] = {
		Wobble = .4, 
		CharacterVisibility = "All", 
		Smoothness = .7, 
		Zoom = 10, 
		AlignChar = false, 
		Offset = CFrame.new(0,0,0), 
		LockMouse = false, 
		MinZoom = 5, 
		MaxZoom = 15, 
		BodyFollow = true},
	
	["ShiftLock"] = {
		Wobble = 0, 
		CharacterVisibility = "All", 
		Smoothness = 0.7, 
		Zoom = 7.5, 
		Offset = CFrame.new(1.75, 0.5, 1), 
		LockMouse = true, 
		AlignChar = true, 
		MinZoom = 2, 
		MaxZoom = 15, 
		BodyFollow = true},
	
	["Cinematic"] = {
		Smoothness = 5,
		CharacterVisibility = "All",
		MinZoom = 10,
		MaxZoom = 10,
		Zoom = 10,
		AlignChar = false,
		Offset = CFrame.new(),
		LockMouse = false,
		BodyFollow = false,
		Wobble = 0
	}	
}


local connectionList: {RBXScriptConnection} = {}

--> For camera views
local propertyTypes = {
	["CharacterVisibility"] = "All",
	["Smoothness"] = 0.5, --> If you're looking to get a smooth effect, I HIGHLY suggest values of 0.3+
	["Zoom"] = 10,
	["RotSmoothness"] = 1,
	["AlignChar"] = false,
	["Offset"] = CFrame.new(),
	["MinZoom"] = 5,
	["MaxZoom"] = 15,
	["LockMouse"] = false,
	["BodyFollow"] = true,
	["Wobble"] = 0
}

--- @class CameraService
--- Structured as a singleton, CameraService operates by implementing its own base camera system
--- with various properties and methods you can use to customize it how you wish, or to enable a prebuilt camera.
---
--- Some of the API is not the cleanest. A cleanup + conversion to Luau is planned!
local CameraService = {
	Offset = CFrame.new(),
	TiltFactor = CFrame.fromEulerAnglesYXZ(0,0,0),
	Angle = 60,
	Host = currentCharacter:WaitForChild("HumanoidRootPart"),
}

--[=[
	@within CameraService
	@prop CameraView string
	@readonly

	The current camera view CameraService is applying. To adjust the current view,
	do so via [CameraService:SetCameraView]
	(e.g. `"FirstPerson"`, `"ThirdPerson"`).
]=]

--[=[
	@within CameraService
	@prop Host BasePart

	The part the camera focuses on. Defaults to the player's
	`HumanoidRootPart`. Point it elsewhere with [CameraService:SetCameraHost],
	which validates the value and resets cleanly on respawn.
]=]

--[=[
	@within CameraService
	@prop Smoothness number

	Value representing how "smooth" camera motion is perceived. `0` is instant, while higher values create smoother, flow motion.
]=]

--[=[
	@within CameraService
	@prop RotSmoothness number
	@tag Restricted

	Smoothing applied to camera *rotation* only, independent of `Smoothness`.
	Applied only when the active view has no zoom range (e.g. first-person).
]=]

--[=[
	@within CameraService
	@prop Zoom number

	Current distance, in studs, between the camera and its host.
]=]

--[=[
	@within CameraService
	@prop MinZoom number

	Closest the player may zoom in, in studs.
]=]

--[=[
	@within CameraService
	@prop MaxZoom number
	Furthest the player may zoom out, in studs.
]=]

--[=[
	@within CameraService
	@prop Offset CFrame

	Positional & rotational offset from the host, applied before zoom. Useful
	for over-the-shoulder or shift-lock framing.
]=]

--[=[
	@within CameraService
	@prop CharacterVisibility string

	Which parts of the host character are visible when it is the host:
	`"All"` shows everything, `"Body"` hides the head, `"None"` hides the
	whole character. Defaults to `"All"`.
]=]

--[=[
	@within CameraService
	@prop AlignChar boolean

	When `true`, the character rotates to face the camera. Good for
	shift-lock and first-person views. Defaults to `false`.
]=]

--[=[
	@within CameraService
	@prop BodyFollow boolean
	@tag Restricted
	@tag R15-Only

	When `true`, the upper body leans toward the
	mouse for a subtle look-at effect. This property
	is *ignored* if `AlignChar` is true, as they are conflicting behaviors.
]=]

--[=[
	@within CameraService
	@prop LockMouse boolean

	When `true`, the mouse is locked to the center of the screen.
	Defaults to `false`.
]=]

--[=[
	@within CameraService
	@prop Wobble number

	Intensity of the avatar-aware wobbling when walking; `0` disables it. Can be changed 
	with [CameraService:SetWobbling].
]=]

--[=[
	@within CameraService
	@prop Angle number

	Maximum vertical look angle, in degrees (how far up/down the player can
	look). Set it through [CameraService:SetVerticalRange], which clamps to
	`0`–`89`.
]=]

--[=[
	@within CameraService
	@prop TiltFactor CFrame

	Accumulated camera tilt applied on top of the view.
]=]

-- > Camera System Functions < --

--> @hideBodyParts: helper function setting up CharacterVisibility
local function hideBodyParts(__type: string) 
	if currentCharacter then
		--> Set-up the rotation for shift-locking
		local hum = currentCharacter:FindFirstChildWhichIsA("Humanoid")
		if hum then
			hum.AutoRotate = not CameraService.AlignChar and true or false
		end

		--> Hide/unhide body parts when changing between views
		for _, v in ipairs(currentCharacter:GetChildren()) do  
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
				--> Run logic for parts within parts
				if v:GetDescendants() then
					for _, child in ipairs(v:GetDescendants()) do
						if child:IsA("BasePart") or child:IsA("Decal") then
							child.LocalTransparencyModifier = __type and __type == "All" and 0 or 1
						end
					end
				end

				--> If no __type, hide everything
				if __type then
					v.LocalTransparencyModifier = __type == "All" and 0 or __type == "Body" and v.Name == "Head" and 1 or 0
				else
					v.LocalTransparencyModifier = 1
				end
			elseif v:IsA("Accessory") and v:FindFirstChildWhichIsA("BasePart") then
				--> Set the hiding logic
				for _, child in ipairs(v:GetDescendants()) do
					if child:IsA("BasePart") or child:IsA("Decal") then
						child.LocalTransparencyModifier = __type and __type == "All" and 0 or 1
					end
				end
			end
		end
	else
		warn("[CameraService] Cannot find a host that is a Character model.")
	end

end


--> @calculateShakingOffset: shakes the camera each frame w/an offset
local function calculateShakingOffset(intensity: number): Vector3 
	local multipliers = {-1, 1}
	--> Use sin/cos for sense of randomness
	local currentSeed = math.random(1, os.time()) * multipliers[math.random(1, #multipliers)] 
	local x = math.sin(currentSeed) * (intensity * 1.5 ^ 2) / 3 
	local y = math.clamp(math.cos(currentSeed) * (intensity * 1.5 ^ 1.5), 0, 10) / 3
	--> Only offset Z in non-first-person views
	local z = CameraService.CharacterVisibility == "All" and (math.cos(currentSeed) / 2) * (intensity) / 5 or 0 

	return Vector3.new(x, y, z) * math.max(CameraService.Smoothness^2 * .5, 1)
end

--> @raycastWorld: correct zooms to avoid clipping parts
local function raycastWorld(origin, direction) 
	--> Set params w/blacklist
	local params = RaycastParams.new()
	params.IgnoreWater = true
	if CameraService.Host.Parent and CameraService.Host.Parent ~= workspace and CameraService.Host.Parent:IsA("Model") then
		params.FilterDescendantsInstances = {currentCharacter, CameraService.Host.Parent}
	else
		params.FilterDescendantsInstances = {currentCharacter, CameraService.Host}
	end
	local pos = (currentCamPosition + offset) -- no Offset property applied yet
	--> Allow clipping through transluscent parts
	local landRay = workspace:Raycast(origin, direction, params)
	if landRay and landRay.Distance and landRay.Instance then 
		if landRay.Instance:IsA("BasePart") or landRay.Instance:IsA("UnionOperation") then	
			direction *= (landRay.Distance * .9 / direction.Magnitude)
		else
			direction *= (landRay.Distance * .95 / direction.Magnitude)
		end
	end

	--> Cframe * Vector3 to zoom out in proper direction.
	return origin + direction

end


--> @updateCamera: update camera orientation + pos @ each frame
local lapsed = 1000 --> Used for dampening while jumping/falling
local arrowKeyAngle = 0
local pastCamRot = CFrame.Angles(0,0,0)
local function updateCamera(deltaTime: number) 

	local self = CameraService
	--> Console has different inputs + logic. This helps set up CONSOLE camera movement
	if UserInputService.GamepadEnabled then
		cameraRotation -= differenceVector
	else
		differenceVector = Vector2.zero
	end
	--> Clamp the y-vals for camera rotating
	cameraRotation = Vector2.new(
		self.xLock and self.atX or cameraRotation.X, 
		self.yLock and self.atY or math.clamp(cameraRotation.Y, math.rad(-self.Angle), math.rad(self.Angle))
	) 
	
	currentCamPosition = self.Host.Position + Vector3.new(0, self.Host.Parent and self.Host.Parent == currentCharacter and 2.5 or 0,0)
	
	
	--> rotate camera via arrow keys on PC
	if UserInputService:IsKeyDown(Enum.KeyCode.Right) then
		arrowKeyAngle += 3 * deltaTime
	elseif UserInputService:IsKeyDown(Enum.KeyCode.Left) then
		arrowKeyAngle -= 3 * deltaTime
	end
	
	--> Convert cameraRotation into an angle CFrame (YXZ = Angles)
	local rotationCFrame = CFrame.fromEulerAnglesYXZ(cameraRotation.Y, cameraRotation.X - arrowKeyAngle, 0)
	updateShake = updateShake < math.random(2,3) and updateShake + 1 or 0
	offset = self.Shaking and offset and updateShake == 0 and calculateShakingOffset(self.ShakingIntensity) or self.Shaking and offset or Vector3.new(0,0,0)
	local yCFOffset = CFrame.fromEulerAnglesYXZ(0,0,0)
	
	--> Dynamic wobble based on character's movement
	if self.Wobble and self.Wobble > 0 and self.Host.Parent and self.Host.Parent == currentCharacter then
		pcall(function()
			local yOff = currentCharacter.Humanoid.RigType == 
				Enum.HumanoidRigType.R15 and (currentCharacter["LeftFoot"].Position.Y - currentCharacter["RightFoot"].Position.Y) / 1.5 
				or currentCharacter.Humanoid.RigType == Enum.HumanoidRigType.R6 and (currentCharacter["Left Leg"].Position.Y - currentCharacter["Right Leg"].Position.Y) or 0
			local target = math.rad(yOff * (self.Wobble^1.5))
			yCFOffset = CFrame.fromEulerAnglesYXZ(0,0, target)
		end) 
	end

	--> Damping the motion of the camera for smoothing
	local desiredTime = self.Smoothness ^ 2 * 0.05 + 0.02 * self.Smoothness +0.005
	local lerpFactor = 1 - math.exp(-deltaTime / desiredTime) --math.min(1, deltaTime / desiredTime)

	if self.MinZoom == 0 and self.MaxZoom == 0 and self.RotSmoothness > self.Smoothness then
		local desiredTime2 = self.RotSmoothness ^ 2 * 0.05 + 0.02 * self.RotSmoothness +0.005
		local lerpFactor2 = 1 - math.exp(-deltaTime / desiredTime2)--math.min(1, deltaTime / desiredTime2)
		rotationCFrame = self.RotSmoothness > 0 and pastCamRot:Lerp(rotationCFrame, lerpFactor2) or rotationCFrame
	end

	pastCamRot = rotationCFrame
	local camCFrame = (rotationCFrame * self.Offset * self.TiltFactor) + currentCamPosition + offset + (rotationCFrame * Vector3.new(0,0,self.Zoom))
	local camPos = raycastWorld(currentCamPosition + offset, camCFrame.p - offset - currentCamPosition)
	camCFrame = (camCFrame - camCFrame.p) + camPos
	local targetCFrame = cam.CFrame:Lerp(camCFrame, lerpFactor)
	local desired2 = desiredTime
	local lerp2
	if self.Zoom > 0 and self.Smoothness > 0 then
		--> @damper: Increases damping factor for vertical motion
		local function damper()
			local hum = currentCharacter:FindFirstChild("Humanoid")
			local humState

			if hum then
				humState = hum:GetState()
			end

			if (humState == Enum.HumanoidStateType.Jumping) or (humState == Enum.HumanoidStateType.Freefall) then
				lapsed = 0
				return desiredTime * 3.33
			end
			lapsed += 1
			if lapsed < 1 / deltaTime then
				return desiredTime * 3.33
			else		
				return math.max(desiredTime, desiredTime * (3.33 - (lapsed - (1 / deltaTime)) * .03))
			end

		end
		desired2 = damper()
	end

	lerp2 = desired2 ~= desiredTime and cam.CFrame:Lerp(camCFrame, 1 - math.exp(-deltaTime / desired2)) or nil
	cam.CFrame = self.Smoothness <= 0 and camCFrame or CFrame.new(targetCFrame.X, lerp2 and lerp2.Y or targetCFrame.Y, targetCFrame.Z) * targetCFrame.Rotation * yCFOffset 
	
	--> Extraneous character alignment features if needed
	if self.Host.Parent == currentCharacter then
		workspace.Retargeting = Enum.AnimatorRetargetingMode.Disabled
		local humanoid, root = currentCharacter:FindFirstChild("Humanoid"), currentCharacter:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 then
			local waist = humanoid.RigType == Enum.HumanoidRigType.R15 and currentCharacter.UpperTorso:FindFirstChildWhichIsA("Motor6D") or nil
			local neck = humanoid.RigType == Enum.HumanoidRigType.R15 and currentCharacter.Head:FindFirstChildWhichIsA("Motor6D") or nil
			if waist and not waistCache then
				waistCache = waist.C0
			end
			if  neck and not neckCache then
				neckCache = neck.C0
			end
			if self.AlignChar and humanoid.FloorMaterial ~= Enum.Material.Water then
				if waist and waistCache and waist.C0 ~= waistCache then
					waist.C0 = waistCache
				end
				if neck and neckCache and neck.C0 ~= neckCache then
					neck.C0 = neckCache
				end
				local _, x, _ = camCFrame:ToEulerAnglesYXZ()
				root.CFrame = CFrame.fromEulerAnglesYXZ(0, x + math.rad(self.Offset.X == 0 and 0 or -6), 0) + root.Position
			elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
				if self.BodyFollow and waist and neck then
					waist.C0 = waist.C0:Lerp((CFrame.fromEulerAnglesYXZ(math.rad(mouse.Hit.LookVector:Dot(Vector3.new(0,1,0)) * 10), math.rad(mouse.Hit.LookVector:Dot((CFrame.Angles(root.CFrame:ToEulerAnglesYXZ()) * CFrame.new(-1,0,0)).Position.Unit) * 40), 0) + waistCache.Position), 0.25)
					neck.C0 = neck.C0:Lerp((CFrame.fromEulerAnglesYXZ(math.rad(mouse.Hit.LookVector:Dot(Vector3.new(0,1,0)) * 30), 0, 0) + neckCache.Position), 0.25)
					if waist and not waistCache then
						waistCache = waist.C0
					end
					if neck and not neckCache then
						neckCache = neck.C0
					end
				else
					if waist and waistCache and waist.C0 ~= waistCache then
						waist.C0 = waistCache
					end
					if neck and neckCache and neck.C0 ~= neckCache then
						neck.C0 = neckCache
					end
				end
			end
		end
	end
end

--- Sets the camera to a built-in or custom view, disconnecting the previous one.
--- Will error if the given view ID does not exist.
--- @within CameraService
--- @param __type string -- The view to apply (e.g. `"FirstPerson"`, `"ThirdPerson"`, `"ShiftLock"`, `"Cinematic"`, `"Default"`).
function CameraService:SetCameraView(__type: string)
	assert(cameraSettings[__type] ~= nil, "[CameraService] Camera view not found for ID: "..tostring(__type))

	self.CameraView = __type
	for i, v in pairs(cameraSettings[__type]) do
		self[i] = v
	end
	for _, connection in pairs(connectionList) do
		connection:Disconnect()
	end

	--> Check what camera view the user wants
	if __type == "Default" then 

		--> Resets it back to non-scriptable, Roblox default camera
		self.LockMouse = false
		cam.CameraSubject = currentCharacter:WaitForChild("Humanoid")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		cam.CameraType = Enum.CameraType.Custom
		workspace.Retargeting = Enum.AnimatorRetargetingMode.Default
		currentCharacter:WaitForChild("Humanoid").AutoRotate = true

	elseif cameraSettings[__type] then

		--> Add in settings
		workspace.Retargeting = Enum.AnimatorRetargetingMode.Disabled
		if self.Host.Parent and self.Host.Parent == currentCharacter then
			hideBodyParts(self.CharacterVisibility ~= "None" and self.CharacterVisibility or nil)
		end
		UserInputService.MouseBehavior = self.LockMouse and __type ~= "Default" and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CameraSubject = nil


		--> @updateZoom: for camera zooming in/out
		local function updateZoom(input, gpe) 
			if not gpe then
				if input.UserInputType == Enum.UserInputType.MouseWheel then --> Computer (mouse)
					local multiplier = input.Position.Z
					self.Zoom = math.clamp(self.Zoom - (multiplier * (self.MaxZoom - self.MinZoom) / 4), self.MinZoom, self.MaxZoom)
				elseif input.UserInputState == Enum.UserInputState.Begin and (input.KeyCode == Enum.KeyCode.I or input.KeyCode == Enum.KeyCode.O) then --> Computer (I/O)
					local multiplier = input.KeyCode == Enum.KeyCode.I and 1 or -1
					self.Zoom = math.clamp(self.Zoom - (multiplier * (self.MaxZoom - self.MinZoom) / 4), self.MinZoom, self.MaxZoom)
				elseif input.KeyCode == Enum.KeyCode.ButtonR3 and input.UserInputState == Enum.UserInputState.Begin then --> Console Joystick Press
					self.Zoom = self.Zoom - ((self.MaxZoom - self.MinZoom) / 4) < self.MinZoom and self.MaxZoom or self.Zoom - ((self.MaxZoom - self.MinZoom) / 4)
				end
			end
		end

		--> @onInputChange: stores input, convert to Vector2 with rotation data
		local function onInputChange(input, gpe) 
			updateZoom(input, gpe)
			local rightHold = self.LockMouse or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			local mobile = input.UserInputType == Enum.UserInputType.Touch
			local console = input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick2
			if (not gpe or (not mobile and not console)) and (rightHold or mobile or console) and input.UserInputState == Enum.UserInputState.Change then
				delta = console and input.Position / 15 * math.sqrt(UserInputService.MouseDeltaSensitivity) or input.Delta --> Get mouse position
				differenceVector = console and Vector2.new(delta.X, -delta.Y) or {X = math.sqrt(math.abs(delta.X)) / (mobile and 27 or 50), Y = math.sqrt(math.abs(delta.Y)) / (mobile and 27 or 50)}
				--> Adjust the positions
				if console then
					differenceVector = Vector2.new(
						if delta.X < 0.2 / 15 * math.sqrt(UserInputService.MouseDeltaSensitivity) and delta.X > -0.2 / 15 * math.sqrt(UserInputService.MouseDeltaSensitivity) then 0 else delta.X,
						if -delta.Y < 0.2 / 15 * math.sqrt(UserInputService.MouseDeltaSensitivity) and -delta.Y > -0.2 / 15 * math.sqrt(UserInputService.MouseDeltaSensitivity) then 0 else -delta.Y
					)
				else
					differenceVector = Vector2.new(
						if delta.X > 0 then 1 * differenceVector.X else -1 * differenceVector.X,
						if delta.Y > 0 then 1 * differenceVector.Y else -1 * differenceVector.Y
					)
				end
				--> Update rotation once if not console; console updates rotation on each frame
				if not console then
					cameraRotation -= differenceVector
					cameraRotation = Vector2.new(self.xLock and self.atX or cameraRotation.X, self.yLock and self.atY or math.clamp(cameraRotation.Y, math.rad(-self.Angle), math.rad(self.Angle)))
				end
			end
			UserInputService.MouseBehavior = self.LockMouse and Enum.MouseBehavior.LockCenter or rightHold and Enum.MouseBehavior.LockCurrentPosition or Enum.MouseBehavior.Default
		end


		--> Disconnect any active connections
		for _, connection in pairs(connectionList) do
			connection:Disconnect()
		end


		--> Mobile Compatibility
		if UserInputService.TouchEnabled then 
			table.insert(connectionList, UserInputService.TouchPan:Connect(onInputChange))
			table.insert(connectionList, UserInputService.TouchRotate:Connect(onInputChange))
			local pinchDelta = 0;
			table.insert(connectionList, UserInputService.TouchPinch:Connect(function(_, scale, _, state, gpe)
				self.Zoom = gpe and self.Zoom or state == Enum.UserInputState.Begin and self.Zoom or math.clamp(self.Zoom - ((pinchDelta and scale - pinchDelta or 0) * 20), self.MinZoom, self.MaxZoom)
				pinchDelta = scale
			end))
		end

		--> Set up the input connections
		table.insert(connectionList, UserInputService.InputBegan:Connect(onInputChange))
		table.insert(connectionList, UserInputService.InputChanged:Connect(onInputChange))
		table.insert(connectionList, UserInputService.InputEnded:Connect(onInputChange))
		--> Set up the actual system to run
		table.insert(connectionList, RunService.PostSimulation:Connect(updateCamera))

		--> Special effects for the CINEMATIC VIEW
		if __type == "Cinematic" then
			local ui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
			ui.Name = "CameraService_Cinematic_Effect"
			ui.Enabled = true
			ui.ResetOnSpawn = false
			ui.IgnoreGuiInset = true
			local uiFrame1 = Instance.new("Frame", ui)
			uiFrame1.BackgroundColor3 = Color3.new(0,0,0)
			uiFrame1.Name = "Frame1"
			uiFrame1.BorderSizePixel = 0
			uiFrame1.Size = UDim2.new(1,0,.135,0)
			local uiFrame2 = uiFrame1:Clone()
			uiFrame2.Parent = ui
			uiFrame2.Name = "Frame2"

			uiFrame1.Position = UDim2.new(0,0,-.136,0)
			uiFrame2.Position = UDim2.new(0,0,1,0)

			uiFrame1:TweenPosition(UDim2.new(0,0,0,0), "Out", "Sine", .25, true)
			uiFrame2:TweenPosition(UDim2.new(0,0,.865,0), "Out", "Sine", .25, true)
		end
	end
	
	if __type ~= "Cinematic" then
		local ui = player:WaitForChild("PlayerGui"):FindFirstChild("CameraService_Cinematic_Effect")
		if ui then
			local uiFrame1 = ui:FindFirstChild("Frame1")
			local uiFrame2 = ui:FindFirstChild("Frame2")
			if uiFrame1 then
				uiFrame1:TweenPosition(UDim2.new(0,0,-.1360,0), "Out", "Sine", .25, true)
			end
			if uiFrame2 then
				uiFrame2:TweenPosition(UDim2.new(0,0,1,0), "Out", "Sine", .25, true)
			end
			task.wait(.25)
			ui:Destroy()
		end
	end
end

--- Registers a new camera view that can later be activated via `:SetCameraView`.
--- Any omitted property falls back to the default value and logs a warning.
--- @within CameraService
--- @param id string -- Unique identifier for the new view.
--- @param settingsArray table -- Table of camera property overrides (see `:Change` for valid keys).
function CameraService:CreateNewCameraView(id: string, settingsArray: {})

	--> Make sure that settingsArray is a table to ensure all runs well
	assert(typeof(settingsArray) == "table", "[CameraService] 2nd parameter should be a table for :CreateNewCameraView()")

	--> Register the new view
	cameraSettings[id] = settingsArray
	for property, default in pairs(propertyTypes) do
		if cameraSettings[id][property] == nil then
			warn('[CameraService] The "'..property..'" property was set to the default value: '..tostring(default))
			cameraSettings[id][property] = default
		end
	end

end


--- Locks camera movement along the X axis (left/right) or Y axis (up/down).
--- Useful for 2D or isotropic cameras.
--- @within CameraService
--- @param lockXAxis boolean -- Lock horizontal rotation.
--- @param lockYAxis boolean -- Lock vertical rotation.
--- @param lockAtX number? -- Angle in degrees to lock horizontal rotation at.
--- @param lockAtY number? -- Angle in degrees to lock vertical rotation at.
function CameraService:LockCameraPanning(lockXAxis: boolean, lockYAxis: boolean, lockAtX: number, lockAtY: number)
	--> Set up the camera orientation
	self.atX = lockAtX and math.rad(lockAtX) or 0
	self.atY = lockAtY and math.rad(lockAtY) or 0
	--> Lock if necessary
	self.xLock = lockXAxis
	self.yLock = lockYAxis
end


--- Redirects the camera to focus on an input BasePart instead of the player character.
--- Pass no argument (or nil) to reset back to the player's HumanoidRootPart.
--- @within CameraService
--- @param newHost BasePart? -- The part to focus on, or nil to reset to the character.
function CameraService:SetCameraHost(newHost: BasePart)
	assert(not newHost or typeof(newHost) == "Instance" and newHost:IsA("BasePart"), "[CameraService] :SetCameraHost() only accepts a BasePart parameter, or none at all. ")
	self.Host = newHost or currentCharacter:FindFirstChild("HumanoidRootPart")
end


--- Changes a live camera property. Optionally persists the change into the current view's defaults.
---
--- Valid properties:
--- - `CharacterVisibility` (string): `"All"`, `"Body"` (hides head), or `"None"` (hides whole body).
--- - `MinZoom` (number): Closest zoom distance in studs.
--- - `MaxZoom` (number): Furthest zoom distance in studs.
--- - `Zoom` (number): Current camera distance in studs.
--- - `Smoothness` (number): Camera lag factor; 0–1 recommended, higher = cinematic.
--- - `Offset` (CFrame): Positional offset from the camera host.
--- - `Wobble` (number): Dynamic wobble intensity.
--- - `LockMouse` (boolean): Keep the mouse locked at screen center.
--- - `AlignChar` (boolean): Rotate the character to match the camera (required for shift-lock / first-person).
--- - `BodyFollow` (boolean): Upper-body rotates toward mouse when `AlignChar` is off.
--- @within CameraService
--- @param property string -- Name of the property to change.
--- @param newVal any -- New value for the property.
--- @param changeDefaultProperty boolean -- If true, also updates the active view's saved default.
function CameraService:Change(property: string, newVal: any, changeDefaultProperty: boolean)
	--> Make sure the requested property to change is valid
	assert(propertyTypes[property] ~= nil, '[CameraService] "'..tostring(property)..'" is not a valid property to change.')

	self[property] = newVal
	if changeDefaultProperty then --> Change the camera view's default setting, if wanted
		cameraSettings[self.CameraView][property] = newVal
	end
end


--- Adjusts mouse/input sensitivity by setting `UserInputService.MouseDeltaSensitivity`.
--- Note: players can override this themselves via the Roblox settings menu.
--- @within CameraService
--- @param val number -- Sensitivity multiplier; must be greater than 0.
function CameraService:ChangeSensitivity(val: number)
	--> Make sure that "val" is positive before doing anything
	assert(type(val) == "number" and val > 0, "[CameraService] Sensitivity should be greater than 0.")
	UserInputService.MouseDeltaSensitivity = val
end


--- Smoothly tweens the camera's field of view to the given value.
--- Pass `true` as the second argument to skip the tween and change it instantly.
--- This function yields until the tween completes (unless `instant` is true).
--- @within CameraService
--- @yields
--- @param val number -- Target field of view; must be greater than 0.
--- @param instant boolean? -- If true, changes FOV immediately with no tween.
function CameraService:ChangeFOV(val: number, instant: boolean)

	--> Make sure that "val" is positive before doing anything
	assert(type(val) == "number" and val > 0, "[CameraService] FieldOfView should be greater than 0.")

	--> Set up FOV logic
	if instant then
		cam.FieldOfView = val
	else
		local tween = TweenService:Create(cam, TWEEN_INFO, {FieldOfView = val})
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
	end

end



--- Applies a shaking effect to the camera for the given duration, then stops.
--- @within CameraService
--- @yields
--- @param intensity number -- Strength of the shake; values in the 0–1 range are recommended.
--- @param duration number -- How long the shake lasts in seconds; must be greater than 0.
function CameraService:Shake(intensity: number, duration: number)

	--> Make sure that arguments are positive before doing anything
	assert(duration > 0 and intensity > 0, "[CameraService] Inputs for :Shake() must be positive")

	--> Logic
	self.ShakingIntensity = intensity --> Property for shake
	self.Shaking = true --> Actively shaking or not
	task.wait(tonumber(duration))
	self.Shaking = false

end


--- Tilts the camera along the Z axis by the given number of degrees.
--- @within CameraService
--- @param degree number -- Tilt angle in degrees.
function CameraService:Tilt(degree: number)
	self.TiltFactor = CFrame.fromEulerAnglesYXZ(0, 0, math.rad(degree) or 0)
end


--- Tilts the camera across all three axes simultaneously. Inputs are in degrees.
--- Arguments follow Y, X, Z order to match `CFrame.fromEulerAnglesYXZ`.
--- @within CameraService
--- @param x number -- Tilt on the X axis in degrees.
--- @param y number -- Tilt on the Y axis in degrees.
--- @param z number -- Tilt on the Z axis in degrees.
function CameraService:TiltAllAxes(x: number, y: number, z: number)
	self.TiltFactor = CFrame.fromEulerAnglesYXZ(y and math.rad(y) or 0, x and math.rad(x) or 0, z and math.rad(z) or 0)
end


--- Sets the avatar-aware wobble intensity. Equivalent to `CameraService:Change("Wobble", value, false)`.
--- @within CameraService
--- @param value number -- Wobble strength; 0 disables wobble.
function CameraService:SetWobbling(value: number)
	self.Wobble = value
end


--- Sets how far up and down the player can look. Input is clamped to 0–89 degrees.
--- @within CameraService
--- @param angle number -- Maximum vertical look angle in degrees (0 = locked horizontal, 89 = nearly vertical).
function CameraService:SetVerticalRange(angle: number)
	self.Angle = math.clamp(math.abs(angle), 0, 89)
end

--> Have camera reset focus to new character.
player.CharacterAdded:Connect(function(char) 
	if (not CameraService.Host) or (not CameraService.Host:IsDescendantOf(workspace)) or (tostring(CameraService.Host.Parent) == player.Name) then
		currentCharacter = char
		CameraService:SetCameraHost()
	end
end)


return CameraService
