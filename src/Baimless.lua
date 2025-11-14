--[[
    Baimless UI Library
    Gradient: #3D1132 (61,17,50) top-left → #100d10 (16,13,16) main color 
    Usage:
        local Baimless = loadstring(game:HttpGet('https://raw.githubusercontent.com/axzaxzz/baimless/feature-background-gradient-top-left/src/Baimless.lua'))()
        Baimless:ShowLogin(function(username, password) return true end)
--]]

local Baimless = {}
Baimless.__index = Baimless
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Theme = {}
local Components = {}
local Animations = {}
Theme.Colors = {
    Background = Color3.fromRGB(16, 13, 16), -- #100d10
    GradientAccent = Color3.fromRGB(61, 17, 50), -- #3D1132
    Panel = Color3.fromRGB(20, 20, 28),
    PanelDark = Color3.fromRGB(16, 16, 22),
    Accent = Color3.fromRGB(188, 70, 255),
    AccentDark = Color3.fromRGB(140, 50, 200),
    AccentBright = Color3.fromRGB(220, 130, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 150),
    TextDark = Color3.fromRGB(100, 100, 110),
    Border = Color3.fromRGB(35, 35, 45),
    BorderBright = Color3.fromRGB(50, 50, 65),
    ButtonDark = Color3.fromRGB(40, 40, 52),
    ButtonHover = Color3.fromRGB(50, 50, 65),
    InputBg = Color3.fromRGB(12, 12, 18),
}
Theme.Sizes = {
    CornerRadius = UDim.new(0, 3),
    BorderSize = 1,
    Padding = 14,
}
Theme.Fonts = {
    Regular = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
    Semibold = Enum.Font.GothamBold,
}
Animations.Speed = 0.2
Animations.SlowSpeed = 0.35
Animations.Style = Enum.EasingStyle.Quad
Animations.Direction = Enum.EasingDirection.Out

function Animations:Tween(object, properties, duration, style)
    duration = duration or self.Speed
    style = style or self.Style
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, self.Direction), properties)
    tween:Play()
    return tween
end

function Animations:FadeIn(object, duration)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        object.TextTransparency = 1
        self:Tween(object, {TextTransparency = 0, BackgroundTransparency = object:GetAttribute("OriginalBgTransparency") or 0}, duration)
    else
        object.BackgroundTransparency = 1
        self:Tween(object, {BackgroundTransparency = object:GetAttribute("OriginalTransparency") or 0}, duration)
    end
end
function Components:Create(className, properties)
    local object = Instance.new(className)
    for prop, value in pairs(properties or {}) do if prop ~= "Parent" then object[prop] = value end end
    if properties.Parent then object.Parent = properties.Parent end
    return object
end
function Components:CreateCorner(parent, radius)
    return self:Create("UICorner", {CornerRadius = radius or UDim.new(0, 3), Parent = parent})
end
function Components:CreateStroke(parent, color, thickness, transparency)
    return self:Create("UIStroke", {Color = color or Theme.Colors.Border, Thickness = thickness or 1, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent})
end
function Components:CreateGradient(parent, colorStart, colorEnd, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorStart),
        ColorSequenceKeypoint.new(0.25, colorStart),
        ColorSequenceKeypoint.new(1, colorEnd)
    })
    gradient.Rotation = rotation or 135
    gradient.Parent = parent
    return gradient
end
-- ...rest of Baimless code unmodified...
function Baimless:CreateWindow()
    local gui = self:CreateScreenGui()
    local mainContainer = Components:Create("Frame", {Size = UDim2.new(0, 900, 0, 650), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Parent = gui })
    Components:CreateShadow(mainContainer, 60, 0.6)
    local mainFrame = Components:Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Theme.Colors.Background, BorderSizePixel = 0, Parent = mainContainer })
    mainFrame:SetAttribute("OriginalTransparency", 0)
    Components:CreateCorner(mainFrame, UDim.new(0, 4))
    Components:CreateStroke(mainFrame, Theme.Colors.BorderBright, 1, 0.4)
    Components:CreateGradient(mainFrame, Theme.Colors.GradientAccent, Theme.Colors.Background, 135)
    Components:CreateGlow(mainFrame, Theme.Colors.Accent, 80, 0.85)
    -- ...rest unchanged...
end
-- ...all other original methods remain...
return Baimless
