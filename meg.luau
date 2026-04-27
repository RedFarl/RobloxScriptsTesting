local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local mouse = player:GetMouse() or player:GetMouse():Wait()
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GLOBAL VARIABLES -----------------------------------------------------------------------------------------------------------
local VersionName = "4.1.3"
local RobloxStudioFriendly = false

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
local Data = {}

-- Pre-define Functions for later use
local loadData
local saveData

-- CONTAINER SETUP -----------------------------------------------------------------------------------------------------------
print("Starting up Athiel's DevMenu v" .. VersionName)

if RobloxStudioFriendly then task.wait(1.5) end

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
	if not pageTitles[page] then pageTitles[page] = "Unnamed" end

	local scaled = (1 - (4*paddingXscale))
	local pageTitle = Instance.new("TextBox", content)
	pageTitle.Name = "PageTitle"
	pageTitle.Size = UDim2.new(scaled / 2, 0, 0, 30)
	pageTitle.Position = UDim2.new(paddingXscale, 0, 0, paddingYoffset)
	pageTitle.Text = ("Page " .. page .. " - " .. pageTitles[page])
	pageTitle.PlaceholderText = "Tap to edit title..."
	pageTitle.TextColor3 = Color3.new(1,1,1)
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.TextScaled = true
	pageTitle.BackgroundTransparency = 1
	pageTitle.TextXAlignment = Enum.TextXAlignment.Left
	pageTitle:SetAttribute("inList", true)

	pageTitle.Focused:Connect(function()
		pageTitle.Text = pageTitles[page]
	end)

	pageTitle.FocusLost:Connect(function(enterPressed)
		if not (sg and main) then return end

		local newTitle = pageTitle.Text

		if newTitle ~= "" then
			pageTitles[page] = newTitle
			if saveData then saveData() end
		else
			pageTitle.Text = "Page " .. page .. " - " .. pageTitles[page]
		end
	end)

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
				i = i + 1
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

local function ResetPageTitles()
	local p = SortPages()
	local i = 1
	repeat
		local pg = getPageContentParent(p[i])
		if pg:FindFirstChild("PageTitle") then
			local pageNum = pg:GetAttribute("Page")
			pg:FindFirstChild("PageTitle").Text = ("Page " .. pageNum .. " - " .. pageTitles[pageNum])
		end
		i = i + 1
	until i > #p
end

local HttpService = game:GetService("HttpService")
local FileVersion = 1
local fileName = "AthielDevMenu:" .. FileVersion .. ".json"

saveData = function()
	if RobloxStudioFriendly then return end
	Data = pageTitles
	local json = HttpService:JSONEncode(Data)
	writefile(fileName, json)

	ResetPageTitles()
	print("Data saved to " .. fileName)
end

loadData = function()
	if RobloxStudioFriendly then return end
	if isfile(fileName) then
		local content = readfile(fileName)
		Data = HttpService:JSONDecode(content)
		if typeof(Data) == "table" then pageTitles = Data end

		ResetPageTitles()
		print("Data loaded!")
	else
		print("No save file found, using defaults.")
	end
end

local connection1, connection2 = nil, nil

sg.Destroying:Connect(function()
	saveData()
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
		startSize = UDim2.new(startSize.X.Scale, 0, 0, math.max(IconSizeY/5, 5))
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
	AddItem(Instance.new("TextButton"), 1, "InfJumpBtn", 0.5, "TextButton", true, Color3.new(0.8, 0, 0), 0, "Inf Jump OFF", nil, nil, nil, nil)
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

	-- THIRD PAGE
	-- WORLD MODIFICATION (SELECT, LOAD, UPDATE, MODIFY)
	AddItem(Instance.new("TextButton"), 3, "SelectionBtn", 1, "TextButton", true, Color3.new(0.8, 0, 0), 0, "No Part Selected", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "LoadPropertiesBtn", 1, "TextButton", true, Color3.new(0.0588235, 0.501961, 0.8), 0, "Load Properties", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "CloneBtn", 0.5, "TextButton", true, Color3.new(0.3, 0.86, 0.4), 0, "Clone Selected Part", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "SetParentBtn", 1, "TextButton", false, Color3.new(0.3, 0.86, 0.4), 0, "SetInst Parent", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "GetPositionBtn", 1, "TextButton", true, Color3.new(0.8, 0, 0), 0, "No Target Position", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "ExplorerBtn", 1, "TextButton", true, Color3.new(0.15, 0.55, 0.25), 0, "Open Explorer", nil, nil, nil, nil)
	AddItem(Instance.new("TextButton"), 3, "OpenExplorerAtBtn", 1, "TextButton", true, Color3.new(0.1, 0.45, 0.18), 0, "Open Explorer At Selected Part", nil, nil, nil, nil)

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
			while HoldingKeybind and task.wait(0.01 + ((input.KeyCode == Enum.KeyCode.Z)*0.5)) do
				local character = player.Character or player.CharacterAdded:Wait()
				local rootPart = character:WaitForChild("HumanoidRootPart")
				if input.KeyCode ~= Enum.KeyCode.Z then
					rootPart.AssemblyLinearVelocity = Vector3.zero
					rootPart.AssemblyAngularVelocity = Vector3.zero
				else
					local alv = rootPart.AssemblyLinearVelocity
					rootPart.AssemblyLinearVelocity = Vector3.new(alv.X*10,math.abs(alv.Y)*10,alv.Z*10)
				end
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
		Deltype = Deltype + 1
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

		if not Delete then rayParams.FilterDescendantsInstances = {player.Character} end
		local ray = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, mouse.Hit.LookVector * 300, rayParams)
		if not ray then return end

		local target = ray.Instance
		if target then
			if (table.find(deleted, target) or target:IsA("BasePart")) and not Delete and target.Parent ~= player.Character then
				if math.abs(target.Transparency - 0.8) < 0.05 and target.CanCollide == false then
					target.Transparency = 0
					target.CanCollide = true
					-- Orig[target] = nil
					-- table.remove(deleted, table.find(deleted, target))
				end
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

-- PROPERTIES PANEL -----------------------------------------------------------------------
local SelectionPart = nil
local SelectionParent = game.Workspace or nil
local Properties = { props = {}, attrs = {}, values = {} }

local function clearOldProperties(gui)
	local old = gui:FindFirstChild("PropertiesPanel")
	if old then
		old:Destroy()
	end
end

local function makeDraggable(frame)
	local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
	frame.Active = true

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input == dragInput and dragStart and startPos then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function splitNums(text)
	local out = {}
	for part in tostring(text):gmatch("[^,%s]+") do
		local n = tonumber(part)
		if not n then
			return nil
		end
		out[#out + 1] = n
	end
	return out
end

local function formatValue(v)
	if v == nil then
		return "nil"
	end

	local t = typeof(v)
	if t == "string" or t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Vector2" then
		return string.format("%g,%g", v.X, v.Y)
	elseif t == "Vector3" then
		return string.format("%g,%g,%g", v.X, v.Y, v.Z)
	elseif t == "Vector2int16" then
		return string.format("%d,%d", v.X, v.Y)
	elseif t == "Vector3int16" then
		return string.format("%d,%d,%d", v.X, v.Y, v.Z)
	elseif t == "UDim" then
		return string.format("%g,%d", v.Scale, v.Offset)
	elseif t == "UDim2" then
		return string.format("%g,%d,%g,%d", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
	elseif t == "Color3" then
		return string.format("%d,%d,%d", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
	elseif t == "BrickColor" then
		return v.Name
	elseif t == "EnumItem" then
		return tostring(v)
	elseif t == "CFrame" then
		return table.concat({ v:GetComponents() }, ",")
	elseif t == "NumberRange" then
		return string.format("%g,%g", v.Min, v.Max)
	elseif t == "PhysicalProperties" then
		return string.format("%g,%g,%g,%g,%g", v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight)
	elseif t == "Ray" then
		return string.format("%g,%g,%g,%g,%g,%g", v.Origin.X, v.Origin.Y, v.Origin.Z, v.Direction.X, v.Direction.Y, v.Direction.Z)
	elseif t == "Instance" then
		return v:GetFullName()
	else
		return tostring(v)
	end
end

local function parseValue(kind, text, old)
	text = tostring(text)

	if kind == "string" then
		return text
	elseif kind == "number" then
		return tonumber(text)
	elseif kind == "boolean" then
		local v = text:lower()
		if v == "true" or v == "1" or v == "yes" then return true end
		if v == "false" or v == "0" or v == "no" then return false end
		return nil
	elseif kind == "Vector2" then
		local n = splitNums(text)
		if n and #n == 2 then
			return Vector2.new(n[1], n[2])
		end
	elseif kind == "Vector3" then
		local n = splitNums(text)
		if n and #n == 3 then
			return Vector3.new(n[1], n[2], n[3])
		end
	elseif kind == "Vector2int16" then
		local n = splitNums(text)
		if n and #n == 2 then
			return Vector2int16.new(math.floor(n[1]), math.floor(n[2]))
		end
	elseif kind == "Vector3int16" then
		local n = splitNums(text)
		if n and #n == 3 then
			return Vector3int16.new(math.floor(n[1]), math.floor(n[2]), math.floor(n[3]))
		end
	elseif kind == "UDim" then
		local n = splitNums(text)
		if n and #n == 2 then
			return UDim.new(n[1], n[2])
		end
	elseif kind == "UDim2" then
		local n = splitNums(text)
		if n and #n == 4 then
			return UDim2.new(n[1], n[2], n[3], n[4])
		end
	elseif kind == "Color3" then
		local n = splitNums(text)
		if n and #n == 3 then
			if n[1] > 1 or n[2] > 1 or n[3] > 1 then
				return Color3.fromRGB(
					math.clamp(math.floor(n[1] + 0.5), 0, 255),
					math.clamp(math.floor(n[2] + 0.5), 0, 255),
					math.clamp(math.floor(n[3] + 0.5), 0, 255)
				)
			end
			return Color3.new(math.clamp(n[1], 0, 1), math.clamp(n[2], 0, 1), math.clamp(n[3], 0, 1))
		end
	elseif kind == "BrickColor" then
		local ok, bc = pcall(BrickColor.new, text)
		if ok then
			return bc
		end
	elseif kind == "EnumItem" then
		local enumType = tostring(old):match("^Enum%.([^%.]+)%.")
		local itemName = text:match("^Enum%.[^%.]+%.(.+)$") or text
		if enumType and Enum[enumType] and Enum[enumType][itemName] then
			return Enum[enumType][itemName]
		end
	elseif kind == "CFrame" then
		local n = splitNums(text)
		if n and #n == 12 then
			return CFrame.new(table.unpack(n))
		end
	elseif kind == "NumberRange" then
		local n = splitNums(text)
		if n and (#n == 1 or #n == 2) then
			return NumberRange.new(n[1], n[2] or n[1])
		end
	elseif kind == "PhysicalProperties" then
		local n = splitNums(text)
		if n and #n == 5 then
			return PhysicalProperties.new(n[1], n[2], n[3], n[4], n[5])
		end
	elseif kind == "Ray" then
		local n = splitNums(text)
		if n and #n == 6 then
			return Ray.new(Vector3.new(n[1], n[2], n[3]), Vector3.new(n[4], n[5], n[6]))
		end
	end

	return nil
end

local function canWriteProperty(inst, prop, value)
	local ok = pcall(function()
		inst[prop] = value
	end)
	return ok
end

local function createRow(parent, propName, defaultText, editable, onCommit)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 24)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.44, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = propName
	label.TextSize = 14
	label.TextScaled = true
	label.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.56, -4, 1, -2)
	box.Position = UDim2.new(0.44, 4, 0, 1)
	box.Text = defaultText
	box.ClearTextOnFocus = false
	box.TextSize = 14
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextScaled = true
	box.TextEditable = editable
	box.Parent = row

	if editable then
		local original = defaultText
		box.Focused:Connect(function()
			original = box.Text
		end)

		box.FocusLost:Connect(function()
			local text = box.Text
			if text == "" then
				text = original
				box.Text = original
			end
			onCommit(text)
		end)
	end

	return box
end

local PROPERTY_CANDIDATES = {}
do
	local seen = {}
	local function add(...)
		for i = 1, select("#", ...) do
			local p = select(i, ...)
			if not seen[p] then
				seen[p] = true
				PROPERTY_CANDIDATES[#PROPERTY_CANDIDATES + 1] = p
			end
		end
	end

	add("Name", "Parent", "Archivable", "ClassName", "UniqueId", "Value")

	add(
		"Position", "Orientation", "Rotation", "CFrame", "PivotOffset", "Size", "Color", "Transparency",
		"Reflectance", "Material", "MaterialVariant", "Anchored", "CanCollide", "CanTouch", "CanQuery",
		"CollisionGroup", "Massless", "RootPriority", "Shape", "Locked", "CustomPhysicalProperties",
		"AssemblyLinearVelocity", "AssemblyAngularVelocity", "LocalTransparencyModifier", "BottomSurface",
		"TopSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface", "BrickColor",
		"AssemblyCenterOfMass", "AssemblyMass", "ExtentsCFrame", "ExtentsSize"
	)

	add(
		"Visible", "Active", "ZIndex", "LayoutOrder", "BackgroundColor3", "BackgroundTransparency",
		"BorderColor3", "BorderSizePixel", "ClipsDescendants", "AnchorPoint", "AutomaticSize",
		"Rotation", "Text", "TextColor3", "TextTransparency", "TextSize", "TextWrapped", "TextScaled",
		"TextXAlignment", "TextYAlignment", "TextStrokeColor3", "TextStrokeTransparency", "RichText",
		"PlaceholderText", "ClearTextOnFocus", "Font", "FontFace", "TextTruncate", "MaxVisibleGraphemes",
		"LineHeight", "AutomaticCanvasSize", "CanvasPosition", "CanvasSize", "ScrollingDirection",
		"CanvasGroup", "BorderMode", "Modal", "Selectable", "Draggable", "AutoButtonColor",
		"Image", "ImageColor3", "ImageTransparency", "ImageRectOffset", "ImageRectSize", "ScaleType",
		"SliceCenter", "SliceScale", "ResampleMode"
	)

	add(
		"SoundId", "Volume", "PlaybackSpeed", "Playing", "Looped", "TimePosition", "RollOffMode",
		"RollOffMaxDistance", "RollOffMinDistance", "EmitterSize"
	)

	add("Brightness", "Enabled", "Range", "Shadows", "Angle", "Face")

	add(
		"WalkSpeed", "JumpPower", "JumpHeight", "Health", "MaxHealth", "HipHeight", "AutoRotate",
		"CameraOffset", "DisplayName", "UseJumpPower", "FloorMaterial"
	)

	add("FieldOfView", "CameraType", "Focus", "CameraSubject")

	add(
		"ActionText", "ObjectText", "HoldDuration", "KeyboardKeyCode", "MaxActivationDistance",
		"RequiresLineOfSight", "Style", "UIOffset", "ExclusivePrompt"
	)

	add("Axis", "SecondaryAxis", "Attachment0", "Attachment1", "Part0", "Part1")

	add(
		"Enabled", "Visible", "TargetAngle", "UpperAngle", "LowerAngle", "Restitution", "CurveSize0",
		"CurveSize1", "FaceCamera", "LightEmission", "LightInfluence", "Segments", "Texture",
		"TextureLength", "TextureSpeed", "Width0", "Width1", "ZOffset", "Acceleration", "EmissionDirection",
		"Lifetime", "Rate", "Rotation", "RotSpeed", "Speed", "SpreadAngle", "Transparency", "Drag",
		"LockedToPart", "VelocityInheritance"
	)

	add(
		"Thickness", "ApplyStrokeMode", "LineJoinMode"
	)
end

local function buildPropertiesPanel(screenGui, inst)
	if not inst then
		return
	end

	clearOldProperties(screenGui)

	local panel = Instance.new("Frame")
	panel.Name = "PropertiesPanel"
	panel.Size = UDim2.new(0, 320, 0, 420)
	panel.Position = UDim2.new(0.5, -160, 0.5, -210)
	panel.BackgroundColor3 = Color3.fromRGB(225, 226, 199)
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

	makeDraggable(panel)

	local topBar = Instance.new("Frame")
	topBar.Size = UDim2.new(1, 0, 0, 30)
	topBar.BackgroundColor3 = Color3.fromRGB(255, 249, 84)
	topBar.BorderSizePixel = 0
	topBar.Parent = panel
	Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Properties"
	title.TextColor3 = Color3.new(0, 0, 0)
	title.TextSize = 16
	title.Parent = topBar

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 1, 0)
	close.Position = UDim2.new(1, -30, 0, 0)
	close.Text = "X"
	close.TextSize = 16
	close.Parent = topBar
	close.MouseButton1Click:Connect(function()
		panel:Destroy()
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -70)
	scroll.Position = UDim2.new(0, 5, 0, 35)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	Properties = { props = {}, attrs = {}, values = {} }

	local rowCount = 0
	local function addRow(name, value, kind, commitTarget, commitKey)
		local parserExists = kind and kind ~= "Instance" and kind ~= "Font" and kind ~= "FontFace" and kind ~= "ColorSequence" and kind ~= "NumberSequence"
		local canEdit = false
		if parserExists and value ~= nil then
			canEdit = canWriteProperty(commitTarget, commitKey, value)
		end

		local display = formatValue(value)
		createRow(scroll, name, display, canEdit, function(text)
			local parsed = parseValue(kind, text, value)
			if parsed ~= nil then
				if commitTarget == inst and commitKey then
					Properties.props[commitKey] = parsed
				end
			end
		end)
		rowCount += 1
	end

	for _, prop in ipairs(PROPERTY_CANDIDATES) do
		local ok, value = pcall(function()
			return inst[prop]
		end)

		if ok then
			local kind = typeof(value)
			local parserExists = kind ~= "Instance" and kind ~= "Font" and kind ~= "FontFace" and kind ~= "ColorSequence" and kind ~= "NumberSequence"
			local canEdit = false
			if parserExists and value ~= nil then
				canEdit = canWriteProperty(inst, prop, value)
			end

			local box = createRow(scroll, prop, formatValue(value), canEdit, function(text)
				local parsed = parseValue(kind, text, value)
				if parsed ~= nil then
					Properties.props[prop] = parsed
				end
			end)

			rowCount += 1
		end
	end

	do
		local attrs = inst:GetAttributes()
		local names = {}
		for k in pairs(attrs) do
			names[#names + 1] = k
		end
		table.sort(names)

		for _, name in ipairs(names) do
			local value = attrs[name]
			local kind = typeof(value)
			local canEdit = value ~= nil and kind ~= "Instance" and kind ~= "Font" and kind ~= "FontFace" and kind ~= "ColorSequence" and kind ~= "NumberSequence"
			if canEdit then
				canEdit = pcall(function()
					inst:SetAttribute(name, value)
				end)
			end

			createRow(scroll, "@" .. name, formatValue(value), canEdit, function(text)
				local parsed = parseValue(kind, text, value)
				if parsed ~= nil then
					Properties.attrs[name] = parsed
				end
			end)

			rowCount += 1
		end
	end

	do
		local kids = {}
		for _, child in ipairs(inst:GetChildren()) do
			if child:IsA("ValueBase") then
				kids[#kids + 1] = child
			end
		end
		table.sort(kids, function(a, b)
			return a.Name < b.Name
		end)

		for _, child in ipairs(kids) do
			local value = child.Value
			local kind = typeof(value)
			local canEdit = value ~= nil and kind ~= "Instance" and kind ~= "Font" and kind ~= "FontFace" and kind ~= "ColorSequence" and kind ~= "NumberSequence"
			if canEdit then
				canEdit = pcall(function()
					child.Value = value
				end)
			end

			createRow(scroll, child.Name, formatValue(value), canEdit, function(text)
				local parsed = parseValue(kind, text, value)
				if parsed ~= nil then
					Properties.values[child] = parsed
				end
			end)

			rowCount += 1
		end
	end

	local apply = Instance.new("TextButton")
	apply.Size = UDim2.new(1, -10, 0, 24)
	apply.Position = UDim2.new(0, 5, 1, -29)
	apply.Text = "Apply"
	apply.BackgroundColor3 = Color3.fromRGB(222, 210, 46)
	apply.BorderSizePixel = 0
	apply.Parent = panel
	Instance.new("UICorner", apply).CornerRadius = UDim.new(0, 8)

	apply.MouseButton1Click:Connect(function()
		if not inst or not inst.Parent then
			return
		end

		for prop, value in pairs(Properties.props) do
			pcall(function()
				inst[prop] = value
			end)
		end

		for name, value in pairs(Properties.attrs) do
			pcall(function()
				inst:SetAttribute(name, value)
			end)
		end

		for child, value in pairs(Properties.values) do
			if child and child.Parent then
				pcall(function()
					child.Value = value
				end)
			end
		end
	end)
end

local function Selection(inst)
	local sp = false
	local Selection = nil
	inst.MouseButton1Click:Connect(function()
		if Selection == nil then
			sp = true
			inst.BackgroundColor3 = Color3.new(0.05, 0.5, 0.8)
			mouse.Button1Down:Wait()
			Selection = mouse.Target
			sp = false
		else
			Selection = nil
		end
		SelectionPart = Selection
		inst.Text = Selection and ("Selected: " .. Selection.Name) or "No Part Selected"
		inst.BackgroundColor3 = Selection and Color3.new(0.5, 0.8, 0) or Color3.new(0.8, 0, 0)
		print(SelectionPart)
	end)
end

local function GetProperties(inst)
	inst.MouseButton1Click:Connect(function()
		if SelectionPart then
			buildPropertiesPanel(sg, SelectionPart)
		end
	end)
end

local function ClonePart(inst)
	inst.MouseButton1Click:Connect(function()
		if SelectionPart then
			local ClonedPart = SelectionPart:Clone()
			ClonedPart.Parent = game.Workspace
		end
	end)
end

local function SetParent(inst)
	inst.MouseButton1Click:Connect(function()
		if SelectionPart and SelectionParent then
			SelectionPart.Parent = SelectionParent
		end
	end)
end

local function GetPosition(inst)
	local hitInst = Instance.new("Part", workspace)
	hitInst.Size = Vector3.new(0.5, 0.5, 0.5)
	hitInst.Anchored = true
	hitInst.Transparency = 1
	hitInst.CanCollide = false

	local highlight = Instance.new("Highlight")
	highlight.Parent = hitInst

	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineTransparency = 0

	local toggle = false
	inst.MouseButton1Click:Connect(function()
		toggle = not toggle
		inst.BackgroundColor3 = toggle and Color3.new(0, 0.8, 0) or Color3.new(0.8, 0, 0)
		inst.Text = toggle and "Click anywhere to get position" or "No Target Position"
		if toggle then
			mouse.Button1Down:Wait()
			toggle = false
			inst.BackgroundColor3 = Color3.new(0.8, 0, 0)
			inst.Text = mouse.Hit.Position and "(" .. math.floor(mouse.Hit.Position.X * 10)/10 .. ", " .. math.floor(mouse.Hit.Position.Y * 10)/10 .. ", " .. math.floor(mouse.Hit.Position.Z * 10)/10 .. ")" or "No Target Position"
			hitInst.Position = mouse.Hit.Position or Vector3.new(0, 0, 0)
			hitInst.Transparency = mouse.Hit and 0 or 1
		end
	end)
end

-- EXPLORER MENU SYSTEM ---------------------------------------------------------------------------------------------------------------------------------
local ESInstance = game.Workspace
local EDInstance = nil

local ExplorerMenu = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local DetailsMenu = Instance.new("Frame")

Instance.new("UICorner", ExplorerMenu).CornerRadius = UDim.new(0, 10)
Instance.new("UICorner", DetailsMenu).CornerRadius = UDim.new(0, 10)

local function EDchange(old, new)
	EDInstance = new or nil

	local info = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local goal
	if new and new.Name then
		goal = {Position = UDim2.new(1.05, 0, 0.2, 0)}

		DetailsMenu.INSTname.Text = new.Name
		DetailsMenu.INSTclass.Text = "Class: " .. new.ClassName
		DetailsMenu.INSTchildrencount.Text = "#Children: " .. #(new:GetChildren())
		DetailsMenu.INSTdescendantscount.Text = "#Descendants: " .. #(new:GetDescendants())
	else
		goal = {Position = UDim2.new(0.05, 0, 0.2, 0)}
	end

	local tween = TweenService:Create(DetailsMenu, info, goal)
	tween:Play()
end

local function SearchSort()
	local sb = ExplorerMenu.SearchBar
	local st = ExplorerMenu.SearchType
	if sb.Text == "" then return end

	local key = st.Text == "Name" and "Name" or "ClassName"

	for _, i in ipairs(ScrollingFrame:GetChildren()) do
		if i:IsA("TextButton") then
			local inst = i["instValue"]
			if inst then inst = inst.Value else return end
			i.Visible = string.find(string.lower(inst[key]), string.lower(sb.Text), 1, true) ~= nil
		end
	end
end

local function AddChildren(sl, inst)
	if ESInstance == nil then ESInstance = workspace.Map end
	local trail = ESInstance.Name or "Inst"
	local TrailInst = inst
	local t = time()
	while TrailInst and TrailInst.Parent and time() - t < 1 do
		TrailInst = TrailInst.Parent
		trail = TrailInst.Name .. " -> " .. trail
	end

	if not ExplorerMenu:FindFirstChild("ExplrNameClass") or not ExplorerMenu:FindFirstChild("ExplrTrail") then return end
	ExplorerMenu.ExplrNameClass.Text = ESInstance.Name .. " + " .. ESInstance.ClassName
	ExplorerMenu.ExplrTrail.Text = trail or "? -> " .. ESInstance.Name
	for _, i in ipairs(ScrollingFrame:GetChildren()) do
		if i:IsA("TextButton") then
			i:Destroy()
		end
	end
	for o, i in ipairs(ESInstance:GetChildren()) do
		local backtrns = 1
		local fr = Instance.new("TextButton")
		fr.Size = UDim2.new(0.9, 0, 0, 50)
		fr.BackgroundColor3 = Color3.fromRGB(161, 237, 154)
		fr.BackgroundTransparency = 0.5 / backtrns
		fr.Parent = ScrollingFrame
		fr.LayoutOrder = o
		fr.Text = i.Name .. ": " .. i.ClassName
		fr.TextSize = 10
		fr.TextWrapped = true
		fr.ZIndex = -2
		Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)

		local Iinst = Instance.new("ObjectValue")
		Iinst.Parent = fr
		Iinst.Name = "instValue"
		Iinst.Value = i

		fr.MouseEnter:Connect(function() fr.BackgroundTransparency = 0.3 / backtrns end)
		fr.MouseLeave:Connect(function() fr.BackgroundTransparency = 0.5 / backtrns end)

		local lastclick = time()
		fr.MouseButton1Click:Connect(function()
			if time() - lastclick < 0.6 then
				ESInstance = EDInstance
				AddChildren(ScrollingFrame, ESInstance)
			end

			lastclick = time()
			EDchange(EDInstance or nil, i or nil)
			if EDInstance == i then
				task.spawn(function()
					while EDInstance == i and sg do
						backtrns = 3
						task.wait(0.2)
					end
				end)
			end
		end)
	end
	SearchSort()
end

ESInstance.ChildAdded:Connect(function() AddChildren(ScrollingFrame, ESInstance) end)
ESInstance.ChildRemoved:Connect(function() AddChildren(ScrollingFrame, ESInstance) end)

task.spawn(function()
	ExplorerMenu.Name = "Explorer"
	ExplorerMenu.Parent = sg
	ExplorerMenu.Position = UDim2.new(0.2, 0, 0.2, 0)
	ExplorerMenu.Size = UDim2.new(0, 320, 0, 420)
	ExplorerMenu.BackgroundColor3 = Color3.new(0.5, 0.8, 0.55)
	ExplorerMenu.ZIndex = -5
	ExplorerMenu.Visible = false
	makeDraggable(ExplorerMenu)

	DetailsMenu.Name = "Details"
	DetailsMenu.Parent = ExplorerMenu
	DetailsMenu.Position = UDim2.new(1.05, 0, 0.2, 0)
	DetailsMenu.Size = UDim2.new(0.6, 0, 0.84, 0)
	DetailsMenu.BackgroundColor3 = Color3.new(0.5, 0.8, 0.55)
	DetailsMenu.ZIndex = -10

	local function newInstDetailsMenu(Ysc, Text, Nm, TYPE)
		local ti = Instance.new(TYPE)
		ti.Name = Nm
		ti.Parent = DetailsMenu
		ti.Position = UDim2.new(0.05, 0, Ysc, 0)
		ti.Size = UDim2.new(0.9, 0, 0.1, 0)
		ti.Text = Text
		ti.TextColor3 = Color3.new(0.2,0.2,0.2)
		ti.BackgroundTransparency = 0.6
		ti.BackgroundColor3 = Color3.new(0.0862745, 0.690196, 0.0196078)
		ti.TextScaled = true
		Instance.new("UICorner", ti).CornerRadius = UDim.new(0, 10)
	end
	newInstDetailsMenu(0.02, "View Instance", "INSTview", "TextButton")
	newInstDetailsMenu(0.14, "Name", "INSTname", "TextLabel")
	newInstDetailsMenu(0.26, "Type", "INSTclass", "TextLabel")
	newInstDetailsMenu(0.38, "#Children", "INSTchildrencount", "TextLabel")
	newInstDetailsMenu(0.50, "#Descendants", "INSTdescendantscount", "TextLabel")
	newInstDetailsMenu(0.62, "Select Instance (Selected Part)", "INSTselect", "TextButton")
	newInstDetailsMenu(0.74, "Select Instance (Selected Inst for Parent)", "INSTselectParent", "TextButton")

	DetailsMenu.INSTselect.MouseButton1Click:Connect(function()
		SelectionPart = EDInstance
	end)
	DetailsMenu.INSTview.MouseButton1Click:Connect(function()
		ESInstance = EDInstance
		AddChildren(ScrollingFrame, ESInstance)
	end)
	DetailsMenu.INSTselectParent.MouseButton1Click:Connect(function()
		if EDInstance ~= nil then
			SelectionParent = EDInstance
		end
	end)

	ScrollingFrame.Parent = ExplorerMenu
	ScrollingFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
	ScrollingFrame.Size = UDim2.new(0.9, 0, 0.65, 0)
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.ClipsDescendants = true

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = ScrollingFrame

	local Back = Instance.new("TextButton")
	Back.Parent = ExplorerMenu
	Back.Position = UDim2.new(0.02, 0, 0.02, 0)
	Back.Size = UDim2.new(0, 50, 0, 20)
	Back.Text = "Back"
	Back.Name = "Back"
	Back.TextColor3 = Color3.new(0,0,0)
	Back.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
	Back.MouseButton1Click:Connect(function()
		if ESInstance then if ESInstance.Parent then ESInstance = ESInstance.Parent end end
		AddChildren(ScrollingFrame, ESInstance)
	end)
	Instance.new("UICorner", Back).CornerRadius = UDim.new(0, 10)

	local Reload = Instance.new("TextButton")
	Reload.Parent = ExplorerMenu
	Reload.Position = UDim2.new(0.02, 0, 0.02, 25)
	Reload.Size = UDim2.new(0, 50, 0, 20)
	Reload.Text = "Reload"
	Reload.Name = "Reload"
	Reload.TextColor3 = Color3.new(0,0,0)
	Reload.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
	Reload.MouseButton1Click:Connect(function()
		AddChildren(ScrollingFrame, ESInstance)
	end)
	Instance.new("UICorner", Reload).CornerRadius = UDim.new(0, 10)

	local tn = Instance.new("TextLabel")
	tn.Name = "ExplrNameClass"
	tn.Parent = ExplorerMenu
	tn.Position = UDim2.new(0.15, 25, 0.02, 0)
	tn.Size = UDim2.new(0.7, 0, 0.1, 0)
	tn.Text = ESInstance.Name .. " + " .. ESInstance.ClassName
	tn.TextScaled = true
	tn.TextWrapped = false
	tn.TextXAlignment = Enum.TextXAlignment.Left
	tn.TextColor3 = Color3.new(0,0,0)
	tn.BackgroundTransparency = 0.7
	Instance.new("UICorner", tn).CornerRadius = UDim.new(0, 10)

	local ti = Instance.new("TextLabel")
	ti.Name = "ExplrTrail"
	ti.Parent = ExplorerMenu
	ti.Position = UDim2.new(0.15, 25, 0.13, 0)
	ti.Size = UDim2.new(0.7, 0, 0.08, 0)
	ti.Text = ESInstance.Name
	ti.TextScaled = true
	ti.TextWrapped = true
	ti.TextXAlignment = Enum.TextXAlignment.Left
	ti.TextColor3 = Color3.new(0.2,0.2,0.2)
	ti.BackgroundTransparency = 0.7
	Instance.new("UICorner", ti).CornerRadius = UDim.new(0, 10)

	local tb = Instance.new("TextBox")
	tb.Name = "SearchBar"
	tb.Parent = ExplorerMenu
	tb.Position = UDim2.new(0.15, 25, 0.22, 0)
	tb.Size = UDim2.new(0.7, 0, 0.10, 0)
	tb.Text = ""
	tb.PlaceholderText = "Search by Name"
	tb.TextScaled = true
	tb.TextWrapped = true
	tb.TextColor3 = Color3.new(0.2,0.2,0.2)
	tb.BackgroundColor3 = Color3.new(1,1,1)
	tb.BackgroundTransparency = 0.9
	Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
	tb:GetPropertyChangedSignal("Text"):Connect(function()
		SearchSort()
	end)

	local tbTYPE = Instance.new("TextButton")
	tbTYPE.Parent = ExplorerMenu
	tbTYPE.Position = UDim2.new(0.02, 0, 0.22, 0)
	tbTYPE.Size = UDim2.new(0.2, 0, 0.08, 0)
	tbTYPE.Text = "Name"
	tbTYPE.TextScaled = true
	tbTYPE.Name = "SearchType"
	tbTYPE.TextColor3 = Color3.new(0,0,0)
	tbTYPE.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
	tbTYPE.MouseButton1Click:Connect(function()
		tbTYPE.Text = tbTYPE.Text == "Name" and "ClassName" or "Name"
		tb.PlaceholderText = "Search by " .. tbTYPE.Text
		AddChildren(ScrollingFrame, ESInstance)
	end)
	Instance.new("UICorner", tbTYPE).CornerRadius = UDim.new(0, 10)
end)

local function Explorer(inst)
	inst.MouseButton1Click:Connect(function()
		ExplorerMenu.Visible = not ExplorerMenu.Visible
		inst.Text = ExplorerMenu.Visible and "Close Explorer" or "Open Explorer"

		for _, i in pairs(ExplorerMenu:GetDescendants()) do
			if i.Name ~= "ExplorerMenu" and i.Name ~= "instValue" and i.Name ~= "DetailsMenu" and not i:IsA("UICorner") and not i:IsA("UIListLayout") then
				i.ZIndex = -2
			end
		end
	end)
end

local function OpenExplorerAt(inst)
	inst.MouseButton1Click:Connect(function()
		ESInstance = SelectionPart
		EDInstance = nil
		AddChildren(ScrollingFrame, ESInstance)
		ExplorerMenu.Visible = true
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
Selection(GetInstance("SelectionBtn", 3, "TextButton"))
GetProperties(GetInstance("LoadPropertiesBtn", 3, "TextButton"))
ClonePart(GetInstance("CloneBtn", 3, "TextButton"))
GetPosition(GetInstance("GetPositionBtn", 3, "TextButton"))
Explorer(GetInstance("ExplorerBtn", 3, "TextButton"))
OpenExplorerAt(GetInstance("OpenExplorerAtBtn", 3, "TextButton"))
SetParent(GetInstance("SetParentBtn", 3, "TextButton"))

if not RobloxStudioFriendly then loadData() end

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
		if inst then inst.TextColor3 = Color3.fromHSV(h, 1, 1) end
	end
end)
