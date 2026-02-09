-- Zolaire Interface Library
-- Still in development

local Zolaire = {}

-- Configuration
Zolaire.Settings = {
    Theme = "Dark",
    Accent = Color3.fromRGB(0, 170, 255),
    Font = Enum.Font.Gotham,
    EnableKeybinds = true,
    ToggleKey = Enum.KeyCode.RightShift,
    ScreenGuiParent = game:GetService("CoreGui"),
    DefaultWindowPosition = UDim2.new(0.5, -250, 0.5, -200) -- Center position
}

-- Colors
Zolaire.Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    Element = Color3.fromRGB(35, 35, 35),
    Header = Color3.fromRGB(45, 45, 45),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 200, 200),
    Stroke = Color3.fromRGB(60, 60, 60),
    Hover = Color3.fromRGB(50, 50, 50),
    Selected = Color3.fromRGB(40, 40, 40),
    ToggleIcon = Color3.fromRGB(0, 170, 255)
}

-- Elements storage
Zolaire.Elements = {}
Zolaire.Windows = {}
Zolaire.Loaded = false
Zolaire.Flags = {}
Zolaire.ToggleIcon = nil
Zolaire.InterfaceVisible = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Improved Tween function with easing options
local function Tween(Object, Properties, Duration, Style, Direction)
    local TweenInfo = TweenInfo.new(Duration or 0.25, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out)
    local Tween = TweenService:Create(Object, TweenInfo, Properties)
    Tween:Play()
    return Tween
end

-- Create rounded corner function
local function ApplyCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    if type(Radius) == "table" then
        Corner.CornerRadius = UDim.new(0, 0)
        if Radius.TopLeft then
            Instance.new("UICorner", Object).CornerRadius = UDim.new(0, Radius.TopLeft)
        end
    else
        Corner.CornerRadius = UDim.new(0, Radius or 8)
    end
    Corner.Parent = Object
    return Corner
end

-- Create stroke function
local function ApplyStroke(Object, Thickness, Color, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = Thickness or 1
    Stroke.Color = Color or Zolaire.Colors.Stroke
    Stroke.Transparency = Transparency or 0
    Stroke.Parent = Object
    return Stroke
end

-- Loader Animation (Enhanced)
local Loader = {
    Container = nil,
    Active = false
}

function Loader:Show()
    if self.Active then return end
    self.Active = true

    local LoaderContainer = Instance.new("ScreenGui")
    LoaderContainer.Name = "ZolaireLoader"
    LoaderContainer.IgnoreGuiInset = true
    LoaderContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.BackgroundColor3 = Zolaire.Colors.Background
    Background.BackgroundTransparency = 0.5
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Parent = LoaderContainer

    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Name = "Loader"
    LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoaderFrame.Size = UDim2.new(0, 300, 0, 140)
    LoaderFrame.BackgroundColor3 = Zolaire.Colors.Element
    LoaderFrame.BackgroundTransparency = 0
    LoaderFrame.Parent = LoaderContainer

    ApplyCorner(LoaderFrame, 12)
    ApplyStroke(LoaderFrame, 2, Zolaire.Settings.Accent)

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.Text = "Zolaire Interface"
    LoadingText.Font = Zolaire.Settings.Font
    LoadingText.TextSize = 20
    LoadingText.TextColor3 = Zolaire.Colors.Text
    LoadingText.BackgroundTransparency = 1
    LoadingText.Size = UDim2.new(1, 0, 0, 35)
    LoadingText.Position = UDim2.new(0, 0, 0, 15)
    LoadingText.Parent = LoaderFrame

    local BarBackground = Instance.new("Frame")
    BarBackground.Name = "BarBackground"
    BarBackground.BackgroundColor3 = Zolaire.Colors.Header
    BarBackground.Size = UDim2.new(0.8, 0, 0, 8)
    BarBackground.Position = UDim2.new(0.1, 0, 0.6, 0)
    BarBackground.Parent = LoaderFrame
    ApplyCorner(BarBackground, 4)

    local BarFill = Instance.new("Frame")
    BarFill.Name = "BarFill"
    BarFill.BackgroundColor3 = Zolaire.Settings.Accent
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.Parent = BarBackground
    ApplyCorner(BarFill, 4)

    local PercentageText = Instance.new("TextLabel")
    PercentageText.Name = "Percentage"
    PercentageText.Text = "0%"
    PercentageText.Font = Zolaire.Settings.Font
    PercentageText.TextSize = 14
    PercentageText.TextColor3 = Zolaire.Colors.SubText
    PercentageText.BackgroundTransparency = 1
    PercentageText.Size = UDim2.new(1, 0, 0, 20)
    PercentageText.Position = UDim2.new(0, 0, 0.8, 0)
    PercentageText.Parent = LoaderFrame

    self.Container = LoaderContainer
    self.BarFill = BarFill
    self.PercentageText = PercentageText
    self.LoadingText = LoadingText

    LoaderContainer.Parent = Zolaire.Settings.ScreenGuiParent

    Tween(Background, {BackgroundTransparency = 0}, 0.3)
    Tween(LoaderFrame, {Size = UDim2.new(0, 320, 0, 150)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return self
end

function Loader:Update(Percentage, Text)
    if not self.Active then return end
    Percentage = math.clamp(Percentage, 0, 100)

    Tween(self.BarFill, {
        Size = UDim2.new(Percentage / 100, 0, 1, 0)
    }, 0.4, Enum.EasingStyle.Quart)

    self.PercentageText.Text = string.format("%d%%", Percentage)
    if Text then
        self.LoadingText.Text = Text
        Tween(self.LoadingText, {TextTransparency = 0}, 0.2)
    end
end

function Loader:Hide()
    if not self.Active then return end
    self.Active = false

    if self.Container then
        Tween(self.Container.Background, {BackgroundTransparency = 1}, 0.5)
        Tween(self.Container.Loader, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 280, 0, 130)
        }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        task.wait(0.5)
        if self.Container and self.Container.Parent then
            self.Container:Destroy()
        end
    end

    self.Container = nil
    self.BarFill = nil
    self.PercentageText = nil
    self.LoadingText = nil
end

-- Create Toggle Icon
local function CreateToggleIcon()
    if Zolaire.ToggleIcon then return end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "ZolaireToggle"
    ToggleGui.IgnoreGuiInset = true
    ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToggleGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleIcon"
    ToggleButton.AnchorPoint = Vector2.new(1, 0)
    ToggleButton.Position = UDim2.new(1, -20, 0, 20)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.BackgroundColor3 = Zolaire.Colors.ToggleIcon
    ToggleButton.AutoButtonColor = false
    ToggleButton.Image = "rbxassetid://3926305904"
    ToggleButton.ImageRectOffset = Vector2.new(964, 324)
    ToggleButton.ImageRectSize = Vector2.new(36, 36)
    ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)

    ApplyCorner(ToggleButton, 10)
    ApplyStroke(ToggleButton, 2, Zolaire.Colors.Stroke)

    ToggleButton.Parent = ToggleGui
    ToggleGui.Parent = Zolaire.Settings.ScreenGuiParent

    Zolaire.ToggleIcon = ToggleButton

    -- Click animation
    ToggleButton.MouseButton1Down:Connect(function()
        Tween(ToggleButton, {Size = UDim2.new(0, 45, 0, 45)}, 0.1)
    end)

    ToggleButton.MouseButton1Up:Connect(function()
        Tween(ToggleButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.1)
        Zolaire:ToggleInterface()
    end)

    -- Hover effects
    ToggleButton.MouseEnter:Connect(function()
        Tween(ToggleButton, {
            BackgroundColor3 = Zolaire.Settings.Accent,
            Rotation = 5
        }, 0.2)
    end)

    ToggleButton.MouseLeave:Connect(function()
        Tween(ToggleButton, {
            BackgroundColor3 = Zolaire.Colors.ToggleIcon,
            Rotation = 0
        }, 0.2)
    end)

    -- Mobile touch support
    local TouchTapInProgress = false
    ToggleButton.TouchTap:Connect(function()
        if not TouchTapInProgress then
            TouchTapInProgress = true
            Zolaire:ToggleInterface()
            task.wait(0.3)
            TouchTapInProgress = false
        end
    end)
end

-- Enhanced drag function with mobile support
local function MakeDraggable(Frame, DragBar)
    local Dragging = false
    local DragInput, DragStart, StartPos
    local DragConnection, InputChangedConnection

    local function Update(Input)
        local Delta = Input.Position - DragStart
        local NewPos = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
        
        -- Boundary checking
        local ViewportSize = workspace.CurrentCamera.ViewportSize
        local FrameSize = Frame.AbsoluteSize
        local MinX = 0
        local MaxX = ViewportSize.X - FrameSize.X
        local MinY = 0
        local MaxY = ViewportSize.Y - FrameSize.Y
        
        local AbsolutePos = NewPos
        local ClampedX = math.clamp(AbsolutePos.X.Offset, MinX, MaxX)
        local ClampedY = math.clamp(AbsolutePos.Y.Offset, MinY, MaxY)
        
        Frame.Position = UDim2.new(
            AbsolutePos.X.Scale,
            ClampedX,
            AbsolutePos.Y.Scale,
            ClampedY
        )
    end

    DragBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Frame.Position
            
            Tween(Frame, {BackgroundTransparency = 0.05}, 0.1)
            Tween(DragBar, {BackgroundTransparency = 0.1}, 0.1)

            local Connection
            Connection = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    Connection:Disconnect()
                    Tween(Frame, {BackgroundTransparency = 0}, 0.2)
                    Tween(DragBar, {BackgroundTransparency = 0}, 0.2)
                end
            end)
        end
    end)

    InputChangedConnection = UserInputService.InputChanged:Connect(function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            Update(Input)
        end
    end)

    -- Clean up connection when frame is destroyed
    Frame.Destroying:Connect(function()
        if InputChangedConnection then
            InputChangedConnection:Disconnect()
        end
    end)
end

-- Initialize Zolaire
function Zolaire:Init(Configuration)
    if self.Loaded then return end

    if Configuration then
        for key, value in pairs(Configuration) do
            self.Settings[key] = value
        end
    end

    Loader:Show()
    Loader:Update(0, "Initializing...")

    task.wait(0.5)
    Loader:Update(20, "Creating interface...")

    self.Interface = Instance.new("ScreenGui")
    self.Interface.Name = "ZolaireInterface"
    self.Interface.IgnoreGuiInset = true
    self.Interface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Interface.ResetOnSpawn = false

    self.Notifications = Instance.new("Frame")
    self.Notifications.Name = "Notifications"
    self.Notifications.BackgroundTransparency = 1
    self.Notifications.Size = UDim2.new(1, 0, 1, 0)
    self.Notifications.Parent = self.Interface

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = self.Notifications

    task.wait(0.5)
    Loader:Update(50, "Setting up keybinds...")

    if self.Settings.EnableKeybinds then
        local ToggleConnection
        ToggleConnection = UserInputService.InputBegan:Connect(function(Input)
            if Input.KeyCode == self.Settings.ToggleKey then
                self:ToggleInterface()
            end
        end)
        table.insert(self.Elements, ToggleConnection)
    end

    task.wait(0.5)
    Loader:Update(80, "Creating toggle icon...")

    CreateToggleIcon()

    task.wait(0.5)
    Loader:Update(100, "Ready!")
    task.wait(0.5)

    self.Interface.Parent = self.Settings.ScreenGuiParent
    self.Loaded = true

    Loader:Hide()

    self:Notify({
        Title = "Zolaire Interface",
        Content = "Welcome! Use the blue icon or RightShift to toggle UI.",
        Duration = 5,
        Actions = {
            {
                Title = "Got it!",
                Callback = function()
                    print("Zolaire UI ready")
                end
            }
        }
    })

    return self
end

-- Enhanced Toggle Interface
function Zolaire:ToggleInterface()
    if not self.Loaded then return end

    local Windows = self.Interface:GetDescendants()
    local isNowVisible = not self.InterfaceVisible
    
    -- Slide animation for toggle icon
    if Zolaire.ToggleIcon then
        if isNowVisible then
            Tween(Zolaire.ToggleIcon, {
                Position = UDim2.new(1, -20, 0, 20),
                Rotation = 0,
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Tween(Zolaire.ToggleIcon, {
                Position = UDim2.new(1, -20, 0, 20),
                Rotation = 180,
                ImageColor3 = Zolaire.Settings.Accent
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end

    -- Toggle all windows with animation
    for _, Window in ipairs(Windows) do
        if Window:IsA("Frame") and Window.Name == "Window" then
            Window.Visible = true
            
            if isNowVisible then
                -- Show animation
                Window.Position = Window.Position + UDim2.new(0, 0, 0, 20)
                Window.BackgroundTransparency = 1
                Tween(Window, {
                    BackgroundTransparency = 0,
                    Position = Window.Position - UDim2.new(0, 0, 0, 20)
                }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            else
                -- Hide animation
                Tween(Window, {
                    BackgroundTransparency = 1,
                    Position = Window.Position + UDim2.new(0, 0, 0, 20)
                }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                
                task.spawn(function()
                    task.wait(0.25)
                    if Window.Parent then
                        Window.Visible = false
                    end
                end)
            end
        end
    end

    self.InterfaceVisible = isNowVisible
    
    -- Play sound effect (optional)
    if isNowVisible then
        print("Zolaire UI: Shown")
    else
        print("Zolaire UI: Hidden")
    end
end

-- Create Window (Enhanced)
function Zolaire:CreateWindow(WindowConfig)
    if not self.Loaded then
        warn("Zolaire not initialized. Call Zolaire:Init() first.")
        return
    end

    local Window = {}

    Window.Config = {
        Name = WindowConfig.Name or "Window",
        LoadingTitle = WindowConfig.LoadingTitle or "Loading",
        LoadingSubtitle = WindowConfig.LoadingSubtitle or "",
        ConfigurationSaving = WindowConfig.ConfigurationSaving or { Enabled = false },
        Theme = WindowConfig.Theme or "Dark",
        Keybind = WindowConfig.Keybind or nil,
        Position = WindowConfig.Position or self.Settings.DefaultWindowPosition,
        Size = WindowConfig.Size or UDim2.new(0, 500, 0, 450)
    }

    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "Window"
    WindowFrame.BackgroundColor3 = Zolaire.Colors.Background
    WindowFrame.Size = Window.Config.Size
    WindowFrame.Position = Window.Config.Position
    WindowFrame.ClipsDescendants = true
    WindowFrame.Visible = true
    WindowFrame.Parent = self.Interface

    ApplyCorner(WindowFrame, 12)
    ApplyStroke(WindowFrame, 2)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Zolaire.Colors.Header
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.Parent = WindowFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = Window.Config.Name
    Title.Font = Zolaire.Settings.Font
    Title.TextSize = 18
    Title.TextColor3 = Zolaire.Colors.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 24
    CloseButton.TextColor3 = Zolaire.Colors.Text
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -17.5)
    CloseButton.Parent = TopBar
    
    ApplyCorner(CloseButton, 8)
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(WindowFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        task.wait(0.3)
        WindowFrame:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.2)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.BackgroundTransparency = 1
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.Parent = WindowFrame

    local ContentLayout = Instance.new("UIPadding")
    ContentLayout.PaddingLeft = UDim.new(0, 15)
    ContentLayout.PaddingRight = UDim.new(0, 15)
    ContentLayout.PaddingTop = UDim.new(0, 15)
    ContentLayout.PaddingBottom = UDim.new(0, 15)
    ContentLayout.Parent = Content

    MakeDraggable(WindowFrame, TopBar)

    local WindowTable = {
        Instance = WindowFrame,
        Title = Title,
        Content = Content,
        CloseButton = CloseButton
    }

    table.insert(self.Windows, WindowTable)
    return WindowTable
end

-- Notify function (keep your existing notification system)
function Zolaire:Notify(NotificationConfig)
    -- Your existing notification implementation
    print("Notification:", NotificationConfig.Title)
end

return Zolaire
