-- Zolaire Interface Library
-- This is a beta test

local Zolaire = {}

-- Configuration
Zolaire.Settings = {
    Theme = "Dark",
    Accent = Color3.fromRGB(0, 170, 255),
    Font = Enum.Font.Gotham,
    EnableKeybinds = true,
    ToggleKey = Enum.KeyCode.RightShift,
    ScreenGuiParent = game:GetService("CoreGui")
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
    Selected = Color3.fromRGB(40, 40, 40)
}

-- Elements storage
Zolaire.Elements = {}
Zolaire.Windows = {}
Zolaire.Loaded = false
Zolaire.Flags = {}

-- Tween service for smooth animations
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Tween function
local function Tween(Object, Properties, Duration, Style, Direction)
    local TweenInfo = TweenInfo.new(Duration or 0.2, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out)
    local Tween = TweenService:Create(Object, TweenInfo, Properties)
    Tween:Play()
    return Tween
end

-- Create rounded corner function
local function ApplyCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 5)
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

-- Loader Animation
local Loader = {
    Container = nil,
    Active = false
}

function Loader:Show()
    if self.Active then return end
    
    self.Active = true
    
    -- Create loader container
    local LoaderContainer = Instance.new("ScreenGui")
    LoaderContainer.Name = "ZolaireLoader"
    LoaderContainer.IgnoreGuiInset = true
    LoaderContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.BackgroundColor3 = Zolaire.Colors.Background
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Parent = LoaderContainer
    
    -- Main loader frame
    local LoaderFrame = Instance.new("Frame")
    LoaderFrame.Name = "Loader"
    LoaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoaderFrame.Size = UDim2.new(0, 300, 0, 120)
    LoaderFrame.BackgroundColor3 = Zolaire.Colors.Element
    LoaderFrame.BackgroundTransparency = 0
    LoaderFrame.Parent = LoaderContainer
    
    ApplyCorner(LoaderFrame, 8)
    ApplyStroke(LoaderFrame)
    
    -- Loading text
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.Text = "Zolaire Interface"
    LoadingText.Font = Zolaire.Settings.Font
    LoadingText.TextSize = 18
    LoadingText.TextColor3 = Zolaire.Colors.Text
    LoadingText.BackgroundTransparency = 1
    LoadingText.Size = UDim2.new(1, 0, 0, 30)
    LoadingText.Position = UDim2.new(0, 0, 0, 10)
    LoadingText.Parent = LoaderFrame
    
    -- Loading bar background
    local BarBackground = Instance.new("Frame")
    BarBackground.Name = "BarBackground"
    BarBackground.BackgroundColor3 = Zolaire.Colors.Header
    BarBackground.Size = UDim2.new(0.8, 0, 0, 6)
    BarBackground.Position = UDim2.new(0.1, 0, 0.6, 0)
    BarBackground.Parent = LoaderFrame
    ApplyCorner(BarBackground, 3)
    
    -- Loading bar fill
    local BarFill = Instance.new("Frame")
    BarFill.Name = "BarFill"
    BarFill.BackgroundColor3 = Zolaire.Settings.Accent
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.Parent = BarBackground
    ApplyCorner(BarFill, 3)
    
    -- Percentage text
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
    
    -- Store reference
    self.Container = LoaderContainer
    self.BarFill = BarFill
    self.PercentageText = PercentageText
    self.LoadingText = LoadingText
    
    -- Parent to CoreGui
    LoaderContainer.Parent = Zolaire.Settings.ScreenGuiParent
    
    -- Animation
    local pulseConnection
    pulseConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.Active then
            pulseConnection:Disconnect()
            return
        end
        
        local glow = math.sin(tick() * 5) * 0.1 + 0.9
        LoadingText.TextTransparency = 1 - glow
    end)
    
    return self
end

function Loader:Update(Percentage, Text)
    if not self.Active then return end
    
    Percentage = math.clamp(Percentage, 0, 100)
    
    -- Update bar
    Tween(self.BarFill, {
        Size = UDim2.new(Percentage / 100, 0, 1, 0)
    }, 0.3)
    
    -- Update text
    self.PercentageText.Text = string.format("%d%%", Percentage)
    
    if Text then
        self.LoadingText.Text = Text
    end
end

function Loader:Hide()
    if not self.Active then return end
    
    self.Active = false
    
    -- Fade out animation
    if self.Container then
        Tween(self.Container, {
            BackgroundTransparency = 1
        }, 0.5):Play()
        
        task.wait(0.5)
        
        if self.Container and self.Container.Parent then
            self.Container:Destroy()
        end
    end
    
    self.Container = nil
end

-- Initialize Zolaire
function Zolaire:Init(Configuration)
    if self.Loaded then return end
    
    -- Merge configuration
    if Configuration then
        for key, value in pairs(Configuration) do
            self.Settings[key] = value
        end
    end
    
    -- Show loader
    Loader:Show()
    Loader:Update(0, "Initializing...")
    
    -- Create main interface
    task.wait(0.5)
    Loader:Update(20, "Creating interface...")
    
    -- Main screen gui
    self.Interface = Instance.new("ScreenGui")
    self.Interface.Name = "ZolaireInterface"
    self.Interface.IgnoreGuiInset = true
    self.Interface.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Notification holder
    self.Notifications = Instance.new("Frame")
    self.Notifications.Name = "Notifications"
    self.Notifications.BackgroundTransparency = 1
    self.Notifications.Size = UDim2.new(1, 0, 1, 0)
    self.Notifications.Parent = self.Interface
    
    -- UIListLayout for notifications
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = self.Notifications
    
    task.wait(0.5)
    Loader:Update(50, "Setting up keybinds...")
    
    -- Toggle keybind
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
    Loader:Update(80, "Finalizing...")
    
    -- Parent interface
    self.Interface.Parent = self.Settings.ScreenGuiParent
    
    -- Mark as loaded
    self.Loaded = true
    
    task.wait(0.5)
    Loader:Update(100, "Ready!")
    task.wait(0.5)
    
    Loader:Hide()
    
    -- Welcome notification
    self:Notify({
        Title = "Zolaire Interface",
        Content = "Welcome! Press RightShift to toggle interface.",
        Duration = 5,
        Actions = {
            {
                Title = "Okay",
                Callback = function()
                    print("Notification acknowledged")
                end
            }
        }
    })
    
    return self
end

-- Toggle interface visibility
function Zolaire:ToggleInterface()
    if not self.Loaded then return end
    
    local Windows = self.Interface:GetDescendants()
    local isVisible = false
    
    for _, Window in ipairs(Windows) do
        if Window:IsA("Frame") and Window.Name == "Window" then
            isVisible = Window.Visible
            break
        end
    end
    
    for _, Window in ipairs(Windows) do
        if Window:IsA("Frame") and Window.Name == "Window" then
            Window.Visible = not isVisible
        end
    end
end

-- Create Window
function Zolaire:CreateWindow(WindowConfig)
    if not self.Loaded then
        warn("Zolaire not initialized. Call Zolaire:Init() first.")
        return
    end
    
    local Window = {}
    
    -- Window configuration
    Window.Config = {
        Name = WindowConfig.Name or "Window",
        LoadingTitle = WindowConfig.LoadingTitle or "Loading",
        LoadingSubtitle = WindowConfig.LoadingSubtitle or "",
        ConfigurationSaving = WindowConfig.ConfigurationSaving or { Enabled = false },
        Theme = WindowConfig.Theme or "Dark",
        Keybind = WindowConfig.Keybind or nil,
        Position = WindowConfig.Position or UDim2.new(0.05, 0, 0.05, 0),
        Size = WindowConfig.Size or UDim2.new(0, 500, 0, 400)
    }
    
    -- Create window frame
    local WindowFrame = Instance.new("Frame")
    WindowFrame.Name = "Window"
    WindowFrame.BackgroundColor3 = Zolaire.Colors.Background
    WindowFrame.Size = Window.Config.Size
    WindowFrame.Position = Window.Config.Position
    WindowFrame.ClipsDescendants = true
    WindowFrame.Parent = self.Interface
    
    ApplyCorner(WindowFrame, 8)
    ApplyStroke(WindowFrame)
    
    -- Top bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.BackgroundColor3 = Zolaire.Colors.Header
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.Parent = WindowFrame
    
    ApplyCorner(TopBar, {TopLeft = 8, TopRight = 8, BottomLeft = 0, BottomRight = 0})
    
    -- Window title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = Window.Config.Name
    Title.Font = Zolaire.Settings.Font
    Title.TextSize = 18
    Title.TextColor3 = Zolaire.Colors.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 20
    CloseButton.TextColor3 = Zolaire.Colors.Text
    CloseButton.BackgroundTransparency = 1
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Parent = TopBar
    
    -- Make window draggable
    local Dragging = false
    local DragInput, DragStart, StartPos
    
    local function Update(Input)
        local Delta = Input.Position - DragStart
        WindowFrame.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
    
    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = WindowFrame.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = Input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
    
    -- Close button functionality
    CloseButton.MouseButton1Click:Connect(function()
        Tween(WindowFrame, {
            Size = UDim2.new(0, WindowFrame.AbsoluteSize.X, 0, 0)
        }, 0.3):Play()
        
        task.wait(0.3)
        WindowFrame.Visible = false
        WindowFrame.Size = Window.Config.Size
    end)
    
    -- Content container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "Content"
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Size = UDim2.new(1, 0, 1, -40)
    ContentContainer.Position = UDim2.new(0, 0, 0, 40)
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = Zolaire.Settings.Accent
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentContainer.Parent = WindowFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = ContentContainer
    
    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)
    ContentPadding.Parent = ContentContainer
    
    -- Store window elements
    Window.Instance = WindowFrame
    Window.Content = ContentContainer
    Window.Elements = {}
    
    -- Window methods
    function Window:CreateTab(TabName)
        local Tab = {}
        
        -- Tab button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName .. "Tab"
        TabButton.Text = TabName
        TabButton.Font = Zolaire.Settings.Font
        TabButton.TextSize = 14
        TabButton.TextColor3 = Zolaire.Colors.Text
        TabButton.BackgroundColor3 = Zolaire.Colors.Element
        TabButton.Size = UDim2.new(0, 80, 0, 30)
        TabButton.Position = UDim2.new(0, 10 + (#Window.Elements * 90), 0, 45)
        TabButton.Parent = Window.Instance
        
        ApplyCorner(TabButton, 6)
        ApplyStroke(TabButton)
        
        -- Tab content
        local TabContent = Instance.new("Frame")
        TabContent.Name = TabName .. "Content"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Visible = false
        TabContent.Parent = Window.Content
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 10)
        TabLayout.Parent = TabContent
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingTop = UDim.new(0, 10)
        TabPadding.Parent = TabContent
        
        -- Tab selection
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tab contents
            for _, ExistingTab in pairs(Window.Elements) do
                if ExistingTab.Content then
                    ExistingTab.Content.Visible = false
                end
                if ExistingTab.Button then
                    Tween(ExistingTab.Button, {
                        BackgroundColor3 = Zolaire.Colors.Element
                    }, 0.2)
                end
            end
            
            -- Show selected tab
            TabContent.Visible = true
            Tween(TabButton, {
                BackgroundColor3 = Zolaire.Settings.Accent
            }, 0.2)
        end)
        
        -- Make first tab active by default
        if #Window.Elements == 0 then
            TabContent.Visible = true
            Tween(TabButton, {
                BackgroundColor3 = Zolaire.Settings.Accent
            }, 0.2)
        end
        
        -- Store tab elements
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Elements = {}
        
        -- Tab methods
        function Tab:CreateSection(SectionName)
            local Section = {}
            
            -- Section container
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SectionName .. "Section"
            SectionFrame.BackgroundColor3 = Zolaire.Colors.Element
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = Tab.Content
            
            ApplyCorner(SectionFrame, 8)
            ApplyStroke(SectionFrame)
            
            -- Section title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Text = SectionName
            SectionTitle.Font = Zolaire.Settings.Font
            SectionTitle.TextSize = 16
            SectionTitle.TextColor3 = Zolaire.Colors.Text
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Size = UDim2.new(1, -20, 0, 30)
            SectionTitle.Position = UDim2.new(0, 10, 0, 5)
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            -- Section content
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.BackgroundTransparency = 1
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Position = UDim2.new(0, 0, 0, 35)
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = SectionFrame
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 8)
            SectionLayout.Parent = SectionContent
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingLeft = UDim.new(0, 10)
            SectionPadding.PaddingRight = UDim.new(0, 10)
            SectionPadding.PaddingBottom = UDim.new(0, 10)
            SectionPadding.Parent = SectionContent
            
            -- Store section elements
            Section.Instance = SectionFrame
            Section.Content = SectionContent
            Section.Elements = {}
            
            -- Section methods
            function Section:CreateButton(ButtonConfig)
                local Button = {}
                
                -- Button frame
                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = ButtonConfig.Name .. "Button"
                ButtonFrame.Text = ""
                ButtonFrame.BackgroundColor3 = Zolaire.Colors.Element
                ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
                ButtonFrame.Parent = Section.Content
                
                ApplyCorner(ButtonFrame, 6)
                ApplyStroke(ButtonFrame)
                
                -- Button title
                local ButtonTitle = Instance.new("TextLabel")
                ButtonTitle.Name = "Title"
                ButtonTitle.Text = ButtonConfig.Name
                ButtonTitle.Font = Zolaire.Settings.Font
                ButtonTitle.TextSize = 14
                ButtonTitle.TextColor3 = Zolaire.Colors.Text
                ButtonTitle.BackgroundTransparency = 1
                ButtonTitle.Size = UDim2.new(1, -10, 1, 0)
                ButtonTitle.Position = UDim2.new(0, 10, 0, 0)
                ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
                ButtonTitle.Parent = ButtonFrame
                
                -- Hover effects
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {
                        BackgroundColor3 = Zolaire.Colors.Hover
                    }, 0.2)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {
                        BackgroundColor3 = Zolaire.Colors.Element
                    }, 0.2)
                end)
                
                -- Click callback
                ButtonFrame.MouseButton1Click:Connect(function()
                    -- Animate click
                    Tween(ButtonFrame, {
                        BackgroundColor3 = Zolaire.Settings.Accent
                    }, 0.1):Play()
                    
                    task.wait(0.1)
                    
                    Tween(ButtonFrame, {
                        BackgroundColor3 = Zolaire.Colors.Hover
                    }, 0.1):Play()
                    
                    -- Execute callback
                    if ButtonConfig.Callback then
                        ButtonConfig.Callback()
                    end
                end)
                
                -- Store button
                Button.Instance = ButtonFrame
                table.insert(Section.Elements, Button)
                
                return Button
            end
            
            function Section:CreateToggle(ToggleConfig)
                local Toggle = {}
                Toggle.Value = ToggleConfig.Default or false
                
                -- Toggle container
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = ToggleConfig.Name .. "Toggle"
                ToggleFrame.BackgroundColor3 = Zolaire.Colors.Element
                ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
                ToggleFrame.Parent = Section.Content
                
                ApplyCorner(ToggleFrame, 6)
                ApplyStroke(ToggleFrame)
                
                -- Toggle title
                local ToggleTitle = Instance.new("TextLabel")
                ToggleTitle.Name = "Title"
                ToggleTitle.Text = ToggleConfig.Name
                ToggleTitle.Font = Zolaire.Settings.Font
                ToggleTitle.TextSize = 14
                ToggleTitle.TextColor3 = Zolaire.Colors.Text
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
                ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.Parent = ToggleFrame
                
                -- Toggle switch background
                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Name = "Switch"
                ToggleSwitch.BackgroundColor3 = Zolaire.Colors.Header
                ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
                ToggleSwitch.Position = UDim2.new(1, -50, 0.5, -10)
                ToggleSwitch.Parent = ToggleFrame
                
                ApplyCorner(ToggleSwitch, 10)
                
                -- Toggle switch indicator
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Name = "Indicator"
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
                ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
                ToggleIndicator.Parent = ToggleSwitch
                
                ApplyCorner(ToggleIndicator, 8)
                
                -- Update visual state
                local function UpdateToggle()
                    if Toggle.Value then
                        Tween(ToggleSwitch, {
                            BackgroundColor3 = Zolaire.Settings.Accent
                        }, 0.2)
                        
                        Tween(ToggleIndicator, {
                            Position = UDim2.new(1, -18, 0, 2)
                        }, 0.2)
                    else
                        Tween(ToggleSwitch, {
                            BackgroundColor3 = Zolaire.Colors.Header
                        }, 0.2)
                        
                        Tween(ToggleIndicator, {
                            Position = UDim2.new(0, 2, 0, 2)
                        }, 0.2)
                    end
                end
                
                -- Initialize
                UpdateToggle()
                
                -- Toggle click
                ToggleFrame.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    UpdateToggle()
                    
                    if ToggleConfig.Callback then
                        ToggleConfig.Callback(Toggle.Value)
                    end
                    
                    -- Save to flags if flag is provided
                    if ToggleConfig.Flag then
                        Zolaire.Flags[ToggleConfig.Flag] = Toggle.Value
                    end
                end)
                
                -- Hover effects
                ToggleFrame.MouseEnter:Connect(function()
                    Tween(ToggleFrame, {
                        BackgroundColor3 = Zolaire.Colors.Hover
                    }, 0.2)
                end)
                
                ToggleFrame.MouseLeave:Connect(function()
                    Tween(ToggleFrame, {
                        BackgroundColor3 = Zolaire.Colors.Element
                    }, 0.2)
                end)
                
                -- Store toggle
                Toggle.Instance = ToggleFrame
                table.insert(Section.Elements, Toggle)
                
                -- Add to flags
                if ToggleConfig.Flag then
                    Zolaire.Flags[ToggleConfig.Flag] = Toggle.Value
                end
                
                return Toggle
            end
            
            function Section:CreateSlider(SliderConfig)
                local Slider = {}
                Slider.Value = SliderConfig.Default or SliderConfig.Min
                
                -- Slider container
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = SliderConfig.Name .. "Slider"
                SliderFrame.BackgroundColor3 = Zolaire.Colors.Element
                SliderFrame.Size = UDim2.new(1, 0, 0, 60)
                SliderFrame.Parent = Section.Content
                
                ApplyCorner(SliderFrame, 6)
                ApplyStroke(SliderFrame)
                
                -- Slider title
                local SliderTitle = Instance.new("TextLabel")
                SliderTitle.Name = "Title"
                SliderTitle.Text = SliderConfig.Name
                SliderTitle.Font = Zolaire.Settings.Font
                SliderTitle.TextSize = 14
                SliderTitle.TextColor3 = Zolaire.Colors.Text
                SliderTitle.BackgroundTransparency = 1
                SliderTitle.Size = UDim2.new(1, -20, 0, 20)
                SliderTitle.Position = UDim2.new(0, 10, 0, 5)
                SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                SliderTitle.Parent = SliderFrame
                
                -- Slider value display
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Name = "Value"
                SliderValue.Text = tostring(Slider.Value)
                SliderValue.Font = Zolaire.Settings.Font
                SliderValue.TextSize = 12
                SliderValue.TextColor3 = Zolaire.Colors.SubText
                SliderValue.BackgroundTransparency = 1
                SliderValue.Size = UDim2.new(1, -20, 0, 15)
                SliderValue.Position = UDim2.new(0, 10, 0, 25)
                SliderValue.TextXAlignment = Enum.TextXAlignment.Left
                SliderValue.Parent = SliderFrame
                
                -- Slider track
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Name = "Track"
                SliderTrack.BackgroundColor3 = Zolaire.Colors.Header
                SliderTrack.Size = UDim2.new(1, -20, 0, 4)
                SliderTrack.Position = UDim2.new(0, 10, 1, -15)
                SliderTrack.Parent = SliderFrame
                
                ApplyCorner(SliderTrack, 2)
                
                -- Slider fill
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "Fill"
                SliderFill.BackgroundColor3 = Zolaire.Settings.Accent
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.Parent = SliderTrack
                
                ApplyCorner(SliderFill, 2)
                
                -- Slider thumb
                local SliderThumb = Instance.new("Frame")
                SliderThumb.Name = "Thumb"
                SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderThumb.Size = UDim2.new(0, 12, 0, 12)
                SliderThumb.Position = UDim2.new(0, -6, 0.5, -6)
                SliderThumb.Parent = SliderTrack
                
                ApplyCorner(SliderThumb, 6)
                ApplyStroke(SliderThumb, 1, Zolaire.Settings.Accent)
                
                -- Update slider
                local function UpdateSlider()
                    local Percent = (Slider.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderThumb.Position = UDim2.new(Percent, -6, 0.5, -6)
                    SliderValue.Text = tostring(Slider.Value)
                end
                
                -- Initialize
                UpdateSlider()
                
                -- Slider dragging
                local Dragging = false
                
                local function UpdateValueFromMouse()
                    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
                    local RelativeX = math.clamp((Mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    Slider.Value = math.floor(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * RelativeX)
                    
                    if SliderConfig.Increment then
                        Slider.Value = math.floor(Slider.Value / SliderConfig.Increment) * SliderConfig.Increment
                    end
                    
                    Slider.Value = math.clamp(Slider.Value, SliderConfig.Min, SliderConfig.Max)
                    UpdateSlider()
                    
                    if SliderConfig.Callback then
                        SliderConfig.Callback(Slider.Value)
                    end
                    
                    -- Save to flags if flag is provided
                    if SliderConfig.Flag then
                        Zolaire.Flags[SliderConfig.Flag] = Slider.Value
                    end
                end
                
                SliderTrack.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateValueFromMouse()
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)
                
                game:GetService("UserInputService").InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateValueFromMouse()
                    end
                end)
                
                -- Hover effects
                SliderFrame.MouseEnter:Connect(function()
                    Tween(SliderFrame, {
                        BackgroundColor3 = Zolaire.Colors.Hover
                    }, 0.2)
                end)
                
                SliderFrame.MouseLeave:Connect(function()
                    Tween(SliderFrame, {
                        BackgroundColor3 = Zolaire.Colors.Element
                    }, 0.2)
                end)
                
                -- Store slider
                Slider.Instance = SliderFrame
                table.insert(Section.Elements, Slider)
                
                -- Add to flags
                if SliderConfig.Flag then
                    Zolaire.Flags[SliderConfig.Flag] = Slider.Value
                end
                
                return Slider
            end
            
            function Section:CreateLabel(LabelConfig)
                local Label = {}
                
                -- Label container
                local LabelFrame = Instance.new("Frame")
                LabelFrame.Name = LabelConfig.Name .. "Label"
                LabelFrame.BackgroundColor3 = Zolaire.Colors.Element
                LabelFrame.Size = UDim2.new(1, 0, 0, 40)
                LabelFrame.Parent = Section.Content
                
                ApplyCorner(LabelFrame, 6)
                ApplyStroke(LabelFrame)
                
                -- Label text
                local LabelText = Instance.new("TextLabel")
                LabelText.Name = "Text"
                LabelText.Text = LabelConfig.Name
                LabelText.Font = Zolaire.Settings.Font
                LabelText.TextSize = 14
                LabelText.TextColor3 = Zolaire.Colors.Text
                LabelText.BackgroundTransparency = 1
                LabelText.Size = UDim2.new(1, -20, 1, 0)
                LabelText.Position = UDim2.new(0, 10, 0, 0)
                LabelText.TextXAlignment = Enum.TextXAlignment.Left
                LabelText.Parent = LabelFrame
                
                -- Store label
                Label.Instance = LabelFrame
                table.insert(Section.Elements, Label)
                
                return Label
            end
            
            table.insert(Tab.Elements, Section)
            return Section
        end
        
        table.insert(Window.Elements, Tab)
        return Tab
    end
    
    -- Store window
    table.insert(self.Windows, Window)
    
    return Window
end

-- Create notification
function Zolaire:Notify(NotificationConfig)
    if not self.Loaded then return end
    
    -- Create notification frame
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.BackgroundColor3 = Zolaire.Colors.Element
    Notification.Size = UDim2.new(0, 300, 0, 100)
    Notification.Position = UDim2.new(1, 10, 1, -10)
    Notification.AnchorPoint = Vector2.new(1, 1)
    Notification.Parent = self.Notifications
    
    ApplyCorner(Notification, 8)
    ApplyStroke(Notification)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = NotificationConfig.Title or "Notification"
    Title.Font = Zolaire.Settings.Font
    Title.TextSize = 16
    Title.TextColor3 = Zolaire.Colors.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification
    
    -- Content
    local Content = Instance.new("TextLabel")
    Content.Name = "Content"
    Content.Text = NotificationConfig.Content or ""
    Content.Font = Zolaire.Settings.Font
    Content.TextSize = 14
    Content.TextColor3 = Zolaire.Colors.SubText
    Content.BackgroundTransparency = 1
    Content.Size = UDim2.new(1, -20, 0, 40)
    Content.Position = UDim2.new(0, 10, 0, 35)
    Content.TextXAlignment = Enum.TextXAlignment.Left
    Content.TextYAlignment = Enum.TextYAlignment.Top
    Content.TextWrapped = true
    Content.Parent = Notification
    
    -- Actions
    local ActionsFrame = Instance.new("Frame")
    ActionsFrame.Name = "Actions"
    ActionsFrame.BackgroundTransparency = 1
    ActionsFrame.Size = UDim2.new(1, -20, 0, 25)
    ActionsFrame.Position = UDim2.new(0, 10, 1, -30)
    ActionsFrame.Parent = Notification
    
    -- Create action buttons
    local Buttons = {}
    
    if NotificationConfig.Actions then
        for i, Action in ipairs(NotificationConfig.Actions) do
            local Button = Instance.new("TextButton")
            Button.Name = Action.Title .. "Button"
            Button.Text = Action.Title
            Button.Font = Zolaire.Settings.Font
            Button.TextSize = 14
            Button.TextColor3 = Zolaire.Colors.Text
            Button.BackgroundColor3 = Zolaire.Settings.Accent
            Button.Size = UDim2.new(0, 80, 0, 25)
            Button.Position = UDim2.new(1, -(i * 85) + 5, 0, 0)
            Button.Parent = ActionsFrame
            
            ApplyCorner(Button, 6)
            
            Button.MouseButton1Click:Connect(function()
                if Action.Callback then
                    Action.Callback()
                end
                Notification:Destroy()
            end)
            
            table.insert(Buttons, Button)
        end
    end
    
    -- Animate in
    Notification.Position = UDim2.new(1, 10, 1, 100)
    Tween(Notification, {
        Position = UDim2.new(1, 10, 1, -10)
    }, 0.3)
    
    -- Auto dismiss
    if NotificationConfig.Duration then
        task.spawn(function()
            task.wait(NotificationConfig.Duration)
            if Notification and Notification.Parent then
                Tween(Notification, {
                    Position = UDim2.new(1, 10, 1, 100)
                }, 0.3):Play()
                task.wait(0.3)
                Notification:Destroy()
            end
        end)
    end
    
    return Notification
end

-- Destroy interface
function Zolaire:Destroy()
    if self.Interface then
        self.Interface:Destroy()
    end
    
    if Loader.Container then
        Loader.Container:Destroy()
    end
    
    -- Disconnect all events
    for _, Connection in ipairs(self.Elements) do
        if typeof(Connection) == "RBXScriptConnection" then
            Connection:Disconnect()
        end
    end
    
    self.Loaded = false
end

-- Loader shortcut
Zolaire.Loader = Loader

return Zolaire
