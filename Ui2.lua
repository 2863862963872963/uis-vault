--[[
  Warp UI Library — Rewritten API
  ─────────────────────────────────────────────────────────────────────────────
  Usage:
    local Warp   = loadstring(...)()
    local Window = Warp:Window({
        Title    = "My Script",
        Subtitle = "v2.0",
        Size     = Vector2.new(880, 580),   -- optional
        Theme    = { Accent = Color3.fromRGB(255,100,50) }, -- optional overrides
    })
    Window:SetTransparency(0)          -- 0 = opaque .. 1 = fully transparent

    local Group   = Window:AddTabGroup("Navigation")
    local Tab     = Window:AddTab(Group, "Combat", "sword")
    local Section = Tab:AddSection("Targeting")

    local toggle = Section:AddToggle("AimbotEnabled", {
        Title    = "Aimbot",
        Desc     = "Locks onto targets",
        Default  = false,
        Callback = function(v) print(v) end,
    })
    toggle:Set(true)               -- API
    Warp.Flags["AimbotEnabled"]    -- same object

    Section:AddDropdown("AimbotMode", {
        Title    = "Mode",
        Options  = {"Head","Body","Legs"},
        Default  = "Head",
        Callback = function(v) print(v) end,
    })
    Section:AddMultiDropdown("Bones", {
        Title    = "Hitboxes",
        Options  = {"Head","Neck","Spine"},
        Default  = {},
        Callback = function(arr) end,
    })
    Section:AddButton("FireBtn", {
        Title      = "Trigger Bot",
        Desc       = "Auto-fires on target",
        ButtonText = "Execute",
        Icon       = "zap",
        Callback   = function() end,
    })
]]

-- ── Services & locals ──────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local Instance_new  = Instance.new
local Color3_RGB    = Color3.fromRGB
local UDim2_new     = UDim2.new
local UDim_new      = UDim.new
local Vector2_new   = Vector2.new
local math_clamp    = math.clamp
local table_insert  = table.insert
local pairs         = pairs
local ipairs        = ipairs
local type          = type

local UIFont = Font.new("rbxassetid://12187365977",
	Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local LocalPlayer = Players.LocalPlayer
local Hui         = LocalPlayer:WaitForChild("PlayerGui")

-- ── Icons (Footagesus/Icons) ───────────────────────────────────────────────
local Icons = {}
task.spawn(function()
	local ok, res = pcall(function()
		return loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/Footagesus/Icons/main/Icons.lua", true
			))()
	end)
	if ok and type(res) == "table" then Icons = res end
end)

local function GetIcon(name)
	if not name then return "" end
	if type(name) == "number" then return "rbxassetid://"..name end
	if type(name) == "string" then
		if name:match("^rbxassetid://") then return name end
		if name:match("^%d+$")          then return "rbxassetid://"..name end
		return Icons[name] or Icons[name:lower()] or ""
	end
	return ""
end

-- ── Library table ─────────────────────────────────────────────────────────
local Warp       = {}
Warp.__index     = Warp
Warp.Flags       = {}    -- global flag registry { [flagName] = elementObj }

-- ── Default theme ─────────────────────────────────────────────────────────
local DefaultTheme = {
	Background              = Color3_RGB(30,  30,  30),
	TopBar                  = Color3_RGB(22,  22,  22),
	TopBarBorder            = Color3_RGB(40,  40,  40),
	Sidebar                 = Color3_RGB(20,  20,  20),
	SidebarBorder           = Color3_RGB(38,  38,  38),
	TabIdle                 = Color3_RGB(140, 140, 140),
	TabHover                = Color3_RGB(224, 224, 224),
	TabActive               = Color3_RGB(255, 255, 255),
	TabActiveBg             = Color3_RGB(42,  42,  42),
	CategoryTitle           = Color3_RGB(85,  85,  85),
	PanelBg                 = Color3_RGB(30,  30,  30),
	SectionBg               = Color3_RGB(36,  36,  36),
	SectionBorder           = Color3_RGB(46,  46,  46),
	SectionHeader           = Color3_RGB(38,  38,  38),
	SectionTitle            = Color3_RGB(124, 77,  255),
	ElementRow              = Color3_RGB(40,  40,  40),
	ElementBorder           = Color3_RGB(50,  50,  50),
	ElementLabel            = Color3_RGB(240, 240, 240),
	ElementDesc             = Color3_RGB(106, 106, 106),
	Accent                  = Color3_RGB(124, 77,  255),
	AccentLight             = Color3_RGB(179, 157, 219),
	AccentGlass             = Color3_RGB(124, 77,  255),
	TextLabel               = Color3_RGB(180, 180, 180),
	TextLabelBg             = Color3_RGB(36,  36,  36),
	Divider                 = Color3_RGB(50,  50,  50),
	ToggleOff               = Color3_RGB(30,  30,  30),
	ToggleOffBorder         = Color3_RGB(58,  58,  58),
	ToggleOffKnob           = Color3_RGB(85,  85,  85),
	ToggleOnBg              = Color3_RGB(124, 77,  255),
	ToggleOnBorder          = Color3_RGB(149, 117, 205),
	ToggleOnKnob            = Color3_RGB(255, 255, 255),
	DropdownBox             = Color3_RGB(30,  30,  30),
	DropdownBorder          = Color3_RGB(58,  58,  58),
	DropdownText            = Color3_RGB(224, 224, 224),
	DropdownList            = Color3_RGB(22,  22,  22),
	DropdownListBorder      = Color3_RGB(54,  54,  54),
	DropdownItem            = Color3_RGB(156, 156, 156),
	DropdownItemHover       = Color3_RGB(255, 255, 255),
	DropdownItemHoverBg     = Color3_RGB(36,  36,  36),
	DropdownItemSelectedBg  = Color3_RGB(38,  28,  64),
	DropdownItemSelectedText= Color3_RGB(179, 157, 219),
	TitleText               = Color3_RGB(138, 138, 138),
	SubtitleText            = Color3_RGB(75,  75,  75),
	White                   = Color3_RGB(255, 255, 255),
	Black                   = Color3_RGB(0,   0,   0),
	ResizeHandle            = Color3_RGB(70,  70,  70),
}

-- ── Default window config ─────────────────────────────────────────────────
local WinDefaults = {
	WindowWidth       = 880,
	WindowHeight      = 580,
	MinWidth          = 580,
	MinHeight         = 380,
	TopBarHeight      = 50,
	SidebarWidth      = 220,
	ElementRowHeight  = 44,
	SectionHeaderH    = 42,
	ToggleWidth       = 42,
	ToggleHeight      = 22,
	ToggleKnobSize    = 14,
	DropdownWidth     = 220,
	DropdownBoxHeight = 34,
	DropdownItemH     = 34,
	DropdownMaxItems  = 5,
	PanelPaddingX     = 25,
	PanelPaddingY     = 20,
	ElementSpacing    = 6,
	CornerRadius      = 6,
	WindowCornerRadius= 12,
	ShadowLayers      = 6,
	ShadowOffsetY     = 4,
	TweenTime         = 0.15,
}

-- ── Helpers ────────────────────────────────────────────────────────────────
local function Tween(obj, props, t)
	TweenService:Create(obj,
		TweenInfo.new(t or WinDefaults.TweenTime, Enum.EasingStyle.Quad), props):Play()
end

local function Create(class, props)
	local inst = Instance_new(class)
	for k, v in pairs(props) do inst[k] = v end
	if (class=="TextLabel" or class=="TextButton" or class=="TextBox")
		and props.FontFace == nil then
		inst.FontFace = UIFont
	end
	return inst
end

local function ApplyCorner(parent, radius)
	local c = Instance_new("UICorner")
	c.CornerRadius = UDim_new(0, radius or WinDefaults.CornerRadius)
	c.Parent = parent
	return c
end

local function ApplyStroke(parent, color, thickness, transparency)
	local s = Instance_new("UIStroke")
	s.Color        = color or Color3_RGB(50, 50, 50)
	s.Thickness    = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function ApplyPadding(parent, top, bottom, left, right)
	local p = Instance_new("UIPadding")
	p.PaddingTop    = UDim_new(0, top    or 0)
	p.PaddingBottom = UDim_new(0, bottom or 0)
	p.PaddingLeft   = UDim_new(0, left   or 0)
	p.PaddingRight  = UDim_new(0, right  or 0)
	p.Parent = parent
	return p
end

local function ApplyListLayout(parent, spacing, dir)
	local l = Instance_new("UIListLayout")
	l.Padding             = UDim_new(0, spacing or 0)
	l.FillDirection       = dir or Enum.FillDirection.Vertical
	l.HorizontalAlignment = Enum.HorizontalAlignment.Left
	l.VerticalAlignment   = Enum.VerticalAlignment.Top
	l.SortOrder           = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function ApplyDropShadow(parent, T)
	local holder = Create("Frame", {
		Name                   = "ShadowHolder",
		Size                   = UDim2_new(1, 28, 1, 28),
		Position               = UDim2_new(0, -14, 0, -14 + WinDefaults.ShadowOffsetY),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ZIndex                 = 0,
		Parent                 = parent,
	})
	for i = WinDefaults.ShadowLayers, 1, -1 do
		local spread = i * 3
		local alpha  = 0.88 + (i / WinDefaults.ShadowLayers) * 0.10
		local layer = Create("Frame", {
			AnchorPoint          = Vector2_new(0.5, 0.5),
			Position             = UDim2_new(0.5, 0, 0.5, 0),
			Size                 = UDim2_new(1, spread, 1, spread),
			BackgroundColor3     = T.Black,
			BackgroundTransparency = alpha,
			BorderSizePixel      = 0,
			ZIndex               = 0,
			Parent               = holder,
		})
		ApplyCorner(layer, WinDefaults.WindowCornerRadius + math.floor(i * 0.8))
	end
	return holder
end

local function ComputeScrollSize(layout, container)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2_new(0, 0, 0,
			layout.AbsoluteContentSize.Y + WinDefaults.PanelPaddingY * 2)
	end)
end

-- Glassmorphism button builder — shared by AddButton at every level
local function BuildGlassButton(parent, buttonText, icon, T, ZBase)
	ZBase = ZBase or 3
	local BtnW = 120

	-- Outer wrapper (no clip, holds everything)
	local Wrap = Create("Frame", {
		Name                   = "GlassBtn",
		Size                   = UDim2_new(0, BtnW, 0, 28),
		Position               = UDim2_new(1, -(BtnW + 14), 0.5, -14),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ZIndex                 = ZBase,
		Parent                 = parent,
	})

	-- ── glass base ──
	local GlassBg = Create("Frame", {
		Size                   = UDim2_new(1, 0, 1, 0),
		BackgroundColor3       = T.AccentGlass,
		BackgroundTransparency = 0.48,
		BorderSizePixel        = 0,
		ZIndex                 = ZBase,
		Parent                 = Wrap,
	})
	ApplyCorner(GlassBg, 7)

	-- sheen gradient
	local grad = Instance_new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3_RGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.45, Color3_RGB(200, 180, 255)),
		ColorSequenceKeypoint.new(1,   Color3_RGB(140, 100, 220)),
	})
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.40),
		NumberSequenceKeypoint.new(0.5, 0.65),
		NumberSequenceKeypoint.new(1,   0.50),
	})
	grad.Rotation = 130
	grad.Parent   = GlassBg

	-- top-edge highlight
	local Highlight = Create("Frame", {
		Size                   = UDim2_new(0.7, 0, 0, 1),
		Position               = UDim2_new(0.15, 0, 0, 1),
		BackgroundColor3       = Color3_RGB(255, 255, 255),
		BackgroundTransparency = 0.55,
		BorderSizePixel        = 0,
		ZIndex                 = ZBase + 1,
		Parent                 = Wrap,
	})
	ApplyCorner(Highlight, 2)

	-- glowing border
	local stroke = ApplyStroke(GlassBg, T.AccentLight, 1, 0.35)

	-- optional icon
	local textX = 0
	if icon then
		local iconId = GetIcon(icon)
		if iconId ~= "" then
			Create("ImageLabel", {
				Name                   = "BtnIcon",
				Size                   = UDim2_new(0, 14, 0, 14),
				Position               = UDim2_new(0, 8, 0.5, -7),
				BackgroundTransparency = 1,
				Image                  = iconId,
				ImageColor3            = T.White,
				ZIndex                 = ZBase + 2,
				Parent                 = Wrap,
			})
			textX = 18
		end
	end

	local BtnText = Create("TextLabel", {
		Name                   = "BtnText",
		Size                   = UDim2_new(1, -(textX + 6), 1, 0),
		Position               = UDim2_new(0, textX + 4, 0, 0),
		BackgroundTransparency = 1,
		Text                   = buttonText or "Execute",
		TextColor3             = T.White,
		TextSize               = 12,
		ZIndex                 = ZBase + 2,
		Parent                 = Wrap,
	})

	-- invisible click surface
	local ClickSurf = Create("TextButton", {
		Size                   = UDim2_new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		ZIndex                 = ZBase + 3,
		Parent                 = Wrap,
	})

	-- hover / press tweens
	ClickSurf.MouseEnter:Connect(function()
		Tween(GlassBg, {BackgroundTransparency = 0.28})
		Tween(stroke,  {Color = T.AccentLight,  Transparency = 0.0})
	end)
	ClickSurf.MouseLeave:Connect(function()
		Tween(GlassBg, {BackgroundTransparency = 0.48})
		Tween(stroke,  {Color = T.AccentLight,  Transparency = 0.35})
	end)
	ClickSurf.MouseButton1Down:Connect(function()
		Tween(GlassBg, {BackgroundTransparency = 0.18})
	end)
	ClickSurf.MouseButton1Up:Connect(function()
		Tween(GlassBg, {BackgroundTransparency = 0.28})
	end)

	return Wrap, ClickSurf, BtnText
end

-- ── Window constructor ─────────────────────────────────────────────────────
--[[
  config = {
    Title    = string,
    Subtitle = string,           -- optional second line in TopBar
    Size     = Vector2.new(w,h), -- optional
    Theme    = { Key = Color3 }, -- optional partial overrides
  }
]]
function Warp:Window(config)
	config = config or {}

	-- Merge theme
	local T = {}
	for k, v in pairs(DefaultTheme) do T[k] = v end
	if type(config.Theme) == "table" then
		for k, v in pairs(config.Theme) do T[k] = v end
	end

	local W = config.Size and config.Size.X or WinDefaults.WindowWidth
	local H = config.Size and config.Size.Y or WinDefaults.WindowHeight

	local win = setmetatable({}, Warp)
	win._T          = T
	win._tabs       = {}
	win._activePanel= nil
	win._gui        = nil
	win._mainFrame  = nil
	win._topBar     = nil
	win._sidebar    = nil
	win._transparencyBases = {}

	-- ── ScreenGui ──────────────────────────────────────────────────────────
	local ScreenGui = Create("ScreenGui", {
		Name           = "WarpUI",
		ResetOnSpawn   = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent         = Hui,
	})

	-- ── Main frame (CanvasGroup) ───────────────────────────────────────────
	local MainFrame = Create("CanvasGroup", {
		Name                   = "MainFrame",
		Size                   = UDim2_new(0, W, 0, H),
		Position               = UDim2_new(0.5, -W/2, 0.5, -H/2),
		BackgroundColor3       = T.Background,
		BackgroundTransparency = 0,
		BorderSizePixel        = 0,
		ClipsDescendants       = false,
		ZIndex                 = 2,
		Parent                 = ScreenGui,
	})
	ApplyCorner(MainFrame, WinDefaults.WindowCornerRadius)
	ApplyStroke(MainFrame, Color3_RGB(55, 55, 55), 1)
	ApplyDropShadow(MainFrame, T)

	-- ── TopBar ────────────────────────────────────────────────────────────
	local TopBar = Create("Frame", {
		Name                   = "TopBar",
		Size                   = UDim2_new(1, 0, 0, WinDefaults.TopBarHeight),
		BackgroundColor3       = T.TopBar,
		BackgroundTransparency = 0,
		BorderSizePixel        = 0,
		ZIndex                 = 4,
		Parent                 = MainFrame,
	})

	-- bottom border of TopBar
	Create("Frame", {
		Name             = "TopBorderLine",
		Size             = UDim2_new(1, 0, 0, 1),
		Position         = UDim2_new(0, 0, 1, -1),
		BackgroundColor3 = T.TopBarBorder,
		BorderSizePixel  = 0,
		Parent           = TopBar,
	})

	-- Title
	local TitleLabel = Create("TextLabel", {
		Name                   = "TitleLabel",
		Size                   = UDim2_new(1, -120, 0, 18),
		Position               = UDim2_new(0, 18, 0, 9),
		BackgroundTransparency = 1,
		Text                   = (config.Title or "Warp Library"):upper(),
		TextColor3             = T.TitleText,
		TextSize               = 11,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Parent                 = TopBar,
	})
	local tConstraint = Instance_new("UITextSizeConstraint")
	tConstraint.MaxTextSize = 11
	tConstraint.Parent = TitleLabel

	-- Subtitle (optional)
	if config.Subtitle then
		Create("TextLabel", {
			Name                   = "SubtitleLabel",
			Size                   = UDim2_new(1, -120, 0, 14),
			Position               = UDim2_new(0, 18, 0, 29),
			BackgroundTransparency = 1,
			Text                   = config.Subtitle,
			TextColor3             = T.SubtitleText,
			TextSize               = 10,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = TopBar,
		})
	end

	-- ── Drag ──────────────────────────────────────────────────────────────
	do
		local dragging, dStart, sPos = false, nil, nil
		TopBar.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dStart   = inp.Position
				-- convert to absolute so resize doesn't fight scale
				local ap = MainFrame.AbsolutePosition
				MainFrame.Position = UDim2_new(0, ap.X, 0, ap.Y)
				sPos = MainFrame.Position
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local d = inp.Position - dStart
				MainFrame.Position = UDim2_new(0,
					sPos.X.Offset + d.X, 0, sPos.Y.Offset + d.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	-- ── Content area ──────────────────────────────────────────────────────
	local ContentArea = Create("Frame", {
		Name                   = "ContentArea",
		Size                   = UDim2_new(1, 0, 1, -WinDefaults.TopBarHeight),
		Position               = UDim2_new(0, 0, 0, WinDefaults.TopBarHeight),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ClipsDescendants       = true,
		Parent                 = MainFrame,
	})

	-- ── Sidebar ───────────────────────────────────────────────────────────
	local Sidebar = Create("Frame", {
		Name                   = "Sidebar",
		Size                   = UDim2_new(0, WinDefaults.SidebarWidth, 1, 0),
		BackgroundColor3       = T.Sidebar,
		BackgroundTransparency = 0,
		BorderSizePixel        = 0,
		ClipsDescendants       = true,
		Parent                 = ContentArea,
	})
	Create("Frame", {
		Name             = "SidebarBorderLine",
		Size             = UDim2_new(0, 1, 1, 0),
		Position         = UDim2_new(1, -1, 0, 0),
		BackgroundColor3 = T.SidebarBorder,
		BorderSizePixel  = 0,
		Parent           = Sidebar,
	})

	local SidebarScroll = Create("ScrollingFrame", {
		Name                  = "SidebarScroll",
		Size                  = UDim2_new(1, 0, 1, 0),
		BackgroundTransparency= 1,
		BorderSizePixel       = 0,
		ScrollBarThickness    = 0,
		CanvasSize            = UDim2_new(0, 0, 2, 0),
		Parent                = Sidebar,
	})
	ApplyPadding(SidebarScroll, 22, 22, 12, 12)
	local SidebarLayout = ApplyListLayout(SidebarScroll, 24)
	ComputeScrollSize(SidebarLayout, SidebarScroll)

	-- ── Panel host ────────────────────────────────────────────────────────
	local PanelHost = Create("Frame", {
		Name                   = "PanelHost",
		Size                   = UDim2_new(1, -WinDefaults.SidebarWidth, 1, 0),
		Position               = UDim2_new(0, WinDefaults.SidebarWidth, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		ClipsDescendants       = true,
		Parent                 = ContentArea,
	})

	-- ── Resize handle (bottom-right corner) ───────────────────────────────
	local ResizeHandle = Create("TextButton", {
		Name                   = "ResizeHandle",
		Size                   = UDim2_new(0, 24, 0, 24),
		Position               = UDim2_new(1, -24, 1, -24),
		AnchorPoint            = Vector2_new(0, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		ZIndex                 = 12,
		Parent                 = MainFrame,
	})
	do
		local iconId = "rbxassetid://123490598231261"
		if iconId ~= "" then
			Create("ImageLabel", {
				Size                   = UDim2_new(1, -4, 1, -4),
				Position               = UDim2_new(0, 2, 0, 2),
				BackgroundTransparency = 1,
				Image                  = iconId,
				ImageColor3            = T.ResizeHandle,
				ZIndex                 = 13,
				Parent                 = ResizeHandle,
			})
		else
			Create("TextLabel", {
				Size                   = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "⤡",
				TextColor3             = T.ResizeHandle,
				TextSize               = 14,
				ZIndex                 = 13,
				Parent                 = ResizeHandle,
			})
		end

		local resizing, rStart, rSize = false, nil, nil
		ResizeHandle.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				rStart   = Vector2_new(inp.Position.X, inp.Position.Y)
				rSize    = Vector2_new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)
				-- lock to absolute position so scale doesn't interfere
				local ap = MainFrame.AbsolutePosition
				MainFrame.Position = UDim2_new(0, ap.X, 0, ap.Y)
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if resizing and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local d    = Vector2_new(inp.Position.X, inp.Position.Y) - rStart
				local newW = math_clamp(rSize.X + d.X, WinDefaults.MinWidth,  1400)
				local newH = math_clamp(rSize.Y + d.Y, WinDefaults.MinHeight, 900)
				MainFrame.Size = UDim2_new(0, newW, 0, newH)
			end
		end)
		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)

		-- highlight on hover
		ResizeHandle.MouseEnter:Connect(function()
			local icon = ResizeHandle:FindFirstChildOfClass("ImageLabel")
				or ResizeHandle:FindFirstChildOfClass("TextLabel")
			if icon then Tween(icon, {ImageColor3 = T.AccentLight}) end
		end)
		ResizeHandle.MouseLeave:Connect(function()
			local icon = ResizeHandle:FindFirstChildOfClass("ImageLabel")
				or ResizeHandle:FindFirstChildOfClass("TextLabel")
			if icon then Tween(icon, {ImageColor3 = T.ResizeHandle}) end
		end)
	end

	-- store references for SetTransparency
	win._gui        = ScreenGui
	win._mainFrame  = MainFrame
	win._topBar     = TopBar
	win._sidebar    = Sidebar
	win._sidebarScroll = SidebarScroll
	win._panelHost  = PanelHost
	win._T          = T

	-- ── SetTransparency ───────────────────────────────────────────────────
	--[[  value: 0 = opaque, 1 = fully transparent  ]]
	function win:SetTransparency(value)
		local v = math_clamp(value or 0, 0, 1)
		Tween(MainFrame, {BackgroundTransparency = v * 0.92})
		Tween(TopBar,    {BackgroundTransparency = math_clamp(v * 0.85, 0, 1)})
		Tween(Sidebar,   {BackgroundTransparency = math_clamp(v * 0.80, 0, 1)})
	end

	function win:Destroy()
		if self._gui then self._gui:Destroy() end
	end

	return win
end

-- ── AddTabGroup ────────────────────────────────────────────────────────────
function Warp:AddTabGroup(groupName)
	local T   = self._T
	local lib = self

	local group = { _name = groupName, _tabs = {}, _lib = lib }

	local GroupContainer = Create("Frame", {
		Name                   = groupName,
		Size                   = UDim2_new(1, 0, 0, 0),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		Parent                 = lib._sidebarScroll,
	})
	Create("TextLabel", {
		Name                   = "CategoryTitle",
		Size                   = UDim2_new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text                   = groupName:upper(),
		TextColor3             = T.CategoryTitle,
		TextSize               = 10,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Parent                 = GroupContainer,
	})

	local BtnList = Create("Frame", {
		Name                   = "BtnList",
		Size                   = UDim2_new(1, 0, 0, 0),
		Position               = UDim2_new(0, 0, 0, 22),
		AutomaticSize          = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		Parent                 = GroupContainer,
	})
	ApplyListLayout(BtnList, 4)

	group._btnList   = BtnList
	group._container = GroupContainer
	table_insert(lib._tabs, group)
	return group
end

-- ── AddTab ─────────────────────────────────────────────────────────────────
--[[
  tabGroup : result of AddTabGroup
  tabName  : string
  icon     : optional icon name / asset string (from Footagesus/Icons or rbxassetid)
]]
function Warp:AddTab(tabGroup, tabName, icon)
	local T   = self._T
	local lib = self

	-- panel (scrollable, hosts all sections)
	local Panel = Create("ScrollingFrame", {
		Name                  = tabName.."Panel",
		Size                  = UDim2_new(1, 0, 1, 0),
		BackgroundColor3      = T.PanelBg,
		BackgroundTransparency= 1,
		BorderSizePixel       = 0,
		ScrollBarThickness    = 3,
		ScrollBarImageColor3  = T.Accent,
		CanvasSize            = UDim2_new(0, 0, 2, 0),
		Visible               = false,
		ZIndex                = 1,
		Parent                = lib._panelHost,
	})
	ApplyPadding(Panel, WinDefaults.PanelPaddingY, WinDefaults.PanelPaddingY,
		WinDefaults.PanelPaddingX,  WinDefaults.PanelPaddingX)
	local PanelLayout = ApplyListLayout(Panel, WinDefaults.ElementSpacing)
	ComputeScrollSize(PanelLayout, Panel)

	-- sidebar button
	local BtnFrame = Create("Frame", {
		Name                   = tabName.."Btn",
		Size                   = UDim2_new(1, 0, 0, 38),
		BackgroundColor3       = T.Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel        = 0,
		Parent                 = tabGroup._btnList,
	})
	ApplyCorner(BtnFrame)

	local iconLabelOffset = 14
	if icon then
		local iconId = GetIcon(icon)
		if iconId ~= "" then
			Create("ImageLabel", {
				Name                   = "TabIcon",
				Size                   = UDim2_new(0, 16, 0, 16),
				Position               = UDim2_new(0, 12, 0.5, -8),
				BackgroundTransparency = 1,
				Image                  = iconId,
				ImageColor3            = T.TabIdle,
				ZIndex                 = 2,
				Parent                 = BtnFrame,
			})
			iconLabelOffset = 36
		end
	end

	local BtnLabel = Create("TextLabel", {
		Name                   = "Label",
		Size                   = UDim2_new(1, -10, 1, 0),
		Position               = UDim2_new(0, iconLabelOffset, 0, 0),
		BackgroundTransparency = 1,
		Text                   = tabName,
		TextColor3             = T.TabIdle,
		TextSize               = 13,
		TextXAlignment         = Enum.TextXAlignment.Left,
		Parent                 = BtnFrame,
	})

	local function SetActive(active)
		local iconImg = BtnFrame:FindFirstChild("TabIcon")
		if active then
			Tween(BtnFrame, {BackgroundColor3 = T.TabActiveBg, BackgroundTransparency = 0})
			Tween(BtnLabel, {TextColor3 = T.TabActive})
			if iconImg then Tween(iconImg, {ImageColor3 = T.TabActive}) end
		else
			Tween(BtnFrame, {BackgroundColor3 = T.Sidebar, BackgroundTransparency = 1})
			Tween(BtnLabel, {TextColor3 = T.TabIdle})
			if iconImg then Tween(iconImg, {ImageColor3 = T.TabIdle}) end
		end
	end

	BtnFrame.MouseEnter:Connect(function()
		if lib._activePanel ~= Panel then
			local i = BtnFrame:FindFirstChild("TabIcon")
			Tween(BtnFrame, {BackgroundColor3 = Color3_RGB(28,28,28), BackgroundTransparency = 0})
			Tween(BtnLabel, {TextColor3 = T.TabHover})
			if i then Tween(i, {ImageColor3 = T.TabHover}) end
		end
	end)
	BtnFrame.MouseLeave:Connect(function()
		if lib._activePanel ~= Panel then
			local i = BtnFrame:FindFirstChild("TabIcon")
			Tween(BtnFrame, {BackgroundColor3 = T.Sidebar, BackgroundTransparency = 1})
			Tween(BtnLabel, {TextColor3 = T.TabIdle})
			if i then Tween(i, {ImageColor3 = T.TabIdle}) end
		end
	end)

	local ClickDetector = Create("TextButton", {
		Size                   = UDim2_new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text                   = "",
		Parent                 = BtnFrame,
	})
	ClickDetector.MouseButton1Click:Connect(function()
		if lib._activePanel then
			lib._activePanel.Visible = false
			lib._activeSetActive(false)
		end
		Panel.Visible        = true
		lib._activePanel     = Panel
		lib._activeSetActive = SetActive
		SetActive(true)
	end)

	if not lib._activePanel then
		Panel.Visible        = true
		lib._activePanel     = Panel
		lib._activeSetActive = SetActive
		SetActive(true)
	end

	-- ── Tab object ────────────────────────────────────────────────────────
	local tab = { _panel = Panel, _layout = PanelLayout }

	function tab:AddPanelHeader(title, desc)
		local HF = Create("Frame", {
			Name                   = "PanelHeader",
			Size                   = UDim2_new(1, 0, 0, desc and 52 or 36),
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			LayoutOrder            = 0,
			Parent                 = Panel,
		})
		Create("TextLabel", {
			Size                   = UDim2_new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text                   = title,
			TextColor3             = T.White,
			TextSize               = 24,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = HF,
		})
		if desc then
			Create("TextLabel", {
				Size                   = UDim2_new(1, 0, 0, 18),
				Position               = UDim2_new(0, 0, 0, 32),
				BackgroundTransparency = 1,
				Text                   = desc,
				TextColor3             = T.ElementDesc,
				TextSize               = 13,
				TextXAlignment         = Enum.TextXAlignment.Left,
				Parent                 = HF,
			})
		end
	end

	function tab:AddSectionTitle(text)
		Create("TextLabel", {
			Name                   = "SectionTitle",
			Size                   = UDim2_new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text                   = text,
			TextColor3             = T.SectionTitle,
			TextSize               = 11,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = Panel,
		})
	end

	function tab:AddDivider()
		Create("Frame", {
			Name             = "Divider",
			Size             = UDim2_new(1, 0, 0, 1),
			BackgroundColor3 = T.Divider,
			BorderSizePixel  = 0,
			Parent           = Panel,
		})
	end

	function tab:AddSpacer(height)
		Create("Frame", {
			Name                   = "Spacer",
			Size                   = UDim2_new(1, 0, 0, height or 8),
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			Parent                 = Panel,
		})
	end

	function tab:AddLabel(flag, config)
		config = config or {}
		local text = config.Title or flag
		local LF = Create("Frame", {
			Name                   = (flag or "Label").."Frame",
			Size                   = UDim2_new(1, 0, 0, 0),
			AutomaticSize          = Enum.AutomaticSize.Y,
			BackgroundColor3       = T.TextLabelBg,
			BorderSizePixel        = 0,
			Parent                 = Panel,
		})
		Create("Frame", {
			Name             = "AccentBar",
			Size             = UDim2_new(0, 3, 1, 0),
			BackgroundColor3 = T.Accent,
			BorderSizePixel  = 0,
			Parent           = LF,
		})
		local LT = Create("TextLabel", {
			Name                   = "LabelText",
			Size                   = UDim2_new(1, -16, 0, 0),
			Position               = UDim2_new(0, 14, 0, 0),
			AutomaticSize          = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text                   = text,
			TextColor3             = T.TextLabel,
			TextSize               = 13,
			TextXAlignment         = Enum.TextXAlignment.Left,
			TextWrapped            = true,
			Parent                 = LF,
		})
		ApplyPadding(LT, 10, 10, 0, 0)

		local obj = {}
		if flag then Warp.Flags[flag] = obj end
		function obj:SetText(t) LT.Text = t end
		return obj
	end

	-- ── tab:AddToggle(flag, config) ────────────────────────────────────────
    --[[
      flag   : string key for Warp.Flags
      config : { Title, Desc, Default, Callback }
    ]]
	function tab:AddToggle(flag, config)
		config = config or {}
		local label    = config.Title or flag
		local desc     = config.Desc
		local state    = config.Default == true
		local callback = config.Callback

		local RowFrame = Create("Frame", {
			Name             = flag.."Row",
			Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
			BackgroundColor3 = T.ElementRow,
			BorderSizePixel  = 0,
			Parent           = Panel,
		})
		ApplyCorner(RowFrame)
		Create("TextLabel", {
			Size                   = UDim2_new(1, -(WinDefaults.ToggleWidth + 32), 0, 20),
			Position               = UDim2_new(0, 16, 0, 6),
			BackgroundTransparency = 1,
			Text                   = label,
			TextColor3             = T.ElementLabel,
			TextSize               = 14,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = RowFrame,
		})
		if desc then
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(WinDefaults.ToggleWidth + 32), 0, 14),
				Position               = UDim2_new(0, 16, 0, 25),
				BackgroundTransparency = 1,
				Text                   = desc,
				TextColor3             = T.ElementDesc,
				TextSize               = 12,
				TextXAlignment         = Enum.TextXAlignment.Left,
				Parent                 = RowFrame,
			})
		end

		local ToggleBg = Create("Frame", {
			Size             = UDim2_new(0, WinDefaults.ToggleWidth, 0, WinDefaults.ToggleHeight),
			Position         = UDim2_new(1, -(WinDefaults.ToggleWidth + 14), 0.5, -WinDefaults.ToggleHeight/2),
			BackgroundColor3 = state and T.ToggleOnBg or T.ToggleOff,
			BorderSizePixel  = 0,
			Parent           = RowFrame,
		})
		ApplyCorner(ToggleBg, 34)
		local KnobOffset = state and (WinDefaults.ToggleWidth - WinDefaults.ToggleKnobSize - 6) or 3
		local Knob = Create("Frame", {
			Size             = UDim2_new(0, WinDefaults.ToggleKnobSize, 0, WinDefaults.ToggleKnobSize),
			Position         = UDim2_new(0, KnobOffset, 0, (WinDefaults.ToggleHeight - WinDefaults.ToggleKnobSize)/2),
			BackgroundColor3 = state and T.ToggleOnKnob or T.ToggleOffKnob,
			BorderSizePixel  = 0,
			Parent           = ToggleBg,
		})
		ApplyCorner(Knob, 34)

		Create("TextButton", {
			Size                   = UDim2_new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text                   = "",
			Parent                 = RowFrame,
		}).MouseButton1Click:Connect(function()
			state = not state
			local kx = state and (WinDefaults.ToggleWidth - WinDefaults.ToggleKnobSize - 6) or 3
			Tween(ToggleBg, {BackgroundColor3 = state and T.ToggleOnBg or T.ToggleOff})
			Tween(Knob,     {
				Position         = UDim2_new(0, kx, 0, (WinDefaults.ToggleHeight - WinDefaults.ToggleKnobSize)/2),
				BackgroundColor3 = state and T.ToggleOnKnob or T.ToggleOffKnob,
			})
			if callback then callback(state) end
		end)

		local obj = { Value = state }
		function obj:Set(val, skipCb)
			state     = val
			obj.Value = val
			local kx  = val and (WinDefaults.ToggleWidth - WinDefaults.ToggleKnobSize - 6) or 3
			Tween(ToggleBg, {BackgroundColor3 = val and T.ToggleOnBg or T.ToggleOff})
			Tween(Knob,     {
				Position         = UDim2_new(0, kx, 0, (WinDefaults.ToggleHeight - WinDefaults.ToggleKnobSize)/2),
				BackgroundColor3 = val and T.ToggleOnKnob or T.ToggleOffKnob,
			})
			if not skipCb and callback then callback(val) end
		end
		function obj:Get() return state end

		if flag then Warp.Flags[flag] = obj end
		return obj
	end

	-- ── tab:AddButton(flag, config) ────────────────────────────────────────
    --[[
      config : { Title, Desc, ButtonText, Icon, Callback }
    ]]
	function tab:AddButton(flag, config)
		config = config or {}
		local label    = config.Title or flag
		local desc     = config.Desc
		local callback = config.Callback

		local RowFrame = Create("Frame", {
			Name             = flag.."Row",
			Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
			BackgroundColor3 = T.ElementRow,
			BorderSizePixel  = 0,
			ZIndex           = 2,
			Parent           = Panel,
		})
		ApplyCorner(RowFrame)
		ApplyStroke(RowFrame, T.ElementBorder, 1)
		Create("TextLabel", {
			Size                   = UDim2_new(1, -(154 + 32), 0, 20),
			Position               = UDim2_new(0, 16, 0, 6),
			BackgroundTransparency = 1,
			Text                   = label,
			TextColor3             = T.ElementLabel,
			TextSize               = 14,
			TextXAlignment         = Enum.TextXAlignment.Left,
			ZIndex                 = 2,
			Parent                 = RowFrame,
		})
		if desc then
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(154 + 32), 0, 14),
				Position               = UDim2_new(0, 16, 0, 25),
				BackgroundTransparency = 1,
				Text                   = desc,
				TextColor3             = T.ElementDesc,
				TextSize               = 12,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 2,
				Parent                 = RowFrame,
			})
		end

		local _, ClickSurf, BtnText =
			BuildGlassButton(RowFrame, config.ButtonText, config.Icon, T, 3)
		ClickSurf.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)

		local obj = { Value = nil }
		if flag then Warp.Flags[flag] = obj end
		function obj:SetText(t) BtnText.Text = t end
		return obj
	end

	-- ── tab:AddSection(sectionName) ────────────────────────────────────────
	function tab:AddSection(sectionName)
		local collapsed = false

		local SectionFrame = Create("Frame", {
			Name             = sectionName.."Section",
			Size             = UDim2_new(1, 0, 0, WinDefaults.SectionHeaderH),
			BackgroundColor3 = T.SectionBg,
			BorderSizePixel  = 0,
			ClipsDescendants = true,
			Parent           = Panel,
		})
		ApplyCorner(SectionFrame)

		local HeaderBtn = Create("TextButton", {
			Name             = "SectionHeader",
			Size             = UDim2_new(1, 0, 0, WinDefaults.SectionHeaderH),
			BackgroundColor3 = T.SectionHeader,
			BorderSizePixel  = 0,
			Text             = "",
			Parent           = SectionFrame,
		})
		ApplyCorner(HeaderBtn)

		Create("TextLabel", {
			Name                   = "SectionTitle",
			Size                   = UDim2_new(1, -40, 1, 0),
			Position               = UDim2_new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			Text                   = sectionName:upper(),
			TextColor3             = T.SectionTitle,
			TextSize               = 12,
			TextXAlignment         = Enum.TextXAlignment.Left,
			Parent                 = HeaderBtn,
		})
		local Chevron = Create("TextLabel", {
			Name                   = "Chevron",
			Size                   = UDim2_new(0, 20, 1, 0),
			Position               = UDim2_new(1, -30, 0, 0),
			BackgroundTransparency = 1,
			Text                   = "▼",
			TextColor3             = T.ElementDesc,
			TextSize               = 10,
			Parent                 = HeaderBtn,
		})

		local ContentFrame = Create("Frame", {
			Name                   = "SectionContent",
			Size                   = UDim2_new(1, 0, 0, 0),
			Position               = UDim2_new(0, 0, 0, WinDefaults.SectionHeaderH),
			BackgroundColor3       = Color3_RGB(34, 34, 34),
			BorderSizePixel        = 0,
			ClipsDescendants       = false,
			AutomaticSize          = Enum.AutomaticSize.Y,
			Visible                = true,
			Parent                 = SectionFrame,
		})
		Create("Frame", {
			Name             = "TopBorder",
			Size             = UDim2_new(1, 0, 0, 1),
			BackgroundColor3 = T.SectionBorder,
			BorderSizePixel  = 0,
			Parent           = ContentFrame,
		})

		local ContentList = Create("Frame", {
			Name                   = "ContentList",
			Size                   = UDim2_new(1, 0, 0, 0),
			Position               = UDim2_new(0, 0, 0, 1),
			AutomaticSize          = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel        = 0,
			Parent                 = ContentFrame,
		})
		ApplyPadding(ContentList, 12, 12, 12, 12)
		local ContentLayout = ApplyListLayout(ContentList, WinDefaults.ElementSpacing)

		local function UpdateSectionHeight()
			if collapsed then
				Tween(SectionFrame, {Size = UDim2_new(1, 0, 0, WinDefaults.SectionHeaderH)})
			else
				local cH = ContentLayout.AbsoluteContentSize.Y + 24 + 1
				Tween(SectionFrame, {Size = UDim2_new(1, 0, 0, WinDefaults.SectionHeaderH + cH)})
			end
		end
		ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionHeight)
		HeaderBtn.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			Tween(Chevron, {Rotation = collapsed and -90 or 0})
			UpdateSectionHeight()
		end)

		-- ── Section object ─────────────────────────────────────────────────
		local section = {}

		-- ── section:AddToggle(flag, config) ───────────────────────────────
		function section:AddToggle(flag, config)
			config = config or {}
			local label    = config.Title or flag
			local desc     = config.Desc
			local state    = config.Default == true
			local callback = config.Callback

			local RowFrame = Create("Frame", {
				Name             = flag.."Row",
				Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
				BackgroundColor3 = T.ElementRow,
				BorderSizePixel  = 0,
				Parent           = ContentList,
			})
			ApplyCorner(RowFrame)
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(WinDefaults.ToggleWidth + 32), 0, 20),
				Position               = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text                   = label,
				TextColor3             = T.ElementLabel,
				TextSize               = 14,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 2,
				Parent                 = RowFrame,
			})
			if desc then
				Create("TextLabel", {
					Size                   = UDim2_new(1, -(WinDefaults.ToggleWidth + 32), 0, 14),
					Position               = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text                   = desc,
					TextColor3             = T.ElementDesc,
					TextSize               = 12,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 2,
					Parent                 = RowFrame,
				})
			end

			local ToggleBg = Create("Frame", {
				Size             = UDim2_new(0, WinDefaults.ToggleWidth, 0, WinDefaults.ToggleHeight),
				Position         = UDim2_new(1, -(WinDefaults.ToggleWidth + 14), 0.5, -WinDefaults.ToggleHeight/2),
				BackgroundColor3 = state and T.ToggleOnBg or T.ToggleOff,
				BorderSizePixel  = 0,
				Parent           = RowFrame,
			})
			ApplyCorner(ToggleBg, 34)
			local KnobOffset = state and (WinDefaults.ToggleWidth - WinDefaults.ToggleKnobSize - 6) or 3
			local Knob = Create("Frame", {
				Size             = UDim2_new(0, WinDefaults.ToggleKnobSize, 0, WinDefaults.ToggleKnobSize),
				Position         = UDim2_new(0, KnobOffset, 0, (WinDefaults.ToggleHeight - WinDefaults.ToggleKnobSize)/2),
				BackgroundColor3 = state and T.ToggleOnKnob or T.ToggleOffKnob,
				BorderSizePixel  = 0,
				Parent           = ToggleBg,
			})
			ApplyCorner(Knob, 34)

			local function DoSet(val, skipCb)
				state = val
				local kx = val and (WinDefaults.ToggleWidth - WinDefaults.ToggleKnobSize - 6) or 3
				Tween(ToggleBg, {BackgroundColor3 = val and T.ToggleOnBg or T.ToggleOff})
				Tween(Knob, {
					Position         = UDim2_new(0, kx, 0, (WinDefaults.ToggleHeight - WinDefaults.ToggleKnobSize)/2),
					BackgroundColor3 = val and T.ToggleOnKnob or T.ToggleOffKnob,
				})
				if not skipCb and callback then callback(val) end
			end

			Create("TextButton", {
				Size                   = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "",
				Parent                 = RowFrame,
			}).MouseButton1Click:Connect(function() DoSet(not state) end)

			local obj = { Value = state }
			function obj:Set(v, skipCb) DoSet(v, skipCb); obj.Value = v end
			function obj:Get() return state end
			if flag then Warp.Flags[flag] = obj end
			return obj
		end

		-- ── section:AddDropdown(flag, config) ─────────────────────────────
        --[[
          config : { Title, Desc, Options, Default, Callback }
        ]]
		function section:AddDropdown(flag, config)
			config   = config or {}
			local label    = config.Title or flag
			local desc     = config.Desc
			local options  = config.Options or {}
			local selected = config.Default or nil
			local callback = config.Callback
			local open     = false
			local dropConn = nil
			local OverlayGui = lib._gui

			local RowFrame = Create("Frame", {
				Name             = flag.."Row",
				Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
				BackgroundColor3 = T.ElementRow,
				BorderSizePixel  = 0,
				ClipsDescendants = false,
				ZIndex           = 2,
				Parent           = ContentList,
			})
			ApplyCorner(RowFrame)
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(WinDefaults.DropdownWidth + 32), 0, 20),
				Position               = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text                   = label,
				TextColor3             = T.ElementLabel,
				TextSize               = 14,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 2,
				Parent                 = RowFrame,
			})
			if desc then
				Create("TextLabel", {
					Size                   = UDim2_new(1, -(WinDefaults.DropdownWidth + 32), 0, 14),
					Position               = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text                   = desc,
					TextColor3             = T.ElementDesc,
					TextSize               = 12,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 2,
					Parent                 = RowFrame,
				})
			end

			local DropBox = Create("Frame", {
				Name             = "DropBox",
				Size             = UDim2_new(0, WinDefaults.DropdownWidth, 0, WinDefaults.DropdownBoxHeight),
				Position         = UDim2_new(1, -(WinDefaults.DropdownWidth + 14), 0.5, -WinDefaults.DropdownBoxHeight/2),
				BackgroundColor3 = T.DropdownBox,
				BorderSizePixel  = 0,
				ZIndex           = 3,
				ClipsDescendants = false,
				Parent           = RowFrame,
			})
			ApplyCorner(DropBox, 5)
			ApplyStroke(DropBox, T.DropdownBorder, 1)

			local DropText = Create("TextLabel", {
				Size                   = UDim2_new(1, -28, 1, 0),
				Position               = UDim2_new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text                   = selected or "Select Parameter...",
				TextColor3             = T.DropdownText,
				TextSize               = 13,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 3,
				Parent                 = DropBox,
			})
			local Arrow = Create("TextLabel", {
				Name                   = "Arrow",
				Size                   = UDim2_new(0, 20, 1, 0),
				Position               = UDim2_new(1, -22, 0, 0),
				BackgroundTransparency = 1,
				Text                   = "▼",
				TextColor3             = T.ElementDesc,
				TextSize               = 8,
				ZIndex                 = 3,
				Parent                 = DropBox,
			})

			local listCount = math_clamp(#options, 1, WinDefaults.DropdownMaxItems)
			local listH = listCount * WinDefaults.DropdownItemH + 8

			-- Parented to ScreenGui for full Z-depth; positioned via AbsolutePosition
			local DropList = Create("ScrollingFrame", {
				Name                  = "DropList",
				Size                  = UDim2_new(0, WinDefaults.DropdownWidth, 0, listH),
				BackgroundColor3      = T.DropdownList,
				BorderSizePixel       = 0,
				ScrollBarThickness    = 2,
				ScrollBarImageColor3  = T.Accent,
				CanvasSize            = UDim2_new(0, 0, 0, #options * WinDefaults.DropdownItemH + 8),
				ZIndex                = 100,
				Visible               = false,
				Parent                = OverlayGui,
			})
			ApplyCorner(DropList, 6)
			ApplyPadding(DropList, 4, 4, 4, 4)
			ApplyListLayout(DropList, 2)
			ApplyStroke(DropList, T.DropdownListBorder, 1)

			local function SyncPos()
				local abs = DropBox.AbsolutePosition
				local sz  = DropBox.AbsoluteSize
				DropList.Position = UDim2_new(0, abs.X, 0, abs.Y + sz.Y + 4)
			end
			local function OpenDrop()
				open = true
				SyncPos()
				DropList.Visible = true
				Tween(Arrow, {Rotation = 180})
				dropConn = RunService.RenderStepped:Connect(SyncPos)
			end
			local function CloseDrop()
				open = false
				DropList.Visible = false
				Tween(Arrow, {Rotation = 0})
				if dropConn then dropConn:Disconnect(); dropConn = nil end
			end

			local itemFrames = {}
			for _, opt in ipairs(options) do
				local ItemFrame = Create("TextButton", {
					Name             = opt,
					Size             = UDim2_new(1, 0, 0, WinDefaults.DropdownItemH - 2),
					BackgroundColor3 = T.DropdownList,
					BorderSizePixel  = 0,
					Text             = opt,
					TextColor3       = selected == opt and T.DropdownItemSelectedText or T.DropdownItem,
					TextSize         = 13,
					TextXAlignment   = Enum.TextXAlignment.Left,
					ZIndex           = 101,
					Parent           = DropList,
				})
				if selected == opt then
					ItemFrame.BackgroundColor3 = T.DropdownItemSelectedBg
				end
				ApplyCorner(ItemFrame, 4)
				ApplyPadding(ItemFrame, 0, 0, 8, 0)

				ItemFrame.MouseEnter:Connect(function()
					if selected ~= opt then
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownItemHoverBg, TextColor3 = T.White})
					end
				end)
				ItemFrame.MouseLeave:Connect(function()
					if selected ~= opt then
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					end
				end)
				ItemFrame.MouseButton1Click:Connect(function()
					for _, f in ipairs(itemFrames) do
						Tween(f, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					end
					selected = opt
					DropText.Text = opt
					Tween(ItemFrame, {BackgroundColor3 = T.DropdownItemSelectedBg, TextColor3 = T.DropdownItemSelectedText})
					CloseDrop()
					if callback then callback(opt) end
				end)
				table_insert(itemFrames, ItemFrame)
			end

			Create("TextButton", {
				Size                   = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "",
				ZIndex                 = 4,
				Parent                 = DropBox,
			}).MouseButton1Click:Connect(function()
				if open then CloseDrop() else OpenDrop() end
			end)

			UserInputService.InputBegan:Connect(function(inp)
				if not open then return end
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos  = UserInputService:GetMouseLocation()
					local abs  = DropList.AbsolutePosition
					local sz   = DropList.AbsoluteSize
					if not (pos.X >= abs.X and pos.X <= abs.X + sz.X
						and pos.Y >= abs.Y and pos.Y <= abs.Y + sz.Y) then
						CloseDrop()
					end
				end
			end)

			local obj = { Value = selected }
			function obj:Set(v)
				selected = v
				obj.Value = v
				DropText.Text = v or "Select Parameter..."
				for _, f in ipairs(itemFrames) do
					if f.Name == v then
						Tween(f, {BackgroundColor3 = T.DropdownItemSelectedBg, TextColor3 = T.DropdownItemSelectedText})
					else
						Tween(f, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					end
				end
			end
			function obj:Get() return selected end
			if flag then Warp.Flags[flag] = obj end
			return obj
		end

		-- ── section:AddMultiDropdown(flag, config) ────────────────────────
        --[[
          config : { Title, Desc, Options, Default = {}, Callback }
        ]]
		function section:AddMultiDropdown(flag, config)
			config = config or {}
			local label       = config.Title or flag
			local desc        = config.Desc
			local options     = config.Options or {}
			local selectedSet = {}
			local callback    = config.Callback
			local open        = false
			local dropConn    = nil
			local OverlayGui  = lib._gui

			-- populate defaults
			if type(config.Default) == "table" then
				for _, v in ipairs(config.Default) do selectedSet[v] = true end
			end

			local RowFrame = Create("Frame", {
				Name             = flag.."Row",
				Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
				BackgroundColor3 = T.ElementRow,
				BorderSizePixel  = 0,
				ClipsDescendants = false,
				ZIndex           = 2,
				Parent           = ContentList,
			})
			ApplyCorner(RowFrame)
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(WinDefaults.DropdownWidth + 32), 0, 20),
				Position               = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text                   = label,
				TextColor3             = T.ElementLabel,
				TextSize               = 14,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 2,
				Parent                 = RowFrame,
			})
			if desc then
				Create("TextLabel", {
					Size                   = UDim2_new(1, -(WinDefaults.DropdownWidth + 32), 0, 14),
					Position               = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text                   = desc,
					TextColor3             = T.ElementDesc,
					TextSize               = 12,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 2,
					Parent                 = RowFrame,
				})
			end

			local DropBox = Create("Frame", {
				Name             = "DropBox",
				Size             = UDim2_new(0, WinDefaults.DropdownWidth, 0, WinDefaults.DropdownBoxHeight),
				Position         = UDim2_new(1, -(WinDefaults.DropdownWidth + 14), 0.5, -WinDefaults.DropdownBoxHeight/2),
				BackgroundColor3 = T.DropdownBox,
				BorderSizePixel  = 0,
				ZIndex           = 3,
				ClipsDescendants = false,
				Parent           = RowFrame,
			})
			ApplyCorner(DropBox, 5)
			ApplyStroke(DropBox, T.DropdownBorder, 1)

			local function CountSelected()
				local n = 0
				for _ in pairs(selectedSet) do n = n + 1 end
				return n
			end

			local DropText = Create("TextLabel", {
				Size                   = UDim2_new(1, -28, 1, 0),
				Position               = UDim2_new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text                   = CountSelected() == 0 and "0 Items Highlighted" or CountSelected().." Options Active",
				TextColor3             = T.DropdownText,
				TextSize               = 13,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 3,
				Parent                 = DropBox,
			})
			local Arrow = Create("TextLabel", {
				Name                   = "Arrow",
				Size                   = UDim2_new(0, 20, 1, 0),
				Position               = UDim2_new(1, -22, 0, 0),
				BackgroundTransparency = 1,
				Text                   = "▼",
				TextColor3             = T.ElementDesc,
				TextSize               = 8,
				ZIndex                 = 3,
				Parent                 = DropBox,
			})

			local function UpdateDisplay()
				local n = CountSelected()
				if n == 0 then
					DropText.Text = "0 Items Highlighted"
				elseif n == 1 then
					local first; for k in pairs(selectedSet) do first = k; break end
					DropText.Text = first
				else
					DropText.Text = n.." Options Active"
				end
			end

			local listCount = math_clamp(#options, 1, WinDefaults.DropdownMaxItems)
			local listH = listCount * WinDefaults.DropdownItemH + 8

			local DropList = Create("ScrollingFrame", {
				Name                  = "DropList",
				Size                  = UDim2_new(0, WinDefaults.DropdownWidth, 0, listH),
				BackgroundColor3      = T.DropdownList,
				BorderSizePixel       = 0,
				ScrollBarThickness    = 2,
				ScrollBarImageColor3  = T.Accent,
				CanvasSize            = UDim2_new(0, 0, 0, #options * WinDefaults.DropdownItemH + 8),
				ZIndex                = 100,
				Visible               = false,
				Parent                = OverlayGui,
			})
			ApplyCorner(DropList, 6)
			ApplyPadding(DropList, 4, 4, 4, 4)
			ApplyListLayout(DropList, 2)
			ApplyStroke(DropList, T.DropdownListBorder, 1)

			local function SyncPos()
				local abs = DropBox.AbsolutePosition
				local sz  = DropBox.AbsoluteSize
				DropList.Position = UDim2_new(0, abs.X, 0, abs.Y + sz.Y + 4)
			end
			local function OpenDrop()
				open = true; SyncPos(); DropList.Visible = true
				Tween(Arrow, {Rotation = 180})
				dropConn = RunService.RenderStepped:Connect(SyncPos)
			end
			local function CloseDrop()
				open = false; DropList.Visible = false
				Tween(Arrow, {Rotation = 0})
				if dropConn then dropConn:Disconnect(); dropConn = nil end
			end

			local itemFrames = {}
			for _, opt in ipairs(options) do
				local isSelected = selectedSet[opt] == true
				local ItemFrame = Create("TextButton", {
					Name             = opt,
					Size             = UDim2_new(1, 0, 0, WinDefaults.DropdownItemH - 2),
					BackgroundColor3 = isSelected and T.DropdownItemSelectedBg or T.DropdownList,
					BorderSizePixel  = 0,
					Text             = opt,
					TextColor3       = isSelected and T.DropdownItemSelectedText or T.DropdownItem,
					TextSize         = 13,
					TextXAlignment   = Enum.TextXAlignment.Left,
					ZIndex           = 101,
					Parent           = DropList,
				})
				ApplyCorner(ItemFrame, 4)
				ApplyPadding(ItemFrame, 0, 0, 8, 0)

				ItemFrame.MouseEnter:Connect(function()
					if not selectedSet[opt] then
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownItemHoverBg, TextColor3 = T.White})
					end
				end)
				ItemFrame.MouseLeave:Connect(function()
					if not selectedSet[opt] then
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					end
				end)
				ItemFrame.MouseButton1Click:Connect(function()
					if selectedSet[opt] then
						selectedSet[opt] = nil
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					else
						selectedSet[opt] = true
						Tween(ItemFrame, {BackgroundColor3 = T.DropdownItemSelectedBg, TextColor3 = T.DropdownItemSelectedText})
					end
					UpdateDisplay()
					if callback then
						local arr = {}
						for k in pairs(selectedSet) do table_insert(arr, k) end
						callback(arr)
					end
				end)
				table_insert(itemFrames, ItemFrame)
			end

			Create("TextButton", {
				Size                   = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text                   = "",
				ZIndex                 = 4,
				Parent                 = DropBox,
			}).MouseButton1Click:Connect(function()
				if open then CloseDrop() else OpenDrop() end
			end)

			UserInputService.InputBegan:Connect(function(inp)
				if not open then return end
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos = UserInputService:GetMouseLocation()
					local abs = DropList.AbsolutePosition
					local sz  = DropList.AbsoluteSize
					if not (pos.X >= abs.X and pos.X <= abs.X + sz.X
						and pos.Y >= abs.Y and pos.Y <= abs.Y + sz.Y) then
						CloseDrop()
					end
				end
			end)

			local obj = {}
			function obj:GetSelected()
				local arr = {}
				for k in pairs(selectedSet) do table_insert(arr, k) end
				return arr
			end
			function obj:SetSelected(arr, skipCb)
				selectedSet = {}
				for _, v in ipairs(arr) do selectedSet[v] = true end
				UpdateDisplay()
				for _, f in ipairs(itemFrames) do
					if selectedSet[f.Name] then
						Tween(f, {BackgroundColor3 = T.DropdownItemSelectedBg, TextColor3 = T.DropdownItemSelectedText})
					else
						Tween(f, {BackgroundColor3 = T.DropdownList, TextColor3 = T.DropdownItem})
					end
				end
				if not skipCb and callback then
					local a = {}; for k in pairs(selectedSet) do table_insert(a, k) end
					callback(a)
				end
			end
			if flag then Warp.Flags[flag] = obj end
			return obj
		end

		-- ── section:AddButton(flag, config) ───────────────────────────────
        --[[
          config : { Title, Desc, ButtonText, Icon, Callback }
        ]]
		function section:AddButton(flag, config)
			config = config or {}
			local label    = config.Title or flag
			local desc     = config.Desc
			local callback = config.Callback

			local RowFrame = Create("Frame", {
				Name             = flag.."Row",
				Size             = UDim2_new(1, 0, 0, WinDefaults.ElementRowHeight),
				BackgroundColor3 = T.ElementRow,
				BorderSizePixel  = 0,
				ZIndex           = 2,
				Parent           = ContentList,
			})
			ApplyCorner(RowFrame)
			ApplyStroke(RowFrame, T.ElementBorder, 1)
			Create("TextLabel", {
				Size                   = UDim2_new(1, -(154 + 32), 0, 20),
				Position               = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text                   = label,
				TextColor3             = T.ElementLabel,
				TextSize               = 14,
				TextXAlignment         = Enum.TextXAlignment.Left,
				ZIndex                 = 2,
				Parent                 = RowFrame,
			})
			if desc then
				Create("TextLabel", {
					Size                   = UDim2_new(1, -(154 + 32), 0, 14),
					Position               = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text                   = desc,
					TextColor3             = T.ElementDesc,
					TextSize               = 12,
					TextXAlignment         = Enum.TextXAlignment.Left,
					ZIndex                 = 2,
					Parent                 = RowFrame,
				})
			end

			local _, ClickSurf, BtnText =
				BuildGlassButton(RowFrame, config.ButtonText, config.Icon, T, 3)
			ClickSurf.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)

			local obj = {}
			function obj:SetText(t) BtnText.Text = t end
			function obj:SetEnabled(v)
				ClickSurf.Active = v
			end
			if flag then Warp.Flags[flag] = obj end
			return obj
		end

		-- ── section:AddLabel(flag, config) ───────────────────────────────
		function section:AddLabel(flag, config)
			config = config or {}
			local text = config.Title or flag
			local LF = Create("Frame", {
				Name                   = (flag or "Label").."Frame",
				Size                   = UDim2_new(1, 0, 0, 0),
				AutomaticSize          = Enum.AutomaticSize.Y,
				BackgroundColor3       = T.TextLabelBg,
				BorderSizePixel        = 0,
				Parent                 = ContentList,
			})
			Create("Frame", {
				Name             = "AccentBar",
				Size             = UDim2_new(0, 3, 1, 0),
				BackgroundColor3 = T.Accent,
				BorderSizePixel  = 0,
				Parent           = LF,
			})
			local LT = Create("TextLabel", {
				Name                   = "LabelText",
				Size                   = UDim2_new(1, -16, 0, 0),
				Position               = UDim2_new(0, 14, 0, 0),
				AutomaticSize          = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Text                   = text,
				TextColor3             = T.TextLabel,
				TextSize               = 13,
				TextXAlignment         = Enum.TextXAlignment.Left,
				TextWrapped            = true,
				Parent                 = LF,
			})
			ApplyPadding(LT, 10, 10, 0, 0)
			local obj = {}
			function obj:SetText(t) LT.Text = t end
			if flag then Warp.Flags[flag] = obj end
			return obj
		end

		return section
	end -- AddSection

	return tab
end -- AddTab

return Warp
