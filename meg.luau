local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local mouse = player:GetMouse() or player:GetMouse():Wait()
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GLOBAL VARIABLES -----------------------------------------------------------------------------------------------------------
local VersionName = "3.0"

_G.SpeedVal = 16
_G.JumpVal = 50
_G.ASspeed = true
_G.ASjump = true
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
local AllInstances = {}
local pageNames = {}

-- CONTAINER SETUP -----------------------------------------------------------------------------------------------------------
print("Starting up Athiel's DevMenu v" .. VersionName)

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
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

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

	pageNames = sortedKeys

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
	pageTitle:SetAttribute("inList", true)

	local rightBtn = Instance.new("TextButton", content)
	rightBtn.Name = "right"
	rightBtn.Size = UDim2.new(scaled / 4, 0, 0, 30)
	rightBtn.Position = UDim2.new((paddingXscale * 2) + (scaled/4*3), 0, 0, paddingYoffset)
	rightBtn.Text = ">"
	rightBtn.TextColor3 = Color3.new(1,1,1)
	rightBtn.BackgroundTransparency = 1
	rightBtn:SetAttribute("inList", true)

	local leftBtn = Instance.new("TextButton", content)
	leftBtn.Name = "left"
	leftBtn.Size = UDim2.new(scaled / 4, 0, 0, 30)
	leftBtn.Position = UDim2.new((paddingXscale * 2) + (scaled/2), 0, 0, paddingYoffset)
	leftBtn.Text = "<"
	leftBtn.TextColor3 = Color3.new(1,1,1)
	leftBtn.BackgroundTransparency = 1
	leftBtn:SetAttribute("inList", true)

	local PageSplit = Instance.new("Frame", content)
	PageSplit.Name = "PageSplit"
	PageSplit.Size = UDim2.new(scaled / 4, 0, 0, 5)
	PageSplit.Position = UDim2.new((paddingXscale * 2) + (scaled/2), 0, 0, 30 + paddingYoffset*2)
	PageSplit.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	PageSplit.BackgroundTransparency = 0.5
	PageSplit:SetAttribute("inList", true)

	return content
end

local function getPageContentParent(page)
	if pages[page] == nil then
		if typeof(page) == "Instance" then
			if page:GetAttribute("Page") then
				warn("Asking for pageContent using pageContent")
				return page
			end
		elseif typeof(page) == "table" then
			if page[1] and page[1].Parent then
				local temp = page[1].Parent
				if temp:GetAttribute("Page") then
					warn("Asking for pageContent using pageContent list of children")
					return temp
				end
			end
		end
		local values = {}
		for a, id in pairs(pageTitles) do
			values[id] = a
		end
		if values[page] then
			local p = getPageContentParent(values[page])
			if p then
				warn("Asking for pageContent from pageTitle")
				return p
			end
		end

		pages[page] = newContent(page)
	end
	return pages[page]
end

local function InsertInstanceIntoPage(inst, page)
	if inst and inst.Name and inst.Position and inst.Size then
		local new = getPageContentParent(page)
		inst.Parent = new
		inst:SetAttribute("inList", true)
	end
end

local function getLowestItemInPage(page)
	local lowest = nil
	for _, inst in ipairs(main:GetChildren()) do
		if inst.Name == "Content" then
			local CP = inst:GetAttribute("Page")
			if CP == page then
				for _, i in ipairs(inst:GetChildren()) do
					if (((lowest == nil or i.Position.Y.Offset > lowest.Position.Y.Offset) or (lowest == nil or i.Position.X.Scale > lowest.Position.X.Scale)) and i:GetAttribute("inList")) then
						lowest = i
					end
				end
			end
		end
	end
	return lowest
end

local function GetMainSize(page)
	local lowest = getLowestItemInPage(page)
	if not lowest then return UDim2.new(0, 260, 0, 350) end
	local Ysize = lowest.Position.Y.Offset + lowest.Size.Y.Offset + IconSizeY + paddingYoffset
	return UDim2.new(0, 260, 0, Ysize)
end

local function AddToAllInstances(inst, lookupVal, page)
	if inst then
		local LKV = lookupVal or inst.Name
		local P = page or LoadedPage
		if not AllInstances[P] then AllInstances[P] = {} end
		if AllInstances[P] then AllInstances[P][LKV] = inst end
	end
end

local function GetInstance(name, page, instType)
	local function FitsCriteria(iN, i, n, t)
		if n and n ~= iN then return false end
		if t and not i:IsA(t) then return false end
		return true
	end
	
	local function LoopPage(p, n, t)
		local list = p
		if typeof(p) ~= "table" then
			list = p:GetDescendants()
		end
		
		for i, inst in list do
			if FitsCriteria(i, inst, n, t) then
				return inst
			end
		end
		return false
	end

	local p = SortPages()
	local ans
	if name then
		if not page then
			local i = 1
			repeat
				i += 1
				local pg = getPageContentParent(p[i])
				ans = LoopPage(pg, name, instType)
				if ans then return ans end
			until i > #p
		else
			ans = LoopPage(AllInstances[page], name, instType)
			if ans then return ans end
		end
	end
end

local connection1, connection2 = nil, nil

sg.Destroying:Connect(function()
	if connection1 and connection1.Connected then connection1:Disconnect() connection1 = nil end
	if connection2 and connection1.Connected then connection2:Disconnect() connection2 = nil end
end)

local function SwapPage(NewPage)
	local p1 = getPageContentParent(LoadedPage)
	local p2 = getPageContentParent(NewPage)

	if connection1 then if connection1.Connected then connection1:Disconnect() connection1 = nil end end
	if connection2 then if connection2.Connected then connection2:Disconnect() connection2 = nil end end

	connection1 = p2:FindFirstChild("right")
	if connection1 then
		connection1 = connection1.MouseButton1Click:Connect(function()
			SwapPage(getNeighboringPage(NewPage, 1))
		end)
	end
	connection2 = p2:FindFirstChild("left")
	if connection2 then
		connection2 = connection2.MouseButton1Click:Connect(function()
			SwapPage(getNeighboringPage(NewPage, -1))
		end)
	end

	for _, inst in ipairs(main:GetChildren()) do
		if inst.Name == "Content" then
			local CP = inst:GetAttribute("Page")
			local targetPos = UDim2.new(CP - NewPage, 0, 0, 30)

			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			TweenService:Create(inst, tweenInfo, { Position = targetPos }):Play()
		end
	end

	main:TweenSize(GetMainSize(NewPage), "Out", "Quad", 0.2, true)
	LoadedPage = NewPage
end

-- INSERT AND CREATE ITEMS / SLIDERS -----------------------------------------------------------------------------------------------------------
local draggingSlider = nil

local function addSlider(name, pos, size, max, default, globalVar, color, page, newLine)
	local content = getPageContentParent(page)
	local sliderId = name

	local holder = Instance.new("Frame", content)
	holder.Name = sliderId
	holder.Size = UDim2.new(size.X.Scale, 0, 0, size.Y.Offset)
	holder.Position = pos
	holder.BackgroundTransparency = 1
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 0.3)

	local lab = Instance.new("TextLabel", holder)
	lab.Name = sliderId
	lab.Size = UDim2.new(0.8, 0, 0, holder.Size.Y.Offset/2.5)
	lab.Position = UDim2.new(0.1, 0, 0, holder.Size.Y.Offset/7.5)
	lab.Text = name..": "..default
	lab.TextColor3 = color or Color3.new(1,1,1)
	lab.TextSize = 11
	lab.Font = Enum.Font.GothamMedium
	lab.BackgroundTransparency = 1

	local sliderBg = Instance.new("TextButton", holder)
	sliderBg.Name = sliderId
	sliderBg.Size = UDim2.new(0.9, 0, 0, holder.Size.Y.Offset/9.35)
	sliderBg.Position = UDim2.new(0.05, 0, 0, holder.Size.Y.Offset/1.75)
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

	local val = fill.AbsoluteSize.Y

	local dot = Instance.new("Frame", fill)
	dot.Size = UDim2.new(0, val*1.5, 1.5, 0)
	dot.Position = UDim2.new(1, -val * 0.75, 0.5, -val * 0.75)
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
	return holder
end

local function AddItem(inst, page, name, ItemSize, ItemType, NewLine, Color, Transparency, Text, TextColor, Max, default, globalVar)
	-- inst refers to the Instance        -->  SET TO FALSE WITH SLIDER
	-- page refers to which page the item will be held on
	-- name is the lookup key it will use for accessing this instance
	-- ItemSize is 1: Max stretch, 2: Half stretch, 3: Quarter stretch
	-- ItemType is "Slider" or the Instance name BEFORE renaming it (instance type)
	-- NewLine is a bool, whether you write the item on a new line or on the current line of content
	-- Color is Color3.new() defines the background color
	-- Transparency is the BackgroundTransparency value
	-- Text is the text displayed, title of slider or button or label
	-- TextColor is the color of the text displayed (Text)

	-- SLIDER ONLY
	-- Max is SLIDER ONLY, sets the max value of the slider
	-- default is SLIDER ONLY, sets the default starting value on the slider
	-- globalVar is SLIDER ONLY, slider sets the globar variable named after that to it's value
	local content = getPageContentParent(page)
	local items = pages[page]
	local ti = getLowestItemInPage(page) or {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0, 0, 0, 0)}

	local Ystart = 0
	local Xstart = 0
	if NewLine then
		Xstart = paddingXscale
		Ystart = ti.Position.Y.Offset + paddingYoffset + ti.Size.Y.Offset
	else
		Xstart = ti.Position.X.Scale + ti.Size.X.Scale + paddingXscale
		Ystart = ti.Position.Y.Offset
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
	else
		local tempVal = 1 - (startPos.X.Scale)
		startSize = UDim2.new(tempVal*ItemSize, 0, 0, IconSizeY)
	end
	if ItemType == "TextButton" or ItemType == "TextLabel" then
		inst.TextWrapped = true
		inst.Size = startSize
		inst.Position = startPos
		if Color then inst.BackgroundColor3 = Color end
		if Transparency then inst.BackgroundTransparency = Transparency end
		inst.Text = Text or ""
		if ItemType == "TextLabel" and not TextColor then
			table.insert(rainbowText, inst)
		else
			inst.TextColor3 = TextColor or Color3.new(1, 1, 1)
		end
		Instance.new("UICorner", inst)
		InsertInstanceIntoPage(inst, page)
	elseif ItemType == "Slider" then
		local r1 = addSlider(Text, startPos, startSize, Max, default, globalVar, TextColor, page, NewLine)
		if r1 then
			InsertInstanceIntoPage(r1, page)
			AddToAllInstances(r1, name, page)
		end
	elseif ItemType == "Frame" then
		startSize = UDim2.new(startSize.X.Offset, 0, 0, math.max(IconSizeY/5, 5))
		inst.Size = startSize
		inst.Position = startPos
		if Transparency then inst.BackgroundTransparency = Transparency end
		if Color then inst.BackgroundColor3 = Color end
		if not (Color or Transparency) then
			inst.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
			inst.BackgroundTransparency = 0.7
		end
		local UIC = Instance.new("UICorner", inst)
		UIC.CornerRadius = UDim.new(0, 1)
		InsertInstanceIntoPage(inst, page)
	end
	if ItemType == "TextButton" or ItemType == "Frame" or ItemType == "TextLabel" then
		AddToAllInstances(inst, name, page)
	end
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

minBtn.MouseButton1Click:Connect(function()
	print(GetMainSize(LoadedPage))
	main:TweenSize(main.Size.Y.Offset == 30 and UDim2.new(0, 260, 0, GetMainSize(LoadedPage).Y.Offset) or UDim2.new(0, 260, 0, 30), "Out", "Quad", 0.2, true)
end)

clsBtn.MouseButton1Click:Connect(function()
	script:Destroy()
	sg:Destroy()
end)

-- CREATE ALL INSTANCES -----------------------------------------------------------------------------------------------------------
local function LoadAllInstances()
	-- AddItem(inst, page, name, ItemSize, ItemType, NewLine, Color, Transparency, Text, TextColor, Max, default, globalVar)

	-- FIRST PAGE
	-- HUMANOID PROPERTIES (SPEED, JUMP, MULTI-JUMP)
	AddItem(nil, 1, "SpeedSlider", 1, "Slider", true, nil, nil, "Speed", nil, 300, 16, "SpeedVal")
	AddItem(nil, 1, "JumpSlider", 1, "Slider", true, nil, nil, "Jump", nil, 300, 16, "JumpVal")
	AddItem(nil, 1, "InfJumpDebounceSlider", 1, "Slider", true, nil, nil, "Inf Jump Debounce (ms)", nil, 300, 16, "InfJumpDelay")
	AddItem(Instance.new("TextButton"), 1, "InfJumpBtn", 0.5, "TextButton", true, Color3.new(0.8, 0, 0), 0, "InfJump OFF", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 1, "AutoSetSpeedBtn", 0.5, "TextButton", false, Color3.new(0, 0.8, 0), 0, "AutoSet Speed ON", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 1, "AutoSetJumpBtn", 0.99, "TextButton", false, Color3.new(0, 0.8, 0), 0, "AutoSet Jump ON", nil, nil, nil, nil)
	AddItem(Instance.new("Frame"), 1, "SplitOffHumanoidProperties", 1, "Frame", true, Color3.new(0.2, 0.2, 0.2), 0.7, nil, nil, nil, nil)

	-- HUMANOID STATES (FLING, SIT, RESET-VELOCITY)
	AddItem(Instance.new("TextButton"), 1, "FlingBtn", 0.5, "TextButton", true, Color3.new(0.5, 0, 0.5), 0, "Fling Character", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 1, "SitBtn", 0.5, "TextButton", false, Color3.new(0.5, 0, 0.5), 0, "Sit Character", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 1, "ResetVelocityBtn", 1, "TextButton", true, Color3.new(0.7, 0.6, 0.84), 0, "Reset Velocity Keybind: F", nil, nil, nil, nil)
	AddItem(Instance.new("Frame"), 1, "SplitOffHumanoidStates", 1, "Frame", true, Color3.new(0.2, 0.2, 0.2), 0.7, nil, nil, nil, nil)

	-- ENVIRONMENTAL CHANGES (DELETE)
	AddItem(Instance.new("TextButton"), 1, "DeleteBtn", 1, "TextButton", true, Color3.new(0.8, 0, 0), 0, "Delete Mode Deactivated", nil, nil, nil, nil)

	-- SECOND PAGE
	-- TRACK FLY (SPEED, TOGGLE)
	AddItem(nil, 2, "VelocityPowerSlider", 1, "Slider", true, nil, nil, "Velocity Power", nil, 300, 16, "TrackFly")
	AddItem(Instance.new("TextButton"), 2, "TrackFlyBtn", 1, "TextButton", true, Color3.new(0.8, 0, 0), 0, "Track Fly OFF", nil, nil, nil, nil)
	
	SwapPage(1)
end

LoadAllInstances()
print("Finished Loading Instances!")


-- INSTANCE BASED CODE -----------------------------------------------------------------------------------------------------------
local function InfJump(inst)
	inst.MouseButton1Click:Connect(function()
		_G.InfJump = (inst.Text == "Inf Jump OFF")
		inst.Text = _G.InfJump and "Inf Jump ON" or "Inf Jump OFF"
		inst.BackgroundColor3 = _G.InfJump and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
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
		if input.KeyCode == Enum.KeyCode.Space then Jumping = false end
	end)

	UIS.InputBegan:Connect(function(input, gpe)
		if input.KeyCode == Enum.KeyCode.Space and not gpe then Jumping = true end
	end)
end

local function AutoSetJump(inst)
	_G.ASjump = true
	inst.MouseButton1Click:Connect(function()
		_G.ASjump = not _G.ASjump
		if _G.ASjump and inst then
			inst.BackgroundColor3 = Color3.new(0, 0.8, 0)
			inst.Text = "AutoSet Jump ON"
		else
			inst.BackgroundColor3 = Color3.new(0.8, 0, 0)
			inst.Text = "AutoSet Jump OFF"
		end
	end)
end

local function AutoSetSpeed(inst)
	_G.ASspeed = true
	inst.MouseButton1Click:Connect(function()
		_G.ASspeed = not _G.ASspeed
		if _G.ASspeed and inst then
			inst.BackgroundColor3 = Color3.new(0, 0.8, 0)
			inst.Text = "AutoSet Speed ON"
		else
			inst.BackgroundColor3 = Color3.new(0.8, 0, 0)
			inst.Text = "AutoSet Speed OFF"
		end
	end)
end

local function Sit(inst)
	inst.MouseButton1Click:Connect(function()
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.Sit = not player.Character.Humanoid.Sit
		end
	end)
end

local function Fling(inst)
	local function f()
		local h = game.Players.LocalPlayer.Character.Humanoid -- REPLACE WITH PROPER FLING (only with states rn, should be done similar to OC upside down jump pad)
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
	inst.MouseButton1Click:Connect(f)
end

local function ResetVelocity(inst)
	local Keybind = Enum.KeyCode.F
	local Selecting = false

	inst.MouseButton1Click:Connect(function()
		task.wait(0.2)
		Selecting = not Selecting
		inst.BackgroundColor3 = Selecting and Color3.fromRGB(210, 200, 255) or Color3.fromRGB(139, 132, 255)
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
			inst.Text = "Reset Velocity Keybind: ".. Keybind.Name

			Selecting = false
			inst.BackgroundColor3 = Color3.fromRGB(139, 132, 255)
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
end

local function TrackFly(inst)
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

	inst.MouseButton1Click:Connect(function()
		RUNLOOP = not RUNLOOP
		if RUNLOOP then run() end
		inst.Text = RUNLOOP and "Track Fly ON" or "Track Fly OFF"
		inst.BackgroundColor3 = RUNLOOP and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
	end)
end

local function Delete(inst)
	local Delete = false
	local Deltype = 1
	inst.MouseButton1Click:Connect(function()
		Deltype += 1
		if Deltype > 3 then Deltype = 1 end
		Delete = Deltype > 1

		inst.Text = Deltype == 3 and "Delete mode Max" or Deltype == 2 and "Delete mode activated" or Deltype == 1 and "Delete mode deactivated"
		inst.BackgroundColor3 = Deltype == 3 and Color3.new(0.1, 0.9, 0) or Deltype == 2 and Color3.new(1, 0.5, 0) or Deltype == 1 and Color3.new(0.8, 0, 0)
	end)

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
end

-- CHARACTER VALUES AND INSTANCE CODE STARTER -----------------------------------------------------------------------------------------------------------
print(AllInstances)
InfJump(GetInstance("InfJumpBtn", 1, "TextButton"))
AutoSetSpeed(GetInstance("AutoSetSpeedBtn", 1, "TextButton"))
AutoSetJump(GetInstance("AutoSetJumpBtn", 1, "TextButton"))
Sit(GetInstance("SitBtn", 1, "TextButton"))
Fling(GetInstance("FlingBtn", 1, "TextButton"))
ResetVelocity(GetInstance("ResetVelocityBtn", 1, "TextButton"))
Delete(GetInstance("DeleteBtn", 1, "TextButton"))
TrackFly(GetInstance("TrackFlyBtn", 2, "TextButton"))

task.spawn(function()
	while task.wait(0.1) and sg do
		pcall(function()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local hum = player.Character.Humanoid
				if _G.ASspeed then hum.WalkSpeed = _G.SpeedVal end
				if _G.ASjump then hum.UseJumpPower = true end
				if _G.ASjump then hum.JumpPower = _G.JumpVal end
			end
		end)
	end
end)

table.insert(rainbowText, title)
RS.RenderStepped:Connect(function()
	local h = tick() % 5 / 5
	for _, inst in ipairs(rainbowText) do
		inst.TextColor3 = Color3.fromHSV(h, 1, 1)
	end
end)
