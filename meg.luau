-- Очистка старых версий
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
	if v.Name == "Akbarshox_V4_1_Rainbow" then v:Destroy() end
end

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnSamsonite = ReplicatedStorage:WaitForChild("Events"):WaitForChild("AdminPanel"):WaitForChild("SpawnSamsonite")

-- Глобальные настройки (Сохраняются при смерти)
_G.SpeedVal = 16
_G.JumpVal = 50
_G.InfJump = false

-- ГЛАВНОЕ ОКНО
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "Akbarshox_V4_1_Rainbow"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 200) -- Чуть шире для красоты
main.Position = UDim2.new(0.5, -130, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Более темный для контраста
main.BorderSizePixel = 1
main.BorderColor3 = Color3.new(1,1,1)
main.Active = true
main.Draggable = true
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 5)

-- ШАПКА
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.BorderSizePixel = 0

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.Text = "Akbarshox Hub v4.1"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКИ
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

-- ФУНКЦИЯ УЛЬТРА-ТОНКИХ РАДУЖНЫХ СЛАЙДЕРОВ
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
	sliderBg.Size = UDim2.new(0.9, 0, 0, 2) -- Ультра-тонкая полоска (2 пикселя)
	sliderBg.Position = UDim2.new(0.05, 0, 0, y + 20)
	sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sliderBg.Text = ""
	sliderBg.AutoButtonColor = false
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 1)

	-- РАДУЖНАЯ ЗАЛИВКА
	local fill = Instance.new("Frame", sliderBg)
	fill.Size = UDim2.new(default/max, 0, 1, 0)
	fill.BackgroundColor3 = Color3.new(1,1,1) -- Базовый белый
	fill.BorderSizePixel = 0
	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(0, 1)

	-- ГРАДИЕНТ ДЛЯ ПОЛОСКИ
	local gradient = Instance.new("UIGradient", fill)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	})

	-- АНИМАЦИЯ ГРАДИЕНТА
	local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
	local tween = TweenService:Create(gradient, tweenInfo, {Offset = Vector2.new(-1, 0)})
	tween:Play()

	-- РАДУЖНЫЙ ПОЛЗУНОК (ТОТ САМЫЙ КРАЙ)
	local dot = Instance.new("Frame", fill)
	dot.Size = UDim2.new(0, 6, 0, 6)
	dot.Position = UDim2.new(1, -3, 0.5, -3)
	dot.BackgroundColor3 = Color3.new(1,1,1) -- Светится белым, но меняет цвет
	local dotCorner = Instance.new("UICorner", dot)
	dotCorner.CornerRadius = UDim.new(1, 0)

	-- ЛОГИКА ИЗМЕНЕНИЯ ЦВЕТА ПОЛЗУНКА И ШАПКИ/ТГ
	task.spawn(function()
		while task.wait() do
			local h = tick() % 5 / 5
			local rainbowColor = Color3.fromHSV(h, 1, 1)
			dot.BackgroundColor3 = rainbowColor -- Ползунок становится радужным!
			if name == "Speed" then -- Только для первого слайдера
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

addSlider("Speed", 5, 500, 16, "SpeedVal")
addSlider("Jump", 45, 500, 50, "JumpVal")

local ijBtn = Instance.new("TextButton", content)
ijBtn.Size = UDim2.new(0.9, 0, 0, 30)
ijBtn.Position = UDim2.new(0.05, 0, 0, 95)
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

local spawnBtn = Instance.new("TextButton", content)
spawnBtn.Size = UDim2.new(0.9, 0, 0, 30)
spawnBtn.Position = UDim2.new(0.05, 0, 0, 135)
spawnBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 80)
spawnBtn.Text = "Spawn Samsonite"
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 12
Instance.new("UICorner", spawnBtn)

spawnBtn.MouseButton1Click:Connect(function()
	SpawnSamsonite:FireServer()
end)

local tg = Instance.new("TextLabel", content)
tg.Size = UDim2.new(1, 0, 0, 20)
tg.Position = UDim2.new(0, 0, 0, 140)
tg.Text = "TG: @UZTUBER_UZ"
tg.Font = Enum.Font.GothamBold
tg.BackgroundTransparency = 1
tg.TextSize = 12

-- АНТИ-СМЕРТЬ (ВЕЧНЫЙ ЦИКЛ)
task.spawn(function()
	while task.wait(0.1) do
		pcall(function()
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				local hum = player.Character.Humanoid
				hum.WalkSpeed = _G.SpeedVal
				hum.UseJumpPower = true
				hum.JumpPower = _G.JumpVal
			end
		end)
	end
end)

minBtn.MouseButton1Click:Connect(function()
	main:TweenSize(main.Size.Y.Offset == 30 and UDim2.new(0, 260, 0, 200) or UDim2.new(0, 260, 0, 30), "Out", "Quad", 0.2, true)
end)
clsBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- РАДУЖНАЯ ШАПКА И ТГ
RS.RenderStepped:Connect(function()
	local h = tick() % 5 / 5
	title.TextColor3 = Color3.fromHSV(h, 1, 1)
	tg.TextColor3 = Color3.fromHSV(h, 1, 1)
end)

UIS.JumpRequest:Connect(function()
	if _G.InfJump and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
	end
end)
