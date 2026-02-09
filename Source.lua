-- Zolaire Interface Library

local Zolaire = {}

-- Configuration
Zolaire.Settings = {
    Theme = "Dark",
    Accent = Color3.fromRGB(0,170,255),
    Font = Enum.Font.Gotham,
    EnableKeybinds = true,
    ToggleKey = Enum.KeyCode.RightShift,
    ScreenGuiParent = game:GetService("CoreGui"),
    DefaultWindowPosition = UDim2.new(0.5,0,0.5,0)
}

-- Colors
Zolaire.Colors = {
    Background = Color3.fromRGB(25,25,25),
    Element = Color3.fromRGB(35,35,35),
    Header = Color3.fromRGB(45,45,45),
    Text = Color3.fromRGB(255,255,255),
    SubText = Color3.fromRGB(200,200,200),
    Stroke = Color3.fromRGB(60,60,60),
    Hover = Color3.fromRGB(50,50,50),
    Selected = Color3.fromRGB(40,40,40),
    ToggleIcon = Color3.fromRGB(0,170,255)
}

Zolaire.Elements = {}
Zolaire.Windows = {}
Zolaire.Loaded = false
Zolaire.Flags = {}
Zolaire.ToggleIcon = nil
Zolaire.InterfaceVisible = true

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

----------------------------------------------------
-- Tween
----------------------------------------------------
local function Tween(o,p,d,s,dir)
    local info = TweenInfo.new(d or .25,s or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(o,info,p)
    t:Play()
    return t
end

----------------------------------------------------
-- Corners / Stroke
----------------------------------------------------
local function ApplyCorner(o,r)
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,r or 8)
    c.Parent=o
end

local function ApplyStroke(o,t,c,tr)
    local s=Instance.new("UIStroke")
    s.Thickness=t or 1
    s.Color=c or Zolaire.Colors.Stroke
    s.Transparency=tr or 0
    s.Parent=o
end

----------------------------------------------------
-- ⭐ Momentum Drag Engine
----------------------------------------------------
local function MomentumDrag(frame, handle)

    frame.Active=true
    handle.Active=true

    local dragging=false
    local dragStart
    local startPos
    local velocity=Vector2.zero
    local lastPos
    local lastTime

    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then

            dragging=true
            dragStart=input.Position
            startPos=frame.Position
            lastPos=input.Position
            lastTime=tick()

            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then
                    dragging=false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType==Enum.UserInputType.MouseMovement or
            input.UserInputType==Enum.UserInputType.Touch) then

            local delta=input.Position-dragStart
            frame.Position=UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset+delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset+delta.Y
            )

            local now=tick()
            velocity=(input.Position-lastPos)/(now-lastTime)
            lastPos=input.Position
            lastTime=now
        end
    end)

    -- Momentum simulation
    RunService.RenderStepped:Connect(function(dt)
        if not dragging and velocity.Magnitude>0 then
            velocity*=0.90

            if velocity.Magnitude<5 then
                velocity=Vector2.zero
                return
            end

            frame.Position+=UDim2.new(
                0, velocity.X*dt*15,
                0, velocity.Y*dt*15
            )
        end
    end)
end

----------------------------------------------------
-- Loader
----------------------------------------------------
local Loader={Active=false}

function Loader:Show()

    self.Active=true

    local gui=Instance.new("ScreenGui")
    gui.IgnoreGuiInset=true
    gui.Name="ZLoader"

    local bg=Instance.new("Frame",gui)
    bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=Zolaire.Colors.Background
    bg.BackgroundTransparency=.4

    local box=Instance.new("Frame",gui)
    box.Size=UDim2.new(0,300,0,140)
    box.AnchorPoint=Vector2.new(.5,.5)
    box.Position=UDim2.fromScale(.5,.5)
    box.BackgroundColor3=Zolaire.Colors.Element
    ApplyCorner(box,12)
    ApplyStroke(box,2,Zolaire.Settings.Accent)

    local txt=Instance.new("TextLabel",box)
    txt.Size=UDim2.new(1,0,0,40)
    txt.BackgroundTransparency=1
    txt.Text="Zolaire Interface"
    txt.Font=Zolaire.Settings.Font
    txt.TextSize=20
    txt.TextColor3=Zolaire.Colors.Text

    local barBG=Instance.new("Frame",box)
    barBG.Size=UDim2.new(.8,0,0,8)
    barBG.Position=UDim2.new(.1,0,.6,0)
    barBG.BackgroundColor3=Zolaire.Colors.Header
    ApplyCorner(barBG,4)

    local fill=Instance.new("Frame",barBG)
    fill.Size=UDim2.new(0,0,1,0)
    fill.BackgroundColor3=Zolaire.Settings.Accent
    ApplyCorner(fill,4)

    self.Gui=gui
    self.Fill=fill

    gui.Parent=Zolaire.Settings.ScreenGuiParent
end

function Loader:Update(p)
    if self.Fill then
        Tween(self.Fill,{Size=UDim2.new(p/100,0,1,0)},.3)
    end
end

function Loader:Hide()
    if self.Gui then
        self.Gui:Destroy()
    end
end

----------------------------------------------------
-- Floating Toggle Bubble (DRAGGABLE)
----------------------------------------------------
local function CreateToggleIcon()

    local gui=Instance.new("ScreenGui")
    gui.IgnoreGuiInset=true
    gui.Name="ZToggle"

    local btn=Instance.new("ImageButton")
    btn.Size=UDim2.new(0,50,0,50)
    btn.Position=UDim2.new(1,-70,0,40)
    btn.BackgroundColor3=Zolaire.Colors.ToggleIcon
    btn.AutoButtonColor=false
    btn.Image="rbxassetid://3926305904"
    btn.ImageRectOffset=Vector2.new(964,324)
    btn.ImageRectSize=Vector2.new(36,36)
    btn.Parent=gui

    ApplyCorner(btn,10)
    ApplyStroke(btn,2)

    gui.Parent=Zolaire.Settings.ScreenGuiParent
    Zolaire.ToggleIcon=btn

    -- draggable bubble
    MomentumDrag(btn,btn)

    btn.MouseButton1Click:Connect(function()
        Zolaire:ToggleInterface()
    end)
end

----------------------------------------------------
-- Init
----------------------------------------------------
function Zolaire:Init()

    Loader:Show()
    Loader:Update(30)

    self.Interface=Instance.new("ScreenGui")
    self.Interface.IgnoreGuiInset=true
    self.Interface.Parent=self.Settings.ScreenGuiParent

    Loader:Update(70)

    CreateToggleIcon()

    Loader:Update(100)
    task.wait(.3)
    Loader:Hide()

    self.Loaded=true
end

----------------------------------------------------
-- Toggle Interface
----------------------------------------------------
function Zolaire:ToggleInterface()
    if not self.Loaded then return end

    self.InterfaceVisible = not self.InterfaceVisible

    for _,window in ipairs(self.Windows) do
        local frame = window.Instance

        if self.InterfaceVisible then
            frame.Visible = true

            frame.Position += UDim2.new(0,0,0,20)
            frame.BackgroundTransparency = 1

            Tween(frame,{
                BackgroundTransparency = 0,
                Position = frame.Position - UDim2.new(0,0,0,20)
            },0.25)

        else
            Tween(frame,{
                BackgroundTransparency = 1,
                Position = frame.Position + UDim2.new(0,0,0,20)
            },0.2)

            task.delay(0.2,function()
                if frame then
                    frame.Visible=false
                end
            end)
        end
    end
end

----------------------------------------------------
-- Create Window
----------------------------------------------------
function Zolaire:CreateWindow(cfg)

    if not self.Loaded then
        warn("Call :Init() first")
        return
    end

    cfg = cfg or {}

    local frame = Instance.new("Frame")
    frame.Name="Window"
    frame.Size = cfg.Size or UDim2.new(0,500,0,450)

    -- ⭐ TRUE CENTERING
    frame.AnchorPoint = Vector2.new(.5,.5)
    frame.Position = UDim2.fromScale(.5,.5)

    frame.BackgroundColor3 = Zolaire.Colors.Background
    frame.Parent = self.Interface

    ApplyCorner(frame,12)
    ApplyStroke(frame,2)

    ------------------------------------------------
    -- Top Bar
    ------------------------------------------------
    local bar=Instance.new("Frame",frame)
    bar.Size=UDim2.new(1,0,0,45)
    bar.BackgroundColor3=Zolaire.Colors.Header
    ApplyCorner(bar,12)

    local title=Instance.new("TextLabel",bar)
    title.BackgroundTransparency=1
    title.Size=UDim2.new(1,-90,1,0)
    title.Position=UDim2.new(0,15,0,0)
    title.Text=cfg.Name or "Window"
    title.Font=Zolaire.Settings.Font
    title.TextSize=18
    title.TextColor3=Zolaire.Colors.Text
    title.TextXAlignment=Enum.TextXAlignment.Left

    ------------------------------------------------
    -- Close
    ------------------------------------------------
    local close=Instance.new("TextButton",bar)
    close.Size=UDim2.new(0,32,0,32)
    close.Position=UDim2.new(1,-38,.5,-16)
    close.Text="×"
    close.Font=Enum.Font.GothamBold
    close.TextSize=20
    close.TextColor3=Color3.new(1,1,1)
    close.BackgroundColor3=Color3.fromRGB(255,80,80)
    ApplyCorner(close,8)

    close.MouseButton1Click:Connect(function()
        Tween(frame,{
            Size=UDim2.new(0,0,0,0),
            BackgroundTransparency=1
        },.25,Enum.EasingStyle.Back,Enum.EasingDirection.In)

        task.wait(.25)
        frame:Destroy()
    end)

    ------------------------------------------------
    -- Content
    ------------------------------------------------
    local content=Instance.new("Frame",frame)
    content.BackgroundTransparency=1
    content.Size=UDim2.new(1,0,1,-45)
    content.Position=UDim2.new(0,0,0,45)

    ------------------------------------------------
    -- ⭐ Momentum Drag Window
    ------------------------------------------------
    MomentumDrag(frame,bar)

    local tbl={
        Instance=frame,
        Content=content,
        Title=title
    }

    table.insert(self.Windows,tbl)
    return tbl
end

----------------------------------------------------
-- Notification Stub
----------------------------------------------------
function Zolaire:Notify(n)
    print("Notification:", n and n.Title)
end

----------------------------------------------------
-- RETURN
----------------------------------------------------
return Zolaire
