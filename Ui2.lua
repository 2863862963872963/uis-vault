local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService") 


local hui = function()
	if RunService:IsStudio() then
		return game:GetService("Players").LocalPlayer.PlayerGui or game:GetService("CoreGui")
	else
		return gethui()
	end
end


local Library = {
	Connections = {},
	MobileMode = UserInputService.TouchEnabled,
	Notifications = {}
} 

local function Create(Name, Properties, Children)
	local Object = Instance.new(tostring(Name))
	for i, v in next, Properties or {} do
		Object[tostring(i)] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function AddConnection(Signal, Function)
	if (not Library.GUI or not Library.GUI.Parent) then return end
	local Connection = Signal:Connect(Function)
	table.insert(Library.Connections, Connection)
	return Connection
end

-- Fixed draggable for mobile
local function MakeDraggable(frame)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
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

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, 
	Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, 
	Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
	return false
end

-- Clean up old GUI
pcall(function()
	if Library.GUI then 
		for _, conn in ipairs(Library.Connections) do
			pcall(function() conn:Disconnect() end)
		end
		Library.Connections = {}
		Library.GUI:Destroy() 
	end
end)

local GUI = Create("ScreenGui", {
	Parent = RunService:IsStudio() and game:GetService("Players").LocalPlayer.PlayerGui or game:GetService("CoreGui")
})

Library.GUI = GUI
Library.FirstTabs = {}
Library.NotificationHolder = Create("Frame", {
	Name = "NotificationSection",
	Parent = Library.GUI,
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1.000,
	BorderColor3 = Color3.fromRGB(0, 0, 0),
	BorderSizePixel = 0,
	Position = UDim2.new(0.919387758, 0, 0.5, 0),
	Size = UDim2.new(0.25, 0, 1, 0)
})

-- Fixed notification system
function Library.AddNotification(configs)
	configs = configs or {}
	configs.Title = configs.Title or "Notification"
	configs.Content = configs.Content or "notif"
	configs.AutoClose = configs.AutoClose or true  -- Fixed: was using Content as boolean
	configs.AutoCloseDelay = configs.AutoCloseDelay or 5

	local NotificationSection = Library.NotificationHolder

	-- Clear existing layout to avoid duplicates
	for _, child in ipairs(NotificationSection:GetChildren()) do
		if child:IsA("UIListLayout") or child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	Create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 20),
		Parent = NotificationSection
	})
	Create("UIPadding", {
		PaddingBottom = UDim.new(0,20),
		PaddingTop = UDim.new(0,20),
		Parent = NotificationSection
	})

	local Notification = Create("Frame", {
		Name = "MacNotification",
		BackgroundColor3 = Color3.fromRGB(12, 12, 12),
		BackgroundTransparency = 0.150,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(-1.68405139, 0, 0.446932018, 0),
		Size = UDim2.new(0, 240, 0, 65),
		Parent = NotificationSection
	}, {
		Create("UICorner", {
			Name = "MacCorner",
			CornerRadius = UDim.new(0,4)
		}),
		Create("UIStroke", {
			Name = "MacUIStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(30, 30, 30),
			Thickness = 1.25
		}),
		Create("Frame", {
			Name = "DropShadowHolder",
			BackgroundTransparency = 1.000,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 0
		}, {
			Create("ImageLabel", {
				Name = "DropShadow",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1.000,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 47, 1, 47),
				ZIndex = 0,
				Image = "rbxassetid://6014261993",
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 0.500,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(49, 49, 450, 450)
			})
		}),
		Create("TextButton", {
			Name = "CloseNotificationButton",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 90, 82),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Position = UDim2.new(0.00999999978, 0, 0, 0),
			Size = UDim2.new(0, 12, 0, 12),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 1.000,
			BackgroundTransparency = 1
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(1,0)
			}),
		}),
		Create("TextLabel", {
			Name = "NotificationTitle",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(0, 240, 0, 0),
			FontFace = Font.new("rbxassetid://12187365977"),
			Text = configs.Title,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 17.000,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Create("UIPadding", {
				PaddingBottom = UDim.new(0,10),
				PaddingTop = UDim.new(0,10),
				PaddingLeft = UDim.new(0,15)
			})
		}),
		Create("TextLabel", {
			Name = "NotificationContentText",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1.000,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(0, 216, 0, 0),
			FontFace = Font.new("rbxassetid://12187365977"),
			Text = configs.Content,
			TextColor3 = Color3.fromRGB(170, 170, 170),
			TextSize = 14.000,
			TextStrokeColor3 = Color3.fromRGB(170, 170, 170),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			Create("UIPadding", {
				PaddingBottom = UDim.new(0,10),
				PaddingTop = UDim.new(0,10),
				PaddingLeft = UDim.new(0,15)
			})
		})
	})

	-- Fixed animation cleanup
	local function DestroyNotification()
		pcall(function()
			TweenService:Create(Notification.CloseNotificationButton, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(Notification.DropShadowHolder, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(Notification, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
			TweenService:Create(Notification.NotificationTitle, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
			TweenService:Create(Notification.NotificationContentText, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
			TweenService:Create(Notification.MacUIStroke, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 0}):Play()
			TweenService:Create(Notification.DropShadowHolder.DropShadow, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 1}):Play()
		end)
		task.wait(0.125)
		pcall(function() Notification:Destroy() end)
	end

	Notification.MouseEnter:Connect(function()
		TweenService:Create(Notification.CloseNotificationButton, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.125}):Play()
	end)
	Notification.MouseLeave:Connect(function()
		TweenService:Create(Notification.CloseNotificationButton, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
	end)

	Notification.CloseNotificationButton.MouseButton1Click:Connect(DestroyNotification)

	-- Auto close (fixed)
	if configs.AutoClose then
		task.wait(configs.AutoCloseDelay)
		pcall(DestroyNotification)
	end
end

function Library.Load(configs)
	configs = configs or {}
	configs.Title = configs.Title or ""

	local mainFrame = Create("Frame", {
		Parent = GUI,
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(10, 10, 10),
		BackgroundTransparency = 0.05,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(750, 450)
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 15)
		}), 
		Create("Frame", {
			Name = ("Title"),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.019, 0.129),
			Size = UDim2.fromOffset(163, 40)
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(0,6)
			}),
			Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(30, 30, 30),
				Thickness = 1.25,
			}),
			Create("TextLabel", {
				FontFace = Font.new("rbxassetid://12187365977"),
				Text = configs.Title,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 17,
				TextStrokeTransparency = 0,
				TextWrapped = true,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1)
			})
		}),
		Create("Frame", {
			Name = "lineSeperators",
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			BorderColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(0, 50),
			Size = UDim2.fromOffset(191, 1),
		}),
		Create("Frame", {
			Name = "lineSeperators",
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			BorderColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(-29, 225),
			Rotation = 90,
			Size = UDim2.fromOffset(445, 1)
		}),
		Create("Frame", {
			Name = "lineSeperators",
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			BorderColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromOffset(0, 105),
			Size = UDim2.fromOffset(191, 1),
		}),
		Create("Frame", {
			Name = "lineSeperators",
			BackgroundColor3 = Color3.fromRGB(27, 27, 27),
			BorderColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.new(0, 0, 1, -65),
			Size = UDim2.fromOffset(191, 1)
		}),
		Create("Frame", {
			Name = ("Shadow"),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 0
		}, {
			Create("ImageLabel", {
				Name = ("DropShadow"),
				Image = ("rbxassetid://6014261993"),
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = .5,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(49, 49, 450, 450),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, 47, 1, 47),
				ZIndex = 0
			}),
		}),
		Create("ScrollingFrame", {
			Name = "tabButtonsFrame",
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarImageTransparency = 1,
			Active = true,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 120),
			Size = UDim2.fromOffset(191, 250),
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(0, 15)
			}),
			Create("UIListLayout", {
				Name = "Buttons Frame UI List layout",
				Padding = UDim.new(0, 15),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Create("UIPadding", {
				Name = ("Buttoms Frame UI Padding"),
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5)
			}),
		}),
		Create("ImageLabel", {
			Name = "hrznPFP",
			Image = "rbxassetid://18383313777",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.0187, 0.878),
			Size = UDim2.fromOffset(40, 40),
			Parent = mainFrame
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			Create("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(0, 143, 0),
				Thickness = 2
			}),
			Create("TextLabel", {
				Name = "TextLabel",
				FontFace = Font.new("rbxassetid://12187365977"),
				Text = "UI made by .hrzn.",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(2.22, 0),
				Size = UDim2.fromScale(1, 1)
			})
		}),
		Create("Frame",{
			Name = "trafficLights",
			BackgroundColor3 = Color3.fromRGB(9, 9, 9),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(191, 50),
		}, {
			Create("TextButton", {
				Name = "Red",
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 1,
				BackgroundColor3 = Color3.fromRGB(255, 90, 82),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.05, 0.2),
				Size = UDim2.fromOffset(12, 12)
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0)
				})
			}),
			Create("TextButton", {
				Name = "Yellow",
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 1,
				BackgroundColor3 = Color3.fromRGB(255, 192, 57),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.15, 0.2),
				Size = UDim2.fromOffset(12, 12)
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0)
				})
			}),
			Create("TextButton", {
				Name = "Green",
				FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 1,
				BackgroundColor3 = Color3.fromRGB(81, 194, 58),
				BorderColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.25, 0.2),
				Size = UDim2.fromOffset(12, 12)
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0)
				}),
			})
		})
	})

	mainFrame.trafficLights.Red.MouseButton1Click:Connect(function()
		Library.GUI:Destroy()
	end)
	MakeDraggable(mainFrame)

	return {AddTab = function(TabName, FirstTab)
		local TabsButton = Create("TextButton", {
			Name = "TabsButton",
			Parent = mainFrame.tabButtonsFrame,
			FontFace = Font.new("rbxassetid://12187365977"),
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromRGB(16, 16, 16),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(163, 45),
			Position = UDim2.fromScale(0.0683, 0.516)
		}, {
			Create("UICorner", {
				CornerRadius = UDim.new(0, 6)
			}),
			Create("UIStroke", {
				Name = ("TabsButtonUIStroke"),
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Color3.fromRGB(30, 30, 30),
				Thickness = 1.25,
				Transparency = 1
			}),
			Create("TextLabel", {
				Name = "TabLabel",
				FontFace = Font.new("rbxassetid://12187365977"),
				Text = TabName,
				TextColor3 = Color3.fromRGB(170,170,170),
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1)
			}),
			Create("UIPadding", {
				PaddingLeft = UDim.new(0, 15)
			})
		})

		local SectionHolders = Create("Frame", {
			Name = ("SectionsHolders"),
			Parent = mainFrame,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = UDim2.fromScale(0.255, 0.025),
			Size = UDim2.fromScale(0.745, 0.95),
			Visible = false
		}, {
			Create("Frame", {
				Name = ("lineSeperators[TabsFrame]"),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(27, 27, 27),
				BorderColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Rotation = 90,
				Size = UDim2.fromOffset(445, 1)
			}),
			Create("ScrollingFrame", {
				Name = ("sectionsLeft"),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarImageTransparency = 1,
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = false,
				Position = UDim2.fromScale(0.25, 0.5),
				Size = UDim2.fromScale(0.49, 1)
			}, {
				Create("UIListLayout", {
					Name = "UIListLayout",
					Padding = UDim.new(0, 20),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5)
				})
			}),
			Create("ScrollingFrame", {
				Name = ("sectionsRight"),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarImageTransparency = 1,
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = false,
				Position = UDim2.fromScale(0.75, 0.5),
				Size = UDim2.fromScale(0.49, 1)
			}, {
				Create("UIListLayout", {
					Name = "UIListLayout",
					Padding = UDim.new(0, 20),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5)
				})
			})
		})

		if FirstTab == true then
			Library.FirstTabs.TabButton = TabsButton
			Library.FirstTabs.TabsHolder = SectionHolders
			SectionHolders.Visible = true

			TweenService:Create(TabsButton, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabsButton.TabLabel, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(TabsButton.TabsButtonUIStroke, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
		end

		TabsButton.MouseButton1Click:Connect(function()
			for _,TabsFrames in pairs(mainFrame:GetChildren()) do
				if TabsFrames:IsA("Frame") and TabsFrames.Name == "SectionsHolders" then
					TabsFrames.Visible = false
				end
			end
			SectionHolders.Visible = true

			for _,Buttons in pairs(mainFrame.tabButtonsFrame:GetChildren()) do
				if Buttons:IsA("TextButton") then
					TweenService:Create(Buttons, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
					TweenService:Create(Buttons.TabLabel, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(170, 170, 170)}):Play()
					TweenService:Create(Buttons.TabsButtonUIStroke, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
				end
			end

			TweenService:Create(TabsButton, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabsButton.TabLabel, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
			TweenService:Create(TabsButton.TabsButtonUIStroke, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
		end)

		return {AddSection =  function(Name, Location)
			local sectionparent = nil
			if Location == "Left" then 
				sectionparent = SectionHolders.sectionsLeft
			else
				sectionparent = SectionHolders.sectionsRight
			end
			local Section = Create("Frame", {
				Name = ("Section"),
				Parent = sectionparent,
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(14, 14, 14),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.05, -0.355),
				Size = UDim2.fromScale(0.9, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXX
			}, {
				Create("UIStroke", {
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(30, 30, 30),
					Thickness = 1.25
				}),
				Create("UICorner", {
					CornerRadius = UDim.new(0, 6)
				}),
				Create("UIListLayout", {
					Padding = UDim.new(0, 15),
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Create("UIPadding", {
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 10)
				})
			})

			return {

				AddToggle = function(configs)
					configs.Name = configs.Name or "Toggle"
					configs.Callback = configs.Callback or function() end
					configs.Identifier = configs.Identifier or ""
					configs.Default = configs.Default or false
					configs.Value = configs.Default
					configs.Type = "Toggle"

					local Toggle = Create("TextButton", {
						Name = configs.Identifier, 
						FontFace = Font.new("rbxassetid://12187365977"),
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.025, 0),
						Size = UDim2.new(0.95, 0, 0, 40),
						Parent = Section
					},{
						Create("UICorner", {
							CornerRadius = UDim.new(0, 4)
						}),
						Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(30, 30, 30),
							Thickness = 1.25
						}),
						Create("TextLabel", {
							Name = "ToggleText",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.fromScale(1, 1)
						}),
						Create("UIPadding", {
							PaddingLeft = UDim.new(0, 15)
						}),
						Create("TextButton", {
							Name = "ToggleStatus",
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
							Text = "",
							TextColor3 = Color3.fromRGB(0, 0, 0),
							TextSize = 0,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(81, 194, 58),
							BorderColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.9, 0.5),
							Size = UDim2.fromOffset(12, 12),
							AutoButtonColor = false
						}, {
							Create("UICorner", {
								CornerRadius = UDim.new(0, 5)
							}),
							Create("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(30, 30, 30),
								Thickness = 1.25
							})
						})
					})

					Toggle.MouseButton1Click:Connect(function()
						configs:Set(not configs.Value)
					end)

					-- Fixed: Added touch support
					if Library.MobileMode then
						Toggle.TouchTap:Connect(function()
							configs:Set(not configs.Value)
						end)
					end

					function configs:Set(Value)
						self.Value = Value
						TweenService:Create(Toggle.ToggleStatus, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = self.Value and 0 or 1}):Play()
						TweenService:Create(Toggle.ToggleText, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = self.Value and Color3.fromRGB(255,255,255) or Color3.fromRGB(175,175,175)}):Play()
						return configs.Callback(self.Value)
					end

					configs:Set(configs.Default)
					return configs
				end,

				AddButton = function(configs)
					configs.Name = configs.Name or "Button"
					configs.Callback = configs.Callback or function() end
					configs.Identifier = configs.Identifier or ""

					local Button = Create("TextButton", {
						Name = configs.Identifier,
						FontFace = Font.new("rbxassetid://12187365977"),
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BackgroundTransparency = 0,
						Parent = Section,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.025, 0),
						Size = UDim2.new(0.95, 0, 0, 40)
					}, {
						Create("UICorner", {
							CornerRadius = UDim.new(0, 4)
						}),
						Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(30, 30, 30),
							Thickness = 1.25
						}),
						Create("TextLabel", {
							Name = "ButtonText",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.fromScale(1, 1)
						}),
						Create("UIPadding", {
							PaddingLeft = UDim.new(0, 15)
						})
					})

					local function animateAndCallback()
						configs.Callback()
						TweenService:Create(Button.ButtonText, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(170,170,170)}):Play()
						task.wait(.125)
						TweenService:Create(Button.ButtonText, TweenInfo.new(.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
					end

					Button.MouseButton1Click:Connect(animateAndCallback)
					if Library.MobileMode then
						Button.TouchTap:Connect(animateAndCallback)
					end
				end,

				AddBind = function(configs)
					configs.Name = configs.Name or "Keybind"
					configs.Identifier = configs.Identifier or "Keybind"
					configs.SelectedBind = configs.SelectedBind or "..."
					configs.Hold = configs.Hold or false
					configs.Default = configs.Default or Enum.KeyCode.Unknown

					local Bind = {Value = configs.Default, Binding = false, Type = "Bind"}
					local Holding = false

					local KeyBind = Create("TextButton", {
						Name = configs.Identifier,
						FontFace = Font.new("rbxassetid://12187365977"),
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.025, 0),
						Size = UDim2.new(0.95, 0, 0, 40),
						Parent = Section
					}, {
						Create("UICorner", {
							CornerRadius = UDim.new(0, 4)
						}),
						Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(30, 30, 30),
							Thickness = 1.25
						}),
						Create("TextLabel", {
							Name = "KeyBindText",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Size = UDim2.fromScale(0.599, 1)
						}),
						Create("UIPadding", {
							PaddingLeft = UDim.new(0, 15)
						}),
						Create("TextLabel", {
							Name = "KeyBindValueText",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.SelectedBind,
							TextColor3 = Color3.fromRGB(130, 130, 130),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Right,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.9, 0.5),
							Size = UDim2.new(0, 12, 1, 0),
						}),
					})

					-- Fixed binding logic
					KeyBind.MouseButton1Click:Connect(function()
						if Bind.Binding then 
							Bind.Binding = false
							KeyBind.KeyBindValueText.Text = Bind.Value.Name or Bind.Value
						else
							Bind.Binding = true
							KeyBind.KeyBindValueText.Text = "..."
						end
					end)

					AddConnection(UserInputService.InputBegan, function(Input)
						if UserInputService:GetFocusedTextBox() then return end

						if Bind.Binding then
							local Key
							if not CheckKey(BlacklistedKeys, Input.KeyCode) and Input.KeyCode ~= Enum.KeyCode.Unknown then
								Key = Input.KeyCode
							elseif CheckKey(WhitelistedMouse, Input.UserInputType) then
								Key = Input.UserInputType
							end
							if Key then
								Bind:Set(Key)
							end
						else
							if (Input.KeyCode == Bind.Value or Input.UserInputType == Bind.Value) and Bind.Value and Bind.Value ~= Enum.KeyCode.Unknown then
								if configs.Hold then
									Holding = true
									configs.Callback(Holding)
								else
									configs.Callback()
								end
							end
						end
					end)

					AddConnection(UserInputService.InputEnded, function(Input)
						if configs.Hold and Holding and (Input.KeyCode == Bind.Value or Input.UserInputType == Bind.Value) then
							Holding = false
							configs.Callback(Holding)
						end
					end)

					function Bind:Set(Key)
						Bind.Binding = false
						Bind.Value = Key or Bind.Value
						local displayName = Bind.Value.Name or tostring(Bind.Value)
						KeyBind.KeyBindValueText.Text = displayName
					end

					Bind:Set(configs.Default)
					return Bind
				end,

				AddSlider = function(configs)
					configs = configs or {}
					configs.Name = configs.Name or "Slider"
					configs.Identifier = configs.Identifier or "Slider"
					configs.Min = configs.Min or 0
					configs.Max = configs.Max or 20
					configs.Increment = configs.Increment or 1
					configs.Default = configs.Default or 10
					configs.Callback = configs.Callback or function() end
					configs.Value = configs.Default or 0
					configs.Dragging = false

					local Slider = Create("Frame", {
						Name = configs.Identifier,
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.025, 0.142),
						Size = UDim2.new(0.95, 0, 0, 65),
						Parent = Section
					}, {
						Create("UICorner", {
							CornerRadius = UDim.new(0,4)
						}),
						Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(30, 30, 30),
							Thickness = 1.25
						}),
						Create("TextLabel", {
							Name = "SliderName",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0, 0.3),
							Size = UDim2.fromScale(1, 0)
						}, {
							Create("UIPadding", {
								PaddingLeft = UDim.new(0, 15)
							}),
						}),
						Create("TextLabel", {
							Name = "SliderNumber",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = tostring(configs.Value),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Right,
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.9, 0.3),
							Size = UDim2.fromOffset(12, 12)
						}, {
							Create("UIPadding", {
								PaddingLeft = UDim.new(0, 15)
							}),
						}),
						Create("Frame", {
							Name = "SliderBar",
							BackgroundColor3 = Color3.fromRGB(16, 16, 16),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0.075, 0.712),
							Size = UDim2.new(0.85, 0, 0, 0),
							BackgroundTransparency = 1
						}, {
							Create("UICorner", {
								CornerRadius = UDim.new(0,4)
							}),
							Create("UIStroke", {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Color = Color3.fromRGB(30, 30, 30),
								Thickness = 1.25
							}),
							Create("TextButton", {
								Name = "SliderDot",
								FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
								Text = "",
								TextColor3 = Color3.fromRGB(0, 0, 0),
								TextSize = 1,
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = Color3.fromRGB(58, 58, 58),
								BorderColor3 = Color3.fromRGB(255, 255, 255),
								BorderSizePixel = 0,
								Position = UDim2.fromScale(0.5, 0.5),
								Size = UDim2.fromOffset(12, 12)
							}, {
								Create("UICorner", {
									CornerRadius = UDim.new(0,5)
								}),
								Create("UIStroke", {
									ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
									Color = Color3.fromRGB(30, 30, 30),
									Thickness = 1.25
								}),
							}),
						}),
					})

					-- Fixed slider dragging for both mouse and touch
					local function startDrag()
						configs.Dragging = true
					end

					local function endDrag()
						configs.Dragging = false
					end

					Slider.SliderBar.SliderDot.InputBegan:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							startDrag()
						end
					end)

					Slider.SliderBar.SliderDot.InputEnded:Connect(function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
							endDrag()
						end
					end)

					AddConnection(UserInputService.InputChanged, function(Input)
						if configs.Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
							local barPos = Slider.SliderBar.AbsolutePosition.X
							local barSize = Slider.SliderBar.AbsoluteSize.X
							local mouseX = Input.Position.X
							local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
							local newValue = configs.Min + ((configs.Max - configs.Min) * percent)
							configs:Set(newValue)
						end
					end)

					function configs:Set(Value)
						self.Value = math.clamp(Round(Value, configs.Increment), configs.Min, configs.Max)
						Slider.SliderNumber.Text = tostring(self.Value)

						local newPosition = UDim2.new(
							(self.Value - configs.Min) / (configs.Max - configs.Min), 0, 
							Slider.SliderBar.SliderDot.Position.Y.Scale, Slider.SliderBar.SliderDot.Position.Y.Offset
						)
						TweenService:Create(Slider.SliderBar.SliderDot, TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = newPosition}):Play()
						return configs.Callback(configs.Value)
					end

					configs:Set(configs.Default)
					return configs
				end,

				AddDropdown = function(configs)
					configs = configs or {}
					configs.Name = configs.Name or "Dropdown"
					configs.Identifier = configs.Identifier or "Dropdown"
					configs.Options = configs.Options or {"Option 1", "Option 2"}
					configs.Default = configs.Default or configs.Options[1]
					configs.Callback = configs.Callback or function() end

					local value = configs.Default
					local open = false
					local dropdownFrame = nil

					local DropdownButton = Create("TextButton", {
						Name = configs.Identifier,
						FontFace = Font.new("rbxassetid://12187365977"),
						Text = "",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 14,
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(18, 18, 18),
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.025, 0),
						Size = UDim2.new(0.95, 0, 0, 40),
						Parent = Section
					}, {
						Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
						Create("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.fromRGB(30, 30, 30),
							Thickness = 1.25
						}),
						Create("TextLabel", {
							Name = "DropdownText",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = configs.Name,
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 16,
							TextXAlignment = Enum.TextXAlignment.Left,
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 1,
							Size = UDim2.fromScale(0.7, 1)
						}),
						Create("UIPadding", {PaddingLeft = UDim.new(0, 15)}),
						Create("TextLabel", {
							Name = "DropdownValue",
							FontFace = Font.new("rbxassetid://12187365977"),
							Text = value,
							TextColor3 = Color3.fromRGB(130, 130, 130),
							TextSize = 14,
							TextXAlignment = Enum.TextXAlignment.Right,
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(0.95, 0, 0.5, 0),
							Size = UDim2.new(0, 100, 1, 0)
						})
					})

					-- Create dropdown menu (initially hidden)
					local function createDropdownMenu()
						if dropdownFrame then return end

						dropdownFrame = Create("Frame", {
							Name = "DropdownMenu",
							Parent = Section,
							BackgroundColor3 = Color3.fromRGB(25, 25, 25),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(0.025, 0, 0, 45),
							Size = UDim2.new(0.95, 0, 0, 0),
							ClipsDescendants = true,
							Visible = false,
							ZIndex = 2
						}, {
							Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
							Create("UIStroke", {
								Color = Color3.fromRGB(30, 30, 30),
								Thickness = 1.25
							}),
							Create("UIListLayout", {
								Padding = UDim.new(0, 2),
								HorizontalAlignment = Enum.HorizontalAlignment.Center
							})
						})

						-- Add options
						for _, option in ipairs(configs.Options) do
							local optionButton = Create("TextButton", {
								Name = option,
								Text = option,
								TextColor3 = Color3.fromRGB(200, 200, 200),
								TextSize = 14,
								FontFace = Font.new("rbxassetid://12187365977"),
								BackgroundColor3 = Color3.fromRGB(25, 25, 25),
								BackgroundTransparency = 0,
								BorderSizePixel = 0,
								Size = UDim2.new(1, 0, 0, 35),
								AutoButtonColor = false,
								Parent = dropdownFrame
							}, {
								Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
								Create("UIPadding", {PaddingLeft = UDim.new(0, 15)})
							})

							optionButton.MouseEnter:Connect(function()
								TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
							end)

							optionButton.MouseLeave:Connect(function()
								TweenService:Create(optionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
							end)

							optionButton.MouseButton1Click:Connect(function()
								value = option
								DropdownButton.DropdownValue.Text = value
								configs.Callback(value)
								closeDropdown()
							end)
						end
					end

					local function openDropdown()
						createDropdownMenu()
						local optionCount = #configs.Options
						local height = math.min(optionCount * 37, 200)
						dropdownFrame.Visible = true
						dropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, height), "Out", "Quad", 0.2, true)
						open = true
					end

					local function closeDropdown()
						if dropdownFrame then
							dropdownFrame:TweenSize(UDim2.new(0.95, 0, 0, 0), "Out", "Quad", 0.2, true)
							task.wait(0.2)
							dropdownFrame.Visible = false
						end
						open = false
					end

					DropdownButton.MouseButton1Click:Connect(function()
						if open then
							closeDropdown()
						else
							openDropdown()
						end
					end)

					-- Close dropdown when clicking outside
					UserInputService.InputBegan:Connect(function(input)
						if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
							local mousePos = UserInputService:GetMouseLocation()
							if dropdownFrame and dropdownFrame.AbsoluteSize.Y > 0 then
								local framePos = dropdownFrame.AbsolutePosition
								if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + dropdownFrame.AbsoluteSize.X and
									mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + dropdownFrame.AbsoluteSize.Y) then
									closeDropdown()
								end
							end
						end
					end)

					return {
						Get = function() return value end,
						Set = function(newValue)
							value = newValue
							DropdownButton.DropdownValue.Text = value
							configs.Callback(value)
						end
					}
				end
			}
		end}
	end}
end

return Library
