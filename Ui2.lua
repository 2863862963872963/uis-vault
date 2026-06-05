local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Instance_new = Instance.new
local Color3_fromRGB = Color3.fromRGB
local UDim2_new = UDim2.new
local UDim_new = UDim.new
local Vector2_new = Vector2.new
local math_clamp = math.clamp
local table_insert = table.insert
local table_remove = table.remove
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local type = type

local UIFont = Font.new("rbxassetid://12187365977", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Hui = game:GetService("Players").LocalPlayer.PlayerGui

local Warp = {}
Warp.__index = Warp

local Theme = {
	Background       = Color3_fromRGB(30,  30,  30),
	TopBar           = Color3_fromRGB(22,  22,  22),
	TopBarBorder     = Color3_fromRGB(40,  40,  40),
	Sidebar          = Color3_fromRGB(20,  20,  20),
	SidebarBorder    = Color3_fromRGB(38,  38,  38),
	TabIdle          = Color3_fromRGB(140, 140, 140),
	TabHover         = Color3_fromRGB(224, 224, 224),
	TabActive        = Color3_fromRGB(255, 255, 255),
	TabActiveBg      = Color3_fromRGB(42,  42,  42),
	CategoryTitle    = Color3_fromRGB(85,  85,  85),
	PanelBg          = Color3_fromRGB(30,  30,  30),
	SectionBg        = Color3_fromRGB(36,  36,  36),
	SectionBorder    = Color3_fromRGB(46,  46,  46),
	SectionHeader    = Color3_fromRGB(38,  38,  38),
	SectionTitle     = Color3_fromRGB(124, 77,  255),
	ElementRow       = Color3_fromRGB(40,  40,  40),
	ElementBorder    = Color3_fromRGB(50,  50,  50),
	ElementLabel     = Color3_fromRGB(240, 240, 240),
	ElementDesc      = Color3_fromRGB(106, 106, 106),
	Accent           = Color3_fromRGB(124, 77,  255),
	AccentLight      = Color3_fromRGB(179, 157, 219),
	TextLabel        = Color3_fromRGB(180, 180, 180),
	TextLabelBg      = Color3_fromRGB(36,  36,  36),
	Divider          = Color3_fromRGB(50,  50,  50),
	ToggleOff        = Color3_fromRGB(30,  30,  30),
	ToggleOffBorder  = Color3_fromRGB(58,  58,  58),
	ToggleOffKnob    = Color3_fromRGB(85,  85,  85),
	ToggleOnBg       = Color3_fromRGB(124, 77,  255),
	ToggleOnBorder   = Color3_fromRGB(149, 117, 205),
	ToggleOnKnob     = Color3_fromRGB(255, 255, 255),
	DropdownBox      = Color3_fromRGB(30,  30,  30),
	DropdownBorder   = Color3_fromRGB(58,  58,  58),
	DropdownText     = Color3_fromRGB(224, 224, 224),
	DropdownList     = Color3_fromRGB(22,  22,  22),
	DropdownListBorder= Color3_fromRGB(54, 54,  54),
	DropdownItem     = Color3_fromRGB(156, 156, 156),
	DropdownItemHover= Color3_fromRGB(255, 255, 255),
	DropdownItemHoverBg = Color3_fromRGB(36, 36, 36),
	DropdownItemSelectedBg = Color3_fromRGB(38, 28, 64),
	DropdownItemSelectedText = Color3_fromRGB(179, 157, 219),
	TitleText        = Color3_fromRGB(138, 138, 138),
	White            = Color3_fromRGB(255, 255, 255),
	Black            = Color3_fromRGB(0,   0,   0),
}

local Config = {
	WindowWidth      = 880,
	WindowHeight     = 580,
	TopBarHeight     = 45,
	SidebarWidth     = 220,
	ElementRowHeight = 44,
	SectionHeaderH   = 42,
	ToggleWidth      = 42,
	ToggleHeight     = 22,
	ToggleKnobSize   = 14,
	DropdownWidth    = 220,
	DropdownBoxHeight= 34,
	DropdownItemH    = 34,
	DropdownMaxItems = 5,
	PanelPaddingX    = 25,
	PanelPaddingY    = 20,
	ElementSpacing   = 6,
	CornerRadius     = 6,
	WindowCornerRadius = 12,
	ShadowLayers     = 6,
	ShadowOffsetY    = 4,
	TweenTime        = 0.15,
}

local function Tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or Config.TweenTime, Enum.EasingStyle.Quad), props):Play()
end

local function ApplyTextFont(textObj)
	if UIFont then
		textObj.FontFace = UIFont
	end
	return textObj
end

local function Create(class, props, children)
	local inst = Instance_new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
		if props.Text == nil or props.Text ~= "" then
			ApplyTextFont(inst)
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

local function ApplyCorner(parent, radius)
	local c = Instance_new("UICorner")
	c.CornerRadius = UDim_new(0, radius or Config.CornerRadius)
	c.Parent = parent
	return c
end

local function ApplyStroke(parent, color, thickness)
	local s = Instance_new("UIStroke")
	s.Color = color or Color3_fromRGB(50, 50, 50)
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

-- FIXED: Shadow now dynamically scales via constraints relative to MainFrame
local function ApplyDropShadow(parent)
	local holder = Create("Frame", {
		Name            = "DropShadowHolder",
		Size            = UDim2_new(1, 24, 1, 24),
		Position        = UDim2_new(0, -12, 0, -12 + Config.ShadowOffsetY),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex          = 0,
		Parent          = parent,
	})

	for i = Config.ShadowLayers, 1, -1 do
		local spread = i * 3
		local alpha = 0.88 + (i / Config.ShadowLayers) * 0.10
		local layer = Create("Frame", {
			Name            = "Layer" .. i,
			AnchorPoint     = Vector2_new(0.5, 0.5),
			Position        = UDim2_new(0.5, 0, 0.5, 0),
			Size            = UDim2_new(1, spread, 1, spread),
			BackgroundColor3= Theme.Black,
			BackgroundTransparency = alpha,
			BorderSizePixel = 0,
			ZIndex          = 0,
			Parent          = holder,
		})
		local radius = Config.WindowCornerRadius + math.floor(i * 0.8)
		ApplyCorner(layer, radius)
	end
	return holder
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

local function ApplyListLayout(parent, spacing, dir, halign, valign)
	local l = Instance_new("UIListLayout")
	l.Padding              = UDim_new(0, spacing or 0)
	l.FillDirection        = dir    or Enum.FillDirection.Vertical
	l.HorizontalAlignment  = halign or Enum.HorizontalAlignment.Left
	l.VerticalAlignment    = valign or Enum.VerticalAlignment.Top
	l.SortOrder            = Enum.SortOrder.LayoutOrder
	l.Parent = parent
	return l
end

local function MakeDraggable(frame, handle)
	local dragging, dragStart, startPos = false, nil, nil
	handle = handle or frame

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2_new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

local function ComputeScrollSize(layout, container)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2_new(0, 0, 0, layout.AbsoluteContentSize.Y + Config.PanelPaddingY * 2)
	end)
end

function Warp.new(title)
	local self = setmetatable({}, Warp)
	self._tabs = {}
	self._activeTab = nil
	self._gui = nil

	local ScreenGui = Create("ScreenGui", {
		Name            = "WarpUI",
		ResetOnSpawn    = false,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		Parent          = Hui,
	})

	-- FIXED: Swapped Frame to CanvasGroup to clean up transparency composition passes 
	-- allows localized backdrop modifications without washing out UI text elements
	local MainFrame = Create("CanvasGroup", {
		Name            = "MainFrame",
		Size            = UDim2_new(0, Config.WindowWidth, 0, Config.WindowHeight),
		Position        = UDim2_new(0.5, -Config.WindowWidth/2, 0.5, -Config.WindowHeight/2),
		BackgroundColor3= Theme.Background,
		BackgroundTransparency = 0.05, -- Gives sleek modern glass pass-through look
		BorderSizePixel = 0,
		ClipsDescendants= false,
		ZIndex          = 2,
		Parent          = ScreenGui,
	})
	ApplyCorner(MainFrame, Config.WindowCornerRadius)
	ApplyStroke(MainFrame, Color3_fromRGB(55, 55, 55), 1)
	ApplyDropShadow(MainFrame)

	local TopBar = Create("Frame", {
		Name            = "TopBar",
		Size            = UDim2_new(1, 0, 0, Config.TopBarHeight),
		BackgroundColor3= Theme.TopBar,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ZIndex          = 4,
		Parent          = MainFrame,
	})

	Create("Frame", {
		Name            = "TopBorderLine",
		Size            = UDim2_new(1, 0, 0, 1),
		Position        = UDim2_new(0, 0, 1, -1),
		BackgroundColor3= Theme.TopBarBorder,
		BorderSizePixel = 0,
		Parent          = TopBar,
	})

	local TitleLabel = Create("TextLabel", {
		Name            = "TitleLabel",
		Size            = UDim2_new(1, -100, 1, 0),
		Position        = UDim2_new(0, 18, 0, 0),
		BackgroundTransparency = 1,
		Text            = (title or "Warp Library"):upper(),
		TextColor3      = Theme.TitleText,
		TextSize        = 11,
		TextScaled      = false,
		TextXAlignment  = Enum.TextXAlignment.Left,
		Parent          = TopBar,
	})

	-- FIXED: Adds structured TextSize wrapping control for crisp responsiveness
	local tConstraint = Instance_new("UITextSizeConstraint")
	tConstraint.MaxTextSize = 11
	tConstraint.Parent = TitleLabel

	MakeDraggable(MainFrame, TopBar)

	local ContentArea = Create("Frame", {
		Name            = "ContentArea",
		Size            = UDim2_new(1, 0, 1, -Config.TopBarHeight),
		Position        = UDim2_new(0, 0, 0, Config.TopBarHeight),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants= true,
		Parent          = MainFrame,
	})

	local Sidebar = Create("Frame", {
		Name            = "Sidebar",
		Size            = UDim2_new(0, Config.SidebarWidth, 1, 0),
		BackgroundColor3= Theme.Sidebar,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ClipsDescendants= true,
		Parent          = ContentArea,
	})

	Create("Frame", {
		Name            = "SidebarBorderLine",
		Size            = UDim2_new(0, 1, 1, 0),
		Position        = UDim2_new(1, -1, 0, 0),
		BackgroundColor3= Theme.SidebarBorder,
		BorderSizePixel = 0,
		Parent          = Sidebar,
	})

	local SidebarScroll = Create("ScrollingFrame", {
		Name            = "SidebarScroll",
		Size            = UDim2_new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize      = UDim2_new(0, 0, 2, 0),
		Parent          = Sidebar,
	})
	ApplyPadding(SidebarScroll, 22, 22, 12, 12)

	local SidebarLayout = ApplyListLayout(SidebarScroll, 24)
	ComputeScrollSize(SidebarLayout, SidebarScroll)

	local PanelHost = Create("Frame", {
		Name            = "PanelHost",
		Size            = UDim2_new(1, -Config.SidebarWidth, 1, 0),
		Position        = UDim2_new(0, Config.SidebarWidth, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants= true,
		Parent          = ContentArea,
	})

	self._gui       = ScreenGui
	self._mainFrame = MainFrame
	self._sidebar   = Sidebar
	self._sidebarScroll = SidebarScroll
	self._panelHost = PanelHost

	return self
end

function Warp:AddTabGroup(groupName)
	local group = {}
	group._name = groupName
	group._tabs = {}
	group._lib  = self

	local GroupContainer = Create("Frame", {
		Name            = groupName,
		Size            = UDim2_new(1, 0, 0, 0),
		AutomaticSize   = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent          = self._sidebarScroll,
	})

	Create("TextLabel", {
		Name            = "CategoryTitle",
		Size            = UDim2_new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		Text            = groupName:upper(),
		TextColor3      = Theme.CategoryTitle,
		TextSize        = 10,
		FontFace        = UIFont,
		TextXAlignment  = Enum.TextXAlignment.Left,
		Parent          = GroupContainer,
	})

	local BtnList = Create("Frame", {
		Name            = "BtnList",
		Size            = UDim2_new(1, 0, 0, 0),
		Position        = UDim2_new(0, 0, 0, 22),
		AutomaticSize   = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent          = GroupContainer,
	})
	ApplyListLayout(BtnList, 4)

	group._btnList   = BtnList
	group._container = GroupContainer

	table_insert(self._tabs, group)
	return group
end

function Warp:AddTab(tabGroup, tabName, icon)
	local lib = self

	local Panel = Create("ScrollingFrame", {
		Name            = tabName .. "Panel",
		Size            = UDim2_new(1, 0, 1, 0),
		BackgroundColor3= Theme.PanelBg,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize      = UDim2_new(0, 0, 2, 0),
		Visible         = false,
		ZIndex          = 1,
		Parent          = lib._panelHost,
	})
	ApplyPadding(Panel, Config.PanelPaddingY, Config.PanelPaddingY, Config.PanelPaddingX, Config.PanelPaddingX)

	local PanelLayout = ApplyListLayout(Panel, Config.ElementSpacing)
	ComputeScrollSize(PanelLayout, Panel)

	local BtnFrame = Create("Frame", {
		Name            = tabName .. "Btn",
		Size            = UDim2_new(1, 0, 0, 38),
		BackgroundColor3= Theme.Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent          = tabGroup._btnList,
	})
	ApplyCorner(BtnFrame)

	local BtnLabel = Create("TextLabel", {
		Name            = "Label",
		Size            = UDim2_new(1, -10, 1, 0),
		Position        = UDim2_new(0, icon and 36 or 14, 0, 0),
		BackgroundTransparency = 1,
		Text            = (icon and (icon .. "  ") or "") .. tabName,
		TextColor3      = Theme.TabIdle,
		TextSize        = 13,
		FontFace        = UIFont,
		TextXAlignment  = Enum.TextXAlignment.Left,
		Parent          = BtnFrame,
	})

	local function SetActive(active)
		if active then
			Tween(BtnFrame, {BackgroundColor3 = Theme.TabActiveBg, BackgroundTransparency = 0})
			Tween(BtnLabel, {TextColor3 = Theme.TabActive})
		else
			Tween(BtnFrame, {BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 1})
			Tween(BtnLabel, {TextColor3 = Theme.TabIdle})
		end
	end

	BtnFrame.MouseEnter:Connect(function()
		if lib._activePanel ~= Panel then
			Tween(BtnFrame, {BackgroundColor3 = Color3_fromRGB(28,28,28), BackgroundTransparency = 0})
			Tween(BtnLabel, {TextColor3 = Theme.TabHover})
		end
	end)
	BtnFrame.MouseLeave:Connect(function()
		if lib._activePanel ~= Panel then
			Tween(BtnFrame, {BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 1})
			Tween(BtnLabel, {TextColor3 = Theme.TabIdle})
		end
	end)

	local ClickDetector = Create("TextButton", {
		Size            = UDim2_new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text            = "",
		Parent          = BtnFrame,
	})

	ClickDetector.MouseButton1Click:Connect(function()
		if lib._activePanel then
			lib._activePanel.Visible = false
			lib._activeSetActive(false)
		end
		Panel.Visible = true
		lib._activePanel    = Panel
		lib._activeSetActive = SetActive
		SetActive(true)
	end)

	if not lib._activePanel then
		Panel.Visible = true
		lib._activePanel    = Panel
		lib._activeSetActive = SetActive
		SetActive(true)
	end

	local tab = {}
	tab._panel = Panel
	tab._layout = PanelLayout

	function tab:AddPanelHeader(title, desc)
		local HeaderFrame = Create("Frame", {
			Name            = "PanelHeader",
			Size            = UDim2_new(1, 0, 0, desc and 52 or 36),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder     = 0,
			Parent          = Panel,
		})

		Create("TextLabel", {
			Size            = UDim2_new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text            = title,
			TextColor3      = Theme.White,
			TextSize        = 24,
			FontFace        = UIFont,
			TextXAlignment  = Enum.TextXAlignment.Left,
			Parent          = HeaderFrame,
		})

		if desc then
			Create("TextLabel", {
				Size            = UDim2_new(1, 0, 0, 18),
				Position        = UDim2_new(0, 0, 0, 32),
				BackgroundTransparency = 1,
				Text            = desc,
				TextColor3      = Theme.ElementDesc,
				TextSize        = 13,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = HeaderFrame,
			})
		end
	end

	function tab:AddSectionTitle(text)
		Create("TextLabel", {
			Name            = "SectionTitle",
			Size            = UDim2_new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Text            = text,
			TextColor3      = Theme.SectionTitle,
			TextSize        = 11,
			FontFace        = UIFont,
			TextXAlignment  = Enum.TextXAlignment.Left,
			Parent          = Panel,
		})
	end

	function tab:AddDivider()
		Create("Frame", {
			Name            = "Divider",
			Size            = UDim2_new(1, 0, 0, 1),
			BackgroundColor3= Theme.Divider,
			BorderSizePixel = 0,
			Parent          = Panel,
		})
	end

	function tab:AddSpacer(height)
		Create("Frame", {
			Name            = "Spacer",
			Size            = UDim2_new(1, 0, 0, height or 8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent          = Panel,
		})
	end

	function tab:AddLabel(text)
		local LabelFrame = Create("Frame", {
			Name            = "LabelFrame",
			Size            = UDim2_new(1, 0, 0, 0),
			AutomaticSize   = Enum.AutomaticSize.Y,
			BackgroundColor3= Theme.TextLabelBg,
			BorderSizePixel = 0,
			Parent          = Panel,
		})

		Create("Frame", {
			Name            = "AccentBar",
			Size            = UDim2_new(0, 3, 1, 0),
			BackgroundColor3= Theme.Accent,
			BorderSizePixel = 0,
			Parent          = LabelFrame,
		})

		local LabelText = Create("TextLabel", {
			Name            = "LabelText",
			Size            = UDim2_new(1, -16, 0, 0),
			Position        = UDim2_new(0, 14, 0, 0),
			AutomaticSize   = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text            = text,
			TextColor3      = Theme.TextLabel,
			TextSize        = 13,
			FontFace        = UIFont,
			TextXAlignment  = Enum.TextXAlignment.Left,
			TextWrapped     = true,
			Parent          = LabelFrame,
		})
		ApplyPadding(LabelText, 10, 10, 0, 0)
	end

	function tab:AddToggle(label, desc, default, callback)
		local state = default == true

		local RowFrame = Create("Frame", {
			Name            = label .. "Row",
			Size            = UDim2_new(1, 0, 0, Config.ElementRowHeight),
			BackgroundColor3= Theme.ElementRow,
			BorderSizePixel = 0,
			Parent          = Panel,
		})
		ApplyCorner(RowFrame)

		Create("TextLabel", {
			Name            = "ElementLabel",
			Size            = UDim2_new(1, -(Config.ToggleWidth + 32), 0, 20),
			Position        = UDim2_new(0, 16, 0, 6),
			BackgroundTransparency = 1,
			Text            = label,
			TextColor3      = Theme.ElementLabel,
			TextSize        = 14,
			FontFace        = UIFont,
			TextXAlignment  = Enum.TextXAlignment.Left,
			Parent          = RowFrame,
		})

		if desc then
			Create("TextLabel", {
				Name            = "ElementDesc",
				Size            = UDim2_new(1, -(Config.ToggleWidth + 32), 0, 14),
				Position        = UDim2_new(0, 16, 0, 25),
				BackgroundTransparency = 1,
				Text            = desc,
				TextColor3      = Theme.ElementDesc,
				TextSize        = 12,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = RowFrame,
			})
		end

		local ToggleBg = Create("Frame", {
			Name            = "ToggleBg",
			Size            = UDim2_new(0, Config.ToggleWidth, 0, Config.ToggleHeight),
			Position        = UDim2_new(1, -(Config.ToggleWidth + 14), 0.5, -Config.ToggleHeight/2),
			BackgroundColor3= state and Theme.ToggleOnBg or Theme.ToggleOff,
			BorderSizePixel = 0,
			Parent          = RowFrame,
		})
		ApplyCorner(ToggleBg, 34)

		Create("Frame", {
			Name            = "ToggleBorder",
			Size            = UDim2_new(1, 2, 1, 2),
			Position        = UDim2_new(0, -1, 0, -1),
			BackgroundTransparency = 1,
			BorderSizePixel = 1,
			BorderColor3    = state and Theme.ToggleOnBorder or Theme.ToggleOffBorder,
			Parent          = ToggleBg,
		})

		local KnobOffset = state and (Config.ToggleWidth - Config.ToggleKnobSize - 6) or 3
		local Knob = Create("Frame", {
			Name            = "Knob",
			Size            = UDim2_new(0, Config.ToggleKnobSize, 0, Config.ToggleKnobSize),
			Position        = UDim2_new(0, KnobOffset, 0, (Config.ToggleHeight - Config.ToggleKnobSize)/2),
			BackgroundColor3= state and Theme.ToggleOnKnob or Theme.ToggleOffKnob,
			BorderSizePixel = 0,
			Parent          = ToggleBg,
		})
		ApplyCorner(Knob, 34)

		local ClickArea = Create("TextButton", {
			Size            = UDim2_new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text            = "",
			Parent          = RowFrame,
		})

		local function SetToggle(val, skipCallback)
			state = val
			local knobX = val and (Config.ToggleWidth - Config.ToggleKnobSize - 6) or 3
			Tween(ToggleBg, {BackgroundColor3 = val and Theme.ToggleOnBg or Theme.ToggleOff})
			Tween(Knob, {
				Position        = UDim2_new(0, knobX, 0, (Config.ToggleHeight - Config.ToggleKnobSize)/2),
				BackgroundColor3= val and Theme.ToggleOnKnob or Theme.ToggleOffKnob,
			})
			if not skipCallback and callback then
				callback(val)
			end
		end

		ClickArea.MouseButton1Click:Connect(function()
			SetToggle(not state)
		end)

		local toggleObj = {}
		function toggleObj:Set(val) SetToggle(val, true) end
		function toggleObj:Get() return state end
		return toggleObj
	end

	function tab:AddSection(sectionName)
		local collapsed = false

		local SectionFrame = Create("Frame", {
			Name            = sectionName .. "Section",
			Size            = UDim2_new(1, 0, 0, Config.SectionHeaderH),
			BackgroundColor3= Theme.SectionBg,
			BorderSizePixel = 0,
			ClipsDescendants= true, -- FIXED: Clips items gracefully when collapsed
			Parent          = Panel,
		})
		ApplyCorner(SectionFrame)

		local HeaderBtn = Create("TextButton", {
			Name            = "SectionHeader",
			Size            = UDim2_new(1, 0, 0, Config.SectionHeaderH),
			BackgroundColor3= Theme.SectionHeader,
			BorderSizePixel = 0,
			Text            = "",
			Parent          = SectionFrame,
		})
		ApplyCorner(HeaderBtn)

		Create("TextLabel", {
			Name            = "SectionTitle",
			Size            = UDim2_new(1, -40, 1, 0),
			Position        = UDim2_new(0, 16, 0, 0),
			BackgroundTransparency = 1,
			Text            = sectionName:upper(),
			TextColor3      = Theme.SectionTitle,
			TextSize        = 12,
			FontFace        = UIFont,
			TextXAlignment  = Enum.TextXAlignment.Left,
			Parent          = HeaderBtn,
		})

		local Chevron = Create("TextLabel", {
			Name            = "Chevron",
			Size            = UDim2_new(0, 20, 1, 0),
			Position        = UDim2_new(1, -30, 0, 0),
			BackgroundTransparency = 1,
			Text            = "▼",
			TextColor3      = Theme.ElementDesc,
			TextSize        = 10,
			FontFace        = UIFont,
			Parent          = HeaderBtn,
		})

		local ContentFrame = Create("Frame", {
			Name            = "SectionContent",
			Size            = UDim2_new(1, 0, 0, 0),
			Position        = UDim2_new(0, 0, 0, Config.SectionHeaderH),
			BackgroundColor3= Color3_fromRGB(34, 34, 34),
			BorderSizePixel = 0,
			ClipsDescendants= false,
			AutomaticSize   = Enum.AutomaticSize.Y,
			Visible         = true,
			Parent          = SectionFrame,
		})

		Create("Frame", {
			Name            = "TopBorder",
			Size            = UDim2_new(1, 0, 0, 1),
			BackgroundColor3= Theme.SectionBorder,
			BorderSizePixel = 0,
			Parent          = ContentFrame,
		})

		local ContentList = Create("Frame", {
			Name            = "ContentList",
			Size            = UDim2_new(1, 0, 0, 0),
			Position        = UDim2_new(0, 0, 0, 1),
			AutomaticSize   = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent          = ContentFrame,
		})
		ApplyPadding(ContentList, 12, 12, 12, 12)
		local ContentListLayout = ApplyListLayout(ContentList, Config.ElementSpacing)

		local function UpdateSectionHeight()
			if collapsed then
				Tween(SectionFrame, {Size = UDim2_new(1, 0, 0, Config.SectionHeaderH)})
			else
				local contentH = ContentListLayout.AbsoluteContentSize.Y + 24 + 1
				Tween(SectionFrame, {Size = UDim2_new(1, 0, 0, Config.SectionHeaderH + contentH)})
			end
		end

		ContentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionHeight)

		HeaderBtn.MouseButton1Click:Connect(function()
			collapsed = not collapsed
			Tween(Chevron, {Rotation = collapsed and -90 or 0})
			UpdateSectionHeight()
		end)

		local section = {}
		section._content    = ContentList
		section._sectionFrame = SectionFrame

		function section:AddToggle(label, desc, default, callback)
			local state = default == true

			local RowFrame = Create("Frame", {
				Name            = label .. "Row",
				Size            = UDim2_new(1, 0, 0, Config.ElementRowHeight),
				BackgroundColor3= Theme.ElementRow,
				BorderSizePixel = 0,
				Parent          = ContentList,
			})
			ApplyCorner(RowFrame)

			Create("TextLabel", {
				Size            = UDim2_new(1, -(Config.ToggleWidth + 32), 0, 20),
				Position        = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text            = label,
				TextColor3      = Theme.ElementLabel,
				TextSize        = 14,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				Parent          = RowFrame,
			})

			if desc then
				Create("TextLabel", {
					Size            = UDim2_new(1, -(Config.ToggleWidth + 32), 0, 14),
					Position        = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text            = desc,
					TextColor3      = Theme.ElementDesc,
					TextSize        = 12,
					FontFace        = UIFont,
					TextXAlignment  = Enum.TextXAlignment.Left,
					Parent          = RowFrame,
				})
			end

			local ToggleBg = Create("Frame", {
				Size            = UDim2_new(0, Config.ToggleWidth, 0, Config.ToggleHeight),
				Position        = UDim2_new(1, -(Config.ToggleWidth + 14), 0.5, -Config.ToggleHeight/2),
				BackgroundColor3= state and Theme.ToggleOnBg or Theme.ToggleOff,
				BorderSizePixel = 0,
				Parent          = RowFrame,
			})
			ApplyCorner(ToggleBg, 34)

			local KnobOffset = state and (Config.ToggleWidth - Config.ToggleKnobSize - 6) or 3
			local Knob = Create("Frame", {
				Size            = UDim2_new(0, Config.ToggleKnobSize, 0, Config.ToggleKnobSize),
				Position        = UDim2_new(0, KnobOffset, 0, (Config.ToggleHeight - Config.ToggleKnobSize)/2),
				BackgroundColor3= state and Theme.ToggleOnKnob or Theme.ToggleOffKnob,
				BorderSizePixel = 0,
				Parent          = ToggleBg,
			})
			ApplyCorner(Knob, 34)

			local ClickArea = Create("TextButton", {
				Size            = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text            = "",
				Parent          = RowFrame,
			})

			local function SetToggle(val, skipCb)
				state = val
				local knobX = val and (Config.ToggleWidth - Config.ToggleKnobSize - 6) or 3
				Tween(ToggleBg, {BackgroundColor3 = val and Theme.ToggleOnBg or Theme.ToggleOff})
				Tween(Knob, {
					Position        = UDim2_new(0, knobX, 0, (Config.ToggleHeight - Config.ToggleKnobSize)/2),
					BackgroundColor3= val and Theme.ToggleOnKnob or Theme.ToggleOffKnob,
				})
				if not skipCb and callback then callback(val) end
			end

			ClickArea.MouseButton1Click:Connect(function()
				SetToggle(not state)
			end)

			local obj = {}
			function obj:Set(v) SetToggle(v, true) end
			function obj:Get() return state end
			return obj
		end

		function section:AddDropdown(label, desc, options, callback)
			local selected = nil
			local open = false

			local RowFrame = Create("Frame", {
				Name            = label .. "Row",
				Size            = UDim2_new(1, 0, 0, Config.ElementRowHeight),
				BackgroundColor3= Theme.ElementRow,
				BorderSizePixel = 0,
				ClipsDescendants= false,
				ZIndex          = 2,
				Parent          = ContentList,
			})
			ApplyCorner(RowFrame)

			Create("TextLabel", {
				Size            = UDim2_new(1, -(Config.DropdownWidth + 32), 0, 20),
				Position        = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text            = label,
				TextColor3      = Theme.ElementLabel,
				TextSize        = 14,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				ZIndex          = 2,
				Parent          = RowFrame,
			})

			if desc then
				Create("TextLabel", {
					Size            = UDim2_new(1, -(Config.DropdownWidth + 32), 0, 14),
					Position        = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text            = desc,
					TextColor3      = Theme.ElementDesc,
					TextSize        = 12,
					FontFace        = UIFont,
					TextXAlignment  = Enum.TextXAlignment.Left,
					ZIndex          = 2,
					Parent          = RowFrame,
				})
			end

			local DropBox = Create("Frame", {
				Name            = "DropBox",
				Size            = UDim2_new(0, Config.DropdownWidth, 0, Config.DropdownBoxHeight),
				Position        = UDim2_new(1, -(Config.DropdownWidth + 14), 0.5, -Config.DropdownBoxHeight/2),
				BackgroundColor3= Theme.DropdownBox,
				BorderSizePixel = 0,
				ZIndex          = 3,
				ClipsDescendants= false,
				Parent          = RowFrame,
			})
			ApplyCorner(DropBox, 5)

			local DropText = Create("TextLabel", {
				Size            = UDim2_new(1, -28, 1, 0),
				Position        = UDim2_new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text            = "Select Parameter...",
				TextColor3      = Theme.DropdownText,
				TextSize        = 13,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				ZIndex          = 3,
				Parent          = DropBox,
			})

			Create("TextLabel", {
				Name            = "Arrow",
				Size            = UDim2_new(0, 20, 1, 0),
				Position        = UDim2_new(1, -22, 0, 0),
				BackgroundTransparency = 1,
				Text            = "▼",
				TextColor3      = Theme.ElementDesc,
				TextSize        = 8,
				FontFace        = UIFont,
				ZIndex          = 3,
				Parent          = DropBox,
			})

			local listItemH = Config.DropdownItemH
			local listCount = math_clamp(#options, 1, Config.DropdownMaxItems)
			local listH = listCount * listItemH + 8

			local DropList = Create("ScrollingFrame", {
				Name            = "DropList",
				Size            = UDim2_new(1, 0, 0, listH),
				Position        = UDim2_new(0, 0, 1, 4),
				BackgroundColor3= Theme.DropdownList,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = Theme.Accent,
				CanvasSize      = UDim2_new(0, 0, 0, #options * listItemH + 8),
				ZIndex          = 10,
				Visible         = false,
				Parent          = DropBox,
			})
			ApplyCorner(DropList, 6)
			ApplyPadding(DropList, 4, 4, 4, 4)
			ApplyListLayout(DropList, 2)

			local itemFrames = {}
			for _, opt in ipairs(options) do
				local ItemFrame = Create("TextButton", {
					Name            = opt,
					Size            = UDim2_new(1, 0, 0, listItemH - 2),
					BackgroundColor3= Theme.DropdownList,
					BorderSizePixel = 0,
					Text            = opt,
					TextColor3      = Theme.DropdownItem,
					TextSize        = 13,
					FontFace        = UIFont,
					TextXAlignment  = Enum.TextXAlignment.Left,
					ZIndex          = 11,
					Parent          = DropList,
				})
				ApplyCorner(ItemFrame, 4)
				ApplyPadding(ItemFrame, 0, 0, 8, 0)

				ItemFrame.MouseEnter:Connect(function()
					if selected ~= opt then
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownItemHoverBg, TextColor3 = Theme.White})
					end
				end)
				ItemFrame.MouseLeave:Connect(function()
					if selected ~= opt then
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownList, TextColor3 = Theme.DropdownItem})
					end
				end)

				ItemFrame.MouseButton1Click:Connect(function()
					for _, f in ipairs(itemFrames) do
						Tween(f, {BackgroundColor3 = Theme.DropdownList, TextColor3 = Theme.DropdownItem})
					end
					selected = opt
					DropText.Text = opt
					Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownItemSelectedBg, TextColor3 = Theme.DropdownItemSelectedText})
					DropList.Visible = false
					open = false
					if callback then callback(opt) end
				end)

				table_insert(itemFrames, ItemFrame)
			end

			local ClickBtn = Create("TextButton", {
				Size            = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 4,
				Parent          = DropBox,
			})

			ClickBtn.MouseButton1Click:Connect(function()
				open = not open
				DropList.Visible = open
			end)

			UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos = UserInputService:GetMouseLocation()
					local abs = DropList.AbsolutePosition
					local size = DropList.AbsoluteSize
					if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
						if open then
							DropList.Visible = false
							open = false
						end
					end
				end
			end)

			local obj = {}
			function obj:Set(v)
				selected = v
				DropText.Text = v
				for _, f in ipairs(itemFrames) do
					if f.Name == v then
						Tween(f, {BackgroundColor3 = Theme.DropdownItemSelectedBg, TextColor3 = Theme.DropdownItemSelectedText})
					else
						Tween(f, {BackgroundColor3 = Theme.DropdownList, TextColor3 = Theme.DropdownItem})
					end
				end
			end
			function obj:Get() return selected end
			return obj
		end

		function section:AddMultiDropdown(label, desc, options, callback)
			local selectedSet = {}
			local open = false

			local RowFrame = Create("Frame", {
				Name            = label .. "Row",
				Size            = UDim2_new(1, 0, 0, Config.ElementRowHeight),
				BackgroundColor3= Theme.ElementRow,
				BorderSizePixel = 0,
				ClipsDescendants= false,
				ZIndex          = 2,
				Parent          = ContentList,
			})
			ApplyCorner(RowFrame)

			Create("TextLabel", {
				Size            = UDim2_new(1, -(Config.DropdownWidth + 32), 0, 20),
				Position        = UDim2_new(0, 16, 0, 6),
				BackgroundTransparency = 1,
				Text            = label,
				TextColor3      = Theme.ElementLabel,
				TextSize        = 14,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				ZIndex          = 2,
				Parent          = RowFrame,
			})

			if desc then
				Create("TextLabel", {
					Size            = UDim2_new(1, -(Config.DropdownWidth + 32), 0, 14),
					Position        = UDim2_new(0, 16, 0, 25),
					BackgroundTransparency = 1,
					Text            = desc,
					TextColor3      = Theme.ElementDesc,
					TextSize        = 12,
					FontFace        = UIFont,
					TextXAlignment  = Enum.TextXAlignment.Left,
					ZIndex          = 2,
					Parent          = RowFrame,
				})
			end

			local DropBox = Create("Frame", {
				Name            = "DropBox",
				Size            = UDim2_new(0, Config.DropdownWidth, 0, Config.DropdownBoxHeight),
				Position        = UDim2_new(1, -(Config.DropdownWidth + 14), 0.5, -Config.DropdownBoxHeight/2),
				BackgroundColor3= Theme.DropdownBox,
				BorderSizePixel = 0,
				ZIndex          = 3,
				ClipsDescendants= false,
				Parent          = RowFrame,
			})
			ApplyCorner(DropBox, 5)

			local DropText = Create("TextLabel", {
				Size            = UDim2_new(1, -28, 1, 0),
				Position        = UDim2_new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Text            = "0 Items Highlighted",
				TextColor3      = Theme.DropdownText,
				TextSize        = 13,
				FontFace        = UIFont,
				TextXAlignment  = Enum.TextXAlignment.Left,
				ZIndex          = 3,
				Parent          = DropBox,
			})

			Create("TextLabel", {
				Name            = "Arrow",
				Size            = UDim2_new(0, 20, 1, 0),
				Position        = UDim2_new(1, -22, 0, 0),
				BackgroundTransparency = 1,
				Text            = "▼",
				TextColor3      = Theme.ElementDesc,
				TextSize        = 8,
				FontFace        = UIFont,
				ZIndex          = 3,
				Parent          = DropBox,
			})

			local listCount = math_clamp(#options, 1, Config.DropdownMaxItems)
			local listH = listCount * Config.DropdownItemH + 8

			local DropList = Create("ScrollingFrame", {
				Name            = "DropList",
				Size            = UDim2_new(1, 0, 0, listH),
				Position        = UDim2_new(0, 0, 1, 4),
				BackgroundColor3= Theme.DropdownList,
				BorderSizePixel = 0,
				ScrollBarThickness = 2,
				ScrollBarImageColor3 = Theme.Accent,
				CanvasSize      = UDim2_new(0, 0, 0, #options * Config.DropdownItemH + 8),
				ZIndex          = 10,
				Visible         = false,
				Parent          = DropBox,
			})
			ApplyCorner(DropList, 6)
			ApplyPadding(DropList, 4, 4, 4, 4)
			ApplyListLayout(DropList, 2)

			local function UpdateDisplay()
				local count = 0
				for _ in pairs(selectedSet) do count = count + 1 end
				if count == 0 then
					DropText.Text = "0 Items Highlighted"
				elseif count == 1 then
					local first
					for k in pairs(selectedSet) do first = k; break end
					DropText.Text = first
				else
					DropText.Text = count .. " Options Active"
				end
			end

			local itemFrames = {}
			for _, opt in ipairs(options) do
				local ItemFrame = Create("TextButton", {
					Name            = opt,
					Size            = UDim2_new(1, 0, 0, Config.DropdownItemH - 2),
					BackgroundColor3= Theme.DropdownList,
					BorderSizePixel = 0,
					Text            = opt,
					TextColor3      = Theme.DropdownItem,
					TextSize        = 13,
					FontFace        = UIFont,
					TextXAlignment  = Enum.TextXAlignment.Left,
					ZIndex          = 11,
					Parent          = DropList,
				})
				ApplyCorner(ItemFrame, 4)
				ApplyPadding(ItemFrame, 0, 0, 8, 0)

				ItemFrame.MouseEnter:Connect(function()
					if not selectedSet[opt] then
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownItemHoverBg, TextColor3 = Theme.White})
					end
				end)
				ItemFrame.MouseLeave:Connect(function()
					if not selectedSet[opt] then
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownList, TextColor3 = Theme.DropdownItem})
					end
				end)

				ItemFrame.MouseButton1Click:Connect(function()
					if selectedSet[opt] then
						selectedSet[opt] = nil
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownList, TextColor3 = Theme.DropdownItem})
					else
						selectedSet[opt] = true
						Tween(ItemFrame, {BackgroundColor3 = Theme.DropdownItemSelectedBg, TextColor3 = Theme.DropdownItemSelectedText})
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

			local ClickBtn = Create("TextButton", {
				Size            = UDim2_new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text            = "",
				ZIndex          = 4,
				Parent          = DropBox,
			})

			ClickBtn.MouseButton1Click:Connect(function()
				open = not open
				DropList.Visible = open
			end)

			UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local pos = UserInputService:GetMouseLocation()
					local abs = DropList.AbsolutePosition
					local size = DropList.AbsoluteSize
					if not (pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y) then
						if open then
							DropList.Visible = false
							open = false
						end
					end
				end
			end)

			local obj = {}
			function obj:GetSelected()
				local arr = {}
				for k in pairs(selectedSet) do table_insert(arr, k) end
				return arr
			end
			return obj
		end

		return section
	end

	return tab
end

function Warp:Destroy()
	if self._gui then
		self._gui:Destroy()
	end
end

return Warp
