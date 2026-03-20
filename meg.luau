local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

_G.SpeedVal = 16
_G.JumpVal = 50
_G.InfJump = false
_G.InfJumpDelay = 0.1
_G.SetCash = 0

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "Athiel's DevMenu"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 350)
main.Position = UDim2.new(0.5, -130, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BorderSizePixel = 1
main.BorderColor3 = Color3.new(1,1,1)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 5)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "Athiel's DevMenu"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundTransparency = 1

local clsBtn = Instance.new("TextButton", header)
clsBtn.Size = UDim2.new(0, 30, 0, 30)
clsBtn.Position = UDim2.new(1, -30, 0, 0)
clsBtn.Text = "×"
clsBtn.TextColor3 = Color3.new(1, 0, 0)
clsBtn.BackgroundTransparency = 1

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1

local draggingSlider = nil

local function addSlider(name, y, max, default, globalVar)
	local sliderId = name
	local lab = Instance.new("TextLabel", content)
	lab.Size = UDim2.new(1, 0, 0, 15)
	lab.Position = UDim2.new(0, 0, 0, y)
	lab.Text = name..": "..default
	lab.TextColor3 = Color3.new(1,1,1)
	lab.TextSize = 11
	lab.Font = Enum.Font.GothamMedium
	lab.BackgroundTransparency = 1

	local sliderBg = Instance.new("TextButton", content)
	sliderBg.Size = UDim2.new(0.9, 0, 0, 4)
	sliderBg.Position = UDim2.new(0.05, 0, 0, y + 20)
	sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sliderBg.Text = ""
	sliderBg.AutoButtonColor = false
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 1)

	local fill = Instance.new("Frame", sliderBg)
	fill.Size = UDim2.new(default/max, 0, 1, 0)
	fill.BackgroundColor3 = Color3.new(1,1,1)
	fill.BorderSizePixel = 0
	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(0, 1)

	local gradient = Instance.new("UIGradient", fill)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	})

	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local tween = TweenService:Create(gradient, tweenInfo, {Offset = Vector2.new(-1, 0)})
	tween:Play()
	
	local dot = Instance.new("Frame", fill)
	dot.Size = UDim2.new(0, 7, 0, 7)
	dot.Position = UDim2.new(1, -3.5, 0.5, -3.5)
	dot.BackgroundColor3 = Color3.new(1,1,1)
	local dotCorner = Instance.new("UICorner", dot)
	dotCorner.CornerRadius = UDim.new(1, 0)

	task.spawn(function()
		while task.wait() do
			local h = tick() % 5 / 5
			local rainbowColor = Color3.fromHSV(h, 1, 1)
			dot.BackgroundColor3 = rainbowColor
			if name == "Speed" then
				title.TextColor3 = rainbowColor
			end
		end
	end)
	
	local function update(input)
		local mousePos = input.Position.X
		local barPos = sliderBg.AbsolutePosition.X
		local barSize = sliderBg.AbsoluteSize.X
		local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		local val = math.floor(percent * max)
		if globalVar == "SpeedVal" and val > 290 and val < 300 then
			val = 1000
		elseif globalVar == "SpeedVal" and val > 299 then
			val = 3000
		end
		
		lab.Text = name..": "..val
		_G[globalVar] = val
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = sliderId
			main.Draggable = false
			update(input)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if draggingSlider == sliderId and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if draggingSlider == sliderId then draggingSlider = nil main.Draggable = true end
		end
	end)
end

addSlider("Speed", 5, 300, 16, "SpeedVal")
addSlider("Jump", 45, 500, 50, "JumpVal")
addSlider("Inf Jump Debounce (ms)", 85, 1000, 10, "InfJumpDelay")

--[[
addSlider("Set Cash Value", 245, 100000, 0, "SetCash")
local SetCash = Instance.new("TextButton", content)
SetCash.Size = UDim2.new(0.9, 0, 0, 20)
SetCash.Position = UDim2.new(0.05, 0, 0, 275)
SetCash.BackgroundColor3 = Color3.fromRGB(18, 221, 7)
SetCash.Text = "Set Cash"
SetCash.TextColor3 = Color3.new(1,1,1)
SetCash.Font = Enum.Font.GothamBold
SetCash.TextSize = 12
Instance.new("UICorner", SetCash)
SetCash.MouseButton1Click:Connect(function()
end)
]]--

local ijBtn = Instance.new("TextButton", content)
ijBtn.Size = UDim2.new(0.9, 0, 0, 30)
ijBtn.Position = UDim2.new(0.05, 0, 0, 125)
ijBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
ijBtn.Text = "Inf Jump: OFF"
ijBtn.TextColor3 = Color3.new(1,1,1)
ijBtn.Font = Enum.Font.GothamBold
ijBtn.TextSize = 12
Instance.new("UICorner", ijBtn)

ijBtn.MouseButton1Click:Connect(function()
	_G.InfJump = not _G.InfJump
	ijBtn.Text = _G.InfJump and "Inf Jump: ON" or "Inf Jump: OFF"
	ijBtn.BackgroundColor3 = _G.InfJump and Color3.fromRGB(20, 80, 20) or Color3.fromRGB(80, 20, 20)
end)

local Delete = false
local DeleteBtn = Instance.new("TextButton", content)
DeleteBtn.Size = UDim2.new(0.9, 0, 0, 30)
DeleteBtn.Position = UDim2.new(0.05, 0, 0, 165)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
DeleteBtn.Text = "Delete mode deactivated"
DeleteBtn.TextColor3 = Color3.new(1,1,1)
DeleteBtn.Font = Enum.Font.GothamBold
DeleteBtn.TextSize = 12
Instance.new("UICorner", DeleteBtn)

DeleteBtn.MouseButton1Click:Connect(function()
	if Delete == false then
		Delete = true
		spawnBtn.Text = "Delete mode activated"
		spawnBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
	else
		Delete = false
		spawnBtn.Text = "Delete mode deactivated"
		spawnBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
	end
end)

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

player.CharacterAdded:Wait()
task.wait(0.5)

local deleted = player.Character:GetChildren()
local Orig = {}

mouse.Button1Down:Connect(function()
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = deleted
	
	if not Delete then rayParams.FilterType = Enum.RaycastFilterType.Include end
	local ray = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, mouse.Hit.LookVector * 100, rayParams)
	if not ray then return end
	
	local target = ray.Instance
	if target then
		if table.find(deleted, target) and not Delete and target.Parent ~= player.Character then
			target.Transparency = Orig[target].Transparency
			target.CanCollide = Orig[target].CanCollide
			Orig[target] = nil
			table.remove(deleted, table.find(deleted, target))
		elseif Delete and not table.find(deleted, target) and target.Parent ~= player.Character then
			Orig[target] = {Transparency = target.Transparency, CanCollide = target.CanCollide}
			target.Transparency = 0.8
			target.CanCollide = false
			table.insert(deleted, target)
		end
	end
end)

local SitBtn = Instance.new("TextButton", content)
SitBtn.Size = UDim2.new(0.3, 0, 0, 30)
SitBtn.Position = UDim2.new(0.05, 0, 0, 205)
SitBtn.BackgroundColor3 = Color3.fromRGB(40, 8, 147)
SitBtn.Text = "Sit"
SitBtn.TextColor3 = Color3.new(1,1,1)
SitBtn.Font = Enum.Font.GothamBold
SitBtn.TextSize = 12
Instance.new("UICorner", SitBtn)

SitBtn.MouseButton1Click:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.Sit = not player.Character.Humanoid.Sit
	end
end)

local SetJumpBtn = Instance.new("TextButton", content)
SetJumpBtn.Size = UDim2.new(0.25, 0, 0, 30)
SetJumpBtn.Position = UDim2.new(0.4, 0, 0, 205)
SetJumpBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
SetJumpBtn.Text = "Auto Set Jump (On)"
SetJumpBtn.TextColor3 = Color3.new(1,1,1)
SetJumpBtn.Font = Enum.Font.GothamBold
SetJumpBtn.TextSize = 12
SetJumpBtn.TextWrapped = true
Instance.new("UICorner", SetJumpBtn)

local AutoSetJump = true
SetJumpBtn.MouseButton1Click:Connect(function()
	AutoSetJump = not AutoSetJump
	if AutoSetJump and SetJumpBtn then
		SetJumpBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
		SetJumpBtn.Text = "Auto Set Jump (On)"
	else
		SetJumpBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
		SetJumpBtn.Text = "Auto Set Jump (Off)"
	end
end)

local SetSpeedBtn = Instance.new("TextButton", content)
SetSpeedBtn.Size = UDim2.new(0.25, 0, 0, 30)
SetSpeedBtn.Position = UDim2.new(0.7, 0, 0, 205)
SetSpeedBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
SetSpeedBtn.Text = "Auto Set Speed (On)"
SetSpeedBtn.TextColor3 = Color3.new(1,1,1)
SetSpeedBtn.Font = Enum.Font.GothamBold
SetSpeedBtn.TextSize = 12
SetSpeedBtn.TextWrapped = true
Instance.new("UICorner", SetSpeedBtn)

local AutoSetSpeed = true
SetSpeedBtn.MouseButton1Click:Connect(function()
	AutoSetSpeed = not AutoSetSpeed
	if AutoSetSpeed and SetSpeedBtn then
		SetSpeedBtn.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
		SetSpeedBtn.Text = "Auto Set Speed (On)"
	else
		SetSpeedBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
		SetSpeedBtn.Text = "Auto Set Jump (Off)"
	end
end)

local tg = Instance.new("TextLabel", content)
tg.Size = UDim2.new(1, 0, 0, 20)
tg.Position = UDim2.new(0, 0, 0, 285)
tg.Text = "These Are NOT Hacks"
tg.Font = Enum.Font.GothamBold
tg.BackgroundTransparency = 1
tg.TextSize = 25

task.spawn(function()
	while task.wait(0.1) do
		pcall(function()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local hum = player.Character.Humanoid
				if AutoSetSpeed then hum.WalkSpeed = _G.SpeedVal end
				if AutoSetSpeed then hum.UseJumpPower = true end
				if AutoSetJump then hum.JumpPower = _G.JumpVal end
			end
		end)
	end
end)

minBtn.MouseButton1Click:Connect(function()
	main:TweenSize(main.Size.Y.Offset == 30 and UDim2.new(0, 260, 0, 350) or UDim2.new(0, 260, 0, 30), "Out", "Quad", 0.2, true)
end)
clsBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

RS.RenderStepped:Connect(function()
	local h = tick() % 5 / 5
	title.TextColor3 = Color3.fromHSV(h, 1, 1)
	tg.TextColor3 = Color3.fromHSV(h, 1, 1)
end)

local LastJump = time()
local Jumping = false

task.spawn(function()
	local humanoid = player.Character.Humanoid
	while task.wait() do
		if _G.InfJump and time() - LastJump > _G.InfJumpDelay / 1000 and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and Jumping then
			LastJump = time()
			player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		Jumping = false
	end
end)

UIS.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.Space and not gpe then
		Jumping = true
	end
end)
