-- =====================================================
--   ScriptDelta | WalkSpeed
--   Author: StandLab494
-- =====================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ⚙️ НАСТРОЙКИ
local DEFAULT_SPEED = 16      -- обычная скорость Roblox
local MIN_SPEED = 0
local MAX_SPEED = 500
local TOGGLE_KEY = Enum.KeyCode.RightShift  -- кнопка открытия/закрытия

-- =====================================================
--          GUI
-- =====================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WalkSpeedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 160)
Frame.Position = UDim2.new(0.5, -160, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true          -- можно перетаскивать мышкой
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(120, 80, 255)
Stroke.Thickness = 2
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "🏃 WalkSpeed"
Title.TextColor3 = Color3.fromRGB(180, 140, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Показ текущего значения
local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.new(1, -20, 0, 25)
ValueLabel.Position = UDim2.new(0, 10, 0, 45)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = "Скорость: " .. DEFAULT_SPEED
ValueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
ValueLabel.TextScaled = true
ValueLabel.Font = Enum.Font.Gotham
ValueLabel.Parent = Frame

-- Слайдер (ползунок)
local Slider = Instance.new("Frame")
Slider.Size = UDim2.new(1, -40, 0, 10)
Slider.Position = UDim2.new(0, 20, 0, 85)
Slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
Slider.BorderSizePixel = 0
Slider.Parent = Frame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(1, 0)
SliderCorner.Parent = Slider

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(0, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
Fill.BorderSizePixel = 0
Fill.Parent = Slider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = Fill

local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 18, 0, 18)
Knob.Position = UDim2.new(0, -9, 0.5, -9)
Knob.BackgroundColor3 = Color3.fromRGB(180, 140, 255)
Knob.BorderSizePixel = 0
Knob.Parent = Fill

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob

-- Кнопка сброса
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, -40, 0, 30)
ResetBtn.Position = UDim2.new(0, 20, 1, -40)
ResetBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ResetBtn.BorderSizePixel = 0
ResetBtn.Text = "СБРОСИТЬ (" .. DEFAULT_SPEED .. ")"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14
ResetBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ResetBtn

-- =====================================================
--          ЛОГИКА
-- =====================================================

local currentSpeed = DEFAULT_SPEED
local dragging = false

local function applySpeed(value)
    currentSpeed = value
    local char = player.Character
    if char and char:FindFirstChildOfClass("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
    ValueLabel.Text = "Скорость: " .. math.floor(value)
    local percent = (value - MIN_SPEED) / (MAX_SPEED - MIN_SPEED)
    Fill.Size = UDim2.new(percent, 0, 1, 0)
end

local function updateFromPosition(mouseX)
    local sliderPos = Slider.AbsolutePosition.X
    local sliderSize = Slider.AbsoluteSize.X
    local percent = math.clamp((mouseX - sliderPos) / sliderSize, 0, 1)
    local value = MIN_SPEED + (MAX_SPEED - MIN_SPEED) * percent
    applySpeed(value)
end

-- Клик по слайдеру
Slider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        updateFromPosition(input.Position.X)
    end
end)

-- Движение мыши
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
    or input.UserInputType == Enum.UserInputType.Touch) then
        updateFromPosition(input.Position.X)
    end
end)

-- Отпускание мыши
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Кнопка сброса
ResetBtn.MouseButton1Click:Connect(function()
    applySpeed(DEFAULT_SPEED)
end)

-- Применение скорости после респавна
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = currentSpeed
    end
end)

-- Открыть/закрыть по RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == TOGGLE_KEY then
        Frame.Visible = not Frame.Visible
    end
end)

print("[ScriptDelta] WalkSpeed загружен. Нажми RightShift для скрытия/показа.")
