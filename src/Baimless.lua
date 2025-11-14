--[[
    Baimless UI Library
    Complete redesign with top-left gradient (#100d10)
    
    Usage:
        local Baimless = loadstring(game:HttpGet('https://raw.githubusercontent.com/axzaxzz/baimless/feature-background-gradient-top-left/src/Baimless.lua'))()
        Baimless:ShowLogin(function(username, password)
            return true
        end)
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
    BackgroundLight = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(20, 20, 28),
    PanelDark = Color3.fromRGB(16, 16, 22),
    GradientAccent = Color3.fromRGB(16, 13, 16), -- #100d10 for gradient
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

function Animations:SlideUp(object, distance, duration)
    local originalPos = object.Position
    object.Position = originalPos + UDim2.new(0, 0, 0, distance or 20)
    self:Tween(object, {Position = originalPos}, duration or self.SlowSpeed)
end

function Animations:Shake(object, intensity, duration)
    local originalPos = object.Position
    intensity = intensity or 8
    duration = duration or 0.4
    
    for i = 1, 5 do
        task.spawn(function()
            task.wait((duration / 10) * (i - 1))
            self:Tween(object, {
                Position = originalPos + UDim2.new(0, math.random(-intensity, intensity), 0, 0)
            }, duration / 10)
        end)
    end
    
    task.wait(duration / 2)
    self:Tween(object, {Position = originalPos}, duration / 2)
end

function Animations:FadeOutGui(guiObject, duration)
    duration = duration or 0.3
    local objects = {}
    
    local function collectObjects(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                table.insert(objects, child)
                collectObjects(child)
            end
        end
    end
    
    collectObjects(guiObject)
    
    for _, obj in ipairs(objects) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            self:Tween(obj, {TextTransparency = 1, BackgroundTransparency = 1}, duration)
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            self:Tween(obj, {ImageTransparency = 1, BackgroundTransparency = 1}, duration)
        elseif obj:IsA("Frame") then
            self:Tween(obj, {BackgroundTransparency = 1}, duration)
        end
    end
end

function Components:Create(className, properties)
    local object = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            object[prop] = value
        end
    end
    if properties.Parent then
        object.Parent = properties.Parent
    end
    return object
end

function Components:CreateCorner(parent, radius)
    return self:Create("UICorner", {
        CornerRadius = radius or Theme.Sizes.CornerRadius,
        Parent = parent
    })
end

function Components:CreateStroke(parent, color, thickness, transparency)
    return self:Create("UIStroke", {
        Color = color or Theme.Colors.Border,
        Thickness = thickness or Theme.Sizes.BorderSize,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

-- GRADIENT FIX: Properly create and parent UIGradient
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

function Components:CreatePadding(parent, padding)
    padding = padding or Theme.Sizes.Padding
    if type(padding) == "number" then
        return self:Create("UIPadding", {
            PaddingTop = UDim.new(0, padding),
            PaddingBottom = UDim.new(0, padding),
            PaddingLeft = UDim.new(0, padding),
            PaddingRight = UDim.new(0, padding),
            Parent = parent
        })
    else
        return self:Create("UIPadding", {
            PaddingTop = UDim.new(0, padding.Top or 0),
            PaddingBottom = UDim.new(0, padding.Bottom or 0),
            PaddingLeft = UDim.new(0, padding.Left or 0),
            PaddingRight = UDim.new(0, padding.Right or 0),
            Parent = parent
        })
    end
end

function Components:CreateShadow(parent, size, transparency)
    local shadow = self:Create("ImageLabel", {
        Size = UDim2.new(1, size or 30, 1, size or 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = parent.ZIndex - 1,
        Parent = parent
    })
    return shadow
end

function Components:CreateGlow(parent, color, size, transparency)
    local glow = self:Create("ImageLabel", {
        Size = UDim2.new(1, size or 40, 1, size or 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = color or Theme.Colors.Accent,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = parent.ZIndex - 1,
        Parent = parent
    })
    return glow
end

function Baimless:ShowLogin(callback)
    local gui = self:CreateScreenGui()
    local overlay = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    local panelContainer = Components:Create("Frame", {
        Size = UDim2.new(0, 360, 0, 300),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = overlay
    })
    
    Components:CreateShadow(panelContainer, 50, 0.5)
    
    local panel = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Colors.Panel,
        BorderSizePixel = 0,
        Parent = panelContainer
    })
    panel:SetAttribute("OriginalTransparency", 0)
    Components:CreateCorner(panel, UDim.new(0, 4))
    Components:CreateStroke(panel, Theme.Colors.BorderBright, 1, 0.3)
    Components:CreateGlow(panel, Theme.Colors.Accent, 60, 0.75)
    
    local accentBar = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = panel
    })
    Components:CreateCorner(accentBar, UDim.new(0, 0))
    
    local leftAccent = Components:Create("Frame", {
        Size = UDim2.new(0, 3, 0, 80),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = panel
    })
    
    local content = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = panel
    })
    Components:CreatePadding(content, {Top = 30, Bottom = 24, Left = 28, Right = 28})
    
    local iconContainer = Components:Create("Frame", {
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.5, 0, 0, -10),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = content
    })
    Components:CreateCorner(iconContainer, UDim.new(0, 8))
    Components:CreateGlow(iconContainer, Theme.Colors.Accent, 30, 0.6)
    
    local iconLabel = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "B",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 28,
        Font = Theme.Fonts.Bold,
        Parent = iconContainer
    })
    
    local title = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 58),
        BackgroundTransparency = 1,
        Text = "credentials",
        TextColor3 = Theme.Colors.Text,
        TextSize = 16,
        Font = Theme.Fonts.Semibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content
    })
    title:SetAttribute("OriginalBgTransparency", 1)
    
    local usernameFrame = self:CreateInput(content, "username", UDim2.new(0, 0, 0, 100))
    local usernameBox = usernameFrame:FindFirstChildOfClass("TextBox")
    
    local passwordFrame = self:CreateInput(content, "password", UDim2.new(0, 0, 0, 155))
    local passwordBox = passwordFrame:FindFirstChildOfClass("TextBox")
    
    local rememberFrame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 205),
        BackgroundTransparency = 1,
        Parent = content
    })
    
    local checkbox = Components:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = Theme.Colors.InputBg,
        BorderSizePixel = 0,
        Parent = rememberFrame
    })
    Components:CreateCorner(checkbox, UDim.new(0, 2))
    Components:CreateStroke(checkbox, Theme.Colors.Border, 1)
    
    local checkmark = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextColor3 = Theme.Colors.Accent,
        TextSize = 12,
        Font = Theme.Fonts.Bold,
        Visible = false,
        Parent = checkbox
    })
    
    local rememberLabel = Components:Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 24, 0, 0),
        BackgroundTransparency = 1,
        Text = "Remember me",
        TextColor3 = Theme.Colors.TextDim,
        TextSize = 12,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rememberFrame
    })
    rememberLabel:SetAttribute("OriginalBgTransparency", 1)
    
    local rememberState = false
    local checkboxButton = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = rememberFrame
    })
    
    checkboxButton.MouseButton1Click:Connect(function()
        rememberState = not rememberState
        checkmark.Visible = rememberState
        Animations:Tween(checkbox, {BackgroundColor3 = rememberState and Theme.Colors.Accent or Theme.Colors.InputBg}, 0.15)
    end)
    
    local submitBtn = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        Position = UDim2.new(0, 0, 1, -42),
        BackgroundColor3 = Theme.Colors.ButtonDark,
        BorderSizePixel = 0,
        Text = "Submit",
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
        Font = Theme.Fonts.Semibold,
        Parent = content
    })
    submitBtn:SetAttribute("OriginalBgTransparency", 0)
    Components:CreateCorner(submitBtn, UDim.new(0, 3))
    Components:CreateStroke(submitBtn, Theme.Colors.BorderBright, 1, 0.5)
    
    submitBtn.MouseEnter:Connect(function()
        Animations:Tween(submitBtn, {BackgroundColor3 = Theme.Colors.ButtonHover}, 0.15)
    end)
    
    submitBtn.MouseLeave:Connect(function()
        Animations:Tween(submitBtn, {BackgroundColor3 = Theme.Colors.ButtonDark}, 0.15)
    end)
    
    submitBtn.MouseButton1Click:Connect(function()
        local username = usernameBox.Text
        local password = passwordBox.Text
        
        if username == "" or password == "" then
            Animations:Shake(panelContainer, 8, 0.4)
            return
        end
        
        local success = callback(username, password)
        
        if success then
            Animations:FadeOutGui(panel, 0.3)
            task.wait(0.3)
            gui:Destroy()
            self:CreateWindow()
        else
            Animations:Shake(panelContainer, 8, 0.4)
        end
    end)
    
    Animations:FadeIn(panel, 0.35)
    Animations:SlideUp(panelContainer, 30, 0.4)
end

function Baimless:CreateInput(parent, placeholder, position)
    local frame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        Position = position,
        BackgroundColor3 = Theme.Colors.InputBg,
        BorderSizePixel = 0,
        Parent = parent
    })
    frame:SetAttribute("OriginalTransparency", 0)
    Components:CreateCorner(frame, UDim.new(0, 3))
    Components:CreateStroke(frame, Theme.Colors.Border, 1)
    
    local textbox = Components:Create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.Colors.TextDark,
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = frame
    })
    textbox:SetAttribute("OriginalBgTransparency", 1)
    
    return frame
end

function Baimless:CreateWindow()
    local gui = self:CreateScreenGui()
    
    local mainContainer = Components:Create("Frame", {
        Size = UDim2.new(0, 900, 0, 650),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = gui
    })
    
    Components:CreateShadow(mainContainer, 60, 0.6)
    
    local mainFrame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = mainContainer
    })
    mainFrame:SetAttribute("OriginalTransparency", 0)
    Components:CreateCorner(mainFrame, UDim.new(0, 4))
    Components:CreateStroke(mainFrame, Theme.Colors.BorderBright, 1, 0.4)
    
    -- GRADIENT APPLIED HERE
    Components:CreateGradient(mainFrame, Theme.Colors.GradientAccent, Theme.Colors.Background, 135)
    
    Components:CreateGlow(mainFrame, Theme.Colors.Accent, 80, 0.85)
    
    local header = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Theme.Colors.PanelDark,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    Components:CreateCorner(header, UDim.new(0, 4))
    
    local headerBottomCover = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 1, -4),
        BackgroundColor3 = Theme.Colors.PanelDark,
        BorderSizePixel = 0,
        Parent = header
    })
    
    local topAccent = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = header
    })
    
    local logo = Components:Create("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = "BAIMLESS",
        TextColor3 = Theme.Colors.Text,
        TextSize = 15,
        Font = Theme.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    logo:SetAttribute("OriginalBgTransparency", 1)
    
    local sidebar = Components:Create("Frame", {
        Size = UDim2.new(0, 200, 1, -55),
        Position = UDim2.new(0, 0, 0, 55),
        BackgroundColor3 = Theme.Colors.PanelDark,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    local sidebarRightBorder = Components:Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Colors.Border,
        BorderSizePixel = 0,
        Parent = sidebar
    })
    
    local sidebarPadding = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, -20),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    
    local sidebarList = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = sidebarPadding
    })
    
    local content = Components:Create("Frame", {
        Size = UDim2.new(1, -200, 1, -55),
        Position = UDim2.new(0, 200, 0, 55),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    Components:CreatePadding(content, 20)
    
    local contentScroll = Components:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = content
    })
    
    local contentList = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 16),
        Parent = contentScroll
    })
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
    end)
    
    local window = {
        Gui = gui,
        Container = mainContainer,
        Frame = mainFrame,
        Sidebar = sidebarPadding,
        Content = contentScroll,
        CurrentCategory = nil,
        Categories = {}
    }
    
    local categories = {
        {name = "aimbot", icon = "🎯", color = Color3.fromRGB(255, 100, 100)},
        {name = "ragebot", icon = "⚡", color = Color3.fromRGB(255, 200, 100)},
        {name = "visuals", icon = "👁", color = Color3.fromRGB(150, 150, 255)},
        {name = "world", icon = "🌍", color = Color3.fromRGB(100, 200, 255)},
        {name = "inventory changer", icon = "🎒", color = Color3.fromRGB(255, 100, 150)},
        {name = "misc", icon = "⚙", color = Color3.fromRGB(180, 180, 180)},
        {name = "grenade helper", icon = "💣", color = Color3.fromRGB(200, 150, 100)},
        {name = "configs", icon = "📁", color = Color3.fromRGB(100, 180, 255)}
    }
    
    for i, cat in ipairs(categories) do
        self:AddCategory(window, cat.name, cat.icon, cat.color)
    end
    
    Animations:FadeIn(mainFrame, 0.4)
    Animations:SlideUp(mainContainer, 40, 0.45)
    
    return window
end

function Baimless:AddCategory(window, name, icon, iconColor)
    local btn = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        LayoutOrder = #window.Categories + 1,
        Parent = window.Sidebar
    })
    
    local highlightBg = Components:Create("Frame", {
        Size = UDim2.new(1, -8, 1, -4),
        Position = UDim2.new(0, 4, 0, 2),
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = btn
    })
    Components:CreateCorner(highlightBg, UDim.new(0, 3))
    
    local highlight = Components:Create("Frame", {
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = btn
    })
    Components:CreateCorner(highlight, UDim.new(0, 2))
    
    local iconLabel = Components:Create("TextLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = iconColor or Theme.Colors.TextDim,
        TextSize = 16,
        Font = Theme.Fonts.Regular,
        Parent = btn
    })
    iconLabel:SetAttribute("OriginalBgTransparency", 1)
    iconLabel:SetAttribute("DefaultColor", iconColor or Theme.Colors.TextDim)
    
    local label = Components:Create("TextLabel", {
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 42, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Colors.TextDim,
        TextSize = 12,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    label:SetAttribute("OriginalBgTransparency", 1)
    
    btn.MouseButton1Click:Connect(function()
        self:SelectCategory(window, name)
    end)
    
    btn.MouseEnter:Connect(function()
        if window.CurrentCategory ~= name then
            Animations:Tween(label, {TextColor3 = Theme.Colors.Text}, 0.15)
            Animations:Tween(highlightBg, {BackgroundTransparency = 0.95}, 0.15)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if window.CurrentCategory ~= name then
            Animations:Tween(label, {TextColor3 = Theme.Colors.TextDim}, 0.15)
            Animations:Tween(highlightBg, {BackgroundTransparency = 1}, 0.15)
        end
    end)
    
    window.Categories[name] = {
        Button = btn,
        Label = label,
        Icon = iconLabel,
        Highlight = highlight,
        HighlightBg = highlightBg,
        Sections = {}
    }
    
    if not window.CurrentCategory then
        self:SelectCategory(window, name)
    end
end

function Baimless:SelectCategory(window, name)
    if window.CurrentCategory then
        local prev = window.Categories[window.CurrentCategory]
        prev.Highlight.Visible = false
        Animations:Tween(prev.HighlightBg, {BackgroundTransparency = 1}, 0.2)
        Animations:Tween(prev.Label, {TextColor3 = Theme.Colors.TextDim}, 0.2)
        if prev.Icon:GetAttribute("DefaultColor") then
            Animations:Tween(prev.Icon, {TextColor3 = prev.Icon:GetAttribute("DefaultColor")}, 0.2)
        end
    end
    
    window.CurrentCategory = name
    local current = window.Categories[name]
    current.Highlight.Visible = true
    Animations:Tween(current.HighlightBg, {BackgroundTransparency = 0.92}, 0.2)
    Animations:Tween(current.Label, {TextColor3 = Theme.Colors.Text}, 0.2)
    Animations:Tween(current.Icon, {TextColor3 = Theme.Colors.Accent}, 0.2)
    
    for _, child in ipairs(window.Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    self:LoadCategoryContent(window, name)
end

function Baimless:LoadCategoryContent(window, categoryName)
    if categoryName == "world" then
        local section1 = self:AddSection(window, "Color")
        self:AddCheckbox(section1, "World Modulation", false)
        self:AddCheckbox(section1, "Night Modulation", false)
        self:AddCheckbox(section1, "Sky Modulation", false)
        
        local section2 = self:AddSection(window, "Dropped Weapons")
        self:AddCheckbox(section2, "Icon Weapon", false)
    elseif categoryName == "inventory changer" then
        local section = self:AddSection(window, "Grenade Tracer")
        self:AddCheckbox(section, "Icon Made Color", false)
    elseif categoryName == "visuals" then
        local section = self:AddSection(window, "ESP")
        self:AddCheckbox(section, "Enable ESP", false)
        self:AddCheckbox(section, "Show Names", false)
        self:AddCheckbox(section, "Show Distance", false)
    end
end

function Baimless:AddSection(window, title)
    local section = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Parent = window.Content
    })
    
    local headerBg = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Colors.PanelDark,
        BorderSizePixel = 0,
        Parent = section
    })
    Components:CreateCorner(headerBg, UDim.new(0, 3))
    Components:CreateStroke(headerBg, Theme.Colors.Border, 1, 0.5)
    
    local accentLine = Components:Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Parent = headerBg
    })
    
    local titleLabel = Components:Create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Colors.Accent,
        TextSize = 13,
        Font = Theme.Fonts.Semibold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerBg
    })
    titleLabel:SetAttribute("OriginalBgTransparency", 1)
    
    local container = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, -38),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
        Parent = section
    })
    
    local layout = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = container
    })
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, 38 + layout.AbsoluteContentSize.Y)
    end)
    
    return container
end

function Baimless:AddCheckbox(parent, text, defaultValue)
    local frame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.Colors.PanelDark,
        BorderSizePixel = 0,
        Parent = parent
    })
    Components:CreateCorner(frame, UDim.new(0, 3))
    Components:CreateStroke(frame, Theme.Colors.Border, 1, 0.7)
    
    local label = Components:Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Colors.Text,
        TextSize = 11,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    label:SetAttribute("OriginalBgTransparency", 1)
    
    local checkbox = Components:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = defaultValue and Theme.Colors.Accent or Theme.Colors.InputBg,
        BorderSizePixel = 0,
        Parent = frame
    })
    Components:CreateCorner(checkbox, UDim.new(0, 2))
    Components:CreateStroke(checkbox, defaultValue and Theme.Colors.Accent or Theme.Colors.Border, 1)
    
    local checkmark = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Theme.Fonts.Bold,
        Visible = defaultValue,
        Parent = checkbox
    })
    checkmark:SetAttribute("OriginalBgTransparency", 1)
    
    local button = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame
    })
    
    local state = defaultValue
    button.MouseButton1Click:Connect(function()
        state = not state
        checkmark.Visible = state
        
        local stroke = checkbox:FindFirstChildOfClass("UIStroke")
        if state then
            Animations:Tween(checkbox, {BackgroundColor3 = Theme.Colors.Accent}, 0.15)
            if stroke then
                Animations:Tween(stroke, {Color = Theme.Colors.Accent}, 0.15)
            end
        else
            Animations:Tween(checkbox, {BackgroundColor3 = Theme.Colors.InputBg}, 0.15)
            if stroke then
                Animations:Tween(stroke, {Color = Theme.Colors.Border}, 0.15)
            end
        end
    end)
    
    button.MouseEnter:Connect(function()
        Animations:Tween(frame, {BackgroundColor3 = Theme.Colors.Panel}, 0.15)
    end)
    
    button.MouseLeave:Connect(function()
        Animations:Tween(frame, {BackgroundColor3 = Theme.Colors.PanelDark}, 0.15)
    end)
    
    return frame
end

function Baimless:CreateScreenGui()
    local gui = Components:Create("ScreenGui", {
        Name = "BaimlessUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
    
    if gethui then
        gui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    else
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    return gui
end

return Baimless