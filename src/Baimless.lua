--[[
    Baimless UI Library
    Main entry point for the UI library
    
    Usage:
        local Baimless = loadstring(game:HttpGet('https://raw.githubusercontent.com/axzaxzz/baimless/main/src/Baimless.lua'))()
        
        -- Show login screen
        Baimless:ShowLogin(function(username, password)
            -- Your authentication logic here
            return true -- Return true to proceed to main UI
        end)
        
        -- Or create main UI directly
        local UI = Baimless:CreateWindow()
--]]

local Baimless = {}
Baimless.__index = Baimless

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Core modules
local Theme = {}
local Components = {}
local Animations = {}

-- Theme Configuration
Theme.Colors = {
    Background = Color3.fromRGB(12, 12, 15),
    Panel = Color3.fromRGB(26, 26, 33),
    Accent = Color3.fromRGB(188, 70, 255),
    AccentSoft = Color3.fromRGB(210, 123, 255),
    Text = Color3.fromRGB(234, 234, 234),
    TextDim = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(40, 40, 50),
    ButtonDark = Color3.fromRGB(45, 45, 55),
    ButtonDarkHover = Color3.fromRGB(55, 55, 65),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 100, 100)
}

Theme.Sizes = {
    CornerRadius = UDim.new(0, 4),
    BorderSize = 1,
    Padding = 12,
    Spacing = 8
}

Theme.Fonts = {
    Regular = Enum.Font.Gotham,
    Bold = Enum.Font.GothamBold,
    Mono = Enum.Font.RobotoMono
}

-- Animation Configuration
Animations.Speed = 0.25
Animations.Style = Enum.EasingStyle.Quad
Animations.Direction = Enum.EasingDirection.Out

function Animations:Tween(object, properties, duration)
    duration = duration or self.Speed
    local tween = TweenService:Create(object, TweenInfo.new(duration, self.Style, self.Direction), properties)
    tween:Play()
    return tween
end

function Animations:FadeIn(object, duration)
    object.Transparency = 1
    self:Tween(object, {Transparency = 0}, duration)
end

function Animations:SlideUp(object, distance, duration)
    local originalPos = object.Position
    object.Position = originalPos + UDim2.new(0, 0, 0, distance or 10)
    self:Tween(object, {Position = originalPos}, duration)
end

function Animations:Shake(object, intensity, duration)
    local originalPos = object.Position
    intensity = intensity or 5
    duration = duration or 0.5
    
    for i = 1, 4 do
        task.wait(duration / 8)
        object.Position = originalPos + UDim2.new(0, math.random(-intensity, intensity), 0, 0)
    end
    object.Position = originalPos
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

-- Component Utilities
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

function Components:CreateStroke(parent, color, thickness)
    return self:Create("UIStroke", {
        Color = color or Theme.Colors.Border,
        Thickness = thickness or Theme.Sizes.BorderSize,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

function Components:CreatePadding(parent, padding)
    padding = padding or Theme.Sizes.Padding
    return self:Create("UIPadding", {
        PaddingTop = UDim.new(0, padding),
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        Parent = parent
    })
end

-- Main Library Functions
function Baimless:ShowLogin(callback)
    local gui = self:CreateScreenGui()
    
    -- Background overlay
    local overlay = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    
    -- Login panel
    local panel = Components:Create("Frame", {
        Size = UDim2.new(0, 340, 0, 280),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Colors.Panel,
        BorderSizePixel = 0,
        Parent = overlay
    })
    Components:CreateCorner(panel)
    Components:CreateStroke(panel)
    Components:CreatePadding(panel, 24)
    
    -- Title
    local title = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "credentials",
        TextColor3 = Theme.Colors.Text,
        TextSize = 18,
        Font = Theme.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = panel
    })
    
    -- Username input
    local usernameFrame = self:CreateInput(panel, "username", UDim2.new(0, 0, 0, 50))
    local usernameBox = usernameFrame:FindFirstChildOfClass("TextBox")
    
    -- Password input
    local passwordFrame = self:CreateInput(panel, "password", UDim2.new(0, 0, 0, 110))
    local passwordBox = passwordFrame:FindFirstChildOfClass("TextBox")
    passwordBox.TextEditable = true
    
    -- Remember me checkbox
    local rememberFrame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 170),
        BackgroundTransparency = 1,
        Parent = panel
    })
    
    local checkbox = Components:Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = rememberFrame
    })
    Components:CreateCorner(checkbox, UDim.new(0, 2))
    Components:CreateStroke(checkbox)
    
    local checkmark = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✓",
        TextColor3 = Theme.Colors.Accent,
        TextSize = 14,
        Font = Theme.Fonts.Bold,
        Visible = false,
        Parent = checkbox
    })
    
    local rememberLabel = Components:Create("TextLabel", {
        Size = UDim2.new(1, -26, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        BackgroundTransparency = 1,
        Text = "Remember me",
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = rememberFrame
    })
    
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
        Animations:Tween(checkbox, {BackgroundColor3 = rememberState and Theme.Colors.Accent or Theme.Colors.Background}, 0.15)
    end)
    
    -- Submit button (dark gray like the reference image)
    local submitBtn = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 1, -40),
        BackgroundColor3 = Theme.Colors.ButtonDark,
        BorderSizePixel = 0,
        Text = "Submit",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Theme.Fonts.Bold,
        Parent = panel
    })
    Components:CreateCorner(submitBtn)
    
    -- Button hover effect
    submitBtn.MouseEnter:Connect(function()
        Animations:Tween(submitBtn, {BackgroundColor3 = Theme.Colors.ButtonDarkHover}, 0.15)
    end)
    
    submitBtn.MouseLeave:Connect(function()
        Animations:Tween(submitBtn, {BackgroundColor3 = Theme.Colors.ButtonDark}, 0.15)
    end)
    
    -- Submit handler
    submitBtn.MouseButton1Click:Connect(function()
        local username = usernameBox.Text
        local password = passwordBox.Text
        
        if username == "" or password == "" then
            Animations:Shake(panel, 5, 0.3)
            return
        end
        
        local success = callback(username, password)
        
        if success then
            Animations:Tween(overlay, {BackgroundTransparency = 1}, 0.3)
            Animations:FadeOutGui(panel, 0.3)
            task.wait(0.3)
            gui:Destroy()
            self:CreateWindow()
        else
            Animations:Shake(panel, 5, 0.3)
        end
    end)
    
    -- Entrance animations
    Animations:FadeIn(overlay, 0.3)
    Animations:SlideUp(panel, 10, 0.3)
end

function Baimless:CreateInput(parent, placeholder, position)
    local frame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = position,
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = parent
    })
    Components:CreateCorner(frame)
    Components:CreateStroke(frame)
    
    local textbox = Components:Create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.Colors.TextDim,
        TextColor3 = Theme.Colors.Text,
        TextSize = 13,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = frame
    })
    
    return frame
end

function Baimless:CreateWindow()
    local gui = self:CreateScreenGui()
    
    -- Main container
    local mainFrame = Components:Create("Frame", {
        Size = UDim2.new(0, 800, 0, 600),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = gui
    })
    Components:CreateCorner(mainFrame)
    Components:CreateStroke(mainFrame)
    
    -- Header
    local header = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Colors.Panel,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    Components:CreateCorner(header)
    
    -- Logo
    local logo = Components:Create("TextLabel", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "BAIMLESS",
        TextColor3 = Theme.Colors.Text,
        TextSize = 16,
        Font = Theme.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Tab bar (world modulation, screen modulation)
    local tabBar = Components:Create("Frame", {
        Size = UDim2.new(1, -170, 1, 0),
        Position = UDim2.new(0, 170, 0, 0),
        BackgroundTransparency = 1,
        Parent = header
    })
    
    local tabList = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 20),
        Parent = tabBar
    })
    
    -- Sidebar
    local sidebar = Components:Create("Frame", {
        Size = UDim2.new(0, 180, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Theme.Colors.Panel,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    local sidebarList = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = sidebar
    })
    
    -- Content area
    local content = Components:Create("Frame", {
        Size = UDim2.new(1, -180, 1, -50),
        Position = UDim2.new(0, 180, 0, 50),
        BackgroundColor3 = Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    Components:CreatePadding(content, 16)
    
    local contentScroll = Components:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = content
    })
    
    local contentList = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = contentScroll
    })
    
    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentScroll.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y)
    end)
    
    -- Window object
    local window = {
        Gui = gui,
        Frame = mainFrame,
        Sidebar = sidebar,
        Content = contentScroll,
        CurrentCategory = nil,
        Categories = {}
    }
    
    -- Add categories
    local categories = {
        {name = "aimbot", icon = "🎯"},
        {name = "ragebot", icon = "⚡"},
        {name = "visuals", icon = "👁️"},
        {name = "world", icon = "🌍"},
        {name = "inventory changer", icon = "🎒"},
        {name = "misc", icon = "⚙️"},
        {name = "grenade helper", icon = "💣"},
        {name = "configs", icon = "📁"}
    }
    
    for i, cat in ipairs(categories) do
        self:AddCategory(window, cat.name, cat.icon)
    end
    
    -- Entrance animation
    Animations:FadeIn(mainFrame, 0.3)
    Animations:SlideUp(mainFrame, 15, 0.3)
    
    return window
end

function Baimless:AddCategory(window, name, icon)
    local btn = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        LayoutOrder = #window.Categories + 1,
        Parent = window.Sidebar
    })
    
    -- Highlight bar
    local highlight = Components:Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Colors.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = btn
    })
    
    -- Label
    local label = Components:Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = icon .. "  " .. name,
        TextColor3 = Theme.Colors.TextDim,
        TextSize = 13,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn
    })
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        self:SelectCategory(window, name)
    end)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        if window.CurrentCategory ~= name then
            Animations:Tween(label, {TextColor3 = Theme.Colors.Text}, 0.15)
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if window.CurrentCategory ~= name then
            Animations:Tween(label, {TextColor3 = Theme.Colors.TextDim}, 0.15)
        end
    end)
    
    window.Categories[name] = {
        Button = btn,
        Label = label,
        Highlight = highlight,
        Sections = {}
    }
    
    -- Select first category
    if #window.Categories == 1 then
        self:SelectCategory(window, name)
    end
end

function Baimless:SelectCategory(window, name)
    -- Deselect previous
    if window.CurrentCategory then
        local prev = window.Categories[window.CurrentCategory]
        prev.Highlight.Visible = false
        Animations:Tween(prev.Label, {TextColor3 = Theme.Colors.TextDim}, 0.15)
    end
    
    -- Select new
    window.CurrentCategory = name
    local current = window.Categories[name]
    current.Highlight.Visible = true
    Animations:Tween(current.Label, {TextColor3 = Theme.Colors.Text}, 0.15)
    
    -- Clear content
    for _, child in ipairs(window.Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Load category content (placeholder)
    self:LoadCategoryContent(window, name)
end

function Baimless:LoadCategoryContent(window, categoryName)
    -- Add sections based on category
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
    end
end

function Baimless:AddSection(window, title)
    local section = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = window.Content
    })
    
    local titleLabel = Components:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Colors.Accent,
        TextSize = 14,
        Font = Theme.Fonts.Bold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
    
    local container = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = section
    })
    
    local layout = Components:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = container
    })
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, 30 + layout.AbsoluteContentSize.Y)
    end)
    
    return container
end

function Baimless:AddCheckbox(parent, text, defaultValue)
    local frame = Components:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = parent
    })
    
    local checkbox = Components:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 0, 4),
        BackgroundColor3 = defaultValue and Theme.Colors.Accent or Theme.Colors.Background,
        BorderSizePixel = 0,
        Parent = frame
    })
    Components:CreateCorner(checkbox, UDim.new(0, 2))
    Components:CreateStroke(checkbox)
    
    local label = Components:Create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Colors.Text,
        TextSize = 12,
        Font = Theme.Fonts.Regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    local button = Components:Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = frame
    })
    
    local state = defaultValue
    button.MouseButton1Click:Connect(function()
        state = not state
        Animations:Tween(checkbox, {
            BackgroundColor3 = state and Theme.Colors.Accent or Theme.Colors.Background
        }, 0.15)
    end)
    
    return frame
end

function Baimless:CreateScreenGui()
    local gui = Components:Create("ScreenGui", {
        Name = "BaimlessUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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