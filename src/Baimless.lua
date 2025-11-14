--[[
    Baimless UI Library
    DEBUG: Visibility Test - Gradient is EXTREMELY LIGHT GREEN in top-left
    
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
    Background = Color3.fromRGB(8, 8, 12),
    GradientAccent = Color3.fromRGB(200, 255, 200), -- EXTREMELY LIGHT GREEN
    Panel = Color3.fromRGB(20, 20, 28),
    PanelDark = Color3.fromRGB(16, 16, 22),
    Accent = Color3.fromRGB(188, 70, 255),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(140, 140, 150),
    Border = Color3.fromRGB(35, 35, 45),
    BorderBright = Color3.fromRGB(50, 50, 65),
    ButtonDark = Color3.fromRGB(40, 40, 52),
    ButtonHover = Color3.fromRGB(50, 50, 65),
    InputBg = Color3.fromRGB(12, 12, 18),
}
Theme.Sizes = {CornerRadius = UDim.new(0, 3), BorderSize = 1, Padding = 14}
Theme.Fonts = {Regular = Enum.Font.Gotham, Bold = Enum.Font.GothamBold, Semibold = Enum.Font.GothamBold}
Animations.Speed = 0.2
Animations.SlowSpeed = 0.35
Animations.Style = Enum.EasingStyle.Quad
Animations.Direction = Enum.EasingDirection.Out
function Animations:Tween(object, properties, duration, style) duration = duration or self.Speed style = style or self.Style local tween = TweenService:Create(object, TweenInfo.new(duration, style, self.Direction), properties) tween:Play() return tween end
function Components:Create(className, properties) local object = Instance.new(className) for prop, value in pairs(properties or {}) do if prop ~= "Parent" then object[prop] = value end end if properties.Parent then object.Parent = properties.Parent end return object end
function Components:CreateCorner(parent, radius) return self:Create("UICorner", {CornerRadius = radius or Theme.Sizes.CornerRadius,Parent = parent}) end
function Components:CreateStroke(parent, color, thickness, transparency) return self:Create("UIStroke", {Color = color or Theme.Colors.Border,Thickness = thickness or Theme.Sizes.BorderSize,Transparency = transparency or 0,ApplyStrokeMode = Enum.ApplyStrokeMode.Border,Parent = parent}) end
function Components:CreateGradient(parent, colorStart, colorEnd, rotation) local gradient = self:Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, colorStart),ColorSequenceKeypoint.new(0.4, colorStart),ColorSequenceKeypoint.new(1, colorEnd)}),Rotation = rotation or 135,Parent = parent}) return gradient end
function Components:CreateShadow(parent, size, transparency) local shadow = self:Create("ImageLabel", {Size = UDim2.new(1, size or 30, 1, size or 30),Position = UDim2.new(0.5, 0, 0.5, 0),AnchorPoint = Vector2.new(0.5, 0.5),BackgroundTransparency = 1,Image = "rbxassetid://5554236805",ImageColor3 = Color3.fromRGB(0, 0, 0),ImageTransparency = transparency or 0.7,ScaleType = Enum.ScaleType.Slice,SliceCenter = Rect.new(23, 23, 277, 277),ZIndex = parent.ZIndex - 1,Parent = parent}) return shadow end
function Components:CreateGlow(parent, color, size, transparency) local glow = self:Create("ImageLabel", {Size = UDim2.new(1, size or 40, 1, size or 40),Position = UDim2.new(0.5, 0, 0.5, 0),AnchorPoint = Vector2.new(0.5, 0.5),BackgroundTransparency = 1,Image = "rbxassetid://5554236805",ImageColor3 = color or Theme.Colors.Accent,ImageTransparency = transparency or 0.5,ScaleType = Enum.ScaleType.Slice,SliceCenter = Rect.new(23, 23, 277, 277),ZIndex = parent.ZIndex - 1,Parent = parent}) return glow end
function Baimless:CreateWindow()
    local gui = Components:Create("ScreenGui", {Name = "BaimlessUI",ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true })
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    local mainContainer = Components:Create("Frame", {Size = UDim2.new(0, 900, 0, 650),Position = UDim2.new(0.5, 0, 0.5, 0),AnchorPoint = Vector2.new(0.5, 0.5),BackgroundTransparency = 1,Parent = gui })
    Components:CreateShadow(mainContainer, 60, 0.6)
    local mainFrame = Components:Create("Frame", {Size = UDim2.new(1, 0, 1, 0),BackgroundColor3 = Theme.Colors.Background,BorderSizePixel = 0,Parent = mainContainer })
    mainFrame:SetAttribute("OriginalTransparency", 0)
    Components:CreateCorner(mainFrame, UDim.new(0, 4))
    Components:CreateStroke(mainFrame, Theme.Colors.BorderBright, 1, 0.4)
    Components:CreateGradient(mainFrame, Theme.Colors.GradientAccent, Theme.Colors.Background, 135)
    Components:CreateGlow(mainFrame, Theme.Colors.Accent, 80, 0.85)
end
return Baimless
