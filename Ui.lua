local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")

local NewInstance      = Instance.new
local FromRGB          = Color3.fromRGB
local UDim2New         = UDim2.new
local Vector2New       = Vector2.new
local UDimNew          = UDim.new
local ClampMath        = math.clamp
local FloorMath        = math.floor
local RandMath         = math.random

local Library = {
    Flags    = {},
    _windows = {},
}

local function Create(class, props, children)
    local inst = NewInstance(class)
    for k, v in next, props do
        inst[k] = v
    end
    if children then
        for _, child in next, children do
            child.Parent = inst
        end
    end
    return inst
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function RandStr(len)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local out = {}
    for i = 1, len do
        out[i] = chars:sub(RandMath(1, #chars), RandMath(1, #chars))
    end
    return table.concat(out)
end

local function GetGuiParent()
    if gethui then return gethui() end
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    return ok and cg or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local TQ  = TweenInfo.new(0.14, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TM  = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TS  = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local T = {
    Bg          = FromRGB(13,  13,  20),
    Surface     = FromRGB(22,  22,  32),
    SurfaceAlt  = FromRGB(30,  30,  44),
    Border      = FromRGB(50,  50,  72),
    BorderHi    = FromRGB(75,  75, 110),
    Accent      = FromRGB(99, 102, 241),
    AccentHi    = FromRGB(129, 132, 255),
    AccentLo    = FromRGB(58,  60, 180),
    Text        = FromRGB(238, 238, 255),
    TextMuted   = FromRGB(130, 130, 165),
    TextDim     = FromRGB(75,  75, 110),
    Success     = FromRGB(52,  211, 153),
    Warning     = FromRGB(251, 191,  36),
    Error       = FromRGB(239,  68,  68),
    TabBg       = FromRGB(16,  16,  26),
    TabActive   = FromRGB(32,  32,  50),
    ToggleOff   = FromRGB(48,  48,  70),
    ToggleOn    = FromRGB(99, 102, 241),
    SliderBg    = FromRGB(32,  32,  50),
    InputBg     = FromRGB(16,  16,  28),
}

local _NotifGui, _NotifList
do
    _NotifGui = Create("ScreenGui", {
        Name             = RandStr(14),
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        DisplayOrder     = 9999,
        Parent           = GetGuiParent(),
    })
    if cloneref then _NotifGui = cloneref(_NotifGui) end

    _NotifList = Create("Frame", {
        Name                = "NotifList",
        Parent              = _NotifGui,
        BackgroundTransparency = 1,
        AnchorPoint         = Vector2New(1, 1),
        Position            = UDim2New(1, -16, 1, -16),
        Size                = UDim2New(0, 300, 1, -16),
    }, {
        Create("UIListLayout", {
            SortOrder           = Enum.SortOrder.LayoutOrder,
            VerticalAlignment   = Enum.VerticalAlignment.Bottom,
            Padding             = UDimNew(0, 8),
        })
    })
end

function Library:Notify(opts)
    opts = opts or {}
    local title    = opts.Title   or "Notice"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4
    local kind     = opts.Type    or "Info"

    local accent = kind == "Success" and T.Success or kind == "Warning" and T.Warning or kind == "Error" and T.Error or T.Accent

    local card = Create("Frame", {
        Parent                 = _NotifList,
        BackgroundColor3       = T.Surface,
        BackgroundTransparency = 1,
        Size                   = UDim2New(1, 0, 0, 0),
        AutomaticSize          = Enum.AutomaticSize.Y,
        ClipsDescendants       = false,
    }, {
        Create("UICorner",  { CornerRadius = UDimNew(0, 10) }),
        Create("UIStroke",  { Color = accent, Thickness = 1, Transparency = 0.45 }),
        Create("UIGradient",{
            Color    = ColorSequence.new{ColorSequenceKeypoint.new(0, FromRGB(30, 30, 46)), ColorSequenceKeypoint.new(1, FromRGB(16, 16, 28))},
            Rotation = 90,
        }),
        Create("Frame", { BackgroundColor3 = accent, Size = UDim2New(0, 3, 1, 0) }, { Create("UICorner", { CornerRadius = UDimNew(0, 6) }) }),
        Create("Frame", {
            BackgroundTransparency = 1,
            Position               = UDim2New(0, 14, 0, 0),
            Size                   = UDim2New(1, -18, 1, 0),
            AutomaticSize          = Enum.AutomaticSize.Y,
        }, {
            Create("UIPadding", { PaddingTop = UDimNew(0, 10), PaddingBottom = UDimNew(0, 10), PaddingRight = UDimNew(0, 6) }),
            Create("TextLabel", { Name = "Title", Text = title, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2New(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left }),
            Create("TextLabel", { Name = "Body", Text = content, TextColor3 = T.TextMuted, TextSize = 12, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0, 0, 0, 20), Size = UDim2New(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true }),
        }),
    })

    Tween(card, TM, { BackgroundTransparency = 0.06 })

    task.delay(duration, function()
        Tween(card, TM, { BackgroundTransparency = 1 })
        task.delay(0.3, function() card:Destroy() end)
    end)
end

local DEFAULT_PATH = "UILibrary"

local function SafeDir(path)
    pcall(function()
        if not isfolder(path) then makefolder(path) end
    end)
end

function Library:SaveConfig(name, path)
    name = tostring(name or "default")
    path = path or DEFAULT_PATH
    SafeDir(path)
    local data = {}
    for flag, ctrl in next, self.Flags do
        if not flag:sub(1, 2) == "__" and ctrl and ctrl.GetValue then
            pcall(function() data[flag] = ctrl:GetValue() end)
        end
    end
    local ok, err = pcall(function()
        writefile(path .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end)
    if ok then
        Library:Notify({ Title = "Config Saved", Content = '"' .. name .. '" saved successfully.', Duration = 3, Type = "Success" })
    else
        Library:Notify({ Title = "Save Failed", Content = tostring(err), Duration = 4, Type = "Error" })
    end
end

function Library:LoadConfig(name, path)
    name = tostring(name or "default")
    path = path or DEFAULT_PATH
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(path .. "/" .. name .. ".json"))
    end)
    if ok and type(result) == "table" then
        for flag, val in next, result do
            local ctrl = self.Flags[flag]
            if ctrl and ctrl.SetValue then pcall(ctrl.SetValue, ctrl, val) end
        end
        Library:Notify({ Title = "Config Loaded", Content = '"' .. name .. '" applied.', Duration = 3, Type = "Success" })
        return true
    else
        if name ~= "autosave" then
            Library:Notify({ Title = "Load Failed", Content = "File missing or corrupted.", Duration = 4, Type = "Error" })
        end
        return false
    end
end

function Library:GetConfigs(path)
    path = path or DEFAULT_PATH
    local list = {}
    pcall(function()
        for _, f in next, listfiles(path) do
            local n = f:match("([^/\\]+)%.json$")
            if n and n ~= "autosave" then table.insert(list, n) end
        end
    end)
    return list
end

function Library:DeleteConfig(name, path)
    name = tostring(name or "default")
    path = path or DEFAULT_PATH
    local ok, err = pcall(delfile, path .. "/" .. name .. ".json")
    if ok then
        Library:Notify({ Title = "Config Deleted", Content = '"' .. name .. '" removed.', Duration = 3, Type = "Warning" })
    else
        Library:Notify({ Title = "Delete Failed", Content = tostring(err), Duration = 4, Type = "Error" })
    end
end

function Library:CreateWindow(opts)
    opts = opts or {}
    local winTitle  = opts.Title    or "UI Library"
    local winSub    = opts.SubTitle or ""
    local winSize   = opts.Size     or UDim2New(0, 720, 0, 560)
    local winPath   = opts.Path     or DEFAULT_PATH
    local cfgUi     = opts.ConfigUi or {}
    local builtIn   = cfgUi.BuiltInSettings ~= false
    local TAB_W     = 155

    local Window = {
        _tabs          = {},
        _active        = nil,
        _onLoad        = {},
        _onUnload      = {},
        _onTabChanged  = {},
        _configPath    = winPath,
    }

    local Gui = Create("ScreenGui", { Name = RandStr(16), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100 })
    if cloneref then Gui = cloneref(Gui) end
    Gui.Parent = GetGuiParent()

    local ShadowImg = Create("ImageLabel", {
        Name = "Shadow", Parent = Gui, BackgroundTransparency = 1,
        Image = "rbxassetid://6014054959", ImageColor3 = FromRGB(0,0,0), ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49,49,450,450),
        AnchorPoint = Vector2New(0.5,0.5), Position = UDim2New(0.5,0,0.5,0),
        Size = UDim2New(winSize.X.Scale, winSize.X.Offset + 50, winSize.Y.Scale, winSize.Y.Offset + 50),
        ZIndex = 0,
    })

    local Main = Create("Frame", {
        Name = "Main", Parent = Gui, BackgroundColor3 = T.Bg,
        AnchorPoint = Vector2New(0.5,0.5), Position = UDim2New(0.5,0,0.5,0),
        Size = winSize, ClipsDescendants = false,
    }, {
        Create("UICorner", { CornerRadius = UDimNew(0, 14) }),
        Create("UIStroke", { Color = T.Border, Thickness = 1.2, Transparency = 0.25 }),
        Create("UIGradient",{ Color = ColorSequence.new{ColorSequenceKeypoint.new(0, FromRGB(24,24,36)), ColorSequenceKeypoint.new(1, FromRGB(12,12,20))}, Rotation = 135 }),
    })

    local TBar = Create("Frame", {
        Name = "TitleBar", Parent = Main, BackgroundColor3 = T.SurfaceAlt,
        Size = UDim2New(1,0,0,52), ZIndex = 5,
    }, {
        Create("UICorner", { CornerRadius = UDimNew(0, 14) }),
        Create("UIGradient",{ Color = ColorSequence.new{ColorSequenceKeypoint.new(0, FromRGB(36,36,56)), ColorSequenceKeypoint.new(1, FromRGB(20,20,34))}, Rotation = 90 }),
    })

    Create("Frame", { Parent = TBar, BackgroundColor3 = T.SurfaceAlt, Size = UDim2New(1,0,0,14), Position = UDim2New(0,0,1,-14), ZIndex = 4 })
    Create("Frame", { Parent = TBar, BackgroundColor3 = T.Border, BackgroundTransparency = 0.5, Size = UDim2New(1,0,0,1), Position = UDim2New(0,0,1,-1), ZIndex = 6 })

    local logoOff = 14
    if opts.Logo and opts.Logo ~= "" then
        Create("ImageLabel", { Parent = TBar, BackgroundTransparency = 1, Image = opts.Logo, Size = UDim2New(0,28,0,28), Position = UDim2New(0,14,0.5,-14), ZIndex = 6 })
        logoOff = 50
    end

    Create("TextLabel", { Parent = TBar, Text = winTitle, TextColor3 = T.Text, TextSize = 15, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Position = UDim2New(0, logoOff, 0, 9), Size = UDim2New(0.55,0,0,18), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 })
    if winSub ~= "" then
        Create("TextLabel", { Parent = TBar, Text = winSub, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0, logoOff, 0, 30), Size = UDim2New(0.55,0,0,14), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6 })
    end

    local function TBarBtn(xOff, bg, icon)
        local b = Create("TextButton", { Parent = TBar, BackgroundColor3 = bg, BackgroundTransparency = 0.75, Size = UDim2New(0,26,0,26), AnchorPoint = Vector2New(1,0.5), Position = UDim2New(1, xOff, 0.5, 0), Text = icon, TextColor3 = T.TextMuted, TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 7 }, { Create("UICorner", { CornerRadius = UDimNew(0, 7) }) })
        b.MouseEnter:Connect(function() Tween(b, TQ, { BackgroundTransparency = 0.25, TextColor3 = T.Text }) end)
        b.MouseLeave:Connect(function() Tween(b, TQ, { BackgroundTransparency = 0.75, TextColor3 = T.TextMuted }) end)
        return b
    end

    local CloseBtn = TBarBtn(-10, T.Error, "✕")
    local MinBtn   = TBarBtn(-42, T.Warning, "—")

    CloseBtn.MouseButton1Click:Connect(function() Window:Destroy() end)

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetH = minimized and 52 or winSize.Y.Offset
        Tween(Main, TM, { Size = UDim2New(winSize.X.Scale, winSize.X.Offset, winSize.Y.Scale, targetH) })
        Tween(ShadowImg, TM, { Size = UDim2New(winSize.X.Scale, winSize.X.Offset + 50, winSize.Y.Scale, targetH + 50) })
    end)

    do
        local drag, dStart, dOrigin = false
        TBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; dStart = i.Position; dOrigin = Main.Position
            end
        end)
        TBar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - dStart
                Main.Position = UDim2New(dOrigin.X.Scale, dOrigin.X.Offset + d.X, dOrigin.Y.Scale, dOrigin.Y.Offset + d.Y)
                ShadowImg.Position = Main.Position
            end
        end)
    end

    local Body = Create("Frame", { Parent = Main, BackgroundTransparency = 1, Position = UDim2New(0,0,0,52), Size = UDim2New(1,0,1,-52), ClipsDescendants = true })

    local Sidebar = Create("Frame", { Name = "Sidebar", Parent = Body, BackgroundColor3 = T.TabBg, Size = UDim2New(0, TAB_W, 1, 0) }, {
        Create("UIGradient",{ Color = ColorSequence.new{ColorSequenceKeypoint.new(0, FromRGB(20,20,32)), ColorSequenceKeypoint.new(1, FromRGB(13,13,22))}, Rotation = 180 }),
        Create("UIPadding", { PaddingTop = UDimNew(0,10), PaddingBottom = UDimNew(0,10), PaddingLeft = UDimNew(0,7), PaddingRight = UDimNew(0,7) }),
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0,3) }),
    })

    Create("Frame", { Parent = Body, BackgroundColor3 = T.Border, BackgroundTransparency = 0.45, Position = UDim2New(0, TAB_W, 0, 0), Size = UDim2New(0,1,1,0), ZIndex = 2 })

    local Content = Create("Frame", { Name = "Content", Parent = Body, BackgroundTransparency = 1, Position = UDim2New(0, TAB_W + 1, 0, 0), Size = UDim2New(1, -(TAB_W + 1), 1, 0), ClipsDescendants = true })

    local function ActivateTab(tab)
        if Window._active == tab then return end
        if Window._active then
            local old = Window._active
            Tween(old._btn, TQ, { BackgroundColor3 = T.TabBg, BackgroundTransparency = 1 })
            old._btn._lbl.TextColor3 = T.TextMuted
            old._page.Visible = false
        end
        Window._active = tab
        tab._page.Visible = true
        Tween(tab._btn, TM, { BackgroundColor3 = T.TabActive, BackgroundTransparency = 0 })
        tab._btn._lbl.TextColor3 = T.Text
        for _, cb in next, Window._onTabChanged do pcall(cb, tab._name) end
    end

    function Window:CreateTab(name)
        local tab = { _name = name, _sections = {} }

        local btn = Create("TextButton", { Parent = Sidebar, BackgroundColor3 = T.TabBg, BackgroundTransparency = 1, Size = UDim2New(1,0,0,33), Text = "", AutoButtonColor = false }, { Create("UICorner", { CornerRadius = UDimNew(0,8) }) })
        local lbl = Create("TextLabel", { Parent = btn, Text = name, TextColor3 = T.TextMuted, TextSize = 12, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Size = UDim2New(1,-10,1,0), Position = UDim2New(0,10,0,0), TextXAlignment = Enum.TextXAlignment.Left })
        btn._lbl = lbl

        btn.MouseEnter:Connect(function() if Window._active ~= tab then Tween(btn, TQ, { BackgroundTransparency = 0.65, BackgroundColor3 = T.TabActive }) end end)
        btn.MouseLeave:Connect(function() if Window._active ~= tab then Tween(btn, TQ, { BackgroundTransparency = 1 }) end end)
        btn.MouseButton1Click:Connect(function() ActivateTab(tab) end)
        tab._btn = btn

        local page = Create("ScrollingFrame", {
            Name = "Page_"..name, Parent = Content, BackgroundTransparency = 1, Size = UDim2New(1,0,1,0),
            ScrollBarThickness = 3, ScrollBarImageColor3 = T.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, BorderSizePixel = 0,
        }, {
            Create("UIPadding", { PaddingTop = UDimNew(0,10), PaddingBottom = UDimNew(0,10), PaddingLeft = UDimNew(0,10), PaddingRight = UDimNew(0,10) }),
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0,8), FillDirection = Enum.FillDirection.Horizontal, Wraps = true }),
        })
        tab._page = page

        function tab:CreateSection(sectionTitle, side)
            side = side or "Left"
            local sWidth = (side == "Full") and UDim2New(1,0,0,0) or UDim2New(0.5,-5,0,0)

            local secFrame = Create("Frame", {
                Parent = page, BackgroundColor3 = T.Surface, BackgroundTransparency = 0.08,
                Size = sWidth, AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = side == "Right" and 2 or 1,
            }, {
                Create("UICorner", { CornerRadius = UDimNew(0,10) }),
                Create("UIStroke", { Color = T.Border, Thickness = 1, Transparency = 0.55 }),
                Create("UIPadding", { PaddingTop = UDimNew(0,8), PaddingBottom = UDimNew(0,10), PaddingLeft = UDimNew(0,10), PaddingRight = UDimNew(0,10) }),
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0,6) }),
            })

            if sectionTitle and sectionTitle ~= "" then
                Create("TextLabel", { Parent = secFrame, Text = sectionTitle:upper(), TextColor3 = T.TextDim, TextSize = 10, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Size = UDim2New(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 0 })
                Create("Frame", { Parent = secFrame, BackgroundColor3 = T.Border, BackgroundTransparency = 0.55, Size = UDim2New(1,0,0,1), LayoutOrder = 1 })
            end

            local Section = {}
            local _order = 9
            local function Order() _order = _order + 1; return _order end

            function Section:CreateToggle(flagName, cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Toggle"
                local dsc = cfg.Description or ""
                local def = cfg.Default or false
                local cb = cfg.Callback or function() end
                local state = def

                local rowH = dsc ~= "" and 46 or 34
                local row = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,rowH), LayoutOrder = Order() })
                local titleLbl = Create("TextLabel", { Parent = row, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,0,0,0), Size = UDim2New(1,-52,0,18), TextXAlignment = Enum.TextXAlignment.Left })
                if dsc ~= "" then
                    Create("TextLabel", { Parent = row, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,0,0,20), Size = UDim2New(1,-52,0,14), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
                end

                local track = Create("Frame", { Parent = row, BackgroundColor3 = state and T.ToggleOn or T.ToggleOff, Size = UDim2New(0,38,0,20), Position = UDim2New(1,-42,0.5,-10) }, { Create("UICorner", { CornerRadius = UDimNew(1,0) }) })
                local knob = Create("Frame", { Parent = track, BackgroundColor3 = T.Text, Size = UDim2New(0,14,0,14), Position = state and UDim2New(0,21,0.5,-7) or UDim2New(0,3,0.5,-7), ZIndex = 3 }, { Create("UICorner", { CornerRadius = UDimNew(1,0) }) })

                local click = Create("TextButton", { Parent = row, BackgroundTransparency = 1, Size = UDim2New(1,0,1,0), Text = "", ZIndex = 4 })

                local function SetState(v, silent)
                    state = v
                    Tween(track, TM, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff })
                    Tween(knob, TM, { Position = v and UDim2New(0,21,0.5,-7) or UDim2New(0,3,0.5,-7) })
                    if not silent then pcall(cb, state) end
                end

                click.MouseButton1Click:Connect(function() SetState(not state) end)

                local ctrl = { _type = "Toggle", _flagName = flagName }
                function ctrl:SetValue(v) SetState(v == true, true) end
                function ctrl:GetValue() return state end
                function ctrl:SetVisible(v) row.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() row:Destroy() end

                if flagName then Library.Flags[flagName] = ctrl end
                return ctrl
            end

            function Section:CreateButton(cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Button"
                local dsc = cfg.Description or ""
                local cb = cfg.Callback or function() end

                local h = dsc ~= "" and 50 or 34
                local btn = Create("TextButton", { Parent = secFrame, BackgroundColor3 = T.SurfaceAlt, Size = UDim2New(1,0,0,h), Text = "", AutoButtonColor = false, LayoutOrder = Order() }, {
                    Create("UICorner", { CornerRadius = UDimNew(0,8) }),
                    Create("UIStroke", { Color = T.BorderHi, Thickness = 1, Transparency = 0.7 }),
                    Create("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,FromRGB(36,36,54)), ColorSequenceKeypoint.new(1,FromRGB(22,22,38))}, Rotation = 90 }),
                })
                local titleLbl = Create("TextLabel", { Parent = btn, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,12,0,dsc~="" and 7 or 8), Size = UDim2New(1,-24,0,18), TextXAlignment = Enum.TextXAlignment.Left })
                if dsc ~= "" then
                    Create("TextLabel", { Parent = btn, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,12,0,27), Size = UDim2New(1,-24,0,14), TextXAlignment = Enum.TextXAlignment.Left })
                end

                btn.MouseEnter:Connect(function() Tween(btn,TQ,{BackgroundColor3=T.Accent}) end)
                btn.MouseLeave:Connect(function() Tween(btn,TQ,{BackgroundColor3=T.SurfaceAlt}) end)
                btn.MouseButton1Down:Connect(function() Tween(btn,TQ,{BackgroundColor3=T.AccentLo}) end)
                btn.MouseButton1Up:Connect(function() Tween(btn,TQ,{BackgroundColor3=T.Accent}) end)
                btn.MouseButton1Click:Connect(function() pcall(cb) end)

                local ctrl = {}
                function ctrl:SetVisible(v) btn.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() btn:Destroy() end
                return ctrl
            end

            function Section:CreateSlider(flagName, cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Slider"
                local dsc = cfg.Description or ""
                local minV = cfg.Min or 0
                local maxV = cfg.Max or 100
                local step = cfg.Step or 1
                local def = cfg.Default or minV
                local showV = cfg.ShowValue ~= false
                local cb = cfg.Callback or function() end
                local value = ClampMath(def, minV, maxV)

                local topY = dsc ~= "" and 36 or 22
                local rowH = topY + 28
                local row = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,rowH), LayoutOrder = Order() })

                local titleLbl = Create("TextLabel", { Parent = row, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,0,0,0), Size = UDim2New(1,-60,0,18), TextXAlignment = Enum.TextXAlignment.Left })
                local valLbl
                if showV then
                    valLbl = Create("TextLabel", { Parent = row, Text = tostring(value), TextColor3 = T.AccentHi, TextSize = 12, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Position = UDim2New(1,-55,0,0), Size = UDim2New(0,55,0,18), TextXAlignment = Enum.TextXAlignment.Right })
                end
                if dsc ~= "" then
                    Create("TextLabel", { Parent = row, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,0,0,20), Size = UDim2New(1,0,0,14), TextXAlignment = Enum.TextXAlignment.Left })
                end

                local track = Create("Frame", { Parent = row, BackgroundColor3 = T.SliderBg, Size = UDim2New(1,0,0,7), Position = UDim2New(0,0,0,topY+8) }, { Create("UICorner", { CornerRadius = UDimNew(1,0) }) })
                local fill = Create("Frame", { Parent = track, BackgroundColor3 = T.Accent, Size = UDim2New(0,0,1,0) }, { Create("UICorner", { CornerRadius = UDimNew(1,0) }), Create("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0,T.Accent), ColorSequenceKeypoint.new(1,T.AccentHi)} }) })
                local knob = Create("Frame", { Parent = track, BackgroundColor3 = T.Text, Size = UDim2New(0,13,0,13), Position = UDim2New(0,-6,0.5,-6), ZIndex = 3 }, { Create("UICorner", { CornerRadius = UDimNew(1,0) }), Create("UIStroke", { Color = T.Accent, Thickness = 2 }) })

                local function UpdateSlider(raw, silent)
                    local snapped = FloorMath((raw - minV) / step + 0.5) * step + minV
                    value = ClampMath(snapped, minV, maxV)
                    local pct = (value - minV) / (maxV - minV)
                    Tween(fill, TQ, { Size = UDim2New(pct, 0, 1, 0) })
                    Tween(knob, TQ, { Position = UDim2New(pct, -6, 0.5, -6) })
                    if valLbl then valLbl.Text = tostring(value) end
                    if not silent then pcall(cb, value) end
                end
                UpdateSlider(value, true)

                local dragging = false
                local function HandleMouse(inp)
                    local apos = track.AbsolutePosition
                    local asize = track.AbsoluteSize
                    local relX = ClampMath(inp.Position.X - apos.X, 0, asize.X)
                    UpdateSlider(minV + (relX / asize.X) * (maxV - minV))
                end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; HandleMouse(i) end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then HandleMouse(i) end
                end)

                local ctrl = { _type = "Slider", _flagName = flagName }
                function ctrl:SetValue(v) UpdateSlider(v, true) end
                function ctrl:GetValue() return value end
                function ctrl:SetVisible(v) row.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() row:Destroy() end

                if flagName then Library.Flags[flagName] = ctrl end
                return ctrl
            end

            function Section:CreateDropdown(flagName, cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Dropdown"
                local dsc = cfg.Description or ""
                local options = cfg.Options or {}
                local multi = cfg.Multi or false
                local cb = cfg.Callback or function() end
                local defVal = cfg.Default

                local sel
                if multi then sel = type(defVal) == "table" and defVal or {} else sel = defVal or options[1] end

                local isOpen = false
                local dropRef = nil

                local btnTop = dsc ~= "" and 38 or 22
                local container = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,btnTop+34), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = false, LayoutOrder = Order(), ZIndex = 5 })

                local titleLbl = Create("TextLabel", { Parent = container, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,0,0,0), Size = UDim2New(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
                if dsc ~= "" then
                    Create("TextLabel", { Parent = container, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,0,0,20), Size = UDim2New(1,0,0,14), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5 })
                end

                local dropBtn = Create("TextButton", { Parent = container, BackgroundColor3 = T.InputBg, Size = UDim2New(1,0,0,30), Position = UDim2New(0,0,0,btnTop), Text = "", AutoButtonColor = false, ZIndex = 5 }, {
                    Create("UICorner", { CornerRadius = UDimNew(0,8) }),
                    Create("UIStroke", { Color = T.Border, Thickness = 1, Transparency = 0.4 }),
                })
                local selLbl = Create("TextLabel", { Parent = dropBtn, TextColor3 = T.TextMuted, TextSize = 12, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,10,0,0), Size = UDim2New(1,-36,1,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6, Text = "Select..." })
                Create("TextLabel", { Parent = dropBtn, Text = "▾", TextColor3 = T.TextMuted, TextSize = 14, Font = Enum.Font.GothamBold, BackgroundTransparency = 1, Position = UDim2New(1,-26,0,0), Size = UDim2New(0,22,1,0), ZIndex = 6 })

                local chipRow
                if multi then
                    chipRow = Create("Frame", { Parent = container, BackgroundTransparency = 1, Position = UDim2New(0,0,0,btnTop+34), Size = UDim2New(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 5 }, {
                        Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDimNew(0,4), SortOrder = Enum.SortOrder.LayoutOrder })
                    })
                end

                local function RefreshDisplay()
                    if multi then
                        for _, c in next, chipRow:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
                        if #sel == 0 then
                            selLbl.Text = "Select..."; selLbl.TextColor3 = T.TextMuted
                        else
                            selLbl.Text = tostring(#sel) .. " selected"; selLbl.TextColor3 = T.Text
                            for _, opt in next, sel do
                                Create("Frame", { Parent = chipRow, BackgroundColor3 = T.Accent, BackgroundTransparency = 0.55, Size = UDim2New(0,0,0,20), AutomaticSize = Enum.AutomaticSize.X }, {
                                    Create("UICorner", { CornerRadius = UDimNew(0,6) }),
                                    Create("UIPadding", { PaddingLeft = UDimNew(0,6), PaddingRight = UDimNew(0,6) }),
                                    Create("TextLabel", { Text = opt, TextColor3 = T.Text, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Size = UDim2New(0,0,1,0), AutomaticSize = Enum.AutomaticSize.X })
                                })
                            end
                        end
                    else
                        selLbl.Text = sel or "Select..."; selLbl.TextColor3 = sel and T.Text or T.TextMuted
                    end
                end
                RefreshDisplay()

                local function CloseDropdown()
                    if dropRef then dropRef:Destroy(); dropRef = nil end
                    isOpen = false
                end

                local function OpenDropdown()
                    CloseDropdown()
                    isOpen = true
                    local abs = dropBtn.AbsolutePosition
                    local absS = dropBtn.AbsoluteSize
                    local guiP = Gui.AbsolutePosition
                    local listH = math.min(#options, 6) * 30 + 8

                    dropRef = Create("Frame", { Parent = Gui, BackgroundColor3 = T.SurfaceAlt, Size = UDim2New(0, absS.X, 0, listH), Position = UDim2New(0, abs.X - guiP.X, 0, abs.Y - guiP.Y + absS.Y + 4), ZIndex = 300, ClipsDescendants = true }, {
                        Create("UICorner", { CornerRadius = UDimNew(0,8) }),
                        Create("UIStroke", { Color = T.BorderHi, Thickness = 1, Transparency = 0.35 }),
                        Create("UIPadding", { PaddingTop = UDimNew(0,4), PaddingBottom = UDimNew(0,4), PaddingLeft = UDimNew(0,4), PaddingRight = UDimNew(0,4) }),
                        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDimNew(0,2) }),
                    })

                    for _, opt in next, options do
                        local isSel = multi and (table.find(sel, opt) ~= nil) or (sel == opt)
                        local ob = Create("TextButton", { Parent = dropRef, BackgroundColor3 = isSel and T.Accent or T.Surface, BackgroundTransparency = isSel and 0.5 or 0, Size = UDim2New(1,0,0,28), Text = opt, TextColor3 = isSel and T.Text or T.TextMuted, TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, ZIndex = 301 }, {
                            Create("UICorner", { CornerRadius = UDimNew(0,6) }),
                            Create("UIPadding", { PaddingLeft = UDimNew(0,8) }),
                        })
                        ob.MouseEnter:Connect(function() Tween(ob,TQ,{BackgroundColor3=T.Accent, BackgroundTransparency=0.5}) end)
                        ob.MouseLeave:Connect(function()
                            local s2 = multi and (table.find(sel,opt)~=nil) or sel==opt
                            Tween(ob,TQ,{ BackgroundColor3 = s2 and T.Accent or T.Surface, BackgroundTransparency = s2 and 0.5 or 0 })
                        end)
                        ob.MouseButton1Click:Connect(function()
                            if multi then
                                local idx = table.find(sel, opt)
                                if idx then table.remove(sel,idx) else table.insert(sel,opt) end
                                RefreshDisplay()
                                pcall(cb, sel)
                                CloseDropdown(); OpenDropdown()
                            else
                                sel = opt
                                RefreshDisplay()
                                pcall(cb, sel)
                                CloseDropdown()
                            end
                        end)
                    end
                end

                dropBtn.MouseButton1Click:Connect(function()
                    if isOpen then CloseDropdown() else OpenDropdown() end
                end)

                UserInputService.InputBegan:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                    if not (isOpen and dropRef) then return end
                    local p = i.Position
                    local ap = dropRef.AbsolutePosition
                    local as = dropRef.AbsoluteSize
                    if p.X < ap.X or p.X > ap.X + as.X or p.Y < ap.Y or p.Y > ap.Y + as.Y then CloseDropdown() end
                end)

                local ctrl = { _type = "Dropdown", _flagName = flagName, _options = options }
                function ctrl:SetValue(v)
                    if multi then sel = type(v)=="table" and v or {v} else sel = v end
                    RefreshDisplay()
                end
                function ctrl:GetValue() return sel end
                function ctrl:SetVisible(v) container.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() CloseDropdown(); container:Destroy() end

                if flagName then Library.Flags[flagName] = ctrl end
                return ctrl
            end

            function Section:CreateKeybind(flagName, cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Keybind"
                local def = cfg.Default or Enum.KeyCode.Unknown
                local cb = cfg.Callback or function() end
                local cur = def
                local listening = false

                local row = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,34), LayoutOrder = Order() })
                local titleLbl = Create("TextLabel", { Parent = row, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,0,0,0), Size = UDim2New(1,-100,1,0), TextXAlignment = Enum.TextXAlignment.Left })
                local kBtn = Create("TextButton", { Parent = row, BackgroundColor3 = T.InputBg, Size = UDim2New(0,88,0,24), AnchorPoint = Vector2New(1,0.5), Position = UDim2New(1,0,0.5,0), Text = cur.Name, TextColor3 = T.AccentHi, TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false }, {
                    Create("UICorner", { CornerRadius = UDimNew(0,6) }),
                    Create("UIStroke", { Color = T.Border, Thickness = 1, Transparency = 0.5 }),
                })

                kBtn.MouseButton1Click:Connect(function()
                    listening = true
                    kBtn.Text = "..."
                    kBtn.TextColor3 = T.Warning
                end)
                UserInputService.InputBegan:Connect(function(i, gp)
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        cur = i.KeyCode
                        kBtn.Text = cur.Name
                        kBtn.TextColor3 = T.AccentHi
                        pcall(cb, cur)
                    elseif not gp and not listening and i.KeyCode == cur then
                        pcall(cb, cur)
                    end
                end)

                local ctrl = { _type = "Keybind", _flagName = flagName }
                function ctrl:SetValue(v) cur = v; kBtn.Text = v.Name end
                function ctrl:GetValue() return cur end
                function ctrl:SetVisible(v) row.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() row:Destroy() end

                if flagName then Library.Flags[flagName] = ctrl end
                return ctrl
            end

            function Section:CreateTextbox(flagName, cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or "Textbox"
                local dsc = cfg.Description or ""
                local def = cfg.Default or ""
                local cb = cfg.Callback or function() end
                local val = def

                local topY = dsc ~= "" and 36 or 22
                local row = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,topY+30), LayoutOrder = Order() })
                local titleLbl = Create("TextLabel", { Parent = row, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Position = UDim2New(0,0,0,0), Size = UDim2New(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left })
                if dsc ~= "" then
                    Create("TextLabel", { Parent = row, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,0,0,20), Size = UDim2New(1,0,0,14), TextXAlignment = Enum.TextXAlignment.Left })
                end
                local bg = Create("Frame", { Parent = row, BackgroundColor3 = T.InputBg, Size = UDim2New(1,0,0,26), Position = UDim2New(0,0,0,topY) }, {
                    Create("UICorner", { CornerRadius = UDimNew(0,7) }),
                    Create("UIStroke", { Color = T.Border, Thickness = 1, Transparency = 0.5 }),
                })
                local box = Create("TextBox", { Parent = bg, BackgroundTransparency = 1, Size = UDim2New(1,-18,1,0), Position = UDim2New(0,9,0,0), Text = def, PlaceholderText = "Type here...", TextColor3 = T.Text, PlaceholderColor3 = T.TextDim, TextSize = 12, Font = Enum.Font.Gotham, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left })
                local stroke = bg:FindFirstChildOfClass("UIStroke")
                box.Focused:Connect(function() Tween(stroke,TQ,{Color=T.Accent, Transparency=0}) end)
                box.FocusLost:Connect(function()
                    Tween(stroke,TQ,{Color=T.Border, Transparency=0.5})
                    val = box.Text; pcall(cb, val)
                end)

                local ctrl = { _type = "Textbox", _flagName = flagName }
                function ctrl:SetValue(v) val = tostring(v); box.Text = val end
                function ctrl:GetValue() return val end
                function ctrl:SetVisible(v) row.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() row:Destroy() end

                if flagName then Library.Flags[flagName] = ctrl end
                return ctrl
            end

            function Section:CreateLabel(cfg)
                cfg = cfg or {}
                local ttl = cfg.Title or ""
                local dsc = cfg.Description or ""

                local row = Create("Frame", { Parent = secFrame, BackgroundTransparency = 1, Size = UDim2New(1,0,0,dsc~="" and 34 or 20), LayoutOrder = Order() })
                local titleLbl = Create("TextLabel", { Parent = row, Text = ttl, TextColor3 = T.Text, TextSize = 13, Font = Enum.Font.GothamSemibold, BackgroundTransparency = 1, Size = UDim2New(1,0,0,18), TextXAlignment = Enum.TextXAlignment.Left })
                local dscLbl
                if dsc ~= "" then
                    dscLbl = Create("TextLabel", { Parent = row, Text = dsc, TextColor3 = T.TextMuted, TextSize = 11, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Position = UDim2New(0,0,0,20), Size = UDim2New(1,0,0,14), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })
                end

                local ctrl = {}
                function ctrl:SetValue(v) titleLbl.Text = tostring(v) end
                function ctrl:GetValue() return titleLbl.Text end
                function ctrl:SetVisible(v) row.Visible = v end
                function ctrl:SetTitle(t) titleLbl.Text = t end
                function ctrl:SetDescription(d) if dscLbl then dscLbl.Text = d end end
                function ctrl:Destroy() row:Destroy() end
                return ctrl
            end

            function Section:CreateParagraph(text)
                local lbl = Create("TextLabel", { Parent = secFrame, Text = text, TextColor3 = T.TextMuted, TextSize = 12, Font = Enum.Font.Gotham, BackgroundTransparency = 1, Size = UDim2New(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, LayoutOrder = Order() })
                local ctrl = {}
                function ctrl:SetValue(v) lbl.Text = tostring(v) end
                function ctrl:GetValue() return lbl.Text end
                function ctrl:SetVisible(v) lbl.Visible = v end
                function ctrl:SetTitle(t) lbl.Text = t end
                function ctrl:SetDescription(d) end
                function ctrl:Destroy() lbl:Destroy() end
                return ctrl
            end

            return Section
        end

        table.insert(Window._tabs, tab)
        return tab
    end

    if builtIn then
        local stab = Window:CreateTab("⚙  Settings")
        local csec = stab:CreateSection("Config Manager", "Full")

        local nameBox = csec:CreateTextbox("__cfgName", { Title = "Config Name", Description = "Name to save or manage", Default = "MyConfig" })

        csec:CreateButton({ Title = "💾  Save Config", Description = "Save all current values to file", Callback = function()
            local n = nameBox:GetValue()
            if n and n ~= "" then Library:SaveConfig(n, Window._configPath) end
        end })

        local cfgDrop = csec:CreateDropdown("__cfgSelect", { Title = "Saved Configs", Description = "Pick a config to load or delete", Options = Library:GetConfigs(Window._configPath) })

        csec:CreateButton({ Title = "📂  Load Config", Callback = function()
            local s = cfgDrop:GetValue()
            if s and s ~= "" then Library:LoadConfig(s, Window._configPath) end
        end })

        csec:CreateButton({ Title = "🗑  Delete Config", Callback = function()
            local s = cfgDrop:GetValue()
            if s and s ~= "" then Library:DeleteConfig(s, Window._configPath); cfgDrop:SetValue(nil) end
        end })

        csec:CreateButton({ Title = "🔄  Refresh List", Callback = function()
            local fresh = Library:GetConfigs(Window._configPath)
            cfgDrop._options = fresh
            cfgDrop:SetValue(nil)
            Library:Notify({ Title = "Refreshed", Content = tostring(#fresh) .. " config(s) found.", Duration = 2 })
        end })
    end

    function Window:OnLoad(cb) table.insert(self._onLoad, cb) end
    function Window:OnUnload(cb) table.insert(self._onUnload, cb) end
    function Window:OnTabChanged(cb) table.insert(self._onTabChanged, cb) end

    function Window:Destroy()
        Library:SaveConfig("autosave", self._configPath)
        for _, cb in next, self._onUnload do pcall(cb) end
        Gui:Destroy()
    end

    task.defer(function()
        if #Window._tabs > 0 then ActivateTab(Window._tabs[1]) end
        for _, cb in next, Window._onLoad do pcall(cb) end
        Library:LoadConfig("autosave", Window._configPath)
    end)

    table.insert(Library._windows, Window)
    return Window
end

return Library
