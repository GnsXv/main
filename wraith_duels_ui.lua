-- ============================================================
-- WRAITH DUELS UI
-- ============================================================

repeat task.wait() until game:IsLoaded()

local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local TS               = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local LP               = Players.LocalPlayer

-- ── PALETTE ──────────────────────────────────────────────────
local ACCENT       = Color3.fromRGB(30,  90,  220)   -- azul choque escuro principal
local ACCENT_GLOW  = Color3.fromRGB(50,  120, 255)   -- versão mais viva p/ hover/ativo
local ACCENT_DIM   = Color3.fromRGB(20,  55,  140)   -- versão mais escura p/ stroke
local BG_MAIN      = Color3.fromRGB(8,   8,   12)    -- fundo principal
local BG_SIDEBAR   = Color3.fromRGB(5,   5,   9)     -- sidebar mais escura
local BG_ROW       = Color3.fromRGB(14,  14,  22)    -- linha de toggle
local BG_BTN       = Color3.fromRGB(18,  18,  30)    -- botão tab inativo
local WHITE        = Color3.fromRGB(240, 240, 255)
local GRAY         = Color3.fromRGB(110, 115, 145)
local GRAY_DARK    = Color3.fromRGB(40,  42,  65)

-- ── HELPERS ──────────────────────────────────────────────────
local function corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r)
    return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke", parent)
    s.Color = color
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function drag(f)
    local dn, ds, sp = false, nil, nil
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dn = true; ds = i.Position; sp = f.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dn = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dn and (i.UserInputType == Enum.UserInputType.MouseMovement
               or  i.UserInputType == Enum.UserInputType.Touch) then
            f.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + (i.Position.X - ds.X),
                sp.Y.Scale, sp.Y.Offset + (i.Position.Y - ds.Y)
            )
        end
    end)
end

-- ── BUILD GUI ────────────────────────────────────────────────
local function buildGui()
    -- limpa instâncias anteriores
    local hg = game:GetService("CoreGui")
    pcall(function()
        local old = hg:FindFirstChild("WraithDuels")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name            = "WraithDuels"
    gui.ResetOnSpawn    = false
    gui.DisplayOrder    = 15
    gui.IgnoreGuiInset  = true
    gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = gethui() end) then
        if not pcall(function() gui.Parent = hg end) then
            gui.Parent = LP:WaitForChild("PlayerGui")
        end
    end

    -- ── JANELA PRINCIPAL ─────────────────────────────────────
    local main = Instance.new("Frame", gui)
    main.AnchorPoint      = Vector2.new(0.5, 0.5)
    main.Size             = UDim2.new(0, 680, 0, 460)
    main.Position         = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = BG_MAIN
    main.BorderSizePixel  = 0
    main.ClipsDescendants = true
    corner(main, 20)
    stroke(main, ACCENT_DIM, 1.5, 0)
    drag(main)

    -- glow sutil no border
    local outerGlow = Instance.new("ImageLabel", main)
    outerGlow.Size                 = UDim2.new(1, 24, 1, 24)
    outerGlow.Position             = UDim2.new(0, -12, 0, -12)
    outerGlow.BackgroundTransparency = 1
    outerGlow.Image                = "rbxassetid://5028857084"
    outerGlow.ImageColor3          = ACCENT
    outerGlow.ImageTransparency    = 0.75
    outerGlow.ScaleType            = Enum.ScaleType.Slice
    outerGlow.SliceCenter          = Rect.new(24, 24, 276, 276)
    outerGlow.ZIndex               = 0

    -- ── SIDEBAR ──────────────────────────────────────────────
    local SIDEBAR_W = 210

    local sidebar = Instance.new("Frame", main)
    sidebar.Size             = UDim2.new(0, SIDEBAR_W, 1, 0)
    sidebar.BackgroundColor3 = BG_SIDEBAR
    sidebar.BorderSizePixel  = 0
    sidebar.ClipsDescendants = true
    sidebar.ZIndex           = 2

    -- linha divisória azul na borda direita da sidebar
    local divLine = Instance.new("Frame", sidebar)
    divLine.Size             = UDim2.new(0, 1, 1, 0)
    divLine.Position         = UDim2.new(1, -1, 0, 0)
    divLine.BackgroundColor3 = ACCENT
    divLine.BorderSizePixel  = 0
    divLine.BackgroundTransparency = 0.4
    divLine.ZIndex           = 3

    -- gradiente vertical sidebar
    local sideGrad = Instance.new("Frame", sidebar)
    sideGrad.Size             = UDim2.new(1, 0, 1, 0)
    sideGrad.BackgroundColor3 = ACCENT
    sideGrad.BorderSizePixel  = 0
    sideGrad.ZIndex           = 1
    local sg = Instance.new("UIGradient", sideGrad)
    sg.Rotation    = 180
    sg.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.88),
        NumberSequenceKeypoint.new(0.5, 0.96),
        NumberSequenceKeypoint.new(1,   1),
    })

    -- branding
    local brandBox = Instance.new("Frame", sidebar)
    brandBox.Size                 = UDim2.new(1, -20, 0, 60)
    brandBox.Position             = UDim2.new(0, 10, 0, 14)
    brandBox.BackgroundTransparency = 1
    brandBox.ZIndex               = 5

    local logoIcon = Instance.new("Frame", brandBox)
    logoIcon.Size             = UDim2.new(0, 28, 0, 28)
    logoIcon.BackgroundColor3 = ACCENT
    logoIcon.BorderSizePixel  = 0
    logoIcon.ZIndex           = 6
    corner(logoIcon, 8)
    local logoInner = Instance.new("TextLabel", logoIcon)
    logoInner.Size               = UDim2.new(1,0,1,0)
    logoInner.BackgroundTransparency = 1
    logoInner.Text               = "W"
    logoInner.TextColor3         = WHITE
    logoInner.Font               = Enum.Font.GothamBold
    logoInner.TextSize           = 16
    logoInner.ZIndex             = 7

    local titleLbl = Instance.new("TextLabel", brandBox)
    titleLbl.Size               = UDim2.new(1, -38, 0, 18)
    titleLbl.Position           = UDim2.new(0, 38, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = "Wraith Duels"
    titleLbl.TextColor3         = WHITE
    titleLbl.Font               = Enum.Font.GothamBold
    titleLbl.TextSize           = 16
    titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
    titleLbl.ZIndex             = 6

    local subLbl = Instance.new("TextLabel", brandBox)
    subLbl.Size               = UDim2.new(1, -38, 0, 12)
    subLbl.Position           = UDim2.new(0, 38, 0, 22)
    subLbl.BackgroundTransparency = 1
    subLbl.Text               = "duels edition"
    subLbl.TextColor3         = ACCENT_GLOW
    subLbl.Font               = Enum.Font.Gotham
    subLbl.TextSize           = 11
    subLbl.TextXAlignment     = Enum.TextXAlignment.Left
    subLbl.ZIndex             = 6

    local brandUnderline = Instance.new("Frame", brandBox)
    brandUnderline.Size             = UDim2.new(0.7, 0, 0, 1)
    brandUnderline.Position         = UDim2.new(0, 0, 1, 2)
    brandUnderline.BackgroundColor3 = ACCENT
    brandUnderline.BorderSizePixel  = 0
    brandUnderline.BackgroundTransparency = 0.3
    brandUnderline.ZIndex           = 6
    corner(brandUnderline, 2)

    -- tabs
    local tabList = Instance.new("Frame", sidebar)
    tabList.Size                 = UDim2.new(1, -20, 0, 280)
    tabList.Position             = UDim2.new(0, 10, 0, 90)
    tabList.BackgroundTransparency = 1
    tabList.ZIndex               = 5

    local tabLayout = Instance.new("UIListLayout", tabList)
    tabLayout.SortOrder         = Enum.SortOrder.LayoutOrder
    tabLayout.Padding           = UDim.new(0, 6)
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- versão / status em baixo
    local verLbl = Instance.new("TextLabel", sidebar)
    verLbl.Size               = UDim2.new(1, -20, 0, 12)
    verLbl.Position           = UDim2.new(0, 10, 1, -22)
    verLbl.BackgroundTransparency = 1
    verLbl.Text               = "v1.0.0  ·  loaded"
    verLbl.TextColor3         = GRAY
    verLbl.Font               = Enum.Font.Gotham
    verLbl.TextSize           = 10
    verLbl.TextXAlignment     = Enum.TextXAlignment.Left
    verLbl.ZIndex             = 5

    -- ── CONTENT ──────────────────────────────────────────────
    local content = Instance.new("Frame", main)
    content.Size             = UDim2.new(1, -SIDEBAR_W, 1, 0)
    content.Position         = UDim2.new(0, SIDEBAR_W, 0, 0)
    content.BackgroundColor3 = BG_MAIN
    content.BorderSizePixel  = 0
    content.ClipsDescendants = true
    content.ZIndex           = 3

    -- header bar no content
    local headerBar = Instance.new("Frame", content)
    headerBar.Size             = UDim2.new(1, 0, 0, 44)
    headerBar.BackgroundColor3 = BG_SIDEBAR
    headerBar.BorderSizePixel  = 0
    headerBar.ZIndex           = 4

    local headerTitle = Instance.new("TextLabel", headerBar)
    headerTitle.Size               = UDim2.new(1, -80, 1, 0)
    headerTitle.Position           = UDim2.new(0, 16, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text               = "Main"
    headerTitle.TextColor3         = WHITE
    headerTitle.Font               = Enum.Font.GothamBold
    headerTitle.TextSize           = 14
    headerTitle.TextXAlignment     = Enum.TextXAlignment.Left
    headerTitle.ZIndex             = 5

    local headerDiv = Instance.new("Frame", content)
    headerDiv.Size             = UDim2.new(1, 0, 0, 1)
    headerDiv.Position         = UDim2.new(0, 0, 0, 44)
    headerDiv.BackgroundColor3 = ACCENT
    headerDiv.BackgroundTransparency = 0.6
    headerDiv.BorderSizePixel  = 0
    headerDiv.ZIndex           = 4

    -- close button
    local closeBtn = Instance.new("TextButton", headerBar)
    closeBtn.Size             = UDim2.new(0, 26, 0, 26)
    closeBtn.Position         = UDim2.new(1, -36, 0.5, -13)
    closeBtn.BackgroundColor3 = BG_ROW
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "×"
    closeBtn.TextColor3       = GRAY
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.TextSize         = 18
    closeBtn.AutoButtonColor  = false
    closeBtn.ZIndex           = 10
    corner(closeBtn, 8)
    stroke(closeBtn, GRAY_DARK, 1, 0.3)

    closeBtn.MouseEnter:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = WHITE, BackgroundColor3 = Color3.fromRGB(180,30,30)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TS:Create(closeBtn, TweenInfo.new(0.15), {TextColor3 = GRAY, BackgroundColor3 = BG_ROW}):Play()
    end)

    -- pageHolder
    local pageHolder = Instance.new("Frame", content)
    pageHolder.Size                 = UDim2.new(1, -24, 1, -60)
    pageHolder.Position             = UDim2.new(0, 12, 0, 52)
    pageHolder.BackgroundTransparency = 1
    pageHolder.ZIndex               = 4

    local function newPage()
        local p = Instance.new("ScrollingFrame", pageHolder)
        p.Size                   = UDim2.new(1, 0, 1, 0)
        p.BackgroundTransparency = 1
        p.BorderSizePixel        = 0
        p.ScrollBarThickness     = 2
        p.ScrollBarImageColor3   = ACCENT_GLOW
        p.ScrollBarImageTransparency = 0.3
        p.CanvasSize             = UDim2.new(0,0,0,0)
        p.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        p.ZIndex                 = 5
        p.Visible                = false
        local lay = Instance.new("UIListLayout", p)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding   = UDim.new(0, 6)
        return p
    end

    local pages = {
        Main   = newPage(),
        Combat = newPage(),
        Visual = newPage(),
        Config = newPage(),
    }
    pages.Main.Visible = true

    -- ── SECTION HEADER ───────────────────────────────────────
    local function sectionHeader(parent, title, order)
        local holder = Instance.new("Frame", parent)
        holder.Size                 = UDim2.new(1, 0, 0, 28)
        holder.BackgroundTransparency = 1
        holder.LayoutOrder          = order
        holder.ZIndex               = 6

        local bar = Instance.new("Frame", holder)
        bar.Size             = UDim2.new(0, 3, 0, 14)
        bar.Position         = UDim2.new(0, 0, 0.5, -7)
        bar.BackgroundColor3 = ACCENT
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 7
        corner(bar, 2)

        local lbl = Instance.new("TextLabel", holder)
        lbl.Size               = UDim2.new(1, -10, 1, 0)
        lbl.Position           = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = title
        lbl.TextColor3         = ACCENT_GLOW
        lbl.Font               = Enum.Font.GothamBold
        lbl.TextSize           = 11
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.ZIndex             = 7
        return holder
    end

    -- ── DIVIDER ──────────────────────────────────────────────
    local function divider(parent, order)
        local d = Instance.new("Frame", parent)
        d.Size             = UDim2.new(1, 0, 0, 1)
        d.BackgroundColor3 = ACCENT_DIM
        d.BorderSizePixel  = 0
        d.BackgroundTransparency = 0.6
        d.LayoutOrder      = order
        d.ZIndex           = 6
        return d
    end

    -- ── TOGGLE ROW ───────────────────────────────────────────
    local function toggleRow(parent, label, defaultOn, order, onToggle)
        local r = Instance.new("Frame", parent)
        r.Size             = UDim2.new(1, 0, 0, 38)
        r.BackgroundColor3 = BG_ROW
        r.BorderSizePixel  = 0
        r.LayoutOrder      = order
        r.ZIndex           = 6
        corner(r, 8)
        stroke(r, GRAY_DARK, 1, 0.5)

        local lbl = Instance.new("TextLabel", r)
        lbl.Size               = UDim2.new(0.65, -8, 1, 0)
        lbl.Position           = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = label
        lbl.TextColor3         = WHITE
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 13
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.ZIndex             = 7

        -- pill toggle
        local pillBG = Instance.new("Frame", r)
        pillBG.Size             = UDim2.new(0, 44, 0, 22)
        pillBG.Position         = UDim2.new(1, -56, 0.5, -11)
        pillBG.BackgroundColor3 = defaultOn and ACCENT or GRAY_DARK
        pillBG.BorderSizePixel  = 0
        pillBG.ZIndex           = 7
        corner(pillBG, 11)

        local knob = Instance.new("Frame", pillBG)
        knob.Size             = UDim2.new(0, 16, 0, 16)
        knob.Position         = defaultOn and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = WHITE
        knob.BorderSizePixel  = 0
        knob.ZIndex           = 8
        corner(knob, 8)

        local state = defaultOn
        local pillBtn = Instance.new("TextButton", pillBG)
        pillBtn.Size               = UDim2.new(1,0,1,0)
        pillBtn.BackgroundTransparency = 1
        pillBtn.Text               = ""
        pillBtn.ZIndex             = 9

        pillBtn.MouseButton1Click:Connect(function()
            state = not state
            TS:Create(pillBG, TweenInfo.new(0.18), {
                BackgroundColor3 = state and ACCENT or GRAY_DARK
            }):Play()
            TS:Create(knob, TweenInfo.new(0.18), {
                Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
            }):Play()
            if onToggle then onToggle(state) end
        end)

        return r, function() return state end
    end

    -- ── VALUE ROW (label + valor direita) ────────────────────
    local function valueRow(parent, label, value, order, valueColor)
        local r = Instance.new("Frame", parent)
        r.Size             = UDim2.new(1, 0, 0, 38)
        r.BackgroundColor3 = BG_ROW
        r.BorderSizePixel  = 0
        r.LayoutOrder      = order
        r.ZIndex           = 6
        corner(r, 8)
        stroke(r, GRAY_DARK, 1, 0.5)

        local lbl = Instance.new("TextLabel", r)
        lbl.Size               = UDim2.new(0.6, 0, 1, 0)
        lbl.Position           = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = label
        lbl.TextColor3         = WHITE
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 13
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.ZIndex             = 7

        local val = Instance.new("TextLabel", r)
        val.Size               = UDim2.new(0.38, -12, 1, 0)
        val.Position           = UDim2.new(0.62, 0, 0, 0)
        val.BackgroundTransparency = 1
        val.Text               = tostring(value)
        val.TextColor3         = valueColor or ACCENT_GLOW
        val.Font               = Enum.Font.GothamBold
        val.TextSize           = 13
        val.TextXAlignment     = Enum.TextXAlignment.Right
        val.ZIndex             = 7

        return r, val
    end

    -- ── BUTTON ROW ───────────────────────────────────────────
    local function buttonRow(parent, label, btnLabel, order, btnColor, onPress)
        local r = Instance.new("Frame", parent)
        r.Size             = UDim2.new(1, 0, 0, 38)
        r.BackgroundColor3 = BG_ROW
        r.BorderSizePixel  = 0
        r.LayoutOrder      = order
        r.ZIndex           = 6
        corner(r, 8)
        stroke(r, GRAY_DARK, 1, 0.5)

        local lbl = Instance.new("TextLabel", r)
        lbl.Size               = UDim2.new(0.55, 0, 1, 0)
        lbl.Position           = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = label
        lbl.TextColor3         = WHITE
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 13
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.ZIndex             = 7

        local btn = Instance.new("TextButton", r)
        btn.Size             = UDim2.new(0, 80, 0, 26)
        btn.Position         = UDim2.new(1, -92, 0.5, -13)
        btn.BackgroundColor3 = btnColor or ACCENT
        btn.BorderSizePixel  = 0
        btn.Text             = btnLabel
        btn.TextColor3       = WHITE
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 12
        btn.AutoButtonColor  = false
        btn.ZIndex           = 7
        corner(btn, 7)

        btn.MouseEnter:Connect(function()
            TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = ACCENT_GLOW}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TS:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = btnColor or ACCENT}):Play()
        end)
        if onPress then btn.MouseButton1Click:Connect(onPress) end

        return r
    end

    -- ── TABS ─────────────────────────────────────────────────
    local tabData = {}

    local function makeTab(name, page, icon, order)
        local b = Instance.new("TextButton", tabList)
        b.Size             = UDim2.new(1, 0, 0, 38)
        b.BackgroundColor3 = BG_BTN
        b.BackgroundTransparency = 0.2
        b.BorderSizePixel  = 0
        b.Text             = icon .. "  " .. name
        b.TextColor3       = GRAY
        b.Font             = Enum.Font.GothamBold
        b.TextSize         = 13
        b.AutoButtonColor  = false
        b.LayoutOrder      = order
        b.ZIndex           = 6
        corner(b, 10)

        local activeBar = Instance.new("Frame", b)
        activeBar.Size             = UDim2.new(0, 3, 0.55, 0)
        activeBar.Position         = UDim2.new(0, 0, 0.225, 0)
        activeBar.BackgroundColor3 = ACCENT
        activeBar.BorderSizePixel  = 0
        activeBar.BackgroundTransparency = 1
        activeBar.ZIndex           = 7
        corner(activeBar, 2)

        b.MouseButton1Click:Connect(function()
            for _, td in ipairs(tabData) do
                TS:Create(td.btn, TweenInfo.new(0.18), {
                    BackgroundTransparency = 0.2,
                    TextColor3 = GRAY
                }):Play()
                TS:Create(td.bar, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
                td.page.Visible = false
            end
            TS:Create(b, TweenInfo.new(0.18), {
                BackgroundTransparency = 0,
                TextColor3 = WHITE
            }):Play()
            TS:Create(activeBar, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
            b.BackgroundColor3 = ACCENT_DIM
            page.Visible = true
            headerTitle.Text = name
        end)

        table.insert(tabData, {btn = b, page = page, bar = activeBar})
        return b, activeBar
    end

    local t1, b1 = makeTab("Main",   pages.Main,   "⚡", 1)
    local t2, b2 = makeTab("Combat", pages.Combat, "⚔", 2)
    local t3, b3 = makeTab("Visual", pages.Visual, "👁", 3)
    local t4, b4 = makeTab("Config", pages.Config, "⚙", 4)

    -- ativa tab Main por padrão
    t1.BackgroundColor3        = ACCENT_DIM
    t1.BackgroundTransparency  = 0
    t1.TextColor3              = WHITE
    b1.BackgroundTransparency  = 0

    -- ── CONTEÚDO: MAIN ───────────────────────────────────────
    local p = pages.Main
    local ord = 0

    ord=ord+1; sectionHeader(p, "SPEED", ord)
    ord=ord+1; valueRow(p, "Normal Speed", "55", ord)
    ord=ord+1; valueRow(p, "Carry Speed",  "28.5", ord)
    ord=ord+1; valueRow(p, "Lagger Speed", "15",   ord)
    ord=ord+1; toggleRow(p, "Speed Bypass",   false, ord)
    ord=ord+1; toggleRow(p, "Lagger",         false, ord)
    ord=ord+1; toggleRow(p, "Unwalk",         false, ord)
    ord=ord+1; toggleRow(p, "Infinity Jump",  false, ord)
    ord=ord+1; divider(p, ord)
    ord=ord+1; sectionHeader(p, "STEAL", ord)
    ord=ord+1; toggleRow(p, "Auto Steal",     false, ord)
    ord=ord+1; valueRow(p, "Steal Radius", "10",    ord)
    ord=ord+1; toggleRow(p, "Anti Ragdoll V1", false, ord)
    ord=ord+1; toggleRow(p, "Anti Ragdoll V2", false, ord)
    ord=ord+1; divider(p, ord)
    ord=ord+1; sectionHeader(p, "MOVEMENT", ord)
    ord=ord+1; toggleRow(p, "Auto Left",      false, ord)
    ord=ord+1; toggleRow(p, "Auto Right",     false, ord)
    ord=ord+1; toggleRow(p, "Auto TP Down",   false, ord)
    ord=ord+1; toggleRow(p, "Doge Mode",      false, ord)
    ord=ord+1; toggleRow(p, "Walk Through Players", false, ord)

    -- ── CONTEÚDO: COMBAT ─────────────────────────────────────
    local pc = pages.Combat
    local co = 0

    co=co+1; sectionHeader(pc, "AIMBOT", co)
    co=co+1; toggleRow(pc, "Bat Aimbot",     false, co)
    co=co+1; toggleRow(pc, "Bat Aimbot V2",  false, co)
    co=co+1; toggleRow(pc, "Bat Aimbot V3",  false, co)
    co=co+1; toggleRow(pc, "Bat Aimbot Envy",false, co)
    co=co+1; toggleRow(pc, "Bat Aimbot Kronos",false, co)
    co=co+1; valueRow(pc,  "Aimbot Speed",   "58",  co)
    co=co+1; divider(pc, co)
    co=co+1; sectionHeader(pc, "COUNTER", co)
    co=co+1; toggleRow(pc, "Bat Counter",    false, co)
    co=co+1; toggleRow(pc, "Medusa Counter", false, co)
    co=co+1; divider(pc, co)
    co=co+1; sectionHeader(pc, "ANTI", co)
    co=co+1; toggleRow(pc, "Anti Die",       true,  co)
    co=co+1; toggleRow(pc, "Anti Bat",       false, co)
    co=co+1; toggleRow(pc, "Anti Bee",       false, co)
    co=co+1; toggleRow(pc, "Anti Fling",     false, co)
    co=co+1; divider(pc, co)
    co=co+1; sectionHeader(pc, "MISC COMBAT", co)
    co=co+1; toggleRow(pc, "Body Lock",      false, co)
    co=co+1; toggleRow(pc, "Cap Aimbot",     false, co)
    co=co+1; toggleRow(pc, "Bat From Front", false, co)
    co=co+1; toggleRow(pc, "Bat Spam",       false, co)

    -- ── CONTEÚDO: VISUAL ─────────────────────────────────────
    local pv = pages.Visual
    local vo = 0

    vo=vo+1; sectionHeader(pv, "ESP", vo)
    vo=vo+1; toggleRow(pv, "Player ESP",     false, vo)
    vo=vo+1; toggleRow(pv, "FOV Circle",     false, vo)
    vo=vo+1; divider(pv, vo)
    vo=vo+1; sectionHeader(pv, "WORLD", vo)
    vo=vo+1; toggleRow(pv, "Xray",           false, vo)
    vo=vo+1; toggleRow(pv, "Dark Sky",       false, vo)
    vo=vo+1; toggleRow(pv, "Galaxy Sky Bright", false, vo)
    vo=vo+1; toggleRow(pv, "Remove Accessories", false, vo)
    vo=vo+1; divider(pv, vo)
    vo=vo+1; sectionHeader(pv, "HUD", vo)
    vo=vo+1; toggleRow(pv, "Show Speed",     true,  vo)
    vo=vo+1; toggleRow(pv, "Show Ragdoll",   false, vo)

    -- ── CONTEÚDO: CONFIG ─────────────────────────────────────
    local pf = pages.Config
    local fo = 0

    fo=fo+1; sectionHeader(pf, "SETTINGS", fo)
    fo=fo+1; buttonRow(pf, "Save Config",  "Save",  fo, ACCENT)
    fo=fo+1; buttonRow(pf, "Load Config",  "Load",  fo, ACCENT)
    fo=fo+1; buttonRow(pf, "Reset Config", "Reset", fo, Color3.fromRGB(180,30,30))
    fo=fo+1; divider(pf, fo)
    fo=fo+1; sectionHeader(pf, "AUTO SAVE", fo)
    fo=fo+1; toggleRow(pf, "Auto Save", true, fo)
    fo=fo+1; divider(pf, fo)
    fo=fo+1; sectionHeader(pf, "INFO", fo)
    fo=fo+1; valueRow(pf, "Version", "1.0.0", fo, GRAY)
    fo=fo+1; valueRow(pf, "Status",  "Loaded", fo, Color3.fromRGB(80,200,100))

    -- ── MINI BUTTON (quando fechado) ─────────────────────────
    local miniBtn = Instance.new("TextButton", gui)
    miniBtn.Size             = UDim2.new(0, 130, 0, 30)
    miniBtn.Position         = UDim2.new(1, -148, 0, 24)
    miniBtn.BackgroundColor3 = ACCENT_DIM
    miniBtn.BorderSizePixel  = 0
    miniBtn.Text             = "⚡ Wraith Duels"
    miniBtn.TextColor3       = WHITE
    miniBtn.Font             = Enum.Font.GothamBold
    miniBtn.TextSize         = 12
    miniBtn.Visible          = false
    miniBtn.ZIndex           = 20
    corner(miniBtn, 15)
    stroke(miniBtn, ACCENT, 1, 0.3)
    drag(miniBtn)

    closeBtn.MouseButton1Click:Connect(function()
        main.Visible    = false
        miniBtn.Visible = true
    end)
    miniBtn.MouseButton1Click:Connect(function()
        main.Visible    = true
        miniBtn.Visible = false
    end)

    -- ── KEYBIND: LCTRL toggle ────────────────────────────────
    UIS.InputBegan:Connect(function(inp, gpe)
        if gpe then return end
        if inp.KeyCode == Enum.KeyCode.LeftControl then
            main.Visible = not main.Visible
            miniBtn.Visible = not main.Visible
        end
    end)
end

local ok, err = pcall(buildGui)
if not ok then
    warn("[WraithDuels] UI error: " .. tostring(err))
end
