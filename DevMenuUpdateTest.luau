local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GLOBAL VARIABLES -----------------------------------------------------------------------------------------------------------
local VersionName = "3.0"

_G.SpeedVal = 16
_G.JumpVal = 50
_G.InfJump = false
_G.InfJumpDelay = 0.1
_G.TrackFly = 0

local IconSizeY = 30
local paddingYoffset = 10
local paddingXscale = 0.05

local LoadedPage = 1
local pageTitles = {}
local pages = {}
local rainbowText = {}

-- CONTAINER SETUP -----------------------------------------------------------------------------------------------------------
for _, child in ipairs(player.PlayerGui:GetChildren()) do
	if string.find(child.Name, "Athiel's DevMenu") then
		child:Destroy()
	end
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "Athiel's DevMenu v" .. VersionName
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 350)
main.Position = UDim2.new(0.1, -130, 0.5, -100)
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
title.Text = "Athiel's DevMenu v" .. VersionName
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- MAIN HANDLING FUNCTIONS -----------------------------------------------------------------------------------------------------------
local function SortPages()
  local sortedKeys = {}
  for id in pairs(pageTitles) do
    table.insert(sortedKeys, id)
  end
  
  table.sort(sortedKeys, function(id1, id2)
    return id1 < id2
  end)
  
  return sortedKeys
end

local function getNeighboringPage(currentId, change)
  local sortedKeys = SortPages()
  
  local currentIndex = table.find(sortedKeys, currentId)
  if not currentIndex then return nil end
  
  local newIndex = currentIndex + change
  local total = #sortedKeys
  while newIndex > total do
    newIndex = newIndex - total
  end
  while newIndex < 1 do
    newIndex = newIndex + total
  end
  
  return sortedKeys[newIndex]
end

local function newContent(page)
  local content = Instance.new("Frame", main)
  content.Name = "Content"
  content.Size = UDim2.new(1, 0, 1, -30)
  content.Position = UDim2.new(page - LoadedPage, 0, 0, 30)
  content.BackgroundTransparency = 1
  content:SetAttribute("Page", page)
  pageTitles[page] = "Unnamed"
  
  local scaled = (1 - (4*paddingXscale))
  local pageTitle = Instance.new("TextLabel", content)
  pageTitle.Size = UDim2.new(scaled / 2, 0, 0, 30)
  pageTitle.Position = UDim2.new(paddingXscale, 0, 0, paddingYoffset)
  pageTitle.Text = ("Page " .. page .. " - " .. pageTitles[page])
  pageTitle.TextColor3 = Color3.new(1,1,1)
  pageTitle.Font = Enum.Font.GothamBold
  pageTitle.TextScaled = true
  pageTitle.BackgroundTransparency = 1
  pageTitle.TextXAlignment = Enum.TextXAlignment.Left
  
  local rightBtn = Instance.new("TextButton", content)
  rightBtn.Name = "right"
  rightBtn.Size = UDim2.new(scaled / 4, 0, 0, 30)
  rightBtn.Position = UDim2.new((paddingXscale * 2) + (scaled/4*3), 0, 0, paddingYoffset)
  rightBtn.Text = ">"
  rightBtn.TextColor3 = Color3.new(1,1,1)
  rightBtn.BackgroundTransparency = 1
  
  local leftBtn = Instance.new("TextButton", content)
  leftBtn.Name = "left"
  leftBtn.Size = UDim2.new(scaled / 4, 0, 0, 30)
  leftBtn.Position = UDim2.new((paddingXscale * 2) + (scaled/2), 0, 0, paddingYoffset)
  leftBtn.Text = "<"
  leftBtn.TextColor3 = Color3.new(1,1,1)
  leftBtn.BackgroundTransparency = 1
end

local function getPageContentParent(page)
  if not pages[page] then
    pages[page] = newContent(page)
  end
  return pages[page]
end

local function InsertInstanceIntoPage(inst)
  if inst and inst.Name and inst.Position and inst.Size then
    local new = getPageContentParent(LoadedPage)
    inst.Parent = new
  end
end

local connection1, connection2 = nil, nil

sg.Destroying:Connect(function()
	if connection1 then connection1:Disconnect() connection1 = nil end
  	if connection2 then connection2:Disconnect() connection2 = nil end
end)

local function SwapPage(NewPage)
  local p1 = getPageContentParent(LoadedPage)
  local p2 = getPageContentParent(NewPage)
  
  if connection1 then connection1:Disconnect() connection1 = nil end
  if connection2 then connection2:Disconnect() connection2 = nil end
  
  connection1 = p2["right"].MouseButton1Click:Connect(SwapPage(getNeighboringPage(page, 1)))
  connection2 = p2["left"].MouseButton1Click:Connect(SwapPage(getNeighboringPage(page, -1)))
  
  for _, inst in ipairs(main:GetChildren()) do
    if inst.Name == "Content" then
      local CP = inst:GetAttribute("Page")
      if CP > math.min(NewPage, LoadedPage) and CP < math.max(NewPage, LoadedPage) then
        local endPos = UDim2.new(page - LoadedPage, 0, 0, 30)
        
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(inst, tweenInfo, {Position = endPos})
        task.spawn(function() tween:Play() end)
      else
        content.Position = UDim2.new(page - LoadedPage, 0, 0, 30)
      end
    end
  end
  LoadedPage = NewPage
end
SwapPage(1)

-- INSERT AND CREATE ITEMS / SLIDERS -----------------------------------------------------------------------------------------------------------
local function AddItem(inst, page, ItemSize, ItemType, NewLine, Color, Text, TextColor, Max, default, globalVar)
  -- inst refers to the Instance        -->  SET TO FALSE WITH SLIDER
  -- page refers to which page the item will be held on
  -- ItemSize is 1: Max stretch, 2: Half stretch, 3: Quarter stretch
  -- ItemType is "Slider" or the Instance name BEFORE renaming it (instance type)
  -- NewLine is a bool, whether you write the item on a new line or on the current line of content
  -- Color is Color3.new() defines the background color
  -- Text is the text displayed, title of slider or button or label
  -- TextColor is the color of the text displayed (Text)
  
  -- SLIDER ONLY
  -- Max is SLIDER ONLY, sets the max value of the slider
  -- default is SLIDER ONLY, sets the default starting value on the slider
  -- globalVar is SLIDER ONLY, slider sets the globar variable named after that to it's value
  local content = getPageContentParent(page)
  local items = pages(page)
  
  local Ystart = 0
  local Xstart = 0
  if NewLine then
    Xstart = paddingXscale
    Ystart = items[#items].Position.Y.Offset + paddingYoffset + items[#items].Size.Y.Offset
  else
    Xstart = items[#items].Position.X.Scale + items[#items].Size.X.Scale + paddingXscale
    Ystart = items[#items].Position.Y.Offset
  end
  local startPos = UDim2.new(Xstart, 0, 0, Ystart)
  
  local startSize = UDim2.new(0, 0, 0, 0)
  if ItemSize == 1 then
    startSize = UDim2.new(1 - startPos.X.Scale - paddingXscale, 0, 0, IconSizeY)
    if startSize.X.Scale < 0.2 then
      Xstart = paddingXscale
      startPos = UDim2.new(Xstart, 0, 0, Ystart)
      startSize = UDim2.new(1 - startPos.X.Scale - paddingXscale, 0, 0, IconSizeY)
    end
  elseif ItemSize == 2 then
    local tempVal = 1 - (startPos.X.Scale + (3 * paddingXscale))
    startSize = UDim2.new(tempVal/2, 0, 0, IconSizeY)
  elseif ItemSize == 3 then
    local tempVal = 1 - (startPos.X.Scale + (5 * paddingXscale))
    startSize = UDim2.new(tempVal/4, 0, 0, IconSizeY)
  end
  if ItemType == "TextButton" or ItemType == "TextLabel" then
    inst.Size = startSize
    inst.Position = startPos
    inst.BackgroundColor3 = Color
    inst.Text = Text
    if ItemType == "TextLabel" and not TextColor then
      table.insert(rainbowText, inst)
    else
      inst.TextColor3 = TextColor
    end
  elseif ItemType == "Slider" then
    local r1, r2 = addSlider(Text, startPos, startSize, Max, default, globalVar, TextColor, page)
    if r1 and r2 then
      InsertInstanceIntoPage(r1)
      InsertInstanceIntoPage(r2)
    end
  end
end

local draggingSlider = nil

local function addSlider(name, pos, size, max, default, globalVar, color, page)
  local content = getPageContentParent(page)
	local sliderId = name
	local lab = Instance.new("TextLabel", content)
	lab.Name = sliderId
	lab.Size = UDim2.new(size.X.Scale, 0, 0, size.Y.Offset/2) -- 1, 0, 0, 15
	lab.Position = pos
	lab.Text = name..": "..default
	lab.TextColor3 = color or Color3.new(1,1,1)
	lab.TextSize = 11
	lab.Font = Enum.Font.GothamMedium
	lab.BackgroundTransparency = 1

	local sliderBg = Instance.new("TextButton", content)
	sliderBg.Name = sliderId
	sliderBg.Size = UDim2.new(size.X.Scale*0.9, 0, 0, 4*(size.Y.Offset/15))
	sliderBg.Position = UDim2.new(pos.X.Scale, 0, 0, pos.Y.Offset + 20*(size.Y.Offset/15))
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
    ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
  })
  
  gradient.Offset = Vector2.new(-1, 0)
  
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
  local tween = TweenService:Create(gradient, tweenInfo, {Offset = Vector2.new(1, 0)})
  tween:Play()
  
  local multi = math.min(size.X.Scale*0.9, size.Y.Offset/15)
  
	local dot = Instance.new("Frame", fill)
	dot.Size = UDim2.new(0, 7*multi, 0, 7*multi)
	dot.Position = UDim2.new(1, -3.5*multi, 0.5, -3.5*multi)
	dot.BackgroundColor3 = Color3.new(1,1,1)
	local dotCorner = Instance.new("UICorner", dot)
	dotCorner.CornerRadius = UDim.new(1, 0)

	task.spawn(function()
		while task.wait() do
			local h = tick() % 5 / 5
			local rainbowColor = Color3.fromHSV(h, 1, 1)
			dot.BackgroundColor3 = rainbowColor
			if not color then
				title.TextColor3 = rainbowColor
			end
		end
	end)

	local function update(input)
	  if not sg then return end
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
	return lab, sliderBg
end

-- SETUP HEADER CONTENANTS -----------------------------------------------------------------------------------------------------------
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

-- CREATE SLIDERS -----------------------------------------------------------------------------------------------------------
addSlider("Speed", 5, 300, 16, "SpeedVal")
addSlider("Jump", 45, 500, 50, "JumpVal")
addSlider("Inf Jump Debounce (ms)", 85, 1000, 10, "InfJumpDelay")
addSlider("Velocity Power", 245, 100, 1, "TrackFly")

-- CREATE BUTTONS AND TEXT -----------------------------------------------------------------------------------------------------------
local TrackFly = Instance.new("TextButton", content)
TrackFly.Size = UDim2.new(0.9, 0, 0, 20)
TrackFly.Position = UDim2.new(0.05, 0, 0, 275)
TrackFly.BackgroundColor3 = Color3.fromRGB(18, 221, 7)
TrackFly.Text = "Start / End Loop"
TrackFly.TextColor3 = Color3.new(1,1,1)
TrackFly.Font = Enum.Font.GothamBold
TrackFly.TextSize = 12
Instance.new("UICorner", TrackFly)

local RUNLOOP = false
local function run()
	repeat
		task.spawn(function()
			local Controller = game.Workspace.Track.Loiper2:FindFirstChild("VehicleSeat")
			print("Before  ".. Controller.AssemblyLinearVelocity)
			local camera = workspace.CurrentCamera
			local lookDirection = camera.CFrame.LookVector
			Controller.AssemblyLinearVelocity = lookDirection * _G.TrackFly
			print("After  ".. Controller.AssemblyLinearVelocity)
		end)
		task.wait(0.2)
	until RUNLOOP == false
end

TrackFly.MouseButton1Click:Connect(function()
	RUNLOOP = not RUNLOOP
	if RUNLOOP then
		run()
	end
end)

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

function fling()
	local h = game.Players.LocalPlayer.Character.Humanoid
	if h:GetState() == Enum.HumanoidStateType.Physics then
		h:ChangeState(Enum.HumanoidStateType.GettingUp)
	else
		h:ChangeState(Enum.HumanoidStateType.Physics)
	end
	--[[
	local jump = Instance.new("Part")
	jump.Name = "JumpPart"
	jump.Anchored = true
	jump.Parent = workspace
	jump.Size = Vector3.new(20, 50, 20)
	jump.Position = game.Players.LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -28, 0)
	jump.Transparency = 0
	jump.AssemblyLinearVelocity = Vector3.new(0, -1000, 0)
	task.wait(2)
	jump:Destroy()
	]]--
end

local FlingBtn = Instance.new("TextButton", content)
FlingBtn.Size = UDim2.new(0.2, 0, 0, 30)
FlingBtn.Position = UDim2.new(0, 0, 0, 205)
FlingBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
FlingBtn.Text = "Fling"
FlingBtn.TextColor3 = Color3.new(1,1,1)
FlingBtn.Font = Enum.Font.GothamBold
FlingBtn.TextSize = 12
Instance.new("UICorner", FlingBtn)

FlingBtn.MouseButton1Click:Connect(fling)

local Delete = false
local Deltype = 1
local DeleteBtn = Instance.new("TextButton", content)
DeleteBtn.Size = UDim2.new(0.7, 0, 0, 30)
DeleteBtn.Position = UDim2.new(0.05, 0, 0, 165)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
DeleteBtn.Text = "Delete mode deactivated"
DeleteBtn.TextColor3 = Color3.new(1,1,1)
DeleteBtn.Font = Enum.Font.GothamBold
DeleteBtn.TextSize = 12
Instance.new("UICorner", DeleteBtn)

DeleteBtn.MouseButton1Click:Connect(function()
	if Delete and Deltype == 2 then
		DeleteBtn.Text = "Delete mode Max"
		Deltype = 3
	else
		Delete = not Delete
		if Deltype == 3 then
			Deltype = 1
		else
			Deltype += 1
		end
		DeleteBtn.Text = Delete and "Delete mode activated" or "Delete mode deactivated"
		DeleteBtn.BackgroundColor3 = Delete and Color3.fromRGB(20, 80, 20) or Color3.fromRGB(80, 20, 20)
	end
end)

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local Keybind = Enum.KeyCode.F
local Selecting = false
local ResetVelocityBtn = Instance.new("TextButton", content)
ResetVelocityBtn.Size = UDim2.new(0.15, 0, 0, 30)
ResetVelocityBtn.Position = UDim2.new(0.8, 0, 0, 165)
ResetVelocityBtn.BackgroundColor3 = Color3.fromRGB(139, 132, 255)
ResetVelocityBtn.Text = "KEYBIND"
ResetVelocityBtn.TextColor3 = Color3.new(1,1,1)
ResetVelocityBtn.Font = Enum.Font.GothamBold
ResetVelocityBtn.TextSize = 12
Instance.new("UICorner", ResetVelocityBtn)

ResetVelocityBtn.MouseButton1Click:Connect(function()
	task.wait(0.2)
	Selecting = not Selecting
	ResetVelocityBtn.BackgroundColor3 = Selecting and Color3.fromRGB(210, 200, 255) or Color3.fromRGB(139, 132, 255)
end)

local HoldingKeybind = false
UIS.InputEnded:Connect(function(input)
	if Selecting == false and input.KeyCode == Keybind then
		HoldingKeybind = false
	end
end)

local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	
	if Selecting then
		local mouseInputTypes = {
			Enum.UserInputType.MouseButton1,
			Enum.UserInputType.MouseButton2,
			Enum.UserInputType.MouseButton3
		}
		if table.find(mouseInputTypes, input.UserInputType) then
			task.wait(1)
			if Selecting == false then
				return
			end
		end
		Keybind = input.KeyCode
		ResetVelocityBtn.Text = Keybind
		
		Selecting = false
		ResetVelocityBtn.BackgroundColor3 = Color3.fromRGB(139, 132, 255)
	end
	if Selecting == false and input.KeyCode == Keybind then
		HoldingKeybind = true
		while HoldingKeybind and task.wait(0.01) do
			local character = player.Character or player.CharacterAdded:Wait()
			local rootPart = character:WaitForChild("HumanoidRootPart")
			rootPart.AssemblyLinearVelocity = Vector3.zero
			rootPart.AssemblyAngularVelocity = Vector3.zero
		end
	end
end
UIS.InputBegan:Connect(onInputBegan)

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
			print("return to normal")
			target.Transparency = Orig[target].Transparency
			target.CanCollide = Orig[target].CanCollide
			Orig[target] = nil
			table.remove(deleted, table.find(deleted, target))
		elseif Delete and not table.find(deleted, target) and target.Parent ~= player.Character then
			print("hide")
			Orig[target] = {Transparency = target.Transparency, CanCollide = target.CanCollide}
			if Deltype == 3 then
				target:Destroy()
			else
				target.Transparency = 0.8
				target.CanCollide = false
				table.insert(deleted, target)
			end
		end
	end
end)

local SitBtn = Instance.new("TextButton", content)
SitBtn.Size = UDim2.new(0.2, 0, 0, 30)
SitBtn.Position = UDim2.new(0.2, 0, 0, 205)
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
		SetSpeedBtn.Text = "Auto Set Speed (Off)"
	end
end)

local tg = Instance.new("TextLabel", content)
tg.Size = UDim2.new(1, 0, 0, 20)
tg.Position = UDim2.new(0, 0, 0, 285)
--tg.Text = "These Are NOT Hacks"
tg.Text = ""
tg.Font = Enum.Font.GothamBold
tg.BackgroundTransparency = 1
tg.TextSize = 25

-- CHARACTER VALUES AND INPUTS HANDLER -----------------------------------------------------------------------------------------------------------

task.spawn(function()
	while task.wait(0.1) and sg do
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
clsBtn.MouseButton1Click:Connect(function()
	script:Destroy()
	sg:Destroy()
end)

table.insert(rainbowText, title)
table.insert(rainbowText, tg)

RS.RenderStepped:Connect(function()
	local h = tick() % 5 / 5
	for _, inst in ipairs(rainbowText) do
	  inst.TextColor3 = Color3.fromHSV(h, 1, 1)
	end
end)

local LastJump = time()
local Jumping = false

task.spawn(function()
	local humanoid = player.Character.Humanoid
	while task.wait() and sg do
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
