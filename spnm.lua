local SkeetLib = {}
SkeetLib.__index = SkeetLib

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Theme = {
	Bg = Color3.fromRGB(12, 12, 12),
	BorderOuter = Color3.fromRGB(0, 0, 0),
	BorderInner = Color3.fromRGB(40, 40, 40),
	Accent = Color3.fromRGB(0, 205, 115),
	Text = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(150, 150, 150),
	ElementBg = Color3.fromRGB(25, 25, 25),
	HitboxActive = Color3.fromRGB(0, 205, 115),
	HitboxInactive = Color3.fromRGB(30, 30, 30),
}

local function makeDraggable(handle, target, dragSpeed)
	local dragging, dragInput, dragStart, startPos
	local speed = dragSpeed or 0.1
	local function update(input)
		local delta = input.Position - dragStart
		local goalPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		TweenService:Create(target, TweenInfo.new(speed), {Position = goalPos}):Play()
	end
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function SkeetLib:CreateWindow(title)
	local sg = Instance.new("ScreenGui")
	sg.Name = "SkeetMenu"
	sg.ResetOnSpawn = false
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(sg) end
		sg.Parent = game:GetService("CoreGui")
	end)
	if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 680, 0, 480)
	main.Position = UDim2.new(0.5, -340, 0.5, -240)
	main.BackgroundColor3 = Theme.Bg
	main.BorderColor3 = Theme.BorderOuter
	main.BorderSizePixel = 1
	main.Active = true
	main.Parent = sg

	local dragHandle = Instance.new("Frame")
	dragHandle.Name = "DragHandle"
	dragHandle.Size = UDim2.new(1, 0, 0, 35)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Parent = main
	makeDraggable(dragHandle, main, 0.05)

	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, -10, 1, -10)
	inner.Position = UDim2.new(0, 5, 0, 5)
	inner.BackgroundColor3 = Theme.Bg
	inner.BorderColor3 = Theme.BorderInner
	inner.BorderSizePixel = 1
	inner.Parent = main

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0, 150, 0, 25)
	titleLabel.Position = UDim2.new(0, 15, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.Code
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = inner

	local tabsContainer = Instance.new("Frame")
	tabsContainer.Name = "TabsContainer"
	tabsContainer.Size = UDim2.new(1, -180, 0, 25)
	tabsContainer.Position = UDim2.new(0, 165, 0, 10)
	tabsContainer.BackgroundTransparency = 1
	tabsContainer.Parent = inner

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsLayout.Padding = UDim.new(0, 10)
	tabsLayout.Parent = tabsContainer

	local pageContainer = Instance.new("Frame")
	pageContainer.Name = "PageContainer"
	pageContainer.Size = UDim2.new(1, -20, 1, -50)
	pageContainer.Position = UDim2.new(0, 10, 0, 40)
	pageContainer.BackgroundTransparency = 1
	pageContainer.Parent = inner

	local self = setmetatable({
		ScreenGui = sg,
		Main = main,
		Inner = inner,
		TabsContainer = tabsContainer,
		PageContainer = pageContainer,
		Tabs = {},
		Pages = {},
		ActiveTab = nil,
		Options = {}
	}, SkeetLib)

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift) then
			main.Visible = not main.Visible
		end
	end)

	return self
end

function SkeetLib:CreateTab(name)
	local windowSelf = self
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name .. "TabBtn"
	tabBtn.Size = UDim2.new(0, 80, 1, 0)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name:upper()
	tabBtn.TextColor3 = Theme.TextDark
	tabBtn.TextSize = 13
	tabBtn.Font = Enum.Font.Code
	tabBtn.Parent = self.TabsContainer

	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = self.PageContainer

	local leftCol = Instance.new("ScrollingFrame")
	leftCol.Name = "LeftCol"
	leftCol.Size = UDim2.new(0.32, 0, 1, 0)
	leftCol.BackgroundTransparency = 1
	leftCol.BorderSizePixel = 0
	leftCol.ScrollBarThickness = 2
	leftCol.ScrollBarImageColor3 = Theme.Accent
	leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
	leftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
	leftCol.Parent = page
	local leftLayout = Instance.new("UIListLayout")
	leftLayout.Padding = UDim.new(0, 15)
	leftLayout.Parent = leftCol

	local midCol = Instance.new("ScrollingFrame")
	midCol.Name = "MidCol"
	midCol.Size = UDim2.new(0.32, 0, 1, 0)
	midCol.Position = UDim2.new(0.34, 0, 0, 0)
	midCol.BackgroundTransparency = 1
	midCol.BorderSizePixel = 0
	midCol.ScrollBarThickness = 2
	midCol.ScrollBarImageColor3 = Theme.Accent
	midCol.CanvasSize = UDim2.new(0, 0, 0, 0)
	midCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
	midCol.Parent = page
	local midLayout = Instance.new("UIListLayout")
	midLayout.Padding = UDim.new(0, 15)
	midLayout.Parent = midCol

	local rightCol = Instance.new("ScrollingFrame")
	rightCol.Name = "RightCol"
	rightCol.Size = UDim2.new(0.32, 0, 1, 0)
	rightCol.Position = UDim2.new(0.68, 0, 0, 0)
	rightCol.BackgroundTransparency = 1
	rightCol.BorderSizePixel = 0
	rightCol.ScrollBarThickness = 2
	rightCol.ScrollBarImageColor3 = Theme.Accent
	rightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
	rightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rightCol.Parent = page
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.Padding = UDim.new(0, 15)
	rightLayout.Parent = rightCol

	local function addColumnPadding(column)
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 10)
		padding.PaddingBottom = UDim.new(0, 10)
		padding.PaddingLeft = UDim.new(0, 2)
		padding.PaddingRight = UDim.new(0, 2)
		padding.Parent = column
	end
	addColumnPadding(leftCol)
	addColumnPadding(midCol)
	addColumnPadding(rightCol)

	local function selectTab()
		for _, t in ipairs(windowSelf.Tabs) do
			t.Button.TextColor3 = Theme.TextDark
			t.Page.Visible = false
		end
		tabBtn.TextColor3 = Theme.Accent
		page.Visible = true
	end

	tabBtn.MouseButton1Click:Connect(selectTab)

	if #windowSelf.Tabs == 0 then
		selectTab()
	end

	local tabData = {
		Button = tabBtn,
		Page = page,
		Columns = {Left = leftCol, Middle = midCol, Right = rightCol}
	}
	table.insert(windowSelf.Tabs, tabData)

	local tabSelf = {}
	function tabSelf:CreateGroupbox(title, column)
		local col = tabData.Columns[column or "Left"]

		local groupbox = Instance.new("Frame")
		groupbox.Name = title .. "Groupbox"
		groupbox.Size = UDim2.new(1, 0, 0, 40)
		groupbox.BackgroundColor3 = Theme.Bg
		groupbox.BorderColor3 = Theme.BorderInner
		groupbox.BorderSizePixel = 1
		groupbox.Parent = col

		local titleLBL = Instance.new("TextLabel")
		titleLBL.Position = UDim2.new(0, 10, 0, -8)
		titleLBL.Size = UDim2.new(0, 0, 0, 16)
		titleLBL.AutomaticSize = Enum.AutomaticSize.X
		titleLBL.Text = " " .. title:lower() .. " "
		titleLBL.TextColor3 = Theme.Text
		titleLBL.TextSize = 12
		titleLBL.Font = Enum.Font.Code
		titleLBL.TextXAlignment = Enum.TextXAlignment.Left
		titleLBL.BackgroundColor3 = Theme.Bg
		titleLBL.BorderSizePixel = 0
		titleLBL.Parent = groupbox

		local elementsContainer = Instance.new("Frame")
		elementsContainer.Name = "ElementsContainer"
		elementsContainer.Size = UDim2.new(1, -20, 1, -20)
		elementsContainer.Position = UDim2.new(0, 10, 0, 12)
		elementsContainer.BackgroundTransparency = 1
		elementsContainer.Parent = groupbox

		local elementLayout = Instance.new("UIListLayout")
		elementLayout.Padding = UDim.new(0, 8)
		elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
		elementLayout.Parent = elementsContainer

		elementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			groupbox.Size = UDim2.new(1, 0, 0, elementLayout.AbsoluteContentSize.Y + 25)
		end)

		local groupSelf = {}

		function groupSelf:CreateToggle(flag, config)
			local state = config.Default or false
			
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Name = flag .. "_Toggle"
			toggleBtn.Size = UDim2.new(1, 0, 0, 18)
			toggleBtn.BackgroundTransparency = 1
			toggleBtn.Text = ""
			toggleBtn.Parent = elementsContainer

			local checkbox = Instance.new("Frame")
			checkbox.Size = UDim2.new(0, 10, 0, 10)
			checkbox.Position = UDim2.new(0, 0, 0.5, -5)
			checkbox.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg
			checkbox.BorderColor3 = Theme.BorderInner
			checkbox.Parent = toggleBtn

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -50, 1, 0)
			label.Position = UDim2.new(0, 18, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = config.Title or flag
			label.TextColor3 = state and Theme.Text or Theme.TextDark
			label.TextSize = 12
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = toggleBtn

			local function trigger(forceState)
				if forceState ~= nil then state = forceState else state = not state end
				checkbox.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg
				label.TextColor3 = state and Theme.Text or Theme.TextDark
				if config.Callback then config.Callback(state) end
			end

			toggleBtn.MouseButton1Click:Connect(function() trigger() end)

			local elementApi = {
				GetValue = function() return state end,
				SetValue = function(self, val) trigger(val) end,
				SetVisible = function(self, visible) toggleBtn.Visible = visible end
			}
			
			function elementApi:KeyBind(defaultKey, bindCallback)
				local currentKey = defaultKey
				local listening = false

				local bindBtn = Instance.new("TextButton")
				bindBtn.Size = UDim2.new(0, 45, 0, 14)
				bindBtn.Position = UDim2.new(1, -45, 0.5, -7)
				bindBtn.BackgroundColor3 = Theme.ElementBg
				bindBtn.BorderColor3 = Theme.BorderInner
				bindBtn.Text = currentKey and currentKey.Name or "[none]"
				bindBtn.TextColor3 = Theme.TextDark
				bindBtn.TextSize = 9
				bindBtn.Font = Enum.Font.Code
				bindBtn.Parent = toggleBtn

				bindBtn.MouseButton1Click:Connect(function()
					listening = true
					bindBtn.Text = "[...]"
					bindBtn.TextColor3 = Theme.Accent
				end)

				UserInputService.InputBegan:Connect(function(input, processed)
					if listening and not processed then
						listening = false
						if input.KeyCode ~= Enum.KeyCode.Escape then
							currentKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
							bindBtn.Text = currentKey.Name
						else
							currentKey = nil
							bindBtn.Text = "[none]"
						end
						bindBtn.TextColor3 = Theme.TextDark
						if bindCallback then bindCallback(currentKey) end
					elseif not listening and not processed and currentKey then
						local match = false
						if currentKey.EnumType == Enum.KeyCode and input.KeyCode == currentKey then
							match = true
						elseif currentKey.EnumType == Enum.UserInputType and input.UserInputType == currentKey then
							match = true
						end
						if match then
							trigger()
						end
					end
				end)
				return elementApi
			end

			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		local function createSliderUtility(parent, flag, config)
			local min = config.Min or 0
			local max = config.Max or 100
			local val = config.Default or min
			
			local sliderFrame = Instance.new("Frame")
			sliderFrame.Name = flag .. "_Slider"
			sliderFrame.Size = UDim2.new(1, 0, 0, 30)
			sliderFrame.BackgroundTransparency = 1
			sliderFrame.Parent = parent

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.BackgroundTransparency = 1
			label.Text = config.Title or flag
			label.TextColor3 = Theme.TextDark
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = sliderFrame

			local slideBar = Instance.new("TextButton")
			slideBar.Size = UDim2.new(1, 0, 0, 8)
			slideBar.Position = UDim2.new(0, 0, 0, 16)
			slideBar.BackgroundColor3 = Theme.ElementBg
			slideBar.BorderColor3 = Theme.BorderInner
			slideBar.Text = ""
			slideBar.Parent = sliderFrame

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((val - min)/(max - min), 0, 1, 0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.Parent = slideBar

			local valLbl = Instance.new("TextLabel")
			valLbl.Size = UDim2.new(1, 0, 1, 0)
			valLbl.BackgroundTransparency = 1
			valLbl.Text = tostring(val)
			valLbl.TextColor3 = Theme.Text
			valLbl.TextSize = 9
			valLbl.Font = Enum.Font.Code
			valLbl.Parent = slideBar

			local function updateVisuals(newVal)
				val = newVal
				local percentage = math.clamp((newVal - min) / (max - min), 0, 1)
				fill.Size = UDim2.new(percentage, 0, 1, 0)
				valLbl.Text = tostring(newVal)
				if config.Callback then config.Callback(newVal) end
			end

			local function updateFromInput(input)
				local percentage = math.clamp((input.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
				local calculated = math.floor((min + (max - min) * percentage) * 100) / 100
				updateVisuals(calculated)
			end

			local sliding = false
			slideBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = true
					updateFromInput(input)
				end
			end)
			
			slideBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromInput(input)
				end
			end)

			local elementApi = {
				GetValue = function() return val end,
				SetValue = function(self, newVal) updateVisuals(newVal) end,
				SetVisible = function(self, visible) sliderFrame.Visible = visible end
			}
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		function groupSelf:CreateSlider(flag, config)
			return createSliderUtility(elementsContainer, flag, config)
		end

		function groupSelf:CreateDropdown(flag, config)
			local options = config.Values or config.Options or {"none"}
			local currentSelection = config.Default or options[1]

			local dropdownFrame = Instance.new("Frame")
			dropdownFrame.Name = flag .. "_Dropdown"
			dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
			dropdownFrame.BackgroundTransparency = 1
			dropdownFrame.Parent = elementsContainer

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.BackgroundTransparency = 1
			label.Text = config.Title or flag
			label.TextColor3 = Theme.TextDark
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = dropdownFrame

			local selectorBtn = Instance.new("TextButton")
			selectorBtn.Size = UDim2.new(1, 0, 0, 18)
			selectorBtn.Position = UDim2.new(0, 0, 0, 16)
			selectorBtn.BackgroundColor3 = Theme.ElementBg
			selectorBtn.BorderColor3 = Theme.BorderInner
			selectorBtn.Text = "  " .. tostring(currentSelection)
			selectorBtn.TextColor3 = Theme.Text
			selectorBtn.TextSize = 11
			selectorBtn.Font = Enum.Font.Code
			selectorBtn.TextXAlignment = Enum.TextXAlignment.Left
			selectorBtn.Parent = dropdownFrame

			local optionList = Instance.new("ScrollingFrame")
			optionList.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 150))
			optionList.Position = UDim2.new(0, 0, 1, 1)
			optionList.BackgroundColor3 = Theme.Bg
			optionList.BorderColor3 = Theme.BorderInner
			optionList.BorderSizePixel = 1
			optionList.Visible = false
			optionList.ZIndex = 5
			optionList.ScrollBarThickness = 2
			optionList.ScrollBarImageColor3 = Theme.Accent
			optionList.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
			optionList.Parent = selectorBtn

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = optionList

			local function selectOption(option)
				currentSelection = option
				selectorBtn.Text = "  " .. tostring(option)
				optionList.Visible = false
				for _, child in ipairs(optionList:GetChildren()) do
					if child:IsA("TextButton") then
						child.TextColor3 = child.Text == "  " .. tostring(option) and Theme.Accent or Theme.TextDark
					end
				end
				if config.Callback then config.Callback(option) end
			end

			local function updateOptions(newOptions)
				options = newOptions
				for _, child in ipairs(optionList:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				optionList.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 150))
				optionList.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
				
				for _, option in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 18)
					optBtn.BackgroundColor3 = Theme.Bg
					optBtn.BorderSizePixel = 0
					optBtn.Text = "  " .. tostring(option)
					optBtn.TextColor3 = option == currentSelection and Theme.Accent or Theme.TextDark
					optBtn.TextSize = 11
					optBtn.Font = Enum.Font.Code
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.ZIndex = 6
					optBtn.Parent = optionList

					optBtn.MouseButton1Click:Connect(function()
						selectOption(option)
					end)
				end
			end

			updateOptions(options)

			selectorBtn.MouseButton1Click:Connect(function()
				optionList.Visible = not optionList.Visible
			end)

			local elementApi = {
				GetValue = function() return currentSelection end,
				SetValue = function(self, option) selectOption(option) end,
				Update = function(self, newOptions) updateOptions(newOptions) end,
				SetVisible = function(self, visible) dropdownFrame.Visible = visible end
			}
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		function groupSelf:CreateMultiDropdown(flag, config)
			local options = config.Values or config.Options or {"none"}
			local selections = {}
			for _, option in ipairs(options) do
				selections[option] = false
			end
			if config.Default then
				for _, option in ipairs(config.Default) do
					selections[option] = true
				end
			end

			local dropdownFrame = Instance.new("Frame")
			dropdownFrame.Name = flag .. "_MultiDropdown"
			dropdownFrame.Size = UDim2.new(1, 0, 0, 36)
			dropdownFrame.BackgroundTransparency = 1
			dropdownFrame.Parent = elementsContainer

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.BackgroundTransparency = 1
			label.Text = config.Title or flag
			label.TextColor3 = Theme.TextDark
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = dropdownFrame

			local selectorBtn = Instance.new("TextButton")
			selectorBtn.Size = UDim2.new(1, 0, 0, 18)
			selectorBtn.Position = UDim2.new(0, 0, 0, 16)
			selectorBtn.BackgroundColor3 = Theme.ElementBg
			selectorBtn.BorderColor3 = Theme.BorderInner
			selectorBtn.Text = "  ..."
			selectorBtn.TextColor3 = Theme.Text
			selectorBtn.TextSize = 11
			selectorBtn.Font = Enum.Font.Code
			selectorBtn.TextXAlignment = Enum.TextXAlignment.Left
			selectorBtn.Parent = dropdownFrame

			local optionList = Instance.new("ScrollingFrame")
			optionList.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 150))
			optionList.Position = UDim2.new(0, 0, 1, 1)
			optionList.BackgroundColor3 = Theme.Bg
			optionList.BorderColor3 = Theme.BorderInner
			optionList.BorderSizePixel = 1
			optionList.Visible = false
			optionList.ZIndex = 5
			optionList.ScrollBarThickness = 2
			optionList.ScrollBarImageColor3 = Theme.Accent
			optionList.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
			optionList.Parent = selectorBtn

			local listLayout = Instance.new("UIListLayout")
			listLayout.Parent = optionList

			local function getSelectedList()
				local list = {}
				for _, option in ipairs(options) do
					if selections[option] then
						table.insert(list, option)
					end
				end
				return list
			end

			local function updateSelectorText()
				local active = getSelectedList()
				if #active == 0 then
					selectorBtn.Text = "  none"
				else
					selectorBtn.Text = "  " .. table.concat(active, ", ")
				end
			end

			local function selectOption(option, forceState)
				if forceState ~= nil then
					selections[option] = forceState
				else
					selections[option] = not selections[option]
				end
				updateSelectorText()

				for _, child in ipairs(optionList:GetChildren()) do
					if child:IsA("TextButton") and child.Text == "  " .. tostring(option) then
						child.TextColor3 = selections[option] and Theme.Accent or Theme.TextDark
					end
				end
				
				if config.Callback then config.Callback(getSelectedList()) end
			end

			local function updateOptions(newOptions)
				options = newOptions
				selections = {}
				for _, option in ipairs(options) do
					selections[option] = false
				end
				for _, child in ipairs(optionList:GetChildren()) do
					if child:IsA("TextButton") then child:Destroy() end
				end
				optionList.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 150))
				optionList.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
				
				for _, option in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 18)
					optBtn.BackgroundColor3 = Theme.Bg
					optBtn.BorderSizePixel = 0
					optBtn.Text = "  " .. tostring(option)
					optBtn.TextColor3 = selections[option] and Theme.Accent or Theme.TextDark
					optBtn.TextSize = 11
					optBtn.Font = Enum.Font.Code
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.ZIndex = 6
					optBtn.Parent = optionList

					optBtn.MouseButton1Click:Connect(function()
						selectOption(option)
					end)
				end
				updateSelectorText()
			end

			updateOptions(options)

			selectorBtn.MouseButton1Click:Connect(function()
				optionList.Visible = not optionList.Visible
			end)

			local elementApi = {
				GetValue = function() return getSelectedList() end,
				SetValue = function(self, tbl)
					for _, opt in ipairs(options) do
						selections[opt] = table.find(tbl, opt) and true or false
					end
					for _, opt in ipairs(options) do
						selectOption(opt, selections[opt])
					end
				end,
				Update = function(self, newOptions) updateOptions(newOptions) end,
				SetVisible = function(self, visible) dropdownFrame.Visible = visible end
			}
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		function groupSelf:CreateTextbox(flag, config)
			local currentText = config.Default or ""
			
			local boxFrame = Instance.new("Frame")
			boxFrame.Name = flag .. "_Textbox"
			boxFrame.Size = UDim2.new(1, 0, 0, 36)
			boxFrame.BackgroundTransparency = 1
			boxFrame.Parent = elementsContainer

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.BackgroundTransparency = 1
			label.Text = config.Title or flag
			label.TextColor3 = Theme.TextDark
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = boxFrame

			local input = Instance.new("TextBox")
			input.Size = UDim2.new(1, 0, 0, 18)
			input.Position = UDim2.new(0, 0, 0, 16)
			input.BackgroundColor3 = Theme.ElementBg
			input.BorderColor3 = Theme.BorderInner
			input.Text = currentText
			input.PlaceholderText = config.Placeholder or "Type here..."
			input.TextColor3 = Theme.Text
			input.TextSize = 11
			input.Font = Enum.Font.Code
			input.TextXAlignment = Enum.TextXAlignment.Left
			input.ClearTextOnFocus = false
			input.Parent = boxFrame

			local function updateText(txt)
				currentText = txt
				if config.Callback then config.Callback(txt) end
			end

			input.FocusLost:Connect(function(enterPressed)
				updateText(input.Text)
			end)

			local elementApi = {
				GetValue = function() return currentText end,
				SetValue = function(self, txt)
					input.Text = txt
					updateText(txt)
				end,
				SetVisible = function(self, visible) boxFrame.Visible = visible end
			}
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		function groupSelf:CreateCharacterHitboxSelector(flag, config)
			local selectionStates = {
				Head = false,
				Torso = false,
				["Left Arm"] = false,
				["Right Arm"] = false,
				["Left Leg"] = false,
				["Right Leg"] = false
			}

			local charFrame = Instance.new("Frame")
			charFrame.Name = flag .. "_Hitbox"
			charFrame.Size = UDim2.new(1, 0, 0, 160)
			charFrame.BackgroundTransparency = 1
			charFrame.Parent = elementsContainer

			local grid = Instance.new("Frame")
			grid.Size = UDim2.new(0, 100, 0, 150)
			grid.Position = UDim2.new(0.5, -50, 0.5, -75)
			grid.BackgroundTransparency = 1
			grid.Parent = charFrame

			local partButtons = {}

			local function setStates(newStates)
				selectionStates = newStates
				for name, active in pairs(selectionStates) do
					local btn = partButtons[name]
					if btn then
						btn.BackgroundColor3 = active and Theme.HitboxActive or Theme.HitboxInactive
					end
				end
				local activeParts = {}
				for partName, isSelected in pairs(selectionStates) do
					if isSelected then table.insert(activeParts, partName) end
				end
				if config.Callback then config.Callback(activeParts) end
			end

			local function createPart(name, size, pos)
				local btn = Instance.new("TextButton")
				btn.Name = name
				btn.Size = size
				btn.Position = pos
				btn.BackgroundColor3 = Theme.HitboxInactive
				btn.BorderColor3 = Theme.BorderInner
				btn.Text = ""
				btn.Parent = grid
				partButtons[name] = btn

				btn.MouseButton1Click:Connect(function()
					selectionStates[name] = not selectionStates[name]
					btn.BackgroundColor3 = selectionStates[name] and Theme.HitboxActive or Theme.HitboxInactive

					local activeParts = {}
					for partName, isSelected in pairs(selectionStates) do
						if isSelected then table.insert(activeParts, partName) end
					end
					if config.Callback then config.Callback(activeParts) end
				end)
			end

			createPart("Head", UDim2.new(0, 24, 0, 24), UDim2.new(0.5, -12, 0, 0))
			createPart("Torso", UDim2.new(0, 48, 0, 48), UDim2.new(0.5, -24, 0, 28))
			createPart("Left Arm", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, -50, 0, 28))
			createPart("Right Arm", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, 28, 0, 28))
			createPart("Left Leg", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, -24, 0, 80))
			createPart("Right Leg", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, 2, 0, 80))

			local elementApi = {
				GetValue = function()
					local activeParts = {}
					for partName, isSelected in pairs(selectionStates) do
						if isSelected then table.insert(activeParts, partName) end
					end
					return activeParts
				end,
				SetValue = function(self, newStates) setStates(newStates) end,
				SetVisible = function(self, visible) charFrame.Visible = visible end
			}
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		function groupSelf:CreateCharacterHitboxSelectorButAdjust(flag, config)
			local activePart = nil
			local partValues = {
				Head = 100,
				Torso = 100,
				["Left Arm"] = 100,
				["Right Arm"] = 100,
				["Left Leg"] = 100,
				["Right Leg"] = 100
			}

			local charFrame = Instance.new("Frame")
			charFrame.Name = flag .. "_HitboxAdjust"
			charFrame.Size = UDim2.new(1, 0, 0, 160)
			charFrame.BackgroundTransparency = 1
			charFrame.Parent = elementsContainer

			local grid = Instance.new("Frame")
			grid.Size = UDim2.new(0, 100, 0, 150)
			grid.Position = UDim2.new(0, 10, 0.5, -75)
			grid.BackgroundTransparency = 1
			grid.Parent = charFrame

			local vertSlider = Instance.new("Frame")
			vertSlider.Name = "VerticalSlider"
			vertSlider.Size = UDim2.new(0, 10, 0, 120)
			vertSlider.Position = UDim2.new(0, 135, 0.5, -60)
			vertSlider.BackgroundColor3 = Theme.ElementBg
			vertSlider.BorderColor3 = Theme.BorderInner
			vertSlider.Visible = false
			vertSlider.Parent = charFrame

			local vertFill = Instance.new("Frame")
			vertFill.Size = UDim2.new(1, 0, 1, 0)
			vertFill.Position = UDim2.new(0, 0, 0, 0)
			vertFill.BackgroundColor3 = Theme.Accent
			vertFill.BorderSizePixel = 0
			vertFill.Parent = vertSlider

			local vertLbl = Instance.new("TextLabel")
			vertLbl.Size = UDim2.new(0, 30, 0, 14)
			vertLbl.Position = UDim2.new(0, -10, 0, -16)
			vertLbl.BackgroundTransparency = 1
			vertLbl.Text = "100"
			vertLbl.TextColor3 = Theme.Text
			vertLbl.TextSize = 10
			vertLbl.Font = Enum.Font.Code
			vertLbl.Parent = vertSlider

			local partButtons = {}

			local function updateVerticalSliderVisuals(val)
				local percentage = math.clamp(val / 100, 0, 1)
				vertFill.Size = UDim2.new(1, 0, percentage, 0)
				vertFill.Position = UDim2.new(0, 0, 1 - percentage, 0)
				vertLbl.Text = tostring(val)
			end

			local function selectPart(name)
				activePart = name
				for pName, btn in pairs(partButtons) do
					btn.BackgroundColor3 = pName == name and Theme.HitboxActive or Theme.HitboxInactive
				end

				vertSlider.Visible = true
				updateVerticalSliderVisuals(partValues[name])

				if config.Callback then config.Callback({ [activePart] = partValues[name] }) end
			end

			local function createPart(name, size, pos)
				local btn = Instance.new("TextButton")
				btn.Name = name
				btn.Size = size
				btn.Position = pos
				btn.BackgroundColor3 = Theme.HitboxInactive
				btn.BorderColor3 = Theme.BorderInner
				btn.Text = ""
				btn.Parent = grid

				partButtons[name] = btn

				btn.MouseButton1Click:Connect(function()
					selectPart(name)
				end)
			end

			createPart("Head", UDim2.new(0, 24, 0, 24), UDim2.new(0.5, -12, 0, 0))
			createPart("Torso", UDim2.new(0, 48, 0, 48), UDim2.new(0.5, -24, 0, 28))
			createPart("Left Arm", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, -50, 0, 28))
			createPart("Right Arm", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, 28, 0, 28))
			createPart("Left Leg", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, -24, 0, 80))
			createPart("Right Leg", UDim2.new(0, 22, 0, 48), UDim2.new(0.5, 2, 0, 80))

			local function updateSliderFromInput(input)
				local absoluteY = vertSlider.AbsolutePosition.Y
				local absoluteSizeY = vertSlider.AbsoluteSize.Y
				local percentage = math.clamp(1 - ((input.Position.Y - absoluteY) / absoluteSizeY), 0, 1)
				local val = math.floor(percentage * 100)

				partValues[activePart] = val
				updateVerticalSliderVisuals(val)

				if config.Callback then config.Callback({ [activePart] = val }) end
			end

			local sliding = false
			vertSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and activePart then
					sliding = true
					updateSliderFromInput(input)
				end
			end)

			vertSlider.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sliding = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateSliderFromInput(input)
				end
			end)

			local elementApi = {
				GetValue = function()
					return activePart and { [activePart] = partValues[activePart] } or {}
				end,
				SetValue = function(self, name, val)
					if partValues[name] then
						partValues[name] = val
						if activePart == name then
							updateVerticalSliderVisuals(val)
						end
						if config.Callback then config.Callback({ [name] = val }) end
					end
				end,
				GetRates = function()
					return partValues
				end,
				SetVisible = function(self, visible) charFrame.Visible = visible end
			}
			
			windowSelf.Options[flag] = elementApi
			return elementApi
		end

		return groupSelf
	end

	return tabSelf
end

return SkeetLib
