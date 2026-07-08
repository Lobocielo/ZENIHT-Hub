--// +1 Speed Keyboard Escape | Candy & Chocolate
--// ZT HUB v3 - Script Completo (PÚBLICO)
--// La verificación de key y expiración se carga desde un módulo externo.

-- ===================== CONFIGURACIÓN DE CARGA =====================
-- ✅ URL de tu Key.lua (repositorio privado)
local KEY_MODULE_URL = "https://raw.githubusercontent.com/Lobocielo/Key-privado/refs/heads/main/Key.lua"

-- ===================== CARGAR MÓDULO DE KEY =====================
local KeyModule = nil
local keyVerified = false
local keyError = nil

local function loadKeyModule()
    local success, result = pcall(function()
        return game:HttpGet(KEY_MODULE_URL)
    end)
    if success and result then
        local func, err = loadstring(result)
        if func then
            local ok, mod = pcall(func)
            if ok and type(mod) == "table" then
                KeyModule = mod
                return true
            else
                keyError = "Error al ejecutar el módulo: " .. tostring(mod)
            end
        else
            keyError = "Error al compilar Key.lua: " .. tostring(err)
        end
    else
        keyError = "No se pudo descargar Key.lua: " .. tostring(result)
    end
    return false
end

-- Cargar al inicio
if not loadKeyModule() then
    warn("[ZT HUB] " .. keyError)
end

-- ===================== FUNCIÓN DE VERIFICACIÓN =====================
local function verifyKey(inputKey)
    if not KeyModule then
        return false, "Error: No se pudo cargar el módulo de key."
    end
    if KeyModule.isExpired and KeyModule.isExpired() then
        return false, "❌ Key expirada (límite: " .. (KeyModule.expiryDate or "desconocida") .. ")"
    end
    if KeyModule.verify then
        return KeyModule.verify(inputKey)
    else
        return false, "Módulo inválido (falta verify)"
    end
end

--// ===================== ANTI DUPLICATE =====================
pcall(function()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "ZT_Hub" then gui:Destroy() end
    end
end)
pcall(function()
    for _, gui in pairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if gui.Name == "ZT_Hub" then gui:Destroy() end
    end
end)

--// ===================== SERVICES =====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// ===================== VARIABLES =====================
local flyEnabled = false
local flySpeed = 50
local noclipEnabled = false
local infJumpEnabled = false
local espEnabled = false
local autoFarmEnabled = false
local autoRebirthEnabled = false
local autoCollectEnabled = false
local noFailEnabled = false
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--// ===================== SCREEN GUI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZT_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--// ===================== UI HELPERS =====================
local function corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = parent; return c
end
local function stroke(parent, color, t)
    local s = Instance.new("UIStroke"); s.Color = color or Color3.fromRGB(138,43,226); s.Thickness = t or 1.5; s.Parent = parent; return s
end
local function pad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

--// ===================== MAIN FRAME =====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, isMobile and 320 or 400, 0, isMobile and 460 or 500)
MainFrame.Position = UDim2.new(0.5, -(isMobile and 160 or 200), 0.5, -(isMobile and 230 or 250))
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
corner(MainFrame, 14)
stroke(MainFrame, Color3.fromRGB(138,43,226), 2)

local gradBG = Instance.new("UIGradient")
gradBG.Color = ColorSequence.new(Color3.fromRGB(22,22,36), Color3.fromRGB(14,14,22))
gradBG.Rotation = 45
gradBG.Parent = MainFrame

--// ===================== TITLE BAR =====================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(28,28,44)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
corner(TitleBar, 14)

local TitleGrad = Instance.new("UIGradient")
TitleGrad.Color = ColorSequence.new(Color3.fromRGB(32,28,50), Color3.fromRGB(22,20,36))
TitleGrad.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.75, 0, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⚡ ZT HUB | " .. LocalPlayer.Name
TitleText.TextColor3 = Color3.fromRGB(200,140,255)
TitleText.TextSize = isMobile and 14 or 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
corner(CloseBtn, 7)

--// ===================== MINIMIZED ICON =====================
local MinIcon = Instance.new("TextButton")
MinIcon.Size = UDim2.new(0, 44, 0, 44)
MinIcon.Position = UDim2.new(0, 10, 0.3, 0)
MinIcon.BackgroundColor3 = Color3.fromRGB(138,43,226)
MinIcon.Text = "⚡"
MinIcon.TextSize = 22
MinIcon.Font = Enum.Font.GothamBold
MinIcon.TextColor3 = Color3.fromRGB(255,255,255)
MinIcon.Visible = false
MinIcon.BorderSizePixel = 0
MinIcon.ZIndex = 200
MinIcon.Parent = ScreenGui
corner(MinIcon, 22)
stroke(MinIcon, Color3.fromRGB(180,100,255), 2)

--// ===================== TABS BAR =====================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -12, 0, 32)
TabBar.Position = UDim2.new(0, 6, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local tabFrames = {}
local tabBtns = {}

--// ===================== CONTENT =====================
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -12, 1, -80)
Content.Position = UDim2.new(0, 6, 0, 76)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = Color3.fromRGB(138,43,226)
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollingEnabled = true
Content.ElasticBehavior = Enum.ElasticBehavior.Always
Content.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Content.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Content.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
Content.Parent = MainFrame
pad(Content, 4, 8, 4, 4)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = Content

--// ===================== CREATE TAB =====================
local layoutOrder = 0
local function newTab(name, icon)
    layoutOrder = 0
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, isMobile and 52 or 58, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,48)
    btn.Text = icon
    btn.TextSize = isMobile and 16 or 15
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(140,140,160)
    btn.BorderSizePixel = 0
    btn.Parent = TabBar
    corner(btn, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 10)
    lbl.Position = UDim2.new(0, 0, 1, -11)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(140,140,160)
    lbl.TextSize = 8
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = btn

    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 999
    frame.Visible = false
    frame.Parent = Content

    local fLayout = Instance.new("UIListLayout")
    fLayout.Padding = UDim.new(0, 5)
    fLayout.SortOrder = Enum.SortOrder.LayoutOrder
    fLayout.Wraps = false
    fLayout.Parent = frame

    tabFrames[name] = frame
    tabBtns[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabBtns) do
            b.BackgroundColor3 = Color3.fromRGB(30,30,48)
            b.TextColor3 = Color3.fromRGB(140,140,160)
        end
        frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(138,43,226)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    return frame
end

--// ===================== CREATE SECTION =====================
local function section(parent, text)
    layoutOrder = layoutOrder + 1
    local s = Instance.new("TextLabel")
    s.Size = UDim2.new(1, 0, 0, 20)
    s.BackgroundTransparency = 1
    s.Text = "— " .. text .. " —"
    s.TextColor3 = Color3.fromRGB(138,43,226)
    s.TextSize = isMobile and 11 or 12
    s.Font = Enum.Font.GothamBold
    s.LayoutOrder = layoutOrder
    s.Parent = parent
    return s
end

--// ===================== CREATE BUTTON =====================
local function btn(parent, text, cb)
    layoutOrder = layoutOrder + 1
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(32,32,50)
    b.Text = "  " .. text
    b.TextColor3 = Color3.fromRGB(210,210,220)
    b.TextSize = isMobile and 12 or 13
    b.Font = Enum.Font.GothamMedium
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    b.LayoutOrder = layoutOrder
    b.Parent = parent
    corner(b, 8)
    stroke(b, Color3.fromRGB(50,50,70), 1)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(48,48,72)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32,32,50)}):Play()
    end)
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

--// ===================== CREATE TOGGLE =====================
local function toggle(parent, text, default, cb)
    layoutOrder = layoutOrder + 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(32,32,50)
    f.BorderSizePixel = 0
    f.LayoutOrder = layoutOrder
    f.Parent = parent
    corner(f, 8)
    stroke(f, Color3.fromRGB(50,50,70), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210,210,220)
    lbl.TextSize = isMobile and 12 or 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 40, 0, 20)
    bg.Position = UDim2.new(1, -48, 0.5, -10)
    bg.BackgroundColor3 = default and Color3.fromRGB(138,43,226) or Color3.fromRGB(60,60,70)
    bg.BorderSizePixel = 0
    bg.Parent = f
    corner(bg, 10)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BorderSizePixel = 0
    dot.Parent = bg
    corner(dot, 8)

    local on = default
    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = f

    hit.MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(bg, TweenInfo.new(0.2), {BackgroundColor3 = on and Color3.fromRGB(138,43,226) or Color3.fromRGB(60,60,70)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        if cb then cb(on) end
    end)
    return hit
end

--// ===================== CREATE SLIDER =====================
local function slider(parent, text, min, max, def, cb)
    layoutOrder = layoutOrder + 1
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 44)
    f.BackgroundColor3 = Color3.fromRGB(32,32,50)
    f.BorderSizePixel = 0
    f.LayoutOrder = layoutOrder
    f.Parent = parent
    corner(f, 8)
    stroke(f, Color3.fromRGB(50,50,70), 1)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.55, 0, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210,210,220)
    lbl.TextSize = isMobile and 12 or 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.4, 0, 0, 18)
    val.Position = UDim2.new(0.58, 0, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(def)
    val.TextColor3 = Color3.fromRGB(138,43,226)
    val.TextSize = isMobile and 12 or 13
    val.Font = Enum.Font.GothamBold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = f

    local barBG = Instance.new("Frame")
    barBG.Size = UDim2.new(1, -16, 0, 5)
    barBG.Position = UDim2.new(0, 8, 1, -14)
    barBG.BackgroundColor3 = Color3.fromRGB(50,50,65)
    barBG.BorderSizePixel = 0
    barBG.Parent = f
    corner(barBG, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(138,43,226)
    fill.BorderSizePixel = 0
    fill.Parent = barBG
    corner(fill, 3)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((def - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    knob.Parent = barBG
    corner(knob, 6)

    local dragging = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * p)
            val.Text = tostring(v)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -6, 0.5, -6)
            if cb then cb(v) end
        end
    end)
end

--// ===================== TELEPORT HELPER =====================
local function tpTo(x, y, z)
    local c = LocalPlayer.Character
    if c then
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(x, y, z) + Vector3.new(0, 5, 0) end
    end
end

--// ===================== NOTIFICATION =====================
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 3})
    end)
end

--// ===================== KEY SCREEN =====================
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 300, 0, 220)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18,18,28)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = ScreenGui
corner(KeyFrame, 14)
stroke(KeyFrame, Color3.fromRGB(138,43,226), 2)

local KeyGrad = Instance.new("UIGradient")
KeyGrad.Color = ColorSequence.new(Color3.fromRGB(22,22,36), Color3.fromRGB(14,14,22))
KeyGrad.Parent = KeyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 30)
keyTitle.Position = UDim2.new(0, 0, 0, 10)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔑 ZT HUB"
keyTitle.TextColor3 = Color3.fromRGB(200,140,255)
keyTitle.TextSize = 16
keyTitle.Font = Enum.Font.GothamBold
keyTitle.Parent = KeyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.8, 0, 0, 38)
keyInput.Position = UDim2.new(0.1, 0, 0, 50)
keyInput.BackgroundColor3 = Color3.fromRGB(40,40,65)
keyInput.Text = ""
keyInput.PlaceholderText = "Escribe tu key aquí..."
keyInput.PlaceholderColor3 = Color3.fromRGB(160,160,180)
keyInput.TextColor3 = Color3.fromRGB(255,255,255)
keyInput.TextSize = 15
keyInput.Font = Enum.Font.GothamBold
keyInput.BorderSizePixel = 0
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 10
keyInput.Parent = KeyFrame
corner(keyInput, 10)
stroke(keyInput, Color3.fromRGB(138,43,226), 2)

local keyInputLabel = Instance.new("TextLabel")
keyInputLabel.Size = UDim2.new(0.8, 0, 0, 16)
keyInputLabel.Position = UDim2.new(0.1, 0, 0, 40)
keyInputLabel.BackgroundTransparency = 1
keyInputLabel.Text = "Escribe tu key:"
keyInputLabel.TextColor3 = Color3.fromRGB(150,150,170)
keyInputLabel.TextSize = 11
keyInputLabel.Font = Enum.Font.GothamMedium
keyInputLabel.TextXAlignment = Enum.TextXAlignment.Left
keyInputLabel.Parent = KeyFrame

local keyStatus = Instance.new("TextLabel")
keyStatus.Size = UDim2.new(0.8, 0, 0, 16)
keyStatus.Position = UDim2.new(0.1, 0, 0, 92)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = ""
keyStatus.TextSize = 12
keyStatus.Font = Enum.Font.GothamBold
keyStatus.Parent = KeyFrame

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.8, 0, 0, 36)
keyBtn.Position = UDim2.new(0.1, 0, 0, 112)
keyBtn.BackgroundColor3 = Color3.fromRGB(138,43,226)
keyBtn.Text = "✅ VERIFICAR KEY"
keyBtn.TextColor3 = Color3.fromRGB(255,255,255)
keyBtn.TextSize = 14
keyBtn.Font = Enum.Font.GothamBold
keyBtn.BorderSizePixel = 0
keyBtn.ZIndex = 10
keyBtn.Parent = KeyFrame
corner(keyBtn, 10)

local keyHint = Instance.new("TextLabel")
keyHint.Size = UDim2.new(0.8, 0, 0, 14)
keyHint.Position = UDim2.new(0.1, 0, 1, -24)
keyHint.BackgroundTransparency = 1
if KeyModule and KeyModule.expiryDate then
    keyHint.Text = "Expira: " .. KeyModule.expiryDate
else
    keyHint.Text = "Expira: 29/7/2026 (verificar módulo)"
end
keyHint.TextColor3 = Color3.fromRGB(120,120,140)
keyHint.TextSize = 10
keyHint.Font = Enum.Font.Gotham
keyHint.Parent = KeyFrame

--// ===================== BOTÓN DE VERIFICACIÓN (MODIFICADO) =====================
keyBtn.MouseButton1Click:Connect(function()
    if not KeyModule then
        keyStatus.Text = "❌ Error cargando módulo"
        keyStatus.TextColor3 = Color3.fromRGB(220,50,50)
        return
    end

    -- Verificar expiración primero
    if KeyModule.isExpired and KeyModule.isExpired() then
        keyStatus.Text = "❌ Key expirada (límite: " .. (KeyModule.expiryDate or "desconocida") .. ")"
        keyStatus.TextColor3 = Color3.fromRGB(220,50,50)
        return
    end

    local ok, msg = KeyModule.verify(keyInput.Text)
    if ok then
        keyVerified = true
        keyStatus.Text = msg
        keyStatus.TextColor3 = Color3.fromRGB(50,205,50)
        wait(0.4)
        -- Animación de ocultar KeyFrame y mostrar MainFrame
        TweenService:Create(KeyFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
        wait(0.4)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0,0,0,0)
        MainFrame.Position = UDim2.new(0.5,0,0.5,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, isMobile and 320 or 400, 0, isMobile and 460 or 500),
            Position = UDim2.new(0.5, -(isMobile and 160 or 200), 0.5, -(isMobile and 230 or 250))
        }):Play()
    else
        keyStatus.Text = msg
        keyStatus.TextColor3 = Color3.fromRGB(220,50,50)
        for _ = 1, 3 do
            TweenService:Create(KeyFrame, TweenInfo.new(0.06), {Position = UDim2.new(0.5, math.random(-8,8), 0.5, -110)}):Play()
            wait(0.06)
        end
        TweenService:Create(KeyFrame, TweenInfo.new(0.06), {Position = UDim2.new(0.5, 0, 0.5, -110)}):Play()
    end
end)

--// ===================== CLOSE / MINIMIZE =====================
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
    wait(0.3)
    MainFrame.Visible = false
    MinIcon.Visible = true
end)

MinIcon.MouseButton1Click:Connect(function()
    MinIcon.Visible = false
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0,0,0,0)
    MainFrame.Position = UDim2.new(0.5,0,0.5,0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, isMobile and 320 or 400, 0, isMobile and 460 or 500),
        Position = UDim2.new(0.5, -(isMobile and 160 or 200), 0.5, -(isMobile and 230 or 250))
    }):Play()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        if MainFrame.Visible then
            CloseBtn.MouseButton1Click:Wait()
        else
            MinIcon.MouseButton1Click:Wait()
        end
    end
end)

--// ===================== TABS =====================
local TabMain = newTab("Main", "🏠")
local TabTP = newTab("TP", "📍")
local TabPlayer = newTab("Player", "👤")
local TabFarm = newTab("Farm", "💰")
local TabMisc = newTab("Misc", "⚙️")

--// ════════════════════ MAIN TAB ════════════════════
section(TabMain, "MOVEMENT")

toggle(TabMain, "✈️ Fly (WASD+Space/Ctrl)", false, function(s)
    flyEnabled = s
    if s then
        local c = LocalPlayer.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                Instance.new("BodyGyro", hrp).Name = "ZT_Fly"
                local g = hrp.ZT_Fly; g.P = 9e3; g.D = 500; g.MaxTorque = Vector3.new(9e4,9e4,9e4)
                Instance.new("BodyVelocity", hrp).Name = "ZT_FlyV"
                local v = hrp.ZT_FlyV; v.MaxForce = Vector3.new(9e4,9e4,9e4); v.Velocity = Vector3.zero
            end
        end
    else
        local c = LocalPlayer.Character
        if c then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, n in ipairs({"ZT_Fly","ZT_FlyV"}) do
                    local x = hrp:FindFirstChild(n); if x then x:Destroy() end
                end
            end
        end
    end
end)

toggle(TabMain, "👻 Noclip", false, function(s) noclipEnabled = s end)
toggle(TabMain, "🦘 Infinite Jump", false, function(s) infJumpEnabled = s end)
toggle(TabMain, "🛡️ Anti-AFK", true, function() end)
toggle(TabMain, "❌ No Fail (No morir)", false, function(s)
    noFailEnabled = s
    if s then
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                h.MaxHealth = math.huge
                h.Health = math.huge
            end
        end
    end
end)

section(TabMain, "SPEED CONTROL")

slider(TabMain, "⚡ Walk Speed", 16, 500, 16, function(v)
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
end)

slider(TabMain, "🦘 Jump Power", 50, 500, 50, function(v)
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.UseJumpPower = true; h.JumpPower = v end end
end)

slider(TabMain, "✈️ Fly Speed", 10, 200, 50, function(v) flySpeed = v end)

--// ════════════════════ TP TAB ════════════════════
section(TabTP, "STAGES (1-15)")

local stages = {
    {"🏠 Lobby (HUB)", -9.5, 10, 27.8},
    {"1️⃣ Stage 1", 1.5, 21, 78},
    {"2️⃣ Stage 2", 2.2, 6.2, 281.5},
    {"3️⃣ Stage 3", 2.2, 6.2, 506.5},
    {"4️⃣ Stage 4", 2.2, 74.8, 773.7},
    {"5️⃣ Stage 5", 2.2, 74.8, 1107.7},
    {"6️⃣ Stage 6", 2.2, 74.8, 1411.7},
    {"7️⃣ Stage 7", -538.8, 52.1, 1467.4},
    {"8️⃣ Stage 8", -1008.8, 52.1, 1467.4},
    {"9️⃣ Stage 9", -1123.5, 294.5, 1447.9},
    {"🔟 Stage 10", -2264, 307, 1466},
    {"11️⃣ Stage 11", -3406, 308, 1466},
    {"12️⃣ Stage 12", -4853, 468, 1547},
    {"13️⃣ Stage 13", -5898, 465, 1569},
    {"14️⃣ Stage 14", -7200, 500, 1600},
    {"15️⃣ Stage 15", -10397, 411, 1822},
}

for _, s in ipairs(stages) do
    btn(TabTP, "📍 " .. s[1], function() tpTo(s[2], s[3], s[4]) end)
end

section(TabTP, "SPECIAL ZONES")

local specials = {
    {"🌀 Portal", -6, 10.3, -60.4},
    {"🔥 Lava Tower", -1066, 171.5, 1466},
    {"⚠️ Corridor Trap", -774, 81.5, 1438.8},
    {"⚠️ Corridor Trap 2", -12700, 772, 3579},
    {"🌊 Tsunami 1", 235, 61, 1466},
    {"🌊 Tsunami 2", -8282, 504, 1488},
    {"🌊 Tsunami 3", -10821, 765, 3572},
    {"🌊 Tsunami 4", -11119, 765, 3497},
    {"🌊 Tsunami 5", -11416, 765, 3490},
    {"🌊 Tsunami 6", -11715, 765, 3682},
    {"🌊 Tsunami 7", -12013, 765, 3490},
    {"🏀 Ball 1", 1, 85.3, 704.8},
    {"🏀 Ball 2", -10401, 472, 1741},
    {"🤖 NPC Zone 10", -3444, 294, 1466},
    {"🤖 NPC Zone 12", -4854, 519, 1543},
    {"📢 Panneau Event", 67.1, 22.7, 67},
    {"🏪 Shop Gauche", 108.5, 15.6, 2.2},
    {"🏆 Boss Room", 1.5, 5.9, -72.8},
    {"⚡ Admin Abuse TP", 52.4, 11.6, 59.1},
    {"🏗️ Admin Stud Part", -38.5, 32.4, -77.8},
    {"🏗️ Admin Pillar", -1.5, 37.9, -72.3},
    {"🍬 Admin Candy", -13.7, 18, -72.6},
    {"🔴 Admin Candy Red", -30.1, 23.2, -72.9},
    {"⚽ Admin Sphere", -54.8, 24.3, -72.9},
    {"🏟️ Admin Sphere 2", -9.1, 61.1, -72.9},
    {"🏟️ Admin Sphere 3", -45.8, 43.4, -72.9},
    {"🏟️ Admin Sphere 4", -28.8, 51.4, -72.9},
    {"🏟️ Admin Sphere 5", -47.1, 59.7, -72.9},
    {"🏟️ Admin Sphere 6", -34.8, 32.4, -72.9},
    {"🏟️ Admin Sphere 7", -42.1, 31.6, -72.9},
    {"🏟️ Admin Sphere 8", -18.9, 30.4, -72.9},
    {"🏟️ Admin Sphere 9", -9.6, 39.1, -72.9},
    {"🏟️ Admin Sphere 10", -31.1, 61.6, -72.9},
    {"🏟️ Admin Sphere 11", -59.1, 46.6, -72.9},
    {"🔴 Admin Candy Red 2", -35.1, 57.8, -72.9},
    {"🍬 Admin Candy 2", -55.6, 56.1, -72.6},
}

for _, s in ipairs(specials) do
    btn(TabTP, "📍 " .. s[1], function() tpTo(s[2], s[3], s[4]) end)
end

section(TabTP, "REVIVE ZONES")

local revives = {
    {"❤️ Revive Zone 4", 19.4, 57, 947.3},
    {"❤️ Revive Zone 5", 3.1, 57, 1272.5},
    {"❤️ Revive Zone 6", -237.6, 59.3, 1466.3},
    {"❤️ Revive Zone 7", -769.6, 59.3, 1466.3},
    {"❤️ Revive Zone 8", -1067.1, 166.8, 1466.3},
    {"❤️ Revive Zone 9", -2005.6, 262.3, 1465.3},
}

for _, s in ipairs(revives) do
    btn(TabTP, "📍 " .. s[1], function() tpTo(s[2], s[3], s[4]) end)
end

section(TabTP, "TREADMILLS")

local tms = {
    {"🏃 Treadmill Normal (Lobby)", 2.2, 15, 50},
    {"🏃 Treadmill Stage 2", 19.2, 5.9, 282.4},
    {"🏃 Treadmill Stage 3", 20.7, 6.2, 498.6},
    {"🏃 Treadmill Stage 4", 20.7, 74.5, 766.3},
    {"🏃 Treadmill Stage 5", 25, 74.4, 1108.4},
    {"🏃 Treadmill Stage 6", 24.9, 74.5, 1408.6},
    {"🏃 Treadmill Stage 7", -538.3, 51.4, 1486.2},
    {"🏃 Treadmill Stage 8", -1007.8, 51.5, 1485.3},
    {"🏃 Treadmill Stage 9", -1121, 293.3, 1485.3},
    {"💎 Treadmill Diamond", 64.8, 11.2, -52.9},
    {"🥇 Treadmill Gold", 34.7, 7.3, -39.2},
    {"🍬 Treadmill Candy", -31.9, 10.7, -53.2},
    {"👑 Treadmill Admin", -50.9, 10.9, -55.8},
    {"🏃 Treadmill Default", 18, 7.5, -40.5},
}

for _, s in ipairs(tms) do
    btn(TabTP, "🏃 " .. s[1], function() tpTo(s[2], s[3], s[4]) end)
end

section(TabTP, "TELEPORT TO PLAYER")

btn(TabTP, "👥 Listar Todos los Jugadores", function()
    for _, child in ipairs(TabTP:GetChildren()) do
        if child:IsA("TextButton") and child.Name:find("PLR_") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local b = btn(TabTP, "👤 " .. p.Name, function()
                local c = LocalPlayer.Character
                local tc = p.Character
                if c and tc then
                    local h = c:FindFirstChild("HumanoidRootPart")
                    local th = tc:FindFirstChild("HumanoidRootPart")
                    if h and th then h.CFrame = th.CFrame * CFrame.new(0, 0, -5) end
                end
            end)
            b.Name = "PLR_" .. p.Name
        end
    end
end)

--// ════════════════════ PLAYER TAB ════════════════════
section(TabPlayer, "CHARACTER")

slider(TabPlayer, "📏 Hip Height", 0, 20, 3, function(v)
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.HipHeight = v end end
end)

btn(TabPlayer, "💀 Kill Character", function()
    local c = LocalPlayer.Character
    if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.Health = 0 end end
end)

btn(TabPlayer, "🔄 Respawn", function()
    LocalPlayer:LoadCharacter()
end)

btn(TabPlayer, "🔄 Reset Speed to Default", function()
    local c = LocalPlayer.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16; h.JumpPower = 50; h.HipHeight = 3 end
    end
end)

section(TabPlayer, "VISUAL")

toggle(TabPlayer, "🔍 ESP (Highlights)", false, function(s)
    espEnabled = s
    if not s then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, obj in ipairs(p.Character:GetChildren()) do
                    if obj.Name == "ZT_ESP" then obj:Destroy() end
                end
            end
        end
    end
end)

toggle(TabPlayer, "🌐 Fullbright", false, function(s)
    if s then
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e5; Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1; Lighting.ClockTime = 12; Lighting.FogEnd = 1e3; Lighting.GlobalShadows = true
    end
end)

toggle(TabPlayer, "🔇 Remove Music", false, function(s)
    if s then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Sound") then obj.Volume = 0 end
        end
    end
end)

toggle(TabPlayer, "✨ Remove Particles", false, function(s)
    if s then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj.Enabled = false end
        end
    end
end)

--// ════════════════════ FARM TAB ════════════════════
section(TabFarm, "AUTO FARM")

toggle(TabFarm, "💰 Auto Farm Speed", false, function(s)
    autoFarmEnabled = s
    if not s then
        local c = LocalPlayer.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 end
        end
    end
end)
toggle(TabFarm, "🔄 Auto Rebirth", false, function(s) autoRebirthEnabled = s end)
toggle(TabFarm, "🧲 Auto Collect", false, function(s) autoCollectEnabled = s end)

section(TabFarm, "TOOLS")

btn(TabFarm, "💰 Farm Speed Rápido", function()
    tpTo(2.2, 15, 50)
end)

btn(TabFarm, "🎁 Claim All Gifts", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local claim = rem:FindFirstChild("ClaimGift")
        if claim then for i = 1, 10 do pcall(function() claim:FireServer(i) end) end end
    end
    notify("🎁 Gifts", "Claiming gifts...", 2)
end)

btn(TabFarm, "⚡ Speed Boost (All)", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        for _, name in ipairs({"PromptSpeedBoost", "Prompt150KSpeed", "Prompt1MSpeed", "Prompt10MSpeed"}) do
            local r = rem:FindFirstChild(name)
            if r then pcall(function() r:FireServer() end) end
        end
    end
    notify("⚡ Boost", "Speed boosts activated!", 2)
end)

btn(TabFarm, "📊 Check Stats", function()
    local ls = LocalPlayer:FindFirstChild("leaderstats")
    if ls then
        local sp = ls:FindFirstChild("Speed")
        local w = ls:FindFirstChild("Wins")
        local r = ls:FindFirstChild("Rebirths")
        notify("📊 Stats", "Speed: " .. (sp and sp.Value or "?") .. " | Wins: " .. (w and w.Value or "?") .. " | Rebirths: " .. (r and r.Value or "?"), 5)
    end
end)

btn(TabFarm, "📋 Copy JobId", function()
    pcall(function() if setclipboard then setclipboard(game.JobId) end end)
    notify("📋 Copiado!", "JobId: " .. game.JobId, 3)
end)

--// ════════════════════ MISC TAB ════════════════════
section(TabMisc, "UI SETTINGS")

local mainStroke = MainFrame:FindFirstChildOfClass("UIStroke")

slider(TabMisc, "🔲 Border Thickness", 0, 5, 2, function(v)
    pcall(function()
        if mainStroke then mainStroke.Thickness = v end
        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("UIStroke") then
                desc.Thickness = v
            end
        end
    end)
end)

slider(TabMisc, "🔲 Corner Round", 0, 20, 14, function(v)
    pcall(function()
        local cornerObj = MainFrame:FindFirstChildOfClass("UICorner")
        if cornerObj then cornerObj.CornerRadius = UDim.new(0, v) end
        local titleCorner = TitleBar:FindFirstChildOfClass("UICorner")
        if titleCorner then titleCorner.CornerRadius = UDim.new(0, v) end
    end)
end)

section(TabMisc, "🔑 KEYS & SKINS")

btn(TabMisc, "🔑 Special Key Event", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local sk = rem:FindFirstChild("SpecialKeyEvent")
        if sk then sk:FireServer() end
    end
    notify("🔑 Special Key", "SpecialKeyEvent fired!", 2)
end)

btn(TabMisc, "⌨️ Bridge Keycap (Stage)", function()
    tpTo(1.5, 104, 1392)
end)

btn(TabMisc, "🎵 Equip Sound: Chocolate", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipStepAward")
        if eq then eq:FireServer("Chocolate") end
    end
    notify("🎵 Sound", "Equipped: Chocolate", 2)
end)

btn(TabMisc, "🎵 Equip Sound: Candy", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipStepAward")
        if eq then eq:FireServer("Candy") end
    end
    notify("🎵 Sound", "Equipped: Candy", 2)
end)

btn(TabMisc, "🎨 Skin: Diamond", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipTreadmillSkin")
        if eq then eq:FireServer("Diamond") end
    end
    notify("🎨 Skin", "Equipped: Diamond", 2)
end)

btn(TabMisc, "🎨 Skin: Gold", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipTreadmillSkin")
        if eq then eq:FireServer("Gold") end
    end
    notify("🎨 Skin", "Equipped: Gold", 2)
end)

btn(TabMisc, "✨ Equip Trail", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipTrail")
        if eq then eq:FireServer("Default") end
    end
end)

btn(TabMisc, "🔮 Equip Aura", function()
    local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        local eq = rem:FindFirstChild("EquipAura")
        if eq then eq:FireServer("Default") end
    end
end)

section(TabMisc, "SERVER")

btn(TabMisc, "🔄 Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

btn(TabMisc, "🌐 Server Hop", function()
    local ok, y = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and y and y.data and #y.data > 1 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, y.data[math.random(1, #y.data)].id, LocalPlayer)
    end
end)

section(TabMisc, "EXTRAS")

btn(TabMisc, "📱 Toggle UI (RightShift)", function()
    MainFrame.Visible = not MainFrame.Visible
end)

btn(TabMisc, "👤 Player Info", function()
    notify("👤 Info", "Name: " .. LocalPlayer.Name .. " | Display: " .. LocalPlayer.DisplayName .. " | ID: " .. LocalPlayer.UserId, 5)
end)

btn(TabMisc, "🌍 Game Info", function()
    notify("🌍 Game", "Place: " .. game.PlaceId .. " | Job: " .. string.sub(game.JobId, 1, 12) .. "...", 5)
end)

btn(TabMisc, "🔄 Reset UI Position", function()
    MainFrame.Position = UDim2.new(0.5, -(isMobile and 160 or 200), 0.5, -(isMobile and 230 or 250))
    MainFrame.Size = UDim2.new(0, isMobile and 320 or 400, 0, isMobile and 460 or 500)
end)

--// ===================== MAIN LOOP =====================
RunService.Heartbeat:Connect(function()
    local c = LocalPlayer.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    --// Fly
    if flyEnabled then
        local gyro = hrp:FindFirstChild("ZT_Fly")
        local vel = hrp:FindFirstChild("ZT_FlyV")
        if gyro and vel then
            gyro.CFrame = Camera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
            vel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
        end
    end

    --// Noclip
    if noclipEnabled then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    --// ESP
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not p.Character:FindFirstChild("ZT_ESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ZT_ESP"
                    hl.FillColor = Color3.fromRGB(138,43,226)
                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.6
                    hl.OutlineTransparency = 0
                    hl.Adornee = p.Character
                    hl.Parent = p.Character
                end
            end
        end
    end

    --// No Fail
    if noFailEnabled then
        hum.MaxHealth = math.huge
        if hum.Health < math.huge then hum.Health = math.huge end
    end

    --// Auto Farm - Teleporta al treadmill y activa farmeo
    if autoFarmEnabled then
        hrp.CFrame = CFrame.new(2.2, 8, 50)
        hum.WalkSpeed = 500
        
        local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
        if rem then
            pcall(function()
                local ts = rem:FindFirstChild("TreadmillSignal")
                if ts then ts:FireServer(true) end
            end)
            pcall(function()
                local ps = rem:FindFirstChild("PersonalTreadmillStep")
                if ps then ps:FireServer() end
            end)
        end
    end

    --// Auto Rebirth
    if autoRebirthEnabled then
        local rem = game.ReplicatedStorage:FindFirstChild("Remotes")
        if rem then
            local reb = rem:FindFirstChild("Rebirth")
            if reb then pcall(function() reb:FireServer() end) end
        end
    end

    --// Auto Collect
    if autoCollectEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local pHRP = p.Character:FindFirstChild("HumanoidRootPart")
                if pHRP then
                    local dist = (hrp.Position - pHRP.Position).Magnitude
                    if dist < 20 then
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj:FindFirstChildOfClass("ProximityPrompt") then
                                local objDist = (hrp.Position - obj.Position).Magnitude
                                if objDist < 15 then
                                    pcall(function()
                                        fireproximityprompt(obj:FindFirstChildOfClass("ProximityPrompt"))
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

--// Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local c = LocalPlayer.Character
        if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
    end
end)

--// Anti-AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.zero)
    end)
end)

--// ===================== INIT =====================
MainFrame.Visible = false
KeyFrame.Visible = true

print("⚡ ZT HUB v3 loaded (Público)")
if KeyModule then
    print("🔑 Módulo de key cargado correctamente | Expira: " .. KeyModule.expiryDate)
else
    warn("⚠️ " .. keyError)
end
print("🔑 Presiona RightShift para abrir/cerrar el menú")
