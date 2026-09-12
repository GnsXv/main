-- ============================================================
-- WRAITH DUELS UI v2
-- Mobile + PC adaptive | gethui() | Azul choque escuro
-- ============================================================

repeat task.wait() until game:IsLoaded()

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local LP         = Players.LocalPlayer

-- ── DETECÇÃO MOBILE ──────────────────────────────────────────
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

-- ── ESCALA ADAPTÁVEL ─────────────────────────────────────────
-- Mobile: menu menor, touch-friendly
-- PC:     menu maior com mais detalhe
local W         = isMobile and 320  or 560
local H         = isMobile and 400  or 440
local SIDEBAR_W = isMobile and 90   or 160
local ROW_H     = isMobile and 44   or 36
local FONT_M    = isMobile and 13   or 13
local FONT_S    = isMobile and 11   or 11
local FONT_XS   = isMobile and 10   or 10
local PAD       = isMobile and 8    or 10
local TAB_H     = isMobile and 42   or 34

-- ── PALETTE ──────────────────────────────────────────────────
local C = {
    ACCENT       = Color3.fromRGB(25,  80,  210),
    ACCENT_LIT   = Color3.fromRGB(55,  120, 255),
    ACCENT_DIM   = Color3.fromRGB(15,  50,  140),
    ACCENT_GLOW  = Color3.fromRGB(80,  140, 255),
    BG           = Color3.fromRGB(7,   7,   11),
    BG2          = Color3.fromRGB(11,  11,  18),
    BG3          = Color3.fromRGB(16,  16,  26),
    BG4          = Color3.fromRGB(22,  22,  36),
    WHITE        = Color3.fromRGB(235, 238, 255),
    GRAY         = Color3.fromRGB(100, 105, 135),
    GRAY_D       = Color3.fromRGB(35,  37,  58),
    SUCCESS      = Color3.fromRGB(60,  200, 110),
    DANGER       = Color3.fromRGB(210, 55,  55),
}

-- ── HELPERS ──────────────────────────────────────────────────
local function corner(p, r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r); return c end
local function stroke(p, col, th, tr)
    local s=Instance.new("UIStroke",p)
    s.Color=col; s.Thickness=th or 1; s.Transparency=tr or 0
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return s
end
local function pad(p, t, r, b, l)
    local u=Instance.new("UIPadding",p)
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingBottom=UDim.new(0,b or 0); u.PaddingLeft=UDim.new(0,l or 0)
    return u
end
local function tween(obj, info, props)
    TS:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- drag funcional em touch e mouse
local function drag(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos  = frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── GUI ROOT ─────────────────────────────────────────────────
local function build()
    -- limpa old
    pcall(function()
        local h = gethui()
        local old = h:FindFirstChild("WraithDuels")
        if old then old:Destroy() end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name           = "WraithDuels"
    gui.ResetOnSpawn   = false
    gui.DisplayOrder   = 99
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = gethui() end) then
        if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then
            gui.Parent = LP:WaitForChild("PlayerGui")
        end
    end

    -- ── SHADOW FRAME (simula sombra externa) ──────────────────
    local shadow = Instance.new("ImageLabel", gui)
    shadow.AnchorPoint    = Vector2.new(0.5,0.5)
    shadow.Size           = UDim2.new(0, W+40, 0, H+40)
    shadow.Position       = UDim2.new(0.5,0, 0.5,2)
    shadow.BackgroundTransparency = 1
    shadow.Image          = "rbxassetid://5028857084"
    shadow.ImageColor3    = C.ACCENT_DIM
    shadow.ImageTransparency = 0.6
    shadow.ScaleType      = Enum.ScaleType.Slice
    shadow.SliceCenter    = Rect.new(24,24,276,276)
    shadow.ZIndex         = 0

    -- ── JANELA PRINCIPAL ──────────────────────────────────────
    local main = Instance.new("Frame", gui)
    main.Name          = "_main"
    main.AnchorPoint   = Vector2.new(0.5,0.5)
    main.Size          = UDim2.new(0, W, 0, H)
    main.Position      = UDim2.new(0.5,0, 0.5,0)
    main.BackgroundColor3 = C.BG
    main.BorderSizePixel  = 0
    main.ClipsDescendants = true
    corner(main, 14)
    stroke(main, C.ACCENT_DIM, 1.2, 0)

    -- sincroniza sombra com main ao arrastar
    local function syncShadow()
        shadow.Position = UDim2.new(
            main.Position.X.Scale, main.Position.X.Offset,
            main.Position.Y.Scale, main.Position.Y.Offset + 2
        )
    end
    RunService = game:GetService("RunService")
    RunService.RenderStepped:Connect(syncShadow)

    -- ── SIDEBAR ───────────────────────────────────────────────
    local sidebar = Instance.new("Frame", main)
    sidebar.Size          = UDim2.new(0, SIDEBAR_W, 1, 0)
    sidebar.BackgroundColor3 = C.BG2
    sidebar.BorderSizePixel  = 0
    sidebar.ClipsDescendants = true
    sidebar.ZIndex        = 2

    -- gradiente vertical azul na sidebar
    local sideFill = Instance.new("Frame", sidebar)
    sideFill.Size             = UDim2.new(1,0,1,0)
    sideFill.BackgroundColor3 = C.ACCENT
    sideFill.BorderSizePixel  = 0
    sideFill.ZIndex           = 1
    local sGrad = Instance.new("UIGradient", sideFill)
    sGrad.Rotation    = 180
    sGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.82),
        NumberSequenceKeypoint.new(0.6, 0.93),
        NumberSequenceKeypoint.new(1,   1),
    })

    -- borda direita da sidebar
    local sLine = Instance.new("Frame", sidebar)
    sLine.Size             = UDim2.new(0,1,1,0)
    sLine.Position         = UDim2.new(1,-1,0,0)
    sLine.BackgroundColor3 = C.ACCENT
    sLine.BackgroundTransparency = 0.45
    sLine.BorderSizePixel  = 0
    sLine.ZIndex           = 3

    -- logo / branding no topo da sidebar
    local logoFrame = Instance.new("Frame", sidebar)
    logoFrame.Size          = UDim2.new(1,0,0, isMobile and 70 or 62)
    logoFrame.BackgroundTransparency = 1
    logoFrame.ZIndex        = 4

    local logoBox = Instance.new("Frame", logoFrame)
    logoBox.Size          = UDim2.new(0, isMobile and 34 or 30, 0, isMobile and 34 or 30)
    logoBox.Position      = UDim2.new(0.5,-( isMobile and 17 or 15), 0, isMobile and 14 or 10)
    logoBox.BackgroundColor3 = C.ACCENT
    logoBox.BorderSizePixel  = 0
    logoBox.ZIndex        = 5
    corner(logoBox, 9)
    -- brilho interno no logo
    local logoGlow = Instance.new("ImageLabel", logoBox)
    logoGlow.Size             = UDim2.new(1.4,0,1.4,0)
    logoGlow.Position         = UDim2.new(-0.2,0,-0.2,0)
    logoGlow.BackgroundTransparency = 1
    logoGlow.Image            = "rbxassetid://5028857084"
    logoGlow.ImageColor3      = C.ACCENT_GLOW
    logoGlow.ImageTransparency = 0.5
    logoGlow.ScaleType        = Enum.ScaleType.Slice
    logoGlow.SliceCenter      = Rect.new(24,24,276,276)
    logoGlow.ZIndex           = 4
    local logoLbl = Instance.new("TextLabel", logoBox)
    logoLbl.Size              = UDim2.new(1,0,1,0)
    logoLbl.BackgroundTransparency = 1
    logoLbl.Text              = "W"
    logoLbl.TextColor3        = C.WHITE
    logoLbl.Font              = Enum.Font.GothamBold
    logoLbl.TextSize          = isMobile and 18 or 16
    logoLbl.ZIndex            = 6

    if not isMobile then
        local brandLbl = Instance.new("TextLabel", logoFrame)
        brandLbl.Size          = UDim2.new(1,-6,0,13)
        brandLbl.Position      = UDim2.new(0,3,0,44)
        brandLbl.BackgroundTransparency = 1
        brandLbl.Text          = "WRAITH"
        brandLbl.TextColor3    = C.WHITE
        brandLbl.Font          = Enum.Font.GothamBold
        brandLbl.TextSize      = 10
        brandLbl.TextXAlignment = Enum.TextXAlignment.Center
        brandLbl.ZIndex        = 5
    end

    -- ── TAB LIST ──────────────────────────────────────────────
    local tabList = Instance.new("Frame", sidebar)
    tabList.Size          = UDim2.new(1,0,1,-(isMobile and 75 or 68))
    tabList.Position      = UDim2.new(0,0,0,isMobile and 74 or 66)
    tabList.BackgroundTransparency = 1
    tabList.ZIndex        = 4
    local tLayout = Instance.new("UIListLayout", tabList)
    tLayout.SortOrder         = Enum.SortOrder.LayoutOrder
    tLayout.Padding           = UDim.new(0, 2)
    tLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- ── CONTENT ÁREA ──────────────────────────────────────────
    local contentArea = Instance.new("Frame", main)
    contentArea.Size          = UDim2.new(1,-SIDEBAR_W,1,0)
    contentArea.Position      = UDim2.new(0,SIDEBAR_W,0,0)
    contentArea.BackgroundColor3 = C.BG
    contentArea.BorderSizePixel  = 0
    contentArea.ClipsDescendants = true
    contentArea.ZIndex        = 2

    -- topbar no content
    local topbar = Instance.new("Frame", contentArea)
    topbar.Size          = UDim2.new(1,0,0, isMobile and 42 or 38)
    topbar.BackgroundColor3 = C.BG2
    topbar.BorderSizePixel  = 0
    topbar.ZIndex        = 5

    local topDiv = Instance.new("Frame", contentArea)
    topDiv.Size          = UDim2.new(1,0,0,1)
    topDiv.Position      = UDim2.new(0,0,0, isMobile and 42 or 38)
    topDiv.BackgroundColor3 = C.ACCENT
    topDiv.BackgroundTransparency = 0.5
    topDiv.BorderSizePixel  = 0
    topDiv.ZIndex        = 5

    drag(main, topbar)
    drag(main, logoFrame)

    local pageTitle = Instance.new("TextLabel", topbar)
    pageTitle.Size          = UDim2.new(1,-50,1,0)
    pageTitle.Position      = UDim2.new(0,12,0,0)
    pageTitle.BackgroundTransparency = 1
    pageTitle.Text          = "Main"
    pageTitle.TextColor3    = C.WHITE
    pageTitle.Font          = Enum.Font.GothamBold
    pageTitle.TextSize      = FONT_M
    pageTitle.TextXAlignment = Enum.TextXAlignment.Left
    pageTitle.ZIndex        = 6

    -- botão fechar
    local closeBtn = Instance.new("TextButton", topbar)
    closeBtn.Size          = UDim2.new(0, isMobile and 30 or 26, 0, isMobile and 30 or 26)
    closeBtn.Position      = UDim2.new(1,-( isMobile and 36 or 32),0.5,-( isMobile and 15 or 13))
    closeBtn.BackgroundColor3 = C.BG3
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text          = "×"
    closeBtn.TextColor3    = C.GRAY
    closeBtn.Font          = Enum.Font.GothamBold
    closeBtn.TextSize      = isMobile and 20 or 17
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex        = 8
    corner(closeBtn, 8)
    stroke(closeBtn, C.GRAY_D, 1, 0.2)

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.12, {BackgroundColor3 = C.DANGER, TextColor3 = C.WHITE})
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.12, {BackgroundColor3 = C.BG3, TextColor3 = C.GRAY})
    end)

    -- page holder
    local pageHolder = Instance.new("Frame", contentArea)
    local topH = isMobile and 42 or 38
    pageHolder.Size          = UDim2.new(1,-PAD*2,1,-topH-PAD)
    pageHolder.Position      = UDim2.new(0,PAD,0,topH+PAD/2)
    pageHolder.BackgroundTransparency = 1
    pageHolder.ZIndex        = 3

    -- ── PAGE FACTORY ──────────────────────────────────────────
    local function newPage()
        local sf = Instance.new("ScrollingFrame", pageHolder)
        sf.Size          = UDim2.new(1,0,1,0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel  = 0
        sf.ScrollBarThickness = isMobile and 3 or 2
        sf.ScrollBarImageColor3 = C.ACCENT_LIT
        sf.ScrollBarImageTransparency = 0.25
        sf.CanvasSize    = UDim2.new(0,0,0,0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.ZIndex        = 4
        sf.Visible       = false
        local lay = Instance.new("UIListLayout", sf)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Padding   = UDim.new(0, isMobile and 5 or 4)
        return sf
    end

    local PAGES = {
        {name="Main",   icon="⚡"},
        {name="Combat", icon="⚔"},
        {name="Visual", icon="👁"},
        {name="Config", icon="⚙"},
    }
    for _, pg in ipairs(PAGES) do
        pg.page = newPage()
    end
    PAGES[1].page.Visible = true

    -- ── SECTION HEADER ────────────────────────────────────────
    local function secHeader(parent, title, order)
        local h = Instance.new("Frame", parent)
        h.Size          = UDim2.new(1,0,0, isMobile and 26 or 24)
        h.BackgroundTransparency = 1
        h.LayoutOrder   = order; h.ZIndex = 5
        -- linha azul esquerda
        local bar = Instance.new("Frame", h)
        bar.Size          = UDim2.new(0,3,0,12)
        bar.Position      = UDim2.new(0,0,0.5,-6)
        bar.BackgroundColor3 = C.ACCENT_LIT
        bar.BorderSizePixel  = 0; bar.ZIndex = 6
        corner(bar,2)
        local lbl = Instance.new("TextLabel", h)
        lbl.Size          = UDim2.new(1,-8,1,0)
        lbl.Position      = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text          = string.upper(title)
        lbl.TextColor3    = C.ACCENT_LIT
        lbl.Font          = Enum.Font.GothamBold
        lbl.TextSize      = FONT_XS
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex        = 6
        return h
    end

    -- ── DIVIDER ───────────────────────────────────────────────
    local function div(parent, order)
        local d = Instance.new("Frame", parent)
        d.Size          = UDim2.new(1,0,0,1)
        d.BackgroundColor3 = C.ACCENT_DIM
        d.BackgroundTransparency = 0.55
        d.BorderSizePixel  = 0
        d.LayoutOrder   = order; d.ZIndex = 5
        return d
    end

    -- ── TOGGLE ROW ────────────────────────────────────────────
    local function toggleRow(parent, label, default, order, cb)
        local row = Instance.new("Frame", parent)
        row.Size          = UDim2.new(1,0,0,ROW_H)
        row.BackgroundColor3 = C.BG3
        row.BorderSizePixel  = 0
        row.LayoutOrder   = order; row.ZIndex = 5
        corner(row, 8)
        stroke(row, C.GRAY_D, 1, 0.3)

        -- label
        local lbl = Instance.new("TextLabel", row)
        lbl.Size          = UDim2.new(1,-60,1,0)
        lbl.Position      = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text          = label
        lbl.TextColor3    = C.WHITE
        lbl.Font          = Enum.Font.Gotham
        lbl.TextSize      = FONT_M
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate  = Enum.TextTruncate.AtEnd
        lbl.ZIndex        = 6

        -- pill
        local pillW = isMobile and 46 or 40
        local pillH = isMobile and 26 or 22
        local knobS = isMobile and 20 or 16
        local pill = Instance.new("Frame", row)
        pill.Size          = UDim2.new(0,pillW,0,pillH)
        pill.Position      = UDim2.new(1,-(pillW+8),0.5,-pillH/2)
        pill.BackgroundColor3 = default and C.ACCENT or C.GRAY_D
        pill.BorderSizePixel  = 0; pill.ZIndex = 6
        corner(pill, pillH/2)

        local knob = Instance.new("Frame", pill)
        knob.Size          = UDim2.new(0,knobS,0,knobS)
        knob.Position      = default
            and UDim2.new(1,-(knobS+3),0.5,-knobS/2)
            or  UDim2.new(0,3,0.5,-knobS/2)
        knob.BackgroundColor3 = C.WHITE
        knob.BorderSizePixel  = 0; knob.ZIndex = 7
        corner(knob, knobS/2)

        local state = default
        local btn = Instance.new("TextButton", pill)
        btn.Size          = UDim2.new(1,0,1,0)
        btn.BackgroundTransparency = 1
        btn.Text          = ""; btn.ZIndex = 8
        btn.MouseButton1Click:Connect(function()
            state = not state
            tween(pill, 0.17, {BackgroundColor3 = state and C.ACCENT or C.GRAY_D})
            tween(knob, 0.17, {
                Position = state
                    and UDim2.new(1,-(knobS+3),0.5,-knobS/2)
                    or  UDim2.new(0,3,0.5,-knobS/2)
            })
            if cb then cb(state) end
        end)

        -- ripple no row ao toque (feedback mobile)
        if isMobile then
            local clickArea = Instance.new("TextButton", row)
            clickArea.Size          = UDim2.new(1,0,1,0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text          = ""; clickArea.ZIndex = 9
            clickArea.MouseButton1Click:Connect(function()
                state = not state
                tween(pill, 0.17, {BackgroundColor3 = state and C.ACCENT or C.GRAY_D})
                tween(knob, 0.17, {
                    Position = state
                        and UDim2.new(1,-(knobS+3),0.5,-knobS/2)
                        or  UDim2.new(0,3,0.5,-knobS/2)
                })
                if cb then cb(state) end
            end)
        end

        return row, function() return state end
    end

    -- ── VALUE ROW ─────────────────────────────────────────────
    local function valueRow(parent, label, val, order, valCol)
        local row = Instance.new("Frame", parent)
        row.Size          = UDim2.new(1,0,0,ROW_H)
        row.BackgroundColor3 = C.BG3
        row.BorderSizePixel  = 0
        row.LayoutOrder   = order; row.ZIndex = 5
        corner(row, 8)
        stroke(row, C.GRAY_D, 1, 0.3)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size          = UDim2.new(0.6,0,1,0)
        lbl.Position      = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text          = label
        lbl.TextColor3    = C.WHITE
        lbl.Font          = Enum.Font.Gotham
        lbl.TextSize      = FONT_M
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate  = Enum.TextTruncate.AtEnd
        lbl.ZIndex        = 6
        local vlbl = Instance.new("TextLabel", row)
        vlbl.Size          = UDim2.new(0.38,-8,1,0)
        vlbl.Position      = UDim2.new(0.62,0,0,0)
        vlbl.BackgroundTransparency = 1
        vlbl.Text          = tostring(val)
        vlbl.TextColor3    = valCol or C.ACCENT_LIT
        vlbl.Font          = Enum.Font.GothamBold
        vlbl.TextSize      = FONT_S
        vlbl.TextXAlignment = Enum.TextXAlignment.Right
        vlbl.ZIndex        = 6
        return row, vlbl
    end

    -- ── BUTTON ROW ────────────────────────────────────────────
    local function btnRow(parent, label, bLabel, order, bCol, cb)
        local row = Instance.new("Frame", parent)
        row.Size          = UDim2.new(1,0,0,ROW_H)
        row.BackgroundColor3 = C.BG3
        row.BorderSizePixel  = 0
        row.LayoutOrder   = order; row.ZIndex = 5
        corner(row, 8)
        stroke(row, C.GRAY_D, 1, 0.3)
        local lbl = Instance.new("TextLabel", row)
        lbl.Size          = UDim2.new(0.55,0,1,0)
        lbl.Position      = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1
        lbl.Text          = label
        lbl.TextColor3    = C.WHITE
        lbl.Font          = Enum.Font.Gotham
        lbl.TextSize      = FONT_M
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex        = 6
        local bW = isMobile and 80 or 70
        local bH = isMobile and 30 or 24
        local btn = Instance.new("TextButton", row)
        btn.Size          = UDim2.new(0,bW,0,bH)
        btn.Position      = UDim2.new(1,-(bW+8),0.5,-bH/2)
        btn.BackgroundColor3 = bCol or C.ACCENT
        btn.BorderSizePixel  = 0
        btn.Text          = bLabel
        btn.TextColor3    = C.WHITE
        btn.Font          = Enum.Font.GothamBold
        btn.TextSize      = FONT_S
        btn.AutoButtonColor = false
        btn.ZIndex        = 6
        corner(btn, 7)
        btn.MouseEnter:Connect(function() tween(btn,0.12,{BackgroundColor3=C.ACCENT_LIT}) end)
        btn.MouseLeave:Connect(function() tween(btn,0.12,{BackgroundColor3=bCol or C.ACCENT}) end)
        if cb then btn.MouseButton1Click:Connect(cb) end
        return row
    end

    -- ── TAB BUTTONS ───────────────────────────────────────────
    local activeTab = nil

    for i, td in ipairs(PAGES) do
        local btn = Instance.new("TextButton", tabList)
        btn.Size          = UDim2.new(1,0,0,TAB_H)
        btn.BackgroundColor3 = C.BG
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel  = 0
        btn.Text          = ""
        btn.AutoButtonColor = false
        btn.LayoutOrder   = i
        btn.ZIndex        = 5
        -- sem corner no tab (sangra até as bordas laterais da sidebar)

        -- indicador azul esquerdo (ativo)
        local indicator = Instance.new("Frame", btn)
        indicator.Size          = UDim2.new(0,3,0.55,0)
        indicator.Position      = UDim2.new(0,0,0.225,0)
        indicator.BackgroundColor3 = C.ACCENT_LIT
        indicator.BorderSizePixel  = 0
        indicator.BackgroundTransparency = 1
        indicator.ZIndex        = 6
        corner(indicator, 2)

        -- ícone centralizado no mobile, ícone + texto no PC
        local iconLbl = Instance.new("TextLabel", btn)
        iconLbl.Size          = UDim2.new(1,0,0, isMobile and 22 or TAB_H)
        iconLbl.Position      = UDim2.new(0,0,0, isMobile and 6 or 0)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Text          = td.icon
        iconLbl.TextColor3    = C.GRAY
        iconLbl.Font          = Enum.Font.GothamBold
        iconLbl.TextSize      = isMobile and 18 or 14
        iconLbl.ZIndex        = 6

        if not isMobile then
            local nameLbl = Instance.new("TextLabel", btn)
            nameLbl.Size          = UDim2.new(1,-6,1,0)
            nameLbl.Position      = UDim2.new(0,6,0,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text          = "  " .. td.icon .. "  " .. td.name
            nameLbl.TextColor3    = C.GRAY
            nameLbl.Font          = Enum.Font.GothamBold
            nameLbl.TextSize      = FONT_S
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.ZIndex        = 6
            iconLbl.Visible       = false
            td.nameLbl            = nameLbl
        end

        if isMobile then
            local mNameLbl = Instance.new("TextLabel", btn)
            mNameLbl.Size          = UDim2.new(1,0,0,12)
            mNameLbl.Position      = UDim2.new(0,0,1,-14)
            mNameLbl.BackgroundTransparency = 1
            mNameLbl.Text          = td.name
            mNameLbl.TextColor3    = C.GRAY
            mNameLbl.Font          = Enum.Font.Gotham
            mNameLbl.TextSize      = 9
            mNameLbl.ZIndex        = 6
            td.mNameLbl            = mNameLbl
        end

        td.btn       = btn
        td.indicator = indicator
        td.iconLbl   = iconLbl

        local function activate(silent)
            if activeTab then
                -- desativa anterior
                tween(activeTab.indicator, 0.15, {BackgroundTransparency = 1})
                tween(activeTab.btn, 0.15, {BackgroundColor3 = C.BG, BackgroundTransparency = 0})
                if activeTab.nameLbl then tween(activeTab.nameLbl, 0.15, {TextColor3 = C.GRAY}) end
                if activeTab.mNameLbl then tween(activeTab.mNameLbl, 0.15, {TextColor3 = C.GRAY}) end
                if activeTab.iconLbl then tween(activeTab.iconLbl, 0.15, {TextColor3 = C.GRAY}) end
                activeTab.page.Visible = false
            end
            activeTab = td
            tween(btn, 0.15, {BackgroundColor3 = C.BG3, BackgroundTransparency = 0})
            tween(indicator, 0.15, {BackgroundTransparency = 0})
            if td.nameLbl then tween(td.nameLbl, 0.15, {TextColor3 = C.WHITE}) end
            if td.mNameLbl then tween(td.mNameLbl, 0.15, {TextColor3 = C.ACCENT_LIT}) end
            if td.iconLbl then tween(td.iconLbl, 0.15, {TextColor3 = C.ACCENT_LIT}) end
            td.page.Visible = true
            pageTitle.Text  = td.name
        end

        btn.MouseButton1Click:Connect(activate)
        if i == 1 then activate(true) end
    end

    -- ── CONTEÚDO ──────────────────────────────────────────────
    -- helper local de ordem
    local function fill(page, items)
        local o = 0
        for _, item in ipairs(items) do
            o = o + 1
            local t = item[1]
            if t == "sec" then
                secHeader(page, item[2], o)
            elseif t == "div" then
                div(page, o)
            elseif t == "tog" then
                toggleRow(page, item[2], item[3] or false, o)
            elseif t == "val" then
                valueRow(page, item[2], item[3], o, item[4])
            elseif t == "btn" then
                btnRow(page, item[2], item[3], o, item[4])
            end
        end
    end

    -- MAIN
    fill(PAGES[1].page, {
        {"sec","Speed"},
        {"tog","Speed Bypass",        false},
        {"tog","Lagger",              false},
        {"val","Normal Speed",        "55"},
        {"val","Carry Speed",         "28.5"},
        {"tog","Infinity Jump",       false},
        {"tog","Unwalk",              false},
        {"div"},
        {"sec","Steal"},
        {"tog","Auto Steal",          false},
        {"val","Steal Radius",        "10"},
        {"div"},
        {"sec","Movement"},
        {"tog","Auto Left",           false},
        {"tog","Auto Right",          false},
        {"tog","Auto TP Down",        false},
        {"tog","Doge Mode",           false},
        {"tog","Walk Through Players",false},
    })

    -- COMBAT
    fill(PAGES[2].page, {
        {"sec","Aimbot"},
        {"tog","Bat Aimbot",          false},
        {"tog","Bat Aimbot V2",       false},
        {"tog","Bat Aimbot V3",       false},
        {"tog","Bat Aimbot Envy",     false},
        {"tog","Bat Aimbot Kronos",   false},
        {"val","Aimbot Speed",        "58"},
        {"div"},
        {"sec","Counter"},
        {"tog","Bat Counter",         false},
        {"tog","Medusa Counter",      false},
        {"div"},
        {"sec","Anti"},
        {"tog","Anti Die",            true},
        {"tog","Anti Bat",            false},
        {"tog","Anti Bee",            false},
        {"tog","Anti Fling",          false},
        {"div"},
        {"sec","Misc"},
        {"tog","Body Lock",           false},
        {"tog","Bat Spam",            false},
        {"tog","Bat From Front",      false},
        {"tog","Cap Aimbot",          false},
        {"tog","Anti Ragdoll V1",     false},
        {"tog","Anti Ragdoll V2",     false},
    })

    -- VISUAL
    fill(PAGES[3].page, {
        {"sec","ESP"},
        {"tog","Player ESP",          false},
        {"tog","FOV Circle",          false},
        {"div"},
        {"sec","World"},
        {"tog","Xray",                false},
        {"tog","Dark Sky",            false},
        {"tog","Galaxy Sky Bright",   false},
        {"tog","Remove Accessories",  false},
        {"div"},
        {"sec","HUD"},
        {"tog","Show Speed",          true},
        {"tog","Show Ragdoll",        false},
    })

    -- CONFIG
    fill(PAGES[4].page, {
        {"sec","Settings"},
        {"btn","Save Config",   "Save",  C.ACCENT},
        {"btn","Load Config",   "Load",  C.ACCENT},
        {"btn","Reset Config",  "Reset", C.DANGER},
        {"div"},
        {"sec","Auto"},
        {"tog","Auto Save",           true},
        {"div"},
        {"sec","Info"},
        {"val","Version",       "1.0.0", C.GRAY},
        {"val","Status",        "Loaded",C.SUCCESS},
    })

    -- ── MINI BUTTON ───────────────────────────────────────────
    local mini = Instance.new("TextButton", gui)
    mini.Size          = UDim2.new(0, isMobile and 120 or 130, 0, isMobile and 34 or 28)
    mini.Position      = UDim2.new(1,-(isMobile and 136 or 146), 0, isMobile and 28 or 22)
    mini.BackgroundColor3 = C.ACCENT_DIM
    mini.BorderSizePixel  = 0
    mini.Text          = "⚡ Wraith Duels"
    mini.TextColor3    = C.WHITE
    mini.Font          = Enum.Font.GothamBold
    mini.TextSize      = isMobile and 12 or 11
    mini.Visible       = false
    mini.ZIndex        = 30
    corner(mini, 17)
    stroke(mini, C.ACCENT, 1.2, 0.1)
    drag(mini)

    closeBtn.MouseButton1Click:Connect(function()
        main.Visible   = false
        shadow.Visible = false
        mini.Visible   = true
    end)
    mini.MouseButton1Click:Connect(function()
        main.Visible   = true
        shadow.Visible = true
        mini.Visible   = false
    end)

    -- PC: LeftCtrl toggle
    if not isMobile then
        UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.KeyCode == Enum.KeyCode.LeftControl then
                local v = not main.Visible
                main.Visible   = v
                shadow.Visible = v
                mini.Visible   = not v
            end
        end)
    end
end

local ok, err = pcall(build)
if not ok then warn("[WraithDuels] " .. tostring(err)) end
