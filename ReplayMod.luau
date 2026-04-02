local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--////////////////////////////////////////////////////////////
-- CONFIG
--////////////////////////////////////////////////////////////

local SAMPLE_INTERVAL = 1 / 30 -- recording sample rate
local DEFAULT_SPEEDS = {0.5, 1, 1.5, 2}

--////////////////////////////////////////////////////////////
-- STATE
--////////////////////////////////////////////////////////////

local frames = {}
local recording = false
local playing = false
local recordConn = nil
local ghostModel = nil
local recordStart = 0
local recordAccumulator = 0
local playToken = 0
local speedIndex = 2
local usePlayerDuringPlayback = true
local playbackSpeed = DEFAULT_SPEEDS[speedIndex]

--////////////////////////////////////////////////////////////
-- HELPERS
--////////////////////////////////////////////////////////////

local function getMotorMap(character)
	local map = {}
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("Motor6D") then
			map[v.Name] = v
		end
	end
	return map
end

local function captureJoints(motorMap)
	local data = {}
	for name, motor in pairs(motorMap) do
		data[name] = motor.Transform
	end
	return data
end

local function applyJointsInterpolated(motorMap, aJoints, bJoints, alpha)
	for name, aCF in pairs(aJoints) do
		local motor = motorMap[name]
		local bCF = bJoints and bJoints[name]

		if motor and aCF and bCF then
			motor.Transform = aCF:Lerp(bCF, alpha)
		elseif motor and aCF then
			motor.Transform = aCF
		end
	end
end

local function getCharacter()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then
		return nil
	end
	return character, humanoid, root
end

local function setStatus(text)
	statusLabel.Text = text
end

local function clearGhost()
	if ghostModel and ghostModel ~= player.Character then
		ghostModel:Destroy()
		ghostModel = nil
	end
end

local function stopRecording()
	if not recording then
		return
	end

	recording = false
	if recordConn then
		recordConn:Disconnect()
		recordConn = nil
	end

	recordButton.Text = "Record"
	recordButton.BackgroundColor3 = Color3.fromRGB(40, 170, 70)

	if #frames >= 2 then
		setStatus(("Saved %d frames"):format(#frames))
	else
		setStatus("Recording too short")
	end
end

local function stopPlayback()
	if not playing then
		return
	end

	playing = false
	playToken += 1
	clearGhost()
	playButton.Text = "Play"
	playButton.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
	
	local animator = Instance.new("Animator")
	animator.Parent = player.Character.Humanoid
	player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	local animate = player.Character:FindFirstChild("Animate")
	player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	player.Character.HumanoidRootPart.Anchored = false
	if animate then
		animate.Enabled = true
	end
	setStatus("Stopped")
end

local function cloneGhost(sourceCharacter, usePlayer)
	local clone = nil
	if usePlayer then
		clone = sourceCharacter
	else
		clone = sourceCharacter:Clone()
	end
	local motorMap = getMotorMap(clone)
	if not clone then
		return nil
	end
	if not usePlayer then 
		clone.Name = "ReplayGhost"
		for _, obj in ipairs(clone:GetDescendants()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") then
				obj:Destroy()
			elseif obj:IsA("BasePart") then
				obj.Anchored = true
				obj.CanCollide = false
				obj.CanQuery = false
				obj.CanTouch = false
				obj.Massless = true
				obj.Transparency = math.clamp(obj.Transparency + 0.35, 0, 0.9)
			end
		end
		
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.8
		highlight.OutlineTransparency = 0.1
		highlight.Parent = clone
	end
	
	local hum = clone:FindFirstChildOfClass("Humanoid")
	if hum then
		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			animator:Destroy()
		end
		
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end
	
	local animate = clone:FindFirstChild("Animate")
	if animate then
		animate.Enabled = false
	end

	clone.Parent = workspace
	clone:PivotTo(sourceCharacter:GetPivot())
	
	local motorMap = getMotorMap(clone)
	clone:SetAttribute("MotorMapReady", true)
	
	clone.HumanoidRootPart.Anchored = true
	
	return clone, motorMap
end

local function startRecording()
	if recording or playing then
		return
	end

	local character, _, root = getCharacter()
	if not character or not root then
		setStatus("No character found")
		return
	end

	frames = {}
	recording = true
	recordStart = os.clock()
	recordAccumulator = 0

	recordButton.Text = "Stop"
	recordButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
	playButton.Text = "Play"
	playButton.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
	setStatus("Recording...")
	
	local motorMap = getMotorMap(character)
	
	local currentCharacter = player.Character
	local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
	
	frames[#frames + 1] = {
		t = os.clock() - recordStart,
		root = currentRoot.CFrame,
		joints = captureJoints(motorMap)
	}

	recordConn = RunService.Heartbeat:Connect(function(dt)
		if not recording then
			return
		end

		recordAccumulator += dt
		if recordAccumulator < SAMPLE_INTERVAL then
			return
		end

		recordAccumulator -= SAMPLE_INTERVAL

		local currentCharacter = player.Character
		local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
		if currentRoot then
			frames[#frames + 1] = {
				t = os.clock() - recordStart,
				root = currentRoot.CFrame,
				joints = captureJoints(motorMap)
			}
		end
	end)
end

local function playReplay()
	if playing or recording then
		return
	end

	if #frames < 2 then
		setStatus("Nothing to replay")
		return
	end

	local character = player.Character
	if not character then
		setStatus("No character found")
		return
	end

	clearGhost()
	local ghostMotors = nil
	ghostModel, ghostMotors = cloneGhost(character, usePlayerDuringPlayback)
	
	playing = true
	playToken += 1
	local myToken = playToken

	playButton.Text = "Stop"
	playButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
	setStatus(("Playing at %.1fx"):format(playbackSpeed))

	local duration = frames[#frames].t
	local index = 1
	local startTime = os.clock()

	while playing and playToken == myToken do
		local elapsed = (os.clock() - startTime) * playbackSpeed

		if elapsed >= duration then
			break
		end

		while index < #frames - 1 and frames[index + 1].t <= elapsed do
			index += 1
		end

		local a = frames[index]
		local b = frames[math.min(index + 1, #frames)]

		if a and b and a.root and b.root then
			local alpha = 0
			if b.t > a.t then
				alpha = math.clamp((elapsed - a.t) / (b.t - a.t), 0, 1)
			end

			if ghostModel and ghostModel.Parent then
				ghostModel:PivotTo(a.root:Lerp(b.root, alpha))
				if ghostMotors and a.joints then
					applyJointsInterpolated(ghostMotors, a.joints, b.joints, alpha)
				end
			end
		else
			warn(a)
			warn("Replay frame missing root data")
			break
		end

		RunService.RenderStepped:Wait()
	end

	stopPlayback()
end

local function clearReplay()
	if recording then
		stopRecording()
	end
	if playing then
		stopPlayback()
	end
	frames = {}
	setStatus("Cleared")
end

local function cycleSpeed()
	speedIndex += 1
	if speedIndex > #DEFAULT_SPEEDS then
		speedIndex = 1
	end
	playbackSpeed = DEFAULT_SPEEDS[speedIndex]
	speedButton.Text = ("Speed: %.1fx"):format(playbackSpeed)
end

--////////////////////////////////////////////////////////////
-- GUI
--////////////////////////////////////////////////////////////

local sg = Instance.new("ScreenGui")
sg.Name = "ReplayMenu"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 270, 0, 230)
main.Position = UDim2.new(0, 20, 0.5, -110)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 70)
stroke.Thickness = 1
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 8)
headerFix.Position = UDim2.new(0, 0, 1, -8)
headerFix.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Replay Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local usePlr = Instance.new("TextButton")
usePlr.Size = UDim2.new(0, 28, 0, 28)
usePlr.Position = UDim2.new(1, -90, 0, 2)
usePlr.BackgroundTransparency = 1
usePlr.Text = ":)"
usePlr.TextColor3 = Color3.new(1,1,1)
usePlr.Font = Enum.Font.GothamBold
usePlr.TextSize = 18
usePlr.Parent = header

usePlr.MouseButton1Click:Connect(function()
	if usePlr.Text == ":(" then
		usePlr.Text = ":)"
		usePlr.TextColor3 = Color3.new(1,1,1)
	else
		usePlr.Text = ":("
		usePlr.TextColor3 = Color3.new(0.8,0.8,0.8)
	end
	usePlayerDuringPlayback = not usePlayerDuringPlayback
end)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 28, 0, 28)
minimize.Position = UDim2.new(1, -60, 0, 2)
minimize.BackgroundTransparency = 1
minimize.Text = "—"
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 18
minimize.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 28, 0, 28)
close.Position = UDim2.new(1, -30, 0, 2)
close.BackgroundTransparency = 1
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 80, 80)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = header

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -32)
body.Position = UDim2.new(0, 0, 0, 32)
body.BackgroundTransparency = 1
body.Parent = main

statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = body

recordButton = Instance.new("TextButton")
recordButton.Size = UDim2.new(1, -20, 0, 34)
recordButton.Position = UDim2.new(0, 10, 0, 40)
recordButton.BackgroundColor3 = Color3.fromRGB(40, 170, 70)
recordButton.Text = "Record"
recordButton.TextColor3 = Color3.new(1, 1, 1)
recordButton.Font = Enum.Font.GothamBold
recordButton.TextSize = 13
recordButton.Parent = body
Instance.new("UICorner", recordButton).CornerRadius = UDim.new(0, 8)

playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(1, -20, 0, 34)
playButton.Position = UDim2.new(0, 10, 0, 80)
playButton.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
playButton.Text = "Play"
playButton.TextColor3 = Color3.new(1, 1, 1)
playButton.Font = Enum.Font.GothamBold
playButton.TextSize = 13
playButton.Parent = body
Instance.new("UICorner", playButton).CornerRadius = UDim.new(0, 8)

clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(1, -20, 0, 30)
clearButton.Position = UDim2.new(0, 10, 0, 120)
clearButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
clearButton.Text = "Clear"
clearButton.TextColor3 = Color3.new(1, 1, 1)
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 12
clearButton.Parent = body
Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 8)

speedButton = Instance.new("TextButton")
speedButton.Size = UDim2.new(1, -20, 0, 30)
speedButton.Position = UDim2.new(0, 10, 0, 156)
speedButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
speedButton.Text = ("Speed: %.1fx"):format(playbackSpeed)
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.Font = Enum.Font.GothamBold
speedButton.TextSize = 12
speedButton.Parent = body
Instance.new("UICorner", speedButton).CornerRadius = UDim.new(0, 8)

--////////////////////////////////////////////////////////////
-- DRAGGING
--////////////////////////////////////////////////////////////

do
	local dragging = false
	local dragStart
	local startPos

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

--////////////////////////////////////////////////////////////
-- BUTTONS
--////////////////////////////////////////////////////////////

recordButton.MouseButton1Click:Connect(function()
	if recording then
		stopRecording()
	else
		startRecording()
	end
end)

playButton.MouseButton1Click:Connect(function()
	if playing then
		stopPlayback()
	else
		playReplay()
	end
end)

clearButton.MouseButton1Click:Connect(clearReplay)
speedButton.MouseButton1Click:Connect(cycleSpeed)

minimize.MouseButton1Click:Connect(function()
	body.Visible = not body.Visible
	main.Size = body.Visible and UDim2.new(0, 270, 0, 230) or UDim2.new(0, 270, 0, 32)
end)

close.MouseButton1Click:Connect(function()
	clearReplay()
	sg:Destroy()
end)

--////////////////////////////////////////////////////////////
-- HOTKEYS
--////////////////////////////////////////////////////////////
-- R = record/stop
-- P = play/stop
-- Delete = clear
-- M = minimize

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.R then
		if recording then
			stopRecording()
		else
			startRecording()
		end
	elseif input.KeyCode == Enum.KeyCode.P then
		if playing then
			stopPlayback()
		else
			playReplay()
		end
	elseif input.KeyCode == Enum.KeyCode.Delete then
		clearReplay()
	elseif input.KeyCode == Enum.KeyCode.M then
		body.Visible = not body.Visible
		main.Size = body.Visible and UDim2.new(0, 270, 0, 220) or UDim2.new(0, 270, 0, 32)
	end
end)

player.CharacterAdded:Connect(function()
	if recording then
		setStatus("Respawned while recording")
	end
end)
