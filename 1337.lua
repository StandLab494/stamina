-- ===== СУПЕРМЕН v25 FIXED =====

local P = game:GetService("Players")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local C = game:GetService("CoreGui")
local VIM = game:GetService("VirtualInputManager")
local SG = game:GetService("SoundService")

local LP = P.LocalPlayer
local MODE = nil

local music = nil
local musicOn = false
local musicID = "rbxassetid://95678241702836"

local mainGui = nil
local menuState = nil
local playerRemovingConn = nil

local function cr(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function mkB(parent, txt, cb, col)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 40)
    b.BackgroundColor3 = col or Color3.fromRGB(180, 40, 40)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Parent = parent
    cr(b, 8)

    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(cb)
        if not ok then
            warn("[СУПЕРМЕН] Button error:", err)
        end
    end)

    return b
end

local function mkSec(parent, txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = "▸ " .. txt
    l.TextColor3 = Color3.fromRGB(255, 80, 80)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.Parent = parent
    return l
end

local function getChar()
    local c = LP.Character
    if not c then
        return nil
    end

    local root = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")

    if not root or not hum then
        return nil
    end

    return c, root, hum
end

local function getTool()
    local c = LP.Character
    if not c then
        return nil
    end
    return c:FindFirstChildOfClass("Tool")
end

-- =========================================================
-- МУЗЫКА
-- =========================================================

local oldMusicGui = C:FindFirstChild("SupermanMusic")
if oldMusicGui then
    oldMusicGui:Destroy()
end

local musGui = Instance.new("ScreenGui")
musGui.Name = "SupermanMusic"
musGui.ResetOnSpawn = false
musGui.IgnoreGuiInset = true
musGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
musGui.Parent = C

local musPanel = Instance.new("Frame")
musPanel.Size = UDim2.new(0, 260, 0, 320)
musPanel.Position = UDim2.new(1, -280, 0.5, -160)
musPanel.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
musPanel.BorderSizePixel = 0
musPanel.Active = true
musPanel.Parent = musGui
cr(musPanel, 14)

local musS = Instance.new("UIStroke")
musS.Color = Color3.fromRGB(255, 50, 50)
musS.Thickness = 2
musS.Parent = musPanel

local musHead = Instance.new("Frame")
musHead.Size = UDim2.new(1, 0, 0, 40)
musHead.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
musHead.BorderSizePixel = 0
musHead.Active = true
musHead.Parent = musPanel
cr(musHead, 14)

local musTitle = Instance.new("TextLabel")
musTitle.Size = UDim2.new(1, -40, 1, 0)
musTitle.BackgroundTransparency = 1
musTitle.Text = "🎵 МУЗЫКА"
musTitle.TextColor3 = Color3.fromRGB(255, 90, 90)
musTitle.Font = Enum.Font.GothamBold
musTitle.TextScaled = true
musTitle.Parent = musHead

local musHide = Instance.new("TextButton")
musHide.Size = UDim2.new(0, 30, 0, 30)
musHide.Position = UDim2.new(1, -35, 0, 5)
musHide.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
musHide.Text = "▲"
musHide.TextColor3 = Color3.fromRGB(255, 255, 255)
musHide.Font = Enum.Font.GothamBold
musHide.TextSize = 14
musHide.Parent = musHead
cr(musHide, 6)

local musBody = Instance.new("Frame")
musBody.Size = UDim2.new(1, -16, 1, -52)
musBody.Position = UDim2.new(0, 8, 0, 46)
musBody.BackgroundTransparency = 1
musBody.Parent = musPanel

local mLabel = Instance.new("TextLabel")
mLabel.Size = UDim2.new(1, 0, 0, 20)
mLabel.BackgroundTransparency = 1
mLabel.Text = "ID трека (rbxassetid://...)"
mLabel.TextColor3 = Color3.fromRGB(255, 180, 180)
mLabel.Font = Enum.Font.Gotham
mLabel.TextSize = 12
mLabel.TextXAlignment = Enum.TextXAlignment.Left
mLabel.Parent = musBody

local mBox = Instance.new("TextBox")
mBox.Size = UDim2.new(1, 0, 0, 35)
mBox.Position = UDim2.new(0, 0, 0, 25)
mBox.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
mBox.TextColor3 = Color3.fromRGB(255, 255, 255)
mBox.PlaceholderText = "rbxassetid://..."
mBox.Text = musicID
mBox.ClearTextOnFocus = false
mBox.Font = Enum.Font.Gotham
mBox.TextSize = 12
mBox.Parent = musBody
cr(mBox, 6)

local function stopMusic()
    if music then
        pcall(function()
            music:Stop()
            music:Destroy()
        end)
        music = nil
    end
end

local function playMusic()
    stopMusic()

    if musicID == "" then
        return
    end

    music = Instance.new("Sound")
    music.Name = "SupermanMusic"
    music.SoundId = musicID
    music.Volume = 0.5
    music.Looped = true
    music.Parent = SG

    pcall(function()
        music:Play()
    end)
end

local mApply = Instance.new("TextButton")
mApply.Size = UDim2.new(1, 0, 0, 32)
mApply.Position = UDim2.new(0, 0, 0, 68)
mApply.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
mApply.Text = "Применить"
mApply.TextColor3 = Color3.fromRGB(255, 255, 255)
mApply.Font = Enum.Font.GothamBold
mApply.TextSize = 13
mApply.Parent = musBody
cr(mApply, 6)

mApply.MouseButton1Click:Connect(function()
    local id = mBox.Text:gsub("^%s+", ""):gsub("%s+$", "")

    if id == "" then
        return
    end

    if not id:match("^rbxassetid://") then
        id = "rbxassetid://" .. id:gsub("%D", "")
    end

    musicID = id

    if musicOn then
        playMusic()
    end
end)

local mToggle = Instance.new("TextButton")
mToggle.Size = UDim2.new(1, 0, 0, 35)
mToggle.Position = UDim2.new(0, 0, 0, 108)
mToggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
mToggle.Text = "▶ ВКЛ"
mToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
mToggle.Font = Enum.Font.GothamBold
mToggle.TextSize = 14
mToggle.Parent = musBody
cr(mToggle, 6)

mToggle.MouseButton1Click:Connect(function()
    musicOn = not musicOn

    if musicOn then
        playMusic()
        mToggle.Text = "⏸ ВЫКЛ"
        mToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 120)
    else
        if music then
            music:Pause()
        end

        mToggle.Text = "▶ ВКЛ"
        mToggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    end
end)

local mStop = Instance.new("TextButton")
mStop.Size = UDim2.new(1, 0, 0, 32)
mStop.Position = UDim2.new(0, 0, 0, 151)
mStop.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
mStop.Text = "⏹ Стоп"
mStop.TextColor3 = Color3.fromRGB(255, 255, 255)
mStop.Font = Enum.Font.GothamBold
mStop.TextSize = 13
mStop.Parent = musBody
cr(mStop, 6)

mStop.MouseButton1Click:Connect(function()
    musicOn = false
    stopMusic()

    mToggle.Text = "▶ ВКЛ"
    mToggle.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
end)

-- Надёжное перетаскивание музыкальной панели
local musicDragging = false
local musicDragStart
local musicStartPos

musHead.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then

        musicDragging = true
        musicDragStart = i.Position
        musicStartPos = musPanel.Position
    end
end)

U.InputChanged:Connect(function(i)
    if not musicDragging then
        return
    end

    if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local d = i.Position - musicDragStart

    musPanel.Position = UDim2.new(
        musicStartPos.X.Scale,
        musicStartPos.X.Offset + d.X,
        musicStartPos.Y.Scale,
        musicStartPos.Y.Offset + d.Y
    )
end)

U.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
        musicDragging = false
    end
end)

local mOpen = true

musHide.MouseButton1Click:Connect(function()
    mOpen = not mOpen

    if mOpen then
        musPanel.Size = UDim2.new(0, 260, 0, 320)
        musBody.Visible = true
        musHide.Text = "▲"
    else
        musPanel.Size = UDim2.new(0, 260, 0, 40)
        musBody.Visible = false
        musHide.Text = "▼"
    end
end)

-- =========================================================
-- ОЧИСТКА ПРЕДЫДУЩЕГО МЕНЮ
-- =========================================================

local function destroyOldMenu()
    if playerRemovingConn then
        playerRemovingConn:Disconnect()
        playerRemovingConn = nil
    end

    if menuState then
        menuState.alive = false
        menuState.ac = false
        menuState.walkc = false
        menuState.fly = false

        for _, item in pairs(menuState.espL) do
            if item.hl then
                item.hl:Destroy()
            end
            if item.bb then
                item.bb:Destroy()
            end
        end

        if menuState.connections then
            for _, conn in ipairs(menuState.connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end
        end

        menuState = nil
    end

    if mainGui then
        mainGui:Destroy()
        mainGui = nil
    end
end

-- =========================================================
-- МЕНЮ
-- =========================================================

local menu

menu = function()
    destroyOldMenu()

    local sg = Instance.new("ScreenGui")
    sg.Name = "SupermanMenu"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = C

    mainGui = sg

    local st = {
        alive = true,

        nc = false,
        sp = false,
        spv = 60,
        originalSpeed = 16,

        fly = false,

        esp = false,
        espL = {},

        ac = false,
        walkc = false,

        connections = {}
    }

    menuState = st

    local function connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(st.connections, conn)
        return conn
    end

    local isOpen = true

    -- =====================================================
    -- КНОПКА СВЁРНУТОГО МЕНЮ
    -- =====================================================

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 60, 0, 60)
    tog.Position = UDim2.new(0, 20, 0.5, -240)
    tog.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    tog.Text = "🦸"
    tog.TextColor3 = Color3.fromRGB(255, 255, 255)
    tog.Font = Enum.Font.GothamBold
    tog.TextSize = 28
    tog.ZIndex = 10
    tog.Visible = false
    tog.Parent = sg
    cr(tog, 30)

    -- =====================================================
    -- ОСНОВНАЯ ПАНЕЛЬ
    -- =====================================================

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 290, 0, 540)
    main.Position = UDim2.new(0, 20, 0.5, -270)
    main.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
    main.BorderSizePixel = 0
    main.Active = true
    main.Parent = sg
    cr(main, 14)

    local mainS = Instance.new("UIStroke")
    mainS.Color = Color3.fromRGB(255, 50, 50)
    mainS.Thickness = 2
    mainS.Parent = main

    local th = Instance.new("Frame")
    th.Size = UDim2.new(1, 0, 0, 45)
    th.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
    th.BorderSizePixel = 0
    th.Active = true
    th.Parent = main
    cr(th, 14)

    local ti = Instance.new("TextLabel")
    ti.Size = UDim2.new(1, -80, 1, 0)
    ti.BackgroundTransparency = 1
    ti.Text =
        MODE == "d1" and "🦸 1х1"
        or MODE == "d2" and "🦸 2х2"
        or MODE == "d3" and "🦸 3х3"
        or "🦸 ОБЫЧНЫЙ"
    ti.TextColor3 = Color3.fromRGB(255, 90, 90)
    ti.Font = Enum.Font.GothamBold
    ti.TextScaled = true
    ti.Parent = th

    local musicOpenBtn = Instance.new("TextButton")
    musicOpenBtn.Size = UDim2.new(0, 32, 0, 32)
    musicOpenBtn.Position = UDim2.new(1, -72, 0, 6)
    musicOpenBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 150)
    musicOpenBtn.Text = "🎵"
    musicOpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    musicOpenBtn.Font = Enum.Font.GothamBold
    musicOpenBtn.TextSize = 16
    musicOpenBtn.Parent = th
    cr(musicOpenBtn, 8)

    musicOpenBtn.MouseButton1Click:Connect(function()
        musPanel.Visible = not musPanel.Visible
    end)

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 32, 0, 32)
    minBtn.Position = UDim2.new(1, -38, 0, 6)
    minBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    minBtn.Text = "▼"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 15
    minBtn.Parent = th
    cr(minBtn, 8)

    -- =====================================================
    -- DRAG ОСНОВНОГО МЕНЮ
    -- =====================================================

    local drag = false
    local dragStart
    local startPos

    connect(th.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            drag = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)

    connect(U.InputChanged, function(i)
        if not drag then
            return
        end

        if i.UserInputType ~= Enum.UserInputType.MouseMovement
            and i.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local d = i.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + d.X,
            startPos.Y.Scale,
            startPos.Y.Offset + d.Y
        )
    end)

    connect(U.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    -- =====================================================
    -- СВЁРТЫВАНИЕ
    -- =====================================================

    minBtn.MouseButton1Click:Connect(function()
        if not isOpen then
            return
        end

        isOpen = false

        tog.Position = main.Position
        main.Visible = false
        tog.Visible = true
    end)

    local togDown = false
    local togStart
    local togPos
    local togMoved = false

    connect(tog.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            togDown = true
            togMoved = false
            togStart = i.Position
            togPos = tog.Position
        end
    end)

    connect(U.InputChanged, function(i)
        if not togDown then
            return
        end

        if i.UserInputType ~= Enum.UserInputType.MouseMovement
            and i.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local d = i.Position - togStart

        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then
            togMoved = true
        end

        if togMoved then
            tog.Position = UDim2.new(
                togPos.X.Scale,
                togPos.X.Offset + d.X,
                togPos.Y.Scale,
                togPos.Y.Offset + d.Y
            )
        end
    end)

    connect(U.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then

            if togDown and not togMoved and not isOpen then
                isOpen = true
                main.Visible = true
                tog.Visible = false
            end

            togDown = false
        end
    end)

    -- =====================================================
    -- SCROLL
    -- =====================================================

    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -16, 1, -57)
    sc.Position = UDim2.new(0, 8, 0, 51)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 4
    sc.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 80)
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = sc

    -- =====================================================
    -- ТЕЛЕПОРТ
    -- =====================================================

    mkSec(sc, "ТЕЛЕПОРТ")

    mkB(sc, "📍 Вперёд", function()
        local c, root = getChar()

        if c and root then
            root.CFrame = root.CFrame * CFrame.new(0, 0, -50)
        end
    end)

    mkB(sc, "⬆️ Вверх", function()
        local c, root = getChar()

        if c and root then
            root.CFrame = root.CFrame * CFrame.new(0, 50, 0)
        end
    end)

    mkB(sc, "🏔️ На горы", function()
        local c, root = getChar()

        if not c or not root then
            return
        end

        local origin = root.Position
        local rayParams = RaycastParams.new()

        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {c}

        local result = workspace:Raycast(
            origin + Vector3.new(0, 5, 0),
            Vector3.new(0, -1000, 0),
            rayParams
        )

        if result then
            root.CFrame = CFrame.new(
                result.Position + Vector3.new(0, 5, 0)
            )
        else
            root.CFrame = root.CFrame + Vector3.new(0, 150, 0)
        end
    end, Color3.fromRGB(150, 60, 60))

    mkB(sc, "👥 К игроку", function()
        local ps = Instance.new("ScreenGui")
        ps.Name = "PlayerSelector"
        ps.ResetOnSpawn = false
        ps.IgnoreGuiInset = true
        ps.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ps.Parent = C

        local pf = Instance.new("Frame")
        pf.Size = UDim2.new(0.7, 0, 0.7, 0)
        pf.Position = UDim2.new(0.15, 0, 0.15, 0)
        pf.BackgroundColor3 = Color3.fromRGB(25, 10, 10)
        pf.Parent = ps
        cr(pf, 12)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 50, 50)
        stroke.Thickness = 2
        stroke.Parent = pf

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 40)
        t.BackgroundTransparency = 1
        t.Text = "👥 ВЫБЕРИ ИГРОКА"
        t.TextColor3 = Color3.fromRGB(255, 100, 100)
        t.Font = Enum.Font.GothamBold
        t.TextScaled = true
        t.Parent = pf

        local cl = Instance.new("TextButton")
        cl.Size = UDim2.new(0, 36, 0, 36)
        cl.Position = UDim2.new(1, -42, 0, 4)
        cl.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        cl.Text = "✕"
        cl.TextColor3 = Color3.fromRGB(255, 255, 255)
        cl.Font = Enum.Font.GothamBold
        cl.TextSize = 18
        cl.Parent = pf
        cr(cl, 8)

        cl.MouseButton1Click:Connect(function()
            ps:Destroy()
        end)

        local s = Instance.new("ScrollingFrame")
        s.Size = UDim2.new(0.94, 0, 1, -50)
        s.Position = UDim2.new(0.03, 0, 0, 44)
        s.BackgroundTransparency = 1
        s.BorderSizePixel = 0
        s.AutomaticCanvasSize = Enum.AutomaticSize.Y
        s.Parent = pf

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.Parent = s

        for _, pl in ipairs(P:GetPlayers()) do
            if pl ~= LP then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -8, 0, 40)
                b.BackgroundColor3 = Color3.fromRGB(90, 30, 30)
                b.Text = pl.Name
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.Font = Enum.Font.Gotham
              
