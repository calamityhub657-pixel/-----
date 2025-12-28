
-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals --[[!nl]]--local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.tools)
local ElementsTable = require(script.Parent.elements)
local Components = script.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local isMobile = Tools.isMobile()
local GetPropsCurrentTheme = Tools.GetPropsCurrentTheme
local CancelTween = Tools.CancelTween
local RemoveThemedObject = Tools.RemoveThemedObject
local RemoveManagedUIElement = Tools.RemoveManagedUIElement

--[[!nl]]--type LibraryConfig = {
    Title: string?,
    ToggleButton: string?,
    BindGui: Enum.KeyCode?,
}

type TabContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: typeof(Library),
}

--[[!nl]]--local function generateRandomString(length: number): string
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/`~"
    local randomString = ""
    math.randomseed(tick() * 1000)) -- Use tick() for more variation
    -- Original: math.randomseed(os.time()) 

    for i = 1, length do
        local randomIndex = math.random(1, #charset)
        randomString = randomString .. charset:sub(randomIndex, randomIndex)
    end

    return randomString
end

--[[!nl]]--local function MakeDraggable(DragPoint: GuiObject, Main: GuiObject)
    -- Consider if mobile dragging is ever desired, currently disabled in MainModule.lua
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    AddConnection(DragPoint.InputBegan, function(input: InputObject)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            mousePos = input.Position
            framePos = Main.Position

            -- No need for input.Changed connection here if we rely on InputEnded below
            -- Input.Changed might fire too frequently and cause performance issues if not handled carefully
        end
    end)
    -- Use UserInputService.InputEnded for a more robust end condition for dragging
    AddConnection(UserInputService.InputEnded, function(input: InputObject)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    AddConnection(UserInputService.InputChanged, function(input: InputObject)
        if
            (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
            and dragging
        then
            local delta = input.Position - mousePos
            Main.Position =
                UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

--[[!nl]]--local Library = {
    Window = nil :: ScreenGui?,
    Flags = {},
    Signals = {}, -- Managed by Tools.Signals
    ToggleBind = nil,
    LoadedWindow = nil :: CanvasGroup?, -- The main draggable canvas group
    managedUIElements = {} :: {[Instance]: boolean}, -- Track UI elements for destruction, though tools.lua also tracks
}

--[[!nl]]--local GUI = Create("ScreenGui", {
    Name = generateRandomString(16),
    Parent = gethui(), -- game.Players.LocalPlayer.PlayerGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
Library.managedUIElements[GUI] = true -- Still track here for completeness, though tools does it

--[[!nl]]--require(Components.notif):Init(GUI)

--[[!nl]]--function Library:SetTheme(themeName: string)
    Tools.SetTheme(themeName)
end

--[[!nl]]--function Library:GetTheme()
    return GetPropsCurrentTheme()
end

--[[!nl]]--function Library:AddTheme(themeName: string, themeProps: Tools.Theme)
    Tools.AddTheme(themeName, themeProps)
end

--[[!nl]]--function Library:IsRunning(): boolean
    return GUI.Parent == gethui() -- Check if GUI is still parented
end

--[[!nl]]--function Library:Cleanup()
    -- Disconnect all managed signals
    Tools.Disconnect()

    -- Cancel all active tweens managed by Tools
    for obj, propTable in pairs(Tools.managedTweens) do
        for prop, tweenData in pairs(propTable) do
            if tweenData.tween.PlaybackState == Enum.PlaybackState.Playing then
                tweenData.tween:Cancel()
            end
            propTable[prop] = nil -- Clear reference
        end
        Tools.managedTweens[obj] = nil -- Clear object table
    end
    Tools.managedTweens = {} -- Ensure full reset

    -- Destroy all managed UI elements and remove their theme tracking
    for obj, _ in pairs(Tools.managedUIElements) do
        if obj and obj.Parent then -- Check if object still exists and is parented
            RemoveThemedObject(obj) -- Remove from theme tracking first
            obj:Destroy()
        end
    end
    Tools.managedUIElements = {} -- Clear the table

    -- Clean up active dialog if any
    local DialogModule = require(Components.dialog)
    if DialogModule.ActiveDialog then
        if DialogModule.ActiveDialog.Parent then
            DialogModule.ActiveDialog:Destroy()
        end
        DialogModule.ActiveDialog = nil
    end

    print("Library cleanup completed.")
end

--[[!nl]]--task.spawn(function()
    while Library:IsRunning() do
        task.wait(Tools.Constants.CLEANUP_CHECK_INTERVAL) -- Reduced frequency
    end
    Library:Cleanup() -- Call the cleanup function
end)

--[[!nl]]--local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
	return Elements[Key](...)
end

--[[!nl]]--for _, ElementComponent in ipairs(ElementsTable) do
	assert(ElementComponent.__type, "ElementComponent missing __type")
	assert(type(ElementComponent.New) == "function", "ElementComponent missing New function")

	Elements["Add" .. ElementComponent.__type] = function(self: TabContext, Idx: string, Config: Tools.Config)
		-- Dependency Injection: pass context directly to New function
		local context: TabContext = {
			Container = self.Container,
			Type = self.Type,
			ScrollFrame = self.ScrollFrame,
			Library = Library, -- Assign Library correctly
		}
		return ElementComponent:New(context, Idx, Config)
	end
end

--[[!nl]]--Library.Elements = Elements

--[[!nl]]--function Library:Callback(Callback: (...any) -> any, ...: any): (true, ...any) | (false, string)
	local success, result = pcall(Callback, ...)

	if success then
		-- print("Callback executed successfully!")
		return true, result
	else
		local errorMessage = tostring(result)
		local errorLine = string.match(errorMessage, ":(%d+):")
		local errorInfo = `Callback execution failed.\n`
		errorInfo = errorInfo .. `Error: {errorMessage}\n`

		if errorLine then
			errorInfo = errorInfo .. `Occurred on line: {errorLine}\n`
		end

		errorInfo = errorInfo
			.. `Possible Fix: Please check the function implementation for potential issues such as invalid arguments or logic errors at the indicated line number.`
		warn(errorInfo) -- Using warn for less intrusive error messages
        return false, errorInfo
	end
end

--[[!nl]]--function Library:Notification(titleText: string, descriptionText: string, duration: number)
	require(Components.notif):ShowNotification(titleText, descriptionText, duration)
end

--[[!nl]]--function Library:Dialog(config: Components.DialogConfig): CanvasGroup?
    local dialogModule = require(Components.dialog)
    return dialogModule:Create(config, self.LoadedWindow or GUI) -- Fallback to GUI if window not loaded
end

--[[!nl]]--function Library:Load(cfgs: LibraryConfig?): table -- Returns Tabs module
	cfgs = cfgs or {}
	cfgs.Title = cfgs.Title or "Window"
	cfgs.ToggleButton = cfgs.ToggleButton or ""
	cfgs.BindGui = cfgs.BindGui or Enum.KeyCode.RightControl

	if Library.Window then
		warn("Cannot create more than one window. Destroying existing GUI.")
		Library:Cleanup() -- Full cleanup before attempting to create a new window
	end
	
	Library.Window = GUI

	local canvas_group = Create("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Position = UDim2.new(0.5, 0, 0.3, 0),
		Size = UDim2.new(0, 650, 0, 400),
		Parent = GUI,
		Visible = false
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})
    -- `Create` now automatically adds to managedUIElements

	if isMobile then
		canvas_group.Size = UDim2.new(0.8, 0, 0.8, 0)
	end

	local togglebtn = Create("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0),
		AutoButtonColor = false,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		Position = UDim2.new(0.5, 8, 0, 0),
		Size = UDim2.new(0, 45, 0, 45),
		Parent = GUI,
		Image = cfgs.ToggleButton,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
	})

	local function ToggleVisibility()
		local isVisible = canvas_group.Visible
		local endPosition = isVisible and UDim2.new(0.5, 0, -1, 0) or UDim2.new(0.5, 0, 0.5, 0)
		
        CancelTween(canvas_group, "Position")
        -- The rest of the commented tweens here were not being used, 
        -- so no need to cancel them unless they are added back.

		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	
		local positionTween = TweenService:Create(canvas_group, tweenInfo, { Position = endPosition })
		Tools.AddManagedTween(positionTween, canvas_group, "Position")
		
		canvas_group.Visible = true
		togglebtn.Visible = false
	
		positionTween:Play()
		
		AddConnection(positionTween.Completed, function()
			if isVisible then
				canvas_group.Visible = false
				togglebtn.Visible = true
			end
            Tools.RemoveManagedTween(positionTween)
		end)
	end

	ToggleVisibility() -- Initial hide

	MakeDraggable(togglebtn, togglebtn)
	AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
	AddConnection(UserInputService.InputBegan, function(value: InputObject)
		if value.KeyCode == cfgs.BindGui then
			ToggleVisibility()
		end
	end)

	local top_frame = Create("Frame", {
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(39, 39, 42),
		Size = UDim2.new(1, 0, 0, 40),
		ZIndex = 9,
		Parent = canvas_group,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
	})

	local title = Create("TextLabel", {
		Font = Enum.Font.GothamMedium,
		RichText = true,
		Text = cfgs.Title,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0),
		Size = UDim2.new(0, 200, 0, 40),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 0),
			PaddingTop = UDim.new(0, 0),
		}),
	})

	local minimizebtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -36, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("ImageLabel", {
			Image = "rbxassetid://15269257100",
			ImageRectOffset = Vector2.new(514, 257),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -10, 1, -10),
			ThemeProps = {
				BackgroundColor3 = "maincolor",
			},
			BorderSizePixel = 0,
			ZIndex = 11,
		}),
	})

	local closebtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 28),
		ZIndex = 10,
		Parent = top_frame,
	}, {
		Create("ImageLabel", {
			Image = "rbxassetid://15269329696",
			ImageRectOffset = Vector2.new(0, 514),
			ImageRectSize = Vector2.new(256, 256),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -10, 1, -10),
			ThemeProps = {
				BackgroundColor3 = "maincolor",
			},
			BorderSizePixel = 0,
			ZIndex = 11,
		}),
	})

	AddConnection(minimizebtn.MouseButton1Click, ToggleVisibility)
	AddConnection(closebtn.MouseButton1Click, function()
		Library:Cleanup() -- Clean up all UI elements and connections
	end)

	local tab_frame = Create("Frame", {
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(39, 39, 42),
		Position = UDim2.new(0, 0, 0, 40),
		Size = UDim2.new(0, 140, 1, -40),
		Parent = canvas_group,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
	})

	local TabHolder = Create("ScrollingFrame", {
		ThemeProps = {
			ScrollBarImageColor3 = "scrollcolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tab_frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 0),
		}),
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 28)
	end)

	AddScrollAnim(TabHolder)

	local containerFolder = Create("Folder", {
		Parent = canvas_group,
	})

	if not isMobile then
		MakeDraggable(top_frame, canvas_group)
	end

	Library.LoadedWindow = canvas_group

	local Tabs = {}

	local TabModule = require(Components.tab):Init(containerFolder, Library)
	function Tabs:AddTab(title: string): Components.Tab -- Corrected return type
		return TabModule:New(title, TabHolder)
	end
	function Tabs:SelectTab(Tab: number)
		TabModule:SelectTab(Tab)
	end

	return Tabs
end
return Library

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local ButtonComponent = require(script.Parent.Parent.elements.buttons)

local Create = Tools.Create
local Validate = Tools.Validate

--[[!nl]]--type DialogButtonConfig = {
    Title: string,
    Callback: ((...any) -> any)?,
    Variant: "Primary" | "Ghost" | "Outline"?,
}

export type DialogConfig = {
    Title: string,
    Content: string,
    Buttons: {DialogButtonConfig},
}

--[[!nl]]--local DialogModule = {
    ActiveDialog = nil :: ScrollingFrame?,
}

--[[!nl]]--function DialogModule:Create(config: DialogConfig, parent: Instance): CanvasGroup?
    local schema = {
        Title = "string",
        Content = "string",
        Buttons = "table",
    }
    if not Validate(config, schema) then
        warn("Dialog - Invalid config provided. Check Title, Content, and Buttons.")
        return nil
    end

    -- Remove existing dialog if any
    if DialogModule.ActiveDialog then
        if DialogModule.ActiveDialog.Parent then -- Ensure it's still in the hierarchy before destroying
            DialogModule.ActiveDialog:Destroy()
        end
        DialogModule.ActiveDialog = nil
    end

    local scrolling_frame = Instance.new("ScrollingFrame") :: ScrollingFrame
    scrolling_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrolling_frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling_frame.ScrollBarImageColor3 = Color3.new(0.109804, 0.109804, 0.117647)
    scrolling_frame.ScrollBarThickness = 4
    scrolling_frame.Active = true
    scrolling_frame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BackgroundTransparency = 0.1
    scrolling_frame.BorderColor3 = Color3.new(0, 0, 0)
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.Size = UDim2.new(1, 0, 1, 0)
    scrolling_frame.Visible = true
    scrolling_frame.ZIndex = 100
    scrolling_frame.Parent = parent
    Tools.AddManagedUIElement(scrolling_frame)

    -- Add a full-frame button to prevent clicks passing through
    local blocker = Instance.new("TextButton") :: TextButton
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.Position = UDim2.new(0, 0, 0, 0)
    blocker.BackgroundTransparency = 1 -- Fully transparent
    blocker.Text = "" -- No text
    blocker.AutoButtonColor = false -- Prevents hover effects
    blocker.Parent = scrolling_frame
    Tools.AddManagedUIElement(blocker)

    local uipadding_3 = Instance.new("UIPadding") :: UIPadding
    uipadding_3.PaddingBottom = UDim.new(0, 45)
    uipadding_3.PaddingTop = UDim.new(0, 45)
    uipadding_3.Parent = scrolling_frame
    Tools.AddManagedUIElement(uipadding_3)

    local dialog = Create("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.new(0, 400, 0, 0),
        ThemeProps = {
            BackgroundColor3 = "maincolor",
        },
        Parent = scrolling_frame,
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
    })
    -- `Create` automatically adds `dialog` and its children to managedUIElements

    local uilist_layout = Instance.new("UIListLayout") :: UIListLayout
    uilist_layout.SortOrder = Enum.SortOrder.LayoutOrder
    uilist_layout.Parent = dialog
    Tools.AddManagedUIElement(uilist_layout)

    -- Create top bar with title
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("TextLabel", {
            Font = Enum.Font.GothamMedium,
            Text = config.Title,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -24, 1, 0),
            BackgroundTransparency = 1,
            ThemeProps = { TextColor3 = "titlecolor" },
        }),
    })
    -- `Create` automatically adds this frame and its children to managedUIElements

    -- Create content container
    local content = Create("TextLabel", {
        Text = config.Content,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 12, 0, 50),
        RichText = true,
        BackgroundTransparency = 1,
        ThemeProps = { TextColor3 = "descriptioncolor" },
        Parent = dialog,
    })
    -- `Create` automatically adds `content` to managedUIElements

    local uipadding = Instance.new("UIPadding") :: UIPadding
    uipadding.PaddingBottom = UDim.new(0, 8)
    uipadding.PaddingLeft = UDim.new(0, 12)
    uipadding.PaddingRight = UDim.new(0, 12)
    uipadding.PaddingTop = UDim.new(0, 8)
    uipadding.Parent = content
    Tools.AddManagedUIElement(uipadding)

    -- Create button container
    local buttonContainer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        AutomaticSize = Enum.AutomaticSize.Y,
        ThemeProps = { BackgroundColor3 = "maincolor" },
        Parent = dialog,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Thickness = 1,
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    -- `Create` automatically adds `buttonContainer` to managedUIElements

    -- Add buttons with validation
    for i, buttonConfig in ipairs(config.Buttons) do
        local buttonSchema = {
            Title = "string",
            Callback = "function?",
            Variant = "string?",
        }
        -- Ensure Config.Title is available for warn message even if validation fails
        buttonConfig.Title = buttonConfig.Title or "Button " .. i 

        if not Validate(buttonConfig, buttonSchema) then
            warn("Dialog button " .. i .. " ('" .. buttonConfig.Title .. "') has invalid config, using defaults.")
            -- Ensure minimal required fields are set for component creation
            buttonConfig.Callback = buttonConfig.Callback or function() end
            buttonConfig.Variant = buttonConfig.Variant or (i == 1 and "Primary" or "Ghost")
        end
        
        local wrappedCallback = function()
            local library = require(script.Parent.Parent) -- Access main library for safe callback
            library:Callback(buttonConfig.Callback)
            if DialogModule.ActiveDialog then
                if DialogModule.ActiveDialog.Parent then
                    DialogModule.ActiveDialog:Destroy()
                end
                DialogModule.ActiveDialog = nil
            end
        end

        local buttonContext = {Container = buttonContainer}
        local button = setmetatable(buttonContext, ButtonComponent):New({
            Title = buttonConfig.Title,
            Variant = buttonConfig.Variant,
            Callback = wrappedCallback,
        })
        -- The button component already handles adding its UI elements to managed list
    end

    DialogModule.ActiveDialog = scrolling_frame
    return dialog
end


return DialogModule

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local Create = Tools.Create
local Validate = Tools.Validate

--[[!nl]]--type ElementConfig = {
    Title: string,
    Description: string?,
}

--[[!nl]]--return function(title: string, desc: string?, parent: Instance): {Frame: TextButton, topbox: Frame, SetTitle: (string) -> (), SetDesc: (string?) -> (), Destroy: () -> ()}
    local schema = {
        Title = "string",
        Description = "string?",
    }
    -- Validate the conceptual config passed, even if directly passed as args
    if not Validate({Title = title, Description = desc}, schema) then
        warn("Element creation with Title:", title, "received invalid config.")
        title = title or "Untitled Element"
        -- desc can be nil/empty, which is handled
    end

	local Element = {}
	Element.Frame = Create("TextButton", {
		Font = Enum.Font.SourceSans,
		Text = "",
		Name = Tools.Constants.ELEMENT_NAME,
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.519230783, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = parent,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})
    -- `Create` automatically adds `Element.Frame` to managedUIElements

	Element.topbox = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Element.Frame,
	})
    -- `Create` automatically adds `Element.topbox` to managedUIElements

	local name = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		LineHeight = 1.2,
		RichText = true,
		Text = title,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,

		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Element.topbox,
		Name = Tools.Constants.ELEMENT_TITLE_NAME,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 0),
			PaddingRight = UDim.new(0, 36),
			PaddingTop = UDim.new(0, 2),
		}),
	})
    -- `Create` automatically adds `name` to managedUIElements

	local description = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		RichText = true,
		Name = Tools.Constants.ELEMENT_DESCRIPTION_NAME,
		ThemeProps = {
			TextColor3 = "elementdescription",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = desc or "",
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 23),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = (desc ~= nil and desc ~= ""),
		Parent = Element.Frame,
	}, {})
    -- `Create` automatically adds `description` to managedUIElements

	function Element:SetTitle(Set: string)
		name.Text = Set
	end

	function Element:SetDesc(Set: string?)
		if Set == nil or Set == "" then
			description.Visible = false
		else
			description.Visible = true
		end
		description.Text = Set or ""
	end

	Element:SetDesc(desc)
	Element:SetTitle(title)

	function Element:Destroy()
		Element.Frame:Destroy()
        -- `Element.Frame` is tracked by Tools.managedUIElements, so Destroying it and then calling
        -- cleanup for Tools.managedUIElements will handle its children and theme objects.
        -- No need to manually remove individual child elements from Tools.managedUIElements or Tools.themedObjects.
	end

	return Element
end

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals --[[!nl]]--local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CancelTween = Tools.CancelTween
local RemoveManagedTween = Tools.RemoveManagedTween
local RemoveManagedUIElement = Tools.RemoveManagedUIElement

--[[!nl]]--local Notif = {
    MainHolder = nil :: Frame?,
}

--[[!nl]]--function Notif:Init(Gui: ScreenGui)
    self.MainHolder = Create("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0,0,0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 262, 0, 100),
        Visible = true,
        Parent = Gui,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 0),
        }),
        Create("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 8),
        })
    })
    -- `Create` automatically adds `self.MainHolder` to managedUIElements
end

--[[!nl]]--function Notif:ShowNotification(titleText: string, descriptionText: string, duration: number)
    if not self.MainHolder or not self.MainHolder.Parent then
        warn("Notification system not initialized or MainHolder destroyed. Call Notif:Init(Gui) first.")
        return
    end

    local main = Create("CanvasGroup", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(9, 9, 9),
        BackgroundTransparency = 1, -- Initial transparency for fade-in effect
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(1, -10, 0.5, -150),
        AnchorPoint = Vector2.new(1, 0.5),
        Visible = true,
        Parent = self.MainHolder,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(23, 23, 23),
            Thickness = 1,
        }),
    })
    -- `Create` automatically adds `main` to managedUIElements

    local holderin = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = true,
        Parent = main,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 12),
        }),
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    -- `Create` automatically adds `holderin` to managedUIElements

    local topframe = Create("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Visible = true,
        Parent = holderin,
    })
    -- `Create` automatically adds `topframe` to managedUIElements

    local user = Create("ImageLabel", {
        Image = "rbxassetid://10723415903",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 18, 0, 18),
        Visible = true,
        Parent = topframe,
    })
    -- `Create` automatically adds `user` to managedUIElements

    local title = Create("TextLabel", {
        Font = Enum.Font.GothamMedium,
        LineHeight = 1.2,
        RichText = true,
        TextColor3 = Color3.fromRGB(225, 225, 225),
        TextSize = 18,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        Text = titleText,
        Visible = true,
        Parent = topframe,
    }, {
        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 24),
        }),
    })
    -- `Create` automatically adds `title` to managedUIElements

    local description = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        TextColor3 = Color3.fromRGB(225, 225, 225),
        TextSize = 16,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.XY,
        LayoutOrder = 1,
        BackgroundTransparency = 1,
        Text = descriptionText,
        Visible = true,
        Parent = holderin,
    })
    -- `Create` automatically adds `description` to managedUIElements

    local progress = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = true,
        Parent = main,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
    -- `Create` automatically adds `progress` to managedUIElements

    local progressindicator = Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 2),
        Visible = true,
        Parent = progress,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
    -- `Create` automatically adds `progressindicator` to managedUIElements

    -- Fade-in animation for all elements
    local fadeInTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    CancelTween(main, "BackgroundTransparency")
    local fadeInTween = TweenService:Create(main, fadeInTweenInfo, {BackgroundTransparency = 0.4})
    Tools.AddManagedTween(fadeInTween, main, "BackgroundTransparency")
    fadeInTween:Play()

    CancelTween(title, "TextTransparency")
    local fadeInTweenTitle = TweenService:Create(title, fadeInTweenInfo, {TextTransparency = 0})
    Tools.AddManagedTween(fadeInTweenTitle, title, "TextTransparency")
    fadeInTweenTitle:Play()

    CancelTween(description, "TextTransparency")
    local fadeInTweenDescription = TweenService:Create(description, fadeInTweenInfo, {TextTransparency = 0})
    Tools.AddManagedTween(fadeInTweenDescription, description, "TextTransparency")
    fadeInTweenDescription:Play()

    CancelTween(user, "ImageTransparency")
    local fadeInTweenUser = TweenService:Create(user, fadeInTweenInfo, {ImageTransparency = 0})
    Tools.AddManagedTween(fadeInTweenUser, user, "ImageTransparency")
    fadeInTweenUser:Play()

    -- Tween for progress bar
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    CancelTween(progressindicator, "Size")
    local tween = TweenService:Create(progressindicator, tweenInfo, {Size = UDim2.new(0, 0, 0, 2)})
    Tools.AddManagedTween(tween, progressindicator, "Size")
    tween:Play()

    -- Remove notification after Tween completes
    AddConnection(tween.Completed, function()
        if main and main.Parent then -- Check if main still exists before destroying
            main:Destroy()
        end
        RemoveManagedTween(tween)
        RemoveManagedTween(fadeInTween)
        RemoveManagedTween(fadeInTweenTitle)
        RemoveManagedTween(fadeInTweenDescription)
        RemoveManagedTween(fadeInTweenUser)
        -- Removing main from managedUIElements is implicitly handled by Destroying main
        -- and the global cleanup iterating over Tools.managedUIElements
    end)

    -- if not game:GetService("RunService"):IsStudio() then
    --require(script.Parent.Parent.Packages.blurModule):ModifyFrame(main)
    -- end
end

return Notif

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CancelTween = Tools.CancelTween
local Validate = Tools.Validate

--[[!nl]]--export type SectionConfig = { -- Exported for tab.lua
    Title: string?,
    Description: string?,
    Default: boolean?,
    Locked: boolean?,
    TitleTextSize: number?,
}

--[[!nl]]--return function(cfgs: SectionConfig, Parent: Instance): {SectionFrame: Frame, SectionContainer: Frame}
    local schema = {
        Title = "string?",
        Description = "string?",
        Default = "boolean?",
        Locked = "boolean?",
        TitleTextSize = "number?",
    }
    if not Validate(cfgs, schema) then
        warn("Section creation received invalid config, using defaults.")
        cfgs = cfgs or {}
    end
	cfgs.Title = cfgs.Title or nil
	cfgs.Description = cfgs.Description or nil
	cfgs.Default  = cfgs.Default or false
	cfgs.Locked = cfgs.Locked or false
	cfgs.TitleTextSize = cfgs.TitleTextSize or 14

	local Section = {}

	Section.SectionFrame = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Name = Tools.Constants.SECTION_NAME,
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Parent,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 6),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor"
			},
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
    -- `Create` automatically adds `Section.SectionFrame` to managedUIElements

	local topbox = Create("TextButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Section.SectionFrame,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})
    -- `Create` automatically adds `topbox` to managedUIElements

	local chevronIcon = Create("ImageButton", {
		ThemeProps = {
			ImageColor3 = "titlecolor",
		},
		Image = "rbxassetid://15269180996",
		ImageRectOffset = Vector2.new(0, 257),
		ImageRectSize = Vector2.new(256, 256),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 24, 0, 24),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Rotation = 180, -- Initial rotation: closed (left)
		Name = "chevron-down",
		ZIndex = 99,
	})
    -- `Create` automatically adds `chevronIcon` to managedUIElements
	
	local name = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		LineHeight = 1.2000000476837158,
		RichText = true,
		ThemeProps = {
			TextColor3 = "titlecolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = topbox,
		Name = Tools.Constants.ELEMENT_TITLE_NAME,
	}, {
		chevronIcon -- chevronIcon is a child of 'name'
	})
    -- `Create` automatically adds `name` to managedUIElements

	if cfgs.Description ~= nil and cfgs.Description ~= "" then
	local description = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		RichText = true,
		Name = Tools.Constants.ELEMENT_DESCRIPTION_NAME,
		ThemeProps = {
			TextColor3 = "descriptioncolor",
			BackgroundColor3 = "maincolor",
		},
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = cfgs.Description or "",
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 23),
		Size = UDim2.new(1, 0, 0, 16),
		Visible = true,
		Parent = topbox,
	}, {})
    -- `Create` automatically adds `description` to managedUIElements
	description.Visible = cfgs.Description ~= nil
	end

	if cfgs.Title ~= nil and cfgs.Title ~= "" then
		name.Size = UDim2.new(1, 0, 0, 16)
		name.Text = cfgs.Title
		name.TextSize = cfgs.TitleTextSize
		name.Visible = true
	end

	Section.SectionContainer = Create("Frame", {
		Name = Tools.Constants.SECTION_CONTAINER_NAME,
		ClipsDescendants = true,
		BackgroundTransparency = 1,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = true,
		Parent = Section.SectionFrame,
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1),
		}),
	})
    -- `Create` automatically adds `Section.SectionContainer` to managedUIElements

	local isExpanded = cfgs.Default
	if cfgs.Default == true then
	chevronIcon.Rotation = 90 -- If default is open, set arrow to "open" (down)
	end

    -- Set initial size for container if expanded, otherwise 0
    -- This relies on UIListLayout.AbsoluteContentSize, which updates after children are parented
    -- So, for initial state, we set it to 0 if closed, or rely on future update if opened
    if not isExpanded then
        Section.SectionContainer.Size = UDim2.new(1, 0, 0, 0)
    end

	local function toggleSection()
		isExpanded = not isExpanded
		local targetRotation = isExpanded and 90 or 180 -- 90 for open (down), 180 for closed (left)
		
		-- Animate chevron rotation
        CancelTween(chevronIcon, "Rotation")
		local chevronTween = TweenService:Create(chevronIcon, TweenInfo.new(0.3), {
			Rotation = targetRotation
		})
        Tools.AddManagedTween(chevronTween, chevronIcon, "Rotation")
		chevronTween:Play()
        AddConnection(chevronTween.Completed, function() Tools.RemoveManagedTween(chevronTween) end)
		
		-- Animate section container
        local targetSizeY = isExpanded and (Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18) or 0
		local targetSize = UDim2.new(1, 0, 0, targetSizeY)
        CancelTween(Section.SectionContainer, "Size")
		local containerTween = TweenService:Create(Section.SectionContainer, TweenInfo.new(0.3), {
			Size = targetSize
		})
        Tools.AddManagedTween(containerTween, Section.SectionContainer, "Size")
		containerTween:Play()
        AddConnection(containerTween.Completed, function() Tools.RemoveManagedTween(containerTween) end)
	end

	if cfgs.Locked == false then
	AddConnection(topbox.MouseButton1Click, toggleSection)
	AddConnection(chevronIcon.MouseButton1Click, toggleSection)
	end
	if cfgs.Locked == true then
	topbox:Destroy()
    -- topbox is tracked by Tools.managedUIElements, so Destroying it is sufficient for cleanup.
	end
	
	AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if isExpanded then
            -- Update size immediately to reflect new content when expanded
            -- Check if Section.SectionContainer still exists before accessing its properties
            if Section.SectionContainer and Section.SectionContainer.Parent then
			    Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18)
            end
		end
	end)

	return Section
end
end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local AddScrollAnim = Tools.AddScrollAnim
local GetPropsCurrentTheme = Tools.GetPropsCurrentTheme

-- Add debug toggle
local SEARCH_DEBUG = false

--[[!nl]]--local function debugLog(...)
	if SEARCH_DEBUG then
		print("[Search]", ...)
	end
end

--[[!nl]]--type Tab = {
    Selected: boolean,
    Name: string,
    Type: string,
    TabBtn: TextButton,
    Container: ScrollingFrame,
    SearchContainer: Frame,
    searchableElements: {[Instance]: true}, -- Stores elements that can be searched within this tab
    updateSearch: (() -> ())?,
    searchDebounceConnection: RBXScriptConnection?, -- New: For debouncing search
}

export type TabModuleType = { -- Exported for MainModule.lua
    Window: Instance?,
    Tabs: {[number]: Tab},
    Containers: {[number]: ScrollingFrame},
    SelectedTab: number,
    TabCount: number,
    Library: any, -- Reference to the main Library
    Init: (Instance, any) -> TabModuleType,
    New: (string, Instance) -> Tab,
    SelectTab: (number) -> (),
}

--[[!nl]]--local TabModule: TabModuleType = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
    Library = nil,
}

--[[!nl]]--function TabModule:Init(Window: Instance, Library: any): TabModuleType
	TabModule.Window = Window
    TabModule.Library = Library -- Store reference to main Library
	return TabModule
end

--[[!nl]]--function TabModule:New(Title: string, Parent: Instance): Tab
	local Window = TabModule.Window
	local Elements = TabModule.Library.Elements

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab: Tab = {
		Selected = false,
		Name = Title,
		Type = Tools.Constants.TAB_TYPE,
        TabBtn = nil :: TextButton, -- Initialized below
        Container = nil :: ScrollingFrame, -- Initialized below
        SearchContainer = nil :: Frame, -- Initialized below
        searchableElements = {}, -- Initialize searchable elements index
        searchDebounceConnection = nil,
	}

	Tab.TabBtn = Create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = Parent,
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
		BorderSizePixel = 0,
	}, {
		Create("TextLabel", {
			Name = Tools.Constants.ELEMENT_TITLE_NAME,
			Font = Enum.Font.Gotham,
			TextColor3 = Color3.fromRGB(63, 63, 63),
			TextSize = 14,
			ThemeProps = {
				BackgroundColor3 = "maincolor",
			},
			BorderSizePixel = 0,
			TextXAlignment = Enum.TextXAlignment.Left,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.new(0.8, 0, 0.9, 0),
			Text = Title,
		}),
		Create("Frame", {
			Name = "Line",
			BackgroundColor3 = Color3.fromRGB(29, 29, 29),
			Position = UDim2.new(0, 4, 0, 0),
			Size = UDim2.new(0, 2, 1, 0),
			BorderSizePixel = 0,
		}),
	})
    -- `Create` automatically adds `Tab.TabBtn` to managedUIElements

	Tab.Container = Create("ScrollingFrame", {
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ThemeProps = {
			ScrollBarImageColor3 = "scrollcolor",
			BackgroundColor3 = "maincolor",
		},
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 1,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 140, 0, 40),
		Size = UDim2.new(1, -140, 1, -40),
		Visible = false,
		Parent = TabModule.Window,
	}, {
		Create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
    -- `Create` automatically adds `Tab.Container` to managedUIElements

	AddScrollAnim(Tab.Container)

	AddConnection(Tab.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Tab.Container.CanvasSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 28)
	end)

	-- Add search container at the top of the tab container
	Tab.SearchContainer = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = Tab.Container,
		LayoutOrder = -1, -- Make sure it appears at the top
		ThemeProps = {
			BackgroundColor3 = "maincolor",
		},
	})
    -- `Create` automatically adds `Tab.SearchContainer` to managedUIElements

	local SearchBox = Create("TextBox", {
		Size = UDim2.new(1, 0, 0, 32),
		Position = UDim2.new(0, 0, 0, 0),
		PlaceholderText = "Search elements...",
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		BackgroundTransparency = 1,
		ThemeProps = {
			TextColor3 = "titlecolor",
			PlaceholderColor3 = "descriptioncolor",
		},
		Parent = Tab.SearchContainer,
		ClearTextOnFocus = false,
	}, {
		Create("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),

		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = {
				Color = "bordercolor",
			},
			Thickness = 1,
		}),
	})
    -- `Create` automatically adds `SearchBox` to managedUIElements

	-- Function to filter elements based on search text
	local function searchInElement(element: Instance, searchText: string): boolean
		if not element or not element:IsA("GuiObject") then return false end
		
		local title = element:FindFirstChild(Tools.Constants.ELEMENT_TITLE_NAME, true) :: TextLabel?
		local desc = element:FindFirstChild(Tools.Constants.ELEMENT_DESCRIPTION_NAME, true) :: TextLabel?

		if title and title.Text then
			debugLog("Checking title:", title.Text)
			-- Using 'true' for literal search (no patterns)
			local cleanTitle = title.Text:gsub("^%s+", "")
			if string.find(string.lower(cleanTitle), searchText, 1, true) then
				debugLog("Found match in title")
				return true
			end
		end

		if desc and desc.Text then
			debugLog("Checking description:", desc.Text)
			if string.find(string.lower(desc.Text), searchText, 1, true) then
				debugLog("Found match in description")
				return true
			end
		end

		return false
	end

	-- Moved updateSearch to be a property of the Tab instance
	local function updateSearchForTab()
		local searchText = string.lower(SearchBox.Text)
		debugLog("Search text:", searchText)

		if not Tab.Container.Visible then
			debugLog("Tab not visible, skipping search")
			return
		end

		-- Iterate through indexed searchable elements
		for elementRef in pairs(Tab.searchableElements) do
			if elementRef and elementRef.Parent then -- Ensure element still exists and is parented
				local isSection = elementRef.Name == Tools.Constants.SECTION_NAME
				
				if isSection then
					-- For sections, we check if any of its children match, or if the section itself matches
					local sectionMatches = searchInElement(elementRef, searchText)
					local childrenMatch = false
					local sectionContainer = elementRef:FindFirstChild(Tools.Constants.SECTION_CONTAINER_NAME)
                    if sectionContainer then
                        for _, childElement in ipairs(sectionContainer:GetChildren()) do
                            if childElement.Name == Tools.Constants.ELEMENT_NAME then
                                local elementVisible = searchInElement(childElement, searchText)
                                childElement.Visible = elementVisible or searchText == ""
                                if elementVisible then
                                    childrenMatch = true
                                end
                            end
                        end
                    end
					elementRef.Visible = sectionMatches or childrenMatch or searchText == ""
					debugLog("Section visibility for", elementRef.Name, ":", elementRef.Visible)
				elseif elementRef.Name == Tools.Constants.ELEMENT_NAME then
					-- Handle standalone elements
					local elementVisible = searchInElement(elementRef, searchText)
					elementRef.Visible = elementVisible or searchText == ""
					debugLog("Standalone element visibility for", elementRef.Name, ":", elementRef.Visible)
				end
			end
		end
	end

	-- Assign the search function to the Tab instance
	Tab.updateSearch = updateSearchForTab

	-- Update search when tab is selected
	AddConnection(Tab.Container:GetPropertyChangedSignal("Visible"), function()
		if Tab.Container.Visible then
			Tab.updateSearch()
		end
	end)

    -- Debounce the search input
    AddConnection(SearchBox:GetPropertyChangedSignal("Text"), function()
        if Tab.searchDebounceConnection then
            Tab.searchDebounceConnection:Disconnect()
            Tab.searchDebounceConnection = nil
        end
        Tab.searchDebounceConnection = task.delay(0.15, function()
            if Tab.updateSearch then
                Tab.updateSearch()
            end
            Tab.searchDebounceConnection = nil
        end)
    end)


	Tab.ContainerFrame = Tab.Container

	AddConnection(Tab.TabBtn.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab

	function Tab:AddSection(cfgs: Tools.SectionConfig): table
		cfgs = cfgs or {}
		cfgs.Title = cfgs.Title or nil
		cfgs.Description = cfgs.Description or nil
		local Section = { Type = Tools.Constants.SECTION_NAME }

		local SectionComponent = require(script.Parent.section)
		local SectionFrame = SectionComponent(cfgs, Tab.Container)
		Section.Container = SectionFrame.SectionContainer

        -- Add SectionFrame to searchable elements
        Tab.searchableElements[SectionFrame.SectionFrame] = true
        -- Iterate children of SectionFrame.SectionContainer to add individual elements
        -- This relies on the UIListLayout updating and children being present
        local function indexSectionChildren()
            for _, child in ipairs(SectionFrame.SectionContainer:GetChildren()) do
                if child.Name == Tools.Constants.ELEMENT_NAME then
                    Tab.searchableElements[child] = true
                end
            end
        end
        -- Index children immediately if already expanded, otherwise after content is visible
        AddConnection(SectionFrame.SectionContainer.UIListLayout.ChildAdded, indexSectionChildren)
        AddConnection(SectionFrame.SectionContainer.UIListLayout.ChildRemoved, function(child: Instance)
            if child.Name == Tools.Constants.ELEMENT_NAME then
                Tab.searchableElements[child] = nil
            end
        end)
        indexSectionChildren() -- Initial indexing

		function Section:AddGroupButton(): table
			local GroupButton = { Type = Tools.Constants.GROUP_BUTTON_TYPE }
			GroupButton.GroupContainer = Create("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = true,
				ThemeProps = {
					BackgroundColor3 = "maincolor",
				},
				BorderSizePixel = 0,
				Parent = SectionFrame.SectionContainer,
			}, {
				Create("UIListLayout", {
					Padding = UDim.new(0, 6),
					Wraps = true,
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			})
            -- `Create` automatically adds `GroupButton.GroupContainer` to managedUIElements

			GroupButton.Container = GroupButton.GroupContainer

			setmetatable(GroupButton, Elements)
			return GroupButton
		end

        -- Create a local proxy for Elements to intercept AddElement* calls for this tab
        local TabElements = setmetatable({}, {
            __index = function(_, key)
                local originalFunc = Elements[key]
                if string.match(key, "^Add") and type(originalFunc) == "function" then
                    return function(selfContext: TabContext, Idx: string, Config: Tools.Config)
                        local newElement = originalFunc(selfContext, Idx, Config)
                        if newElement and newElement.Frame then
                            Tab.searchableElements[newElement.Frame] = true
                        end
                        return newElement
                    end
                end
                return originalFunc
            end
        })

		setmetatable(Section, TabElements) -- Set metatable to the proxy
		return Section
	end

	return Tab
end

--[[!nl]]--function TabModule:SelectTab(TabIdx: number)
    local CurrentThemeProps = GetPropsCurrentTheme()

    TabModule.SelectedTab = TabIdx

    for idx, tab in pairs(TabModule.Tabs) do
        -- Cancel existing tweens before starting new ones
        Tools.CancelTween(tab.TabBtn.Title, "TextColor3")
        Tools.CancelTween(tab.TabBtn.Line, "BackgroundColor3")

        TweenService:Create(
            tab.TabBtn.Title,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { TextColor3 = CurrentThemeProps.offTextBtn }
        ):Play()
        TweenService:Create(
            tab.TabBtn.Line,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundColor3 = CurrentThemeProps.offBgLineBtn }
        ):Play()
        tab.Selected = false
        
        -- Hide search container for non-selected tabs
        if tab.SearchContainer then
            tab.SearchContainer.Visible = false
        end
    end

    local selectedTab = TabModule.Tabs[TabIdx]
    if selectedTab then
        -- Cancel existing tweens before starting new ones for the selected tab
        Tools.CancelTween(selectedTab.TabBtn.Title, "TextColor3")
        Tools.CancelTween(selectedTab.TabBtn.Line, "BackgroundColor3")

        TweenService:Create(
            selectedTab.TabBtn.Title,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { TextColor3 = CurrentThemeProps.onTextBtn }
        ):Play()
        TweenService:Create(
            selectedTab.TabBtn.Line,
            TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundColor3 = CurrentThemeProps.onBgLineBtn }
        ):Play()

        task.spawn(function()
            for _, Container in pairs(TabModule.Containers) do
                Container.Visible = false
            end

            -- Show search container for selected tab
            if selectedTab.SearchContainer then
                selectedTab.SearchContainer.Visible = true
                if selectedTab.updateSearch then
                    selectedTab.updateSearch()
                end
            end

            TabModule.Containers[TabIdx].Visible = true
        end)
    else
        warn("Attempted to select a non-existent tab:", TabIdx)
    end
end

return TabModule

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals --[[!nl]]--local Elements = {}

for _, Theme in next, script:GetChildren() do
	table.insert(Elements, require(Theme))
end

return Elements
end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals --[[!nl]]--local UserInputService = game:GetService("UserInputService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local Validate = Tools.Validate

--[[!nl]]--type BindConfig = {
    Title: string,
    Description: string?,
    Hold: boolean?,
    Callback: ((holding: boolean) -> ())?,
    ChangeCallback: ((key: string) -> ())?,
    Default: Enum.KeyCode | Enum.UserInputType | string,
}

type BindContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local BlacklistedKeys = {
	Enum.KeyCode.Unknown,
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	Enum.KeyCode.Up,
	Enum.KeyCode.Left,
	Enum.KeyCode.Down,
	Enum.KeyCode.Right,
	Enum.KeyCode.Slash,
	Enum.KeyCode.Tab,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Escape,
}

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Bind"

--[[!nl]]--function Element:New(context: BindContext, Idx: string, Config: BindConfig)
    local schema = {
        Title = "string",
        Description = "string?",
        Hold = "boolean?",
        Callback = "function?",
        ChangeCallback = "function?",
        Default = "any", -- Can be KeyCode, UserInputType, or string
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Bind" 
    if not Validate(Config, schema) then
        warn("Bind element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Hold = Config.Hold or false
        Config.Callback = Config.Callback or function() end
        Config.ChangeCallback = Config.ChangeCallback or function() end
        Config.Default = Config.Default or Enum.KeyCode.RightControl
    end

	local Bind = { Value = nil :: Enum.KeyCode | Enum.UserInputType | string, Binding = false, Type = "Bind" }
	local Holding = false

	local BindFrame = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

	local value = Create("TextLabel", {
		Font = Enum.Font.Gotham,
		RichText = true,
		Text = "",
		ThemeProps = {
			BackgroundColor3 = "bordercolor",
			TextColor3 = "titlecolor",
		},
		TextSize = 14,
		AnchorPoint = Vector2.new(1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 0, 0, 16),
		Visible = true,
		Parent = BindFrame.topbox,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 0),
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})
    -- `Create` automatically adds `value` to managedUIElements

	AddConnection(BindFrame.Frame.InputEnded, function(Input: InputObject)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if Bind.Binding then
				return
			end
			Bind.Binding = true
			value.Text = "..."
		end
	end)

	function Bind:Set(Key: Enum.KeyCode | Enum.UserInputType | string)
		Bind.Binding = false
        local keyName: string
        if typeof(Key) == "EnumItem" then
            keyName = Key.Name
        else
            keyName = Key
        end
		Bind.Value = keyName
		value.Text = keyName
		context.Library:Callback(Config.ChangeCallback, keyName)
	end

	AddConnection(UserInputService.InputBegan, function(Input: InputObject)
		if UserInputService:GetFocusedTextBox() then
			return
		end
        
        local currentKeyName: string
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            currentKeyName = Input.KeyCode.Name
        else
            currentKeyName = Input.UserInputType.Name
        end

		if (currentKeyName == Bind.Value) and not Bind.Binding then
			if Config.Hold then
				Holding = true
				context.Library:Callback(Config.Callback, Holding)
			else
				context.Library:Callback(Config.Callback)
			end
		elseif Bind.Binding then
			local KeyToSet: Enum.KeyCode | Enum.UserInputType | string
			
            local isBlacklisted = table.find(BlacklistedKeys, Input.KeyCode)
            if Input.UserInputType == Enum.UserInputType.Keyboard and not isBlacklisted then
                KeyToSet = Input.KeyCode
            elseif Input.UserInputType ~= Enum.UserInputType.Keyboard and Input.UserInputType ~= Enum.UserInputType.None then
                KeyToSet = Input.UserInputType
            else
                KeyToSet = Bind.Value -- Fallback to current if invalid input
            end

			Bind:Set(KeyToSet)
		end
	end)

	AddConnection(UserInputService.InputEnded, function(Input: InputObject)
        local currentKeyName: string
        if Input.UserInputType == Enum.UserInputType.Keyboard then
            currentKeyName = Input.KeyCode.Name
        else
            currentKeyName = Input.UserInputType.Name
        end

		if currentKeyName == Bind.Value then
			if Config.Hold and Holding then
				Holding = false
				context.Library:Callback(Config.Callback, Holding)
			end
		end
	end)

	Bind:Set(Config.Default)

	context.Library.Flags[Idx] = Bind
	return Bind
end

return Element

end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals --[[!nl]]--local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local GetPropsCurrentTheme = Tools.GetPropsCurrentTheme
local CancelTween = Tools.CancelTween
local Validate = Tools.Validate

--[[!nl]]--type ButtonConfig = {
    Title: string,
    Variant: "Primary" | "Ghost" | "Outline"?,
    Callback: ((...any) -> any)?,
}

type ButtonContext = {
    Container: Instance,
}

--[[!nl]]--local ButtonStyles = {
	Primary = {
		TextColor3 = Color3.fromRGB(9, 9, 9),
		BackgroundColor3 = GetPropsCurrentTheme().primarycolor,
		BackgroundTransparency = 0,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			BackgroundTransparency = 0.1,
		},
		FocusConfig = {
			BackgroundTransparency = 0.2,
		},
	},
	Ghost = {
		TextColor3 = Color3.fromRGB(244, 244, 244),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		HoverConfig = {
			BackgroundTransparency = 0.98,
		},
		FocusConfig = {
			BackgroundTransparency = 0.94,
		},
	},
	Outline = {
		TextColor3 = Color3.fromRGB(244, 244, 244),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 1,
		UIStroke = {
			Color = Color3.fromRGB(39, 39, 42),
			Thickness = 1,
		},
		HoverConfig = {
			BackgroundTransparency = 0.94,
		},
		FocusConfig = {
			BackgroundTransparency = 0.98,
		},
	},
}

--[[!nl]]--local function ApplyTweens(button: TextButton, config: {[string]: any}, uiStroke: UIStroke?)
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Faster tween for responsiveness
	local tweenGoals = {}

	for property, value in pairs(config) do
		if property ~= "UIStroke" then
            CancelTween(button, property) -- Cancel existing tween for this property
			tweenGoals[property] = value
		end
	end

    if next(tweenGoals) ~= nil then -- Only create tween if there are goals
        local tween = TweenService:Create(button, tweenInfo, tweenGoals)
        Tools.AddManagedTween(tween, button, "TweenState") -- Manage a generic tween state
        tween:Play()
        AddConnection(tween.Completed, function() Tools.RemoveManagedTween(tween) end)
    end

	if uiStroke and config.UIStroke then
		local strokeTweenGoals = {}
		for property, value in pairs(config.UIStroke) do
            CancelTween(uiStroke, property) -- Cancel existing tween for this property
			strokeTweenGoals[property] = value
		end
        if next(strokeTweenGoals) ~= nil then -- Only create tween if there are goals
            local strokeTween = TweenService:Create(uiStroke, tweenInfo, strokeTweenGoals)
            Tools.AddManagedTween(strokeTween, uiStroke, "TweenStrokeState") -- Manage a generic tween state
            strokeTween:Play()
            AddConnection(strokeTween.Completed, function() Tools.RemoveManagedTween(strokeTween) end)
        end
	end
end

--[[!nl]]--local function CreateButton(style: "Primary" | "Ghost" | "Outline", text: string, parent: Instance): TextButton
	local config = ButtonStyles[style]
	assert(config, "Invalid button style: " .. style)

	local button = Create("TextButton", {
		Font = Enum.Font.Gotham,
		LineHeight = 1.25,
		Text = text,
		TextColor3 = config.TextColor3,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = config.BackgroundColor3,
		BackgroundTransparency = config.BackgroundTransparency,
		BorderColor3 = config.BorderColor3,
		BorderSizePixel = config.BorderSizePixel,
		Visible = true,
		Parent = parent,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingTop = UDim.new(0, 8),
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
	})
    -- `Create` automatically adds `button` to managedUIElements

    local uiStroke: UIStroke?
	if config.UIStroke then
		uiStroke = Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = config.UIStroke.Color,
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
			Parent = button,
		})
        -- `Create` automatically adds `uiStroke` to managedUIElements
	end

	AddConnection(button.MouseEnter, function()
		if config.HoverConfig then
			ApplyTweens(button, config.HoverConfig, uiStroke)
		end
	end)

	AddConnection(button.MouseLeave, function()
		ApplyTweens(button, {
			BackgroundColor3 = config.BackgroundColor3,
			TextColor3 = config.TextColor3,
			BackgroundTransparency = config.BackgroundTransparency,
			BorderColor3 = config.BorderColor3,
			BorderSizePixel = config.BorderSizePixel,
			UIStroke = config.UIStroke,
		}, uiStroke)
	end)

	AddConnection(button.MouseButton1Down, function()
		if config.FocusConfig then
			ApplyTweens(button, config.FocusConfig, uiStroke)
		end
	end)

	AddConnection(button.MouseButton1Up, function()
		if config.HoverConfig then
			ApplyTweens(button, config.HoverConfig, uiStroke)
		else
			ApplyTweens(button, {
				BackgroundColor3 = config.BackgroundColor3,
				TextColor3 = config.TextColor3,
				BackgroundTransparency = config.BackgroundTransparency,
				BorderColor3 = config.BorderColor3,
				BorderSizePixel = config.BorderSizePixel,
				UIStroke = config.UIStroke,
			}, uiStroke)
		end
	end)

	return button
end

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Button"

--[[!nl]]--function Element:New(context: ButtonContext, Config: ButtonConfig)
    local schema = {
        Title = "string",
        Variant = "string?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Button"
    if not Validate(Config, schema) then
        warn("Button element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Variant = Config.Variant or "Primary"
        Config.Callback = Config.Callback or function() end
    end

	local Button = {}

	Button.StyledButton = CreateButton(Config.Variant, Config.Title, context.Container)
    local library = require(script.Parent.Parent) -- Access the main library for safe callback
	AddConnection(Button.StyledButton.MouseButton1Click, function(...)
        library:Callback(Config.Callback, ...)
    end)

	return Button
end

return Element

end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals --[[!nl]]--local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local Validate = Tools.Validate
local RemoveManagedTween = Tools.RemoveManagedTween
local CancelTween = Tools.CancelTween

--[[!nl]]--type ColorpickerConfig = {
    Title: string,
    Description: string?,
    Default: Color3,
    Transparency: number?,
    Callback: ((color: Color3) -> ())?,
}

type ColorpickerContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local HueSelectionPosition, RainbowColorValue = 0, 0
local RAINBOW_INCREMENT = 1 / 255 
local HUE_INCREMENT_BASE = 1 
local MAX_HUE_POSITION = 127 

local rainbowUpdateConnection = nil :: RBXScriptConnection?
local activeRainbowColorpickers = 0 -- Tracks how many colorpickers have rainbow mode active

--[[!nl]]--local function ensureRainbowLoop()
    if rainbowUpdateConnection and rainbowUpdateConnection.Connected then return end -- Loop already running

    rainbowUpdateConnection = AddConnection(RunService.Heartbeat, function(deltaTime: number)
        if activeRainbowColorpickers <= 0 then
            -- Stop loop if no active colorpickers require it
            if rainbowUpdateConnection then
                rainbowUpdateConnection:Disconnect()
                rainbowUpdateConnection = nil
            end
            return
        end
        -- Scale increment by deltaTime for frame-rate independent animation
        RainbowColorValue = (RainbowColorValue + RAINBOW_INCREMENT * (deltaTime / Tools.Constants.RAINBOW_LOOP_BASE_DT)) % 1 
        HueSelectionPosition = (HueSelectionPosition + HUE_INCREMENT_BASE * (deltaTime / Tools.Constants.RAINBOW_LOOP_BASE_DT)) % MAX_HUE_POSITION
    end)
end

-- Start the loop on module load, it will self-regulate based on activeRainbowColorpickers
ensureRainbowLoop() 

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Colorpicker"

--[[!nl]]--function Element:New(context: ColorpickerContext, Idx: string, Config: ColorpickerConfig)
    local schema = {
        Title = "string",
        Description = "string?",
        Default = "Color3",
        Transparency = "number?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Colorpicker"
    if not Validate(Config, schema) then
        warn("Colorpicker element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Default = Config.Default or Color3.new(1, 0, 0)
        Config.Transparency = Config.Transparency or 0
        Config.Callback = Config.Callback or function() end
    end

    local Colorpicker = {
        Value = Config.Default,
        Transparency = Config.Transparency,
        Type = "Colorpicker",
        Callback = Config.Callback,
        RainbowMode = false, 
        ColorpickerToggle = false,
        Hue = 0,
        Sat = 0,
        Vib = 0,
        rainbowModeConnection = nil :: RBXScriptConnection?, -- Connection for this specific colorpicker's rainbow mode
    }

	function Colorpicker:SetHSVFromRGB(Color: Color3)
		local H, S, V = Color3.toHSV(Color)
		Colorpicker.Hue = H
		Colorpicker.Sat = S
		Colorpicker.Vib = V
	end
	Colorpicker:SetHSVFromRGB(Colorpicker.Value)

	local ColorpickerFrame = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

	local InputFrame = Create("CanvasGroup", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Visible = true,
		Parent = ColorpickerFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(24, 24, 26),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
	})
    -- `Create` automatically adds `InputFrame` to managedUIElements

	local colorBox = Create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(3, 255, 150),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 30, 1, 0),
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(24, 24, 26),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
	})
    -- `Create` automatically adds `colorBox` to managedUIElements

	local inputHex = Create("TextBox", {
		Font = Enum.Font.GothamMedium,
		LineHeight = 1.2000000476837158,
		PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
		Text = "#03ff96",
		TextColor3 = Color3.fromRGB(178, 178, 178),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Visible = true,
		Parent = InputFrame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 0),
		}),
	})
    -- `Create` automatically adds `inputHex` to managedUIElements

	AddConnection(inputHex.FocusLost, function(Enter: boolean)
		if Enter then
			local Success, Result = pcall(Color3.fromHex, inputHex.Text)
			if Success and typeof(Result) == "Color3" then
				Colorpicker:Set(Result) -- Update colorpicker through Set function
			else
                warn("Invalid hex code entered: ", inputHex.Text)
                -- Optionally revert text or show an error
            end
		end
	end)

	-- Colorpicker
	local colorpicker_frame = Create("TextButton", {
		AutoButtonColor = false,
		Text = "",
		ZIndex = 20,
		BackgroundColor3 = Color3.fromRGB(9, 9, 11),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 0, 166),
		Visible = false,
		Parent = ColorpickerFrame.Frame,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6),
		}),
	})
    -- `Create` automatically adds `colorpicker_frame` to managedUIElements

	local color = Create("ImageLabel", {
		Image = "rbxassetid://4155801252",
		BackgroundColor3 = Color3.fromRGB(255, 0, 4),
		Size = UDim2.new(1, -10, 0, 127),
		Visible = true,
		ZIndex = 10,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	})
    -- `Create` automatically adds `color` to managedUIElements

	local color_selection = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 12, 0, 12),
		Visible = true,
		Parent = color,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.fromRGB(255, 255, 255),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.2000000476837158,
		}),
	})
    -- `Create` automatically adds `color_selection` to managedUIElements

	local hue = Create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 6, 0, 127),
		Visible = true,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 9),
		}),
		Create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Enabled = true,
			Offset = Vector2.new(0, 0),
			Rotation = 270,
		}),
	})
    -- `Create` automatically adds `hue` to managedUIElements

	local hue_selection = Create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 0, 0.1, 0),
		Size = UDim2.new(0, 8, 0, 8),
		Visible = true,
		Parent = hue,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
			Color = Color3.fromRGB(255, 255, 255),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1.2000000476837158,
		}),
	})
    -- `Create` automatically adds `hue_selection` to managedUIElements

	local rainbowtoggle = Create("TextButton", {
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Color3.fromRGB(0, 0, 0),
		TextSize = 14,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 16),
		Visible = true,
		Parent = colorpicker_frame,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(250, 250, 250),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),

		Create("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=6031094667",
			ImageColor3 = Color3.fromRGB(9, 9, 11),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 12, 0, 12),
			Visible = true,
		}),
		Create("TextLabel", {
			Font = Enum.Font.Gotham,
			Text = "Rainbow",
			TextColor3 = Color3.fromRGB(234, 234, 234),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 26, 0, 0),
			Size = UDim2.new(1, 0, 0, 16),
			Visible = true,
		}),
	})
    -- `Create` automatically adds `rainbowtoggle` to managedUIElements

	local togglebox = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(250, 250, 250),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 16, 0, 16),
		Visible = true,
		Parent = rainbowtoggle,
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(250, 250, 250),
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),

		Create("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=6031094667",
			ImageColor3 = Color3.fromRGB(9, 9, 11),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 12, 0, 12),
			Visible = true,
		}),
		Create("TextLabel", {
			Font = Enum.Font.Gotham,
			Text = "Rainbow",
			TextColor3 = Color3.fromRGB(234, 234, 234),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 26, 0, 0),
			Size = UDim2.new(1, 0, 0, 16),
			Visible = true,
		}),
	})
    -- `Create` automatically adds `togglebox` to managedUIElements

	local function UpdateColorPicker()
        if not (Colorpicker.Hue ~= nil and Colorpicker.Sat ~= nil and Colorpicker.Vib ~= nil) then
            warn("Missing HSV values in UpdateColorPicker for", Config.Title)
            return
        end
        
        local newColor = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
        colorBox.BackgroundColor3 = newColor
        color.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
        color_selection.BackgroundColor3 = newColor
        
        -- Update hex input safely
        if inputHex then
            inputHex.Text = "#" .. newColor:ToHex()
        end
        
        context.Library:Callback(Colorpicker.Callback, newColor)
        Colorpicker.Value = newColor
    end
	
	local function UpdateColorPickerPosition()
		local ColorX = math.clamp(mouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X)
		local ColorY = math.clamp(mouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y)
		color_selection.Position = UDim2.new(ColorX / color.AbsoluteSize.X, 0, ColorY / color.AbsoluteSize.Y, 0)
		Colorpicker.Sat = ColorX / color.AbsoluteSize.X
		Colorpicker.Vib = 1 - (ColorY / color.AbsoluteSize.Y)
		UpdateColorPicker()
	end
	
	local ColorInputConnectionRef, HueInputConnectionRef = nil, nil -- Use local refs for connections
	
	AddConnection(color.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if Colorpicker.RainbowMode then
				return
			end
			if ColorInputConnectionRef then
				ColorInputConnectionRef:Disconnect()
                ColorInputConnectionRef = nil
			end
			ColorInputConnectionRef = AddConnection(mouse.Move, UpdateColorPickerPosition)
			UpdateColorPickerPosition()
		end
	end)
	
	AddConnection(color.InputEnded, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ColorInputConnectionRef then
				ColorInputConnectionRef:Disconnect()
				ColorInputConnectionRef = nil
			end
		end
	end)
	
	AddConnection(hue.InputBegan, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if Colorpicker.RainbowMode then
				return
			end
			if HueInputConnectionRef then
				HueInputConnectionRef:Disconnect()
                HueInputConnectionRef = nil
			end
			HueInputConnectionRef = AddConnection(mouse.Move, UpdateHuePickerPosition)
			UpdateHuePickerPosition()
		end
	end)
	
	AddConnection(hue.InputEnded, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if HueInputConnectionRef then
				HueInputConnectionRef:Disconnect()
				HueInputConnectionRef = nil
			end
		end
	end)	

	AddConnection(ColorpickerFrame.Frame.MouseButton1Click, function()
		Colorpicker.ColorpickerToggle = not Colorpicker.ColorpickerToggle
        CancelTween(colorpicker_frame, "Visible")
        TweenService:Create(colorpicker_frame, TweenInfo.new(0.2), {Visible = Colorpicker.ColorpickerToggle}):Play()

        -- If toggling to visible and rainbow mode is active, ensure it updates
        if Colorpicker.ColorpickerToggle and Colorpicker.RainbowMode then
            -- Immediately update for visual feedback
            Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = RainbowColorValue, 1, 1
            local hueYPos = RainbowColorValue * hue.AbsoluteSize.Y
            hue_selection.Position = UDim2.new(0.5, 0, hueYPos / hue.AbsoluteSize.Y, 0)
            color_selection.Position = UDim2.new(1, 0, 0.5, 0) 
            UpdateColorPicker()
        end
	end)

	AddConnection(rainbowtoggle.MouseButton1Click, function()
		Colorpicker.RainbowMode = not Colorpicker.RainbowMode
		
        CancelTween(togglebox, "BackgroundTransparency")
		TweenService:Create(
			togglebox,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ BackgroundTransparency = Colorpicker.RainbowMode and 0 or 1 }
		):Play()

		if Colorpicker.RainbowMode then
            activeRainbowColorpickers = activeRainbowColorpickers + 1 -- Increment active count
            ensureRainbowLoop() -- Ensure the global loop is running
            
            -- Immediately update for visual feedback
            Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib = RainbowColorValue, 1, 1
            local hueYPos = RainbowColorValue * hue.AbsoluteSize.Y
            hue_selection.Position = UDim2.new(0.5, 0, hueYPos / hue.AbsoluteSize.Y, 0)
            color_selection.Position = UDim2.new(1, 0, 0.5, 0) 
            UpdateColorPicker()
		else
            activeRainbowColorpickers = math.max(0, activeRainbowColorpickers - 1) -- Decrement active count
            -- When exiting rainbow mode, set color to last chosen or default if no interaction happened
            Colorpicker:SetHSVFromRGB(Colorpicker.Value) -- Revert to stored value or default
            color_selection.Position = UDim2.new(Colorpicker.Sat, 0, 1 - Colorpicker.Vib, 0)
            hue_selection.Position = UDim2.new(0.5, 0, Colorpicker.Hue, 0)
            UpdateColorPicker()
		end
	end)

    function Colorpicker:Set(newColor: Color3)
        if typeof(newColor) ~= "Color3" then
            warn("Invalid color value provided to Colorpicker:Set for", Config.Title, ". Expected Color3, got", typeof(newColor))
            return
        end
        
        self:SetHSVFromRGB(newColor)
        
        -- Update UI elements safely
        if color_selection and colorBox and hue_selection then
            color_selection.Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
            colorBox.BackgroundColor3 = newColor
            hue_selection.Position = UDim2.new(0.5, 0, self.Hue, 0)
            UpdateColorPicker()
        end
        -- Ensure rainbow mode is off when color is manually set
        if self.RainbowMode then
            self.RainbowMode = false
            activeRainbowColorpickers = math.max(0, activeRainbowColorpickers - 1) -- Decrement active count
            CancelTween(togglebox, "BackgroundTransparency")
            TweenService:Create(
                togglebox,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = 1 }
            ):Play()
        end
    end

	context.Library.Flags[Idx] = Colorpicker
	return Colorpicker
end

return Element

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components
local TweenService = game:GetService("TweenService")

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local GetPropsCurrentTheme = Tools.GetPropsCurrentTheme
local CancelTween = Tools.CancelTween
local Validate = Tools.Validate

--[[!nl]]--type DropdownConfig = {
    Title: string,
    Description: string?,
    Options: {string},
    Default: string | {string}, -- Single string or table of strings for multiple
    IgnoreFirst: boolean?,
    Multiple: boolean?,
    MaxOptions: number?,
    PlaceHolder: string?,
    Callback: ((value: string | {string}) -> ())?,
}

type DropdownContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

--[[!nl]]--function Element:New(context: DropdownContext, Idx: string, Config: DropdownConfig)
    local schema = {
        Title = "string",
        Description = "string?",
        Options = "table",
        Default = "any", -- string or table
        IgnoreFirst = "boolean?",
        Multiple = "boolean?",
        MaxOptions = "number?",
        PlaceHolder = "string?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Dropdown"
    if not Validate(Config, schema) then
        warn("Dropdown element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Options = Config.Options or {}
        Config.Multiple = Config.Multiple or false
        Config.Default = Config.Default or (Config.Multiple and {} or "")
        Config.IgnoreFirst = Config.IgnoreFirst or false
        Config.MaxOptions = Config.MaxOptions or math.huge
        Config.PlaceHolder = Config.PlaceHolder or ""
        Config.Callback = Config.Callback or function() end
    end

	local Dropdown = {
		Value = Config.Default,
		Options = Config.Options,
		Buttons = {},
		Toggled = false,
		Type = "Dropdown",
		Multiple = Config.Multiple,
		Callback = Config.Callback,
	}
	local MaxElements = 5 -- This variable is unused currently

	local DropdownFrame = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

	local DropdownElement = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 30),
		Visible = true,
		Parent = DropdownFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = { Color = "bordercolor" },
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Create("UIListLayout", {
			Wraps = true,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
	})
    -- `Create` automatically adds `DropdownElement` to managedUIElements

	local holder = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 30),
		Visible = true,
		Parent = DropdownElement,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 4),
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 4),
			Wraps = true,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),
		Create("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Shrink,
		}, {}),
	})
    -- `Create` automatically adds `holder` to managedUIElements

	local search = Create("TextBox", {
		CursorPosition = -1,
		Font = Enum.Font.Gotham,
		PlaceholderText = Config.PlaceHolder,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ThemeProps = {
			BackgroundColor3 = "maincolor"
		},
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 120, 0, 30),
		Visible = true,
		Parent = DropdownElement,
	}, {
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 0),
		}),
		Create("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Fill,
		}),
	})
    -- `Create` automatically adds `search` to managedUIElements

	local dropcont = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		ThemeProps = { BackgroundColor3 = "containeritemsbg" },
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = DropdownFrame.Frame,
	}, {
		Create("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeProps = { Color = "bordercolor" },
			Enabled = true,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 1,
		}),
		Create("UICorner", {
			CornerRadius = UDim.new(0, 6),
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
		}),
		Create("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
    -- `Create` automatically adds `dropcont` to managedUIElements

	AddConnection(search.Focused, function()
		Dropdown.Toggled = true
		dropcont.Visible = true
	end)
	AddConnection(DropdownFrame.Frame.MouseButton1Click, function()
		Dropdown.Toggled = not Dropdown.Toggled
		dropcont.Visible = Dropdown.Toggled
	end)
	function SearchOptions()
		local searchText = string.lower(search.Text)
		for _, v in ipairs(dropcont:GetChildren()) do
			if v:IsA("TextButton") then
				local buttonText = string.lower(v.TextLabel.Text)
				-- Using 'true' for literal search (no patterns)
				if string.find(buttonText, searchText, 1, true) then
					v.Visible = true
				else
					v.Visible = false
				end
			end
		end
	end

	AddConnection(search.Changed, SearchOptions)

	local function AddOptions(Options: {string})
		for _, Option in pairs(Options) do
			local check = Create("ImageLabel", {
				Image = "rbxassetid://15269180838",
				ThemeProps = { ImageColor3 = "itemcheckmarkcolor", },
				ImageRectOffset = Vector2.new(514, 257),
				ImageRectSize = Vector2.new(256, 256),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.new(1, -9, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14),
				Visible = true,
			})
            -- `Create` automatically adds `check` to managedUIElements

			local text_label_2 = Create("TextLabel", {
				Font = Enum.Font.Gotham,
				Text = Option,
				LineHeight = 0,
				TextColor3 = Color3.fromRGB(154, 154, 154),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, 0),
				Visible = true,
			}, {
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 14),
					PaddingRight = UDim.new(0, 0),
					PaddingTop = UDim.new(0, 0),
				}),
			})
            -- `Create` automatically adds `text_label_2` to managedUIElements

			local dropbtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				ThemeProps = { BackgroundColor3 = "itembg" },
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 30),
				Visible = true,
				Parent = dropcont,
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				text_label_2,
				check,
			})
            -- `Create` automatically adds `dropbtn` to managedUIElements

			AddConnection(dropbtn.MouseButton1Click, function()
				if Config.Multiple then
					local index = table.find(Dropdown.Value, Option)
					if index then
						table.remove(Dropdown.Value, index)
					else
						if #Dropdown.Value < (Config.MaxOptions or math.huge) then
							table.insert(Dropdown.Value, Option)
						end
					end
					Dropdown:Set(Dropdown.Value)
				else
					if Dropdown.Value == Option then
						Dropdown:Set("")
					else
						Dropdown:Set(Option)
					end
				end
				
				if not Config.Multiple then
					Dropdown.Toggled = false
					dropcont.Visible = false
				end
			end)

			Dropdown.Buttons[Option] = dropbtn
		end
	end

	function Dropdown:Refresh(Options: {string}, Delete: boolean?)
        -- Always clean up existing buttons first
        for _, v in pairs(Dropdown.Buttons) do
            if v and v.Parent then
                v:Destroy()
            end
        end
        Dropdown.Buttons = {} -- Clear the table of button references

        -- Then add new options
        Dropdown.Options = Options
        AddOptions(Dropdown.Options)
        
        -- Re-set value to update UI with new options, if necessary
        Dropdown:Set(Dropdown.Value, true)
	end

	function Dropdown:Set(Value: string | {string}, ignore: boolean?)
		local currentTheme = GetPropsCurrentTheme()
		local function updateButtonTransparency(button: TextButton, isSelected: boolean)
			local transparency = isSelected and 0 or 1
			local textTransparency = isSelected and currentTheme.itemTextOff or currentTheme.itemTextOn
			
            CancelTween(button, "BackgroundTransparency")
			TweenService:Create(
				button,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = transparency }
			):Play()
            
            local imageLabel = button:FindFirstChildOfClass("ImageLabel")
            if imageLabel then
                CancelTween(imageLabel, "ImageTransparency")
                TweenService:Create(
                    imageLabel,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { ImageTransparency = transparency }
                ):Play()
            end

            local textLabel = button:FindFirstChildOfClass("TextLabel")
            if textLabel then
                CancelTween(textLabel, "TextColor3")
                TweenService:Create(
                    textLabel,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { TextColor3 = textTransparency }
                ):Play()
            end
		end

		local function clearValueText()
			for _, label in pairs(holder:GetChildren()) do
				if label:IsA("TextButton") then
					label:Destroy()
				end
			end
		end

		local function addValueTag(text: string)
			local tagBtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 14,
				AutomaticSize = Enum.AutomaticSize.X,
				ThemeProps = { BackgroundColor3 = "valuebg" },
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 0, 22),
				Visible = true,
				Parent = holder,
			}, {
				Create("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
				Create("UIPadding", {
					PaddingBottom = UDim.new(0, 0),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 0),
				}),
				Create("UIListLayout", {
					Padding = UDim.new(0, 4),
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}, {}),
				Create("TextLabel", {
					Font = Enum.Font.Gotham,
					ThemeProps = { TextColor3 = "valuetext" },
					TextSize = 14,
					Text = text,
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
				}, {}),
			})
            -- `Create` automatically adds `tagBtn` to managedUIElements

			local closebtn = Create("TextButton", {
				Font = Enum.Font.SourceSans,
				Text = "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 14,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 16, 0, 16),
				Visible = true,
				Parent = tagBtn,
			}, {
				Create("ImageLabel", {
					Image = "rbxassetid://15269329696",
					ImageRectOffset = Vector2.new(0, 514),
					ImageRectSize = Vector2.new(256, 256),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 16, 0, 16),
					Visible = true,
				}, {}),
			})
            -- `Create` automatically adds `closebtn` to managedUIElements
			
            -- Clicking the tag or close button should remove it
			AddConnection(tagBtn.MouseButton1Click, function()
				if Config.Multiple then
					local index = table.find(Dropdown.Value, text)
					if index then
						table.remove(Dropdown.Value, index)
						Dropdown:Set(Dropdown.Value)
					end
				else
					Dropdown:Set("")
				end
			end)
		end

        -- Handle the Value assignment properly for both single and multiple modes
        if Config.Multiple then
            if type(Value) == "table" then
                Dropdown.Value = Value
            elseif type(Value) == "string" and Value ~= "" then  -- Only modify if not clearing
                if type(Dropdown.Value) ~= "table" then
                    Dropdown.Value = {}
                end
                local index = table.find(Dropdown.Value, Value)
                if index then
                    table.remove(Dropdown.Value, index)
                else
                    if #Dropdown.Value < (Config.MaxOptions or math.huge) then
                        table.insert(Dropdown.Value, Value)
                    end
                end
            else -- Value is empty string or nil, meaning clear all for multiple
                Dropdown.Value = {}
            end
        else
            -- For single selection, just set the value directly
            if type(Value) == "string" then
                Dropdown.Value = Value
            else -- If a table is passed in single mode, use the first value or clear
                Dropdown.Value = Value[1] or ""
            end
        end

		local found = Config.Multiple or table.find(Dropdown.Options, Dropdown.Value)
		if Config.Multiple then
			for i = #Dropdown.Value, 1, -1 do
				if not table.find(Dropdown.Options, Dropdown.Value[i]) then
					table.remove(Dropdown.Value, i)
				end
			end
			found = #Dropdown.Value > 0
		end

		clearValueText()

		if not found then
			Dropdown.Value = Config.Multiple and {} or ""
			for _, button in pairs(Dropdown.Buttons) do
				updateButtonTransparency(button, false)
			end
			-- The callback with an empty value will be handled below
		else
			if Config.Multiple then
				for _, val in ipairs(Dropdown.Value) do
					addValueTag(val)
				end
			else
				addValueTag(Dropdown.Value)
			end
		end

		for i, button in pairs(Dropdown.Buttons) do
			local isSelected = (Config.Multiple and table.find(Dropdown.Value, i))
				or (not Config.Multiple and i == Dropdown.Value)
			updateButtonTransparency(button, isSelected)
		end

		if not ignore then
			context.Library:Callback(Config.Callback, Dropdown.Value)
		end
	end

	Dropdown:Refresh(Dropdown.Options, false)
	Dropdown:Set(Config.Default, Config.IgnoreFirst) -- Initial set with default and ignoreFirst

	context.Library.Flags[Idx] = Dropdown
	return Dropdown
end

return Element

end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals --[[!nl]]--local Components = script.Parent.Parent.components
local Tools = require(script.Parent.Parent.tools)
local Validate = Tools.Validate

--[[!nl]]--type ParagraphConfig = {
    Title: string,
    Description: string?,
}

type ParagraphContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Paragraph"

--[[!nl]]--function Element:New(context: ParagraphContext, Config: ParagraphConfig)
    local schema = {
        Title = "string",
        Description = "string?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Paragraph"
    if not Validate(Config, schema) then
        warn("Paragraph element with Title:", Config.Title, "has invalid config.")
        -- Default values for description are handled by element.lua
    end

	local paragraph = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

	return paragraph
end

return Element

end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals --[[!nl]]--local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CancelTween = Tools.CancelTween
local Validate = Tools.Validate
local RemoveManagedTween = Tools.RemoveManagedTween

--[[!nl]]--type SliderConfig = {
    Title: string,
    Description: string?,
    Min: number?,
        Max: number?,
    Increment: number?,
    Default: number?,
    IgnoreFirst: boolean?,
    Callback: ((value: number) -> ())?,
}

type SliderContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local function Round(Number: number, Factor: number): number
    local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then
        Result = Result + Factor
    end
    return Result
end

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Slider"

--[[!nl]]--function Element:New(context: SliderContext, Idx: string, Config: SliderConfig)
    local Library = context.Library
    local schema = {
        Title = "string",
        Description = "string?",
        Min = "number?",
        Max = "number?",
        Increment = "number?",
        Default = "number?",
        IgnoreFirst = "boolean?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Slider"
    if not Validate(Config, schema) then
        warn("Slider element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Min = Config.Min or 0
        Config.Max = Config.Max or 100
        Config.Increment = Config.Increment or 1
        Config.Default = Config.Default or (Config.Min + Config.Max) / 2
        Config.IgnoreFirst = Config.IgnoreFirst or false
        Config.Callback = Config.Callback or function() end
    end

    local Slider = {
        Value = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Increment = Config.Increment,
        IgnoreFirst = Config.IgnoreFirst,
        Callback = Config.Callback,
        Type = "Slider",
    }

    local Dragging = false
    local DraggingDot = false

    local SliderFrame = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

    local ValueText = Create("TextLabel", {
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = "0", -- Default text, will be updated by Set
        ThemeProps = {
            TextColor3 = "titlecolor",
        },
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.754537523, 8, 0, 0),
        Size = UDim2.new(0, 90, 0, 16),
        Visible = true,
        Parent = SliderFrame.topbox,
    })
    -- `Create` automatically adds `ValueText` to managedUIElements

    local SliderBar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        ThemeProps = { BackgroundColor3 = "sliderbar" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 26),
        Size = UDim2.new(1, -6, 0, 2),
        Visible = true,
        Parent = SliderFrame.Frame,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderbarstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
    })
    -- `Create` automatically adds `SliderBar` to managedUIElements

    local SliderProgress = Create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderprogressbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderprogressborder" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
    })
    -- `Create` automatically adds `SliderProgress` to managedUIElements

    local SliderDot = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        ThemeProps = { BackgroundColor3 = "sliderdotbg" },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 10, 0, 10),
        Visible = true,
        Parent = SliderBar,
    }, {
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "sliderdotstroke" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })
    -- `Create` automatically adds `SliderDot` to managedUIElements

    function Slider:Set(Value: number, ignore: boolean?)
        self.Value = math.clamp(Round(Value, Config.Increment), Config.Min, Config.Max)
        ValueText.Text = string.format("%s<font transparency='0.5'>/%s </font>", tostring(self.Value), Config.Max)
        
        local range = Config.Max - Config.Min
        if range == 0 then
            warn("Slider: Min and Max values are equal for", Config.Title, ". Cannot calculate position.")
            return -- Return to avoid division by zero
        end

        local newPosition = (self.Value - Config.Min) / range
        
        if DraggingDot then
            -- Instant update when dragging dot
            SliderDot.Position = UDim2.new(newPosition, 0, 0.5, 0)
            SliderProgress.Size = UDim2.fromScale(newPosition, 1)
        else
            -- Smooth tween when not dragging
            CancelTween(SliderDot, "Position")
            local dotTween = TweenService:Create(SliderDot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(newPosition, 0, 0.5, 0)
            })
            Tools.AddManagedTween(dotTween, SliderDot, "Position")
            dotTween:Play()
            AddConnection(dotTween.Completed, function() Tools.RemoveManagedTween(dotTween) end)
            
            CancelTween(SliderProgress, "Size")
            local progressTween = TweenService:Create(SliderProgress, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromScale(newPosition, 1)
            })
            Tools.AddManagedTween(progressTween, SliderProgress, "Size")
            progressTween:Play()
            AddConnection(progressTween.Completed, function() Tools.RemoveManagedTween(progressTween) end)
        end
        
        if not ignore then
            return Library:Callback(Config.Callback, self.Value)
        end
    end

    local function updateSliderFromInput(inputPosition: Vector2)
        if Dragging then
            local barPosition = SliderBar.AbsolutePosition
            local barSize = SliderBar.AbsoluteSize
            -- Prevent division by zero if barSize.X is 0
            if barSize.X == 0 then return end 
            local relativeX = (inputPosition.X - barPosition.X) / barSize.X
            local clampedPosition = math.clamp(relativeX, 0, 1)
            local newValue = Config.Min + (Config.Max - Config.Min) * clampedPosition
            Slider:Set(newValue)
        end
    end

    AddConnection(SliderBar.InputBegan, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(SliderDot.InputBegan, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DraggingDot = true
            updateSliderFromInput(input.Position)
        end
    end)

    AddConnection(UserInputService.InputEnded, function(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            DraggingDot = false
        end
    end)

    AddConnection(UserInputService.InputChanged, function(input: InputObject)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSliderFromInput(input.Position)
        end
    end)

    Slider:Set(Config.Default, Config.IgnoreFirst)

    Library.Flags[Idx] = Slider
    return Slider
end

return Element
end)() end,
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals --[[!nl]]--local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local Validate = Tools.Validate

--[[!nl]]--type TextboxConfig = {
    Title: string,
    Description: string?,
    PlaceHolder: string?,
    Default: string?,
    TextDisappear: boolean?,
    Callback: ((value: string) -> ())?,
}

type TextboxContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Textbox"

--[[!nl]]--function Element:New(context: TextboxContext, Config: TextboxConfig)
    local schema = {
        Title = "string",
        Description = "string?",
        PlaceHolder = "string?",
        Default = "string?",
        TextDisappear = "boolean?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Textbox"
    if not Validate(Config, schema) then
        warn("Textbox element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.PlaceHolder = Config.PlaceHolder or ""
        Config.Default = Config.Default or ""
        Config.TextDisappear = Config.TextDisappear or false
        Config.Callback = Config.Callback or function() end
    end

    local Textbox = {
        Value = Config.Default or "",
        Callback = Config.Callback,
        Type = "Textbox",
    }

    local TextboxFrame = require(Components.element)(Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

    local textbox = Create("TextBox", {
        CursorPosition = -1,
        Font = Enum.Font.Gotham,
        PlaceholderText = Config.PlaceHolder,
        Text = Textbox.Value,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Visible = true,
        Parent = TextboxFrame.Frame,
    }, {
        Create("UIPadding", {
            PaddingBottom = UDim.new(0, 0),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            PaddingTop = UDim.new(0, 0),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = { Color = "bordercolor" },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })
    -- `Create` automatically adds `textbox` to managedUIElements

    function Textbox:Set(value: string)
        textbox.Text = value
        Textbox.Value = value
        context.Library:Callback(Config.Callback, value)
    end

    AddConnection(textbox.FocusLost, function()
        Textbox.Value = textbox.Text
        context.Library:Callback(Config.Callback, Textbox.Value)
        if Config.TextDisappear then
            textbox.Text = ""
        end
    end)

    return Textbox
end

return Element

end)() end,
    [16] = function()local wax,script,require=ImportGlobals(16)local ImportGlobals --[[!nl]]--local TweenService = game:GetService("TweenService")
local Tools = require(script.Parent.Parent.tools)
local Components = script.Parent.Parent.components

local Create = Tools.Create
local AddConnection = Tools.AddConnection
local CancelTween = Tools.CancelTween
local Validate = Tools.Validate
local RemoveManagedTween = Tools.RemoveManagedTween

--[[!nl]]--type ToggleConfig = {
    Title: string,
    Description: string?,
    Default: boolean?,
    IgnoreFirst: boolean?,
    Callback: ((value: boolean) -> ())?,
}

type ToggleContext = {
    Container: Instance,
    Type: string,
    ScrollFrame: Instance,
    Library: any,
}

--[[!nl]]--local Element = {}
Element.__index = Element
Element.__type = "Toggle"

--[[!nl]]--function Element:New(context: ToggleContext, Idx: string, Config: ToggleConfig)
    local Library = context.Library
    local schema = {
        Title = "string",
        Description = "string?",
        Default = "boolean?",
        IgnoreFirst = "boolean?",
        Callback = "function?",
    }
    -- Ensure Config.Title is available for warn message even if validation fails
    Config.Title = Config.Title or "Toggle"
    if not Validate(Config, schema) then
        warn("Toggle element with Title:", Config.Title, "has invalid config, using defaults.")
        Config.Default = Config.Default or false
        Config.IgnoreFirst = Config.IgnoreFirst or false
        Config.Callback = Config.Callback or function() end
    end

    local Toggle = {
        Value = Config.Default,
        Callback = Config.Callback,
        IgnoreFirst = Config.IgnoreFirst,
        FirstUpdate = true,
        Type = "Toggle",
    }

    local ToggleFrame = require(Components.element)("        " .. Config.Title, Config.Description, context.Container)
    -- Element component already adds it to managed UI elements

    local box_frame = Create("Frame", {
        ThemeProps = {
            BackgroundColor3 = "togglebg",
        },
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Visible = true,
        Parent = ToggleFrame.topbox,
    }, {
        Create("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Create("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeProps = {
                Color = "toggleborder",
            },
            Enabled = true,
            LineJoinMode = Enum.LineJoinMode.Round,
            Thickness = 1,
        }),
        Create("ImageLabel", {
            Image = "http://www.roblox.com/asset/?id=6031094667",
            ThemeProps = {
                ImageColor3 = "maincolor"
            },
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 12, 0, 12),
            Visible = true,
        })
    })
    -- `Create` automatically adds `box_frame` to managedUIElements

    function Toggle:Set(Value: boolean, ignore: boolean?)
        self.Value = Value
        CancelTween(box_frame, "BackgroundTransparency")
        local tween = TweenService:Create(box_frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = self.Value and 0 or 1})
        Tools.AddManagedTween(tween, box_frame, "BackgroundTransparency")
        tween:Play()
        AddConnection(tween.Completed, function() RemoveManagedTween(tween) end)

        if not ignore and (not self.IgnoreFirst or not self.FirstUpdate) then
            Library:Callback(Toggle.Callback, self.Value)
        end
        self.FirstUpdate = false
    end

    AddConnection(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:Set(not Toggle.Value)
    end)

    Toggle:Set(Config.Default, Config.IgnoreFirst)

    Library.Flags[Idx] = Toggle
    return Toggle
end

return Element

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals --[[!nl]]--local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--[[!nl]]---- Centralized types for better code quality and Luau support
export type ColorConfig = {
    TextColor3: Color3?,
    BackgroundColor3: Color3?,
    ImageColor3: Color3?,
    BorderColor3: Color3?,
}

export type Theme = {
    maincolor: Color3,
    bordercolor: Color3,
    titlecolor: Color3,
    descriptioncolor: Color3,
    offTextBtn: Color3,
    onTextBtn: Color3,
    offBgLineBtn: Color3,
    onBgLineBtn: Color3,
    scrollcolor: Color3,
    elementdescription: Color3,
    primarycolor: Color3,
    containeritemsbg: Color3,
    itemcheckmarkcolor: Color3,
    itembg: Color3,
    itemTextOff: Color3,
    itemTextOn: Color3,
    valuebg: Color3,
    valuetext: Color3,
    sliderbar: Color3,
    sliderbarstroke: Color3,
    sliderprogressbg: Color3,
    sliderprogressborder: Color3,
    sliderdotbg: Color3,
    sliderdotstroke: Color3,
    togglebg: Color3,
    toggleborder: Color3,
}

export type Config = {
    Title: string,
    Description: string?,
    Default: any,
    Callback: ((value: any) -> ())?,
    -- ... other config properties specific to each element type
}

-- ManagedTweenEntry is now optimized for O(1) lookup
type ManagedTweenEntry = Tween 

--[[!nl]]--local tools = {
    Signals = {} :: {[number]: RBXScriptConnection}, -- Store all connections
    -- managedTweens is now indexed by object and property for O(1) lookup
    managedTweens = {} :: {[Instance]: {[string]: ManagedTweenEntry}}, 
    themedObjects = {} :: {[Instance]: ColorConfig}, -- Stores objects whose colors are theme-dependent
    managedUIElements = {} :: {[Instance]: boolean}, -- Stores all UI elements created by tools.Create for cleanup
    
    Constants = {
        CLEANUP_CHECK_INTERVAL = 1, -- seconds
        ELEMENT_NAME = "Element",
        SECTION_NAME = "Section",
        SECTION_CONTAINER_NAME = "SectionContainer",
        ELEMENT_TITLE_NAME = "Title",
        ELEMENT_DESCRIPTION_NAME = "Description",
        TAB_TYPE = "Tab",
        GROUP_BUTTON_TYPE = "Group",
        RAINBOW_LOOP_BASE_DT = 0.06, -- Base deltaTime for rainbow loop scaling
    },
}

--[[!nl]]--local themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/Just3itx/3itx-UI-LIB/refs/heads/main/themes"))() :: {[string]: Theme}

local currentTheme = themes.default :: Theme
local lastAppliedTheme: string? = nil -- Cache last applied theme name

--[[!nl]]--function tools.SetTheme(themeName: string)
    if lastAppliedTheme == themeName then return end -- Only re-apply if theme actually changed
    
    if themes[themeName] then
		currentTheme = themes[themeName]
        lastAppliedTheme = themeName
		for obj, props in pairs(tools.themedObjects) do
            if obj and obj.Parent then -- Only update if object exists and is parented
                for propName, themeKey in next, props do
                    if currentTheme[themeKey] then
                        obj[propName] = currentTheme[themeKey]
                    end
                end
            else
                tools.themedObjects[obj] = nil -- Clean up nil references in theme tracking
            end
		end
	else
		warn("Theme not found: " .. themeName)
	end
end

--[[!nl]]--function tools.GetPropsCurrentTheme(): Theme
	return currentTheme
end

--[[!nl]]--function tools.AddTheme(themeName: string, themeProps: Theme)
	themes[themeName] = themeProps
end

--[[!nl]]--function tools.isMobile(): boolean
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
	-- return true -- For testing mobile UI
end

--[[!nl]]--function tools.AddConnection(Signal: RBXScriptSignal, Function: (...any) -> any): RBXScriptConnection
	local connection = Signal:Connect(Function)
	table.insert(tools.Signals, connection)
	return connection -- Return the connection so it can be disconnected later
end

--[[!nl]]--function tools.Disconnect()
	for key = #tools.Signals, 1, -1 do
		local Connection = table.remove(tools.Signals, key)
        if Connection and Connection.Connected then
		    Connection:Disconnect()
        end
	end
    tools.Signals = {} -- Clear the table after disconnecting
end

--[[!nl]]--function tools.AddManagedTween(tween: Tween, object: Instance, property: string)
    if not tools.managedTweens[object] then
        tools.managedTweens[object] = {}
    end
    -- Overwrite any existing tween for this object and property
    tools.managedTweens[object][property] = tween 
end

--[[!nl]]--function tools.RemoveManagedTween(tween: Tween)
    -- Iterate through managedTweens to find and remove the specific tween
    for obj, propTable in pairs(tools.managedTweens) do
        for prop, storedTween in pairs(propTable) do
            if storedTween == tween then
                propTable[prop] = nil
                -- Clean up object table if no more tweens for it
                if next(propTable) == nil then
                    tools.managedTweens[obj] = nil
                end
                return -- Tween found and removed
            end
        end
    end
end

--[[!nl]]--function tools.CancelTween(object: Instance, property: string)
    if not tools.managedTweens[object] then return end
    local tween = tools.managedTweens[object][property]
    if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
        tween:Cancel()
    end
    -- Remove the tween reference after cancellation
    if tools.managedTweens[object] then
        tools.managedTweens[object][property] = nil
        -- Clean up object table if no more tweens for it
        if next(tools.managedTweens[object]) == nil then
            tools.managedTweens[object] = nil
        end
    end
end

--[[!nl]]--function tools.AddManagedUIElement(element: Instance)
    tools.managedUIElements[element] = true
end

--[[!nl]]--function tools.RemoveManagedUIElement(element: Instance)
    tools.managedUIElements[element] = nil
end

--[[!nl]]--function tools.RemoveThemedObject(object: Instance)
    tools.themedObjects[object] = nil
end

--[[!nl]]--function tools.Create(Name: string, Properties: {[string]: any}, Children: {Instance}?)
	local Object = Instance.new(Name) :: Instance

	if Properties.ThemeProps then
		for propName, themeKey in next, Properties.ThemeProps do
			if currentTheme[themeKey] then
				Object[propName] = currentTheme[themeKey]
			end
		end
		tools.themedObjects[Object] = Properties.ThemeProps -- Store for theme updates
		Properties.ThemeProps = nil
	end

	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end

    tools.AddManagedUIElement(Object) -- Track all created UI elements

	return Object
end

--[[!nl]]--function tools.AddScrollAnim(scrollbar: ScrollingFrame)
    -- Ensure all internal connections of AddScrollAnim are also managed
	local visibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 0 })
    tools.AddManagedTween(visibleTween, scrollbar, "ScrollBarImageTransparency_Visible")
	local invisibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 1 })
    tools.AddManagedTween(invisibleTween, scrollbar, "ScrollBarImageTransparency_Invisible")
	local lastInteraction = tick()
	local delayTime = 0.6

	local function showScrollbar()
        tools.CancelTween(scrollbar, "ScrollBarImageTransparency_Invisible") -- Cancel hide if showing
		visibleTween:Play()
	end

	local function hideScrollbar()
		if tick() - lastInteraction >= delayTime then
            tools.CancelTween(scrollbar, "ScrollBarImageTransparency_Visible") -- Cancel show if hiding
			invisibleTween:Play()
		end
	end

	tools.AddConnection(scrollbar.MouseEnter, function()
		lastInteraction = tick()
		showScrollbar()
	end)

	tools.AddConnection(scrollbar.MouseLeave, function()
		task.delay(delayTime, hideScrollbar) -- Use task.delay instead of wait() for robustness
	end)

	tools.AddConnection(scrollbar.InputChanged, function(input: InputObject)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			lastInteraction = tick()
			showScrollbar()
		end
	end)

	tools.AddConnection(scrollbar:GetPropertyChangedSignal("CanvasPosition"), function()
		lastInteraction = tick()
		showScrollbar()
	end)

	tools.AddConnection(UserInputService.InputChanged, function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			lastInteraction = tick()
			showScrollbar()
		end
	end)

	tools.AddConnection(RunService.RenderStepped, function()
		if tick() - lastInteraction >= delayTime then
			hideScrollbar()
		end
	end)
end

--[[!nl]]--function tools.Validate(config: {[string]: any}, schema: {[string]: string}): boolean
    local isValid = true
    for key, expectedType in pairs(schema) do
        local value = config[key]
        local actualType = typeof(value)

        local isOptional = string.find(expectedType, "?")
        local baseExpectedType = string.gsub(expectedType, "?", "")

        if value == nil then
            if not isOptional then
                warn(`Validation failed for key '{key}': Expected value, but got nil. Schema: '{expectedType}'`)
                isValid = false
            end
        elseif baseExpectedType ~= "any" and actualType ~= baseExpectedType then
            -- Special handling for EnumItems if expected type is "string" (e.g., variant names)
            if baseExpectedType == "string" and typeof(value) == "EnumItem" then
                -- Allow EnumItem.Name to be treated as string
            elseif baseExpectedType == "number" and (actualType == "number" or actualType == "Vector2" or actualType == "UDim") then
                -- Allow common number-like types
            elseif baseExpectedType == "boolean" and actualType == "boolean" then
                -- Standard boolean check
            elseif baseExpectedType == "Color3" and actualType == "Color3" then
                -- Standard Color3 check
            elseif baseExpectedType == "table" and actualType == "table" then
                -- Standard table check
            else
                warn(`Validation failed for key '{key}': Expected type '{baseExpectedType}', but got '{actualType}'. Schema: '{expectedType}'`)
                isValid = false
            end
        end
    end
    return isValid
end

return tools

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "MainModule"
        },
        {
            {
                2,
                1,
                {
                    "components"
                },
                {
                    {
                        6,
                        2,
                        {
                            "section"
                        }
                    },
                    {
                        3,
                        2,
                        {
                            "dialog"
                        }
                    },
                    {
                        5,
                        2,
                        {
                            "notif"
                        }
                    },
                    {
                        4,
                        2,
                        {
                            "element"
                        }
                    },
                    {
                        7,
                        2,
                        {
                            "tab"
                        }
                    }
                }
            },
            {
                8,
                2,
                {
                    "elements"
                },
                {
                    {
                        12,
                        2,
                        {
                            "dropdown"
                        }
                    },
                    {
                        10,
                        2,
                        {
                            "buttons"
                        }
                    },
                    {
                        16,
                        2,
                        {
                            "toggle"
                        }
                    },
                    {
                        11,
                        2,
                        {
                            "colorpicker"
                        }
                    },
                    {
                        9,
                        2,
                        {
                            "bind"
                        }
                    },
                    {
                        14,
                        2,
                        {
                            "slider"
                        }
                    },
                    {
                        13,
                        2,
                        {
                            "paragraph"
                        }
                    },
                    {
                        15,
                        2,
                        {
                            "textbox"
                        }
                    }
                }
            },
            {
                17,
                2,
                {
                    "tools"
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    8,
    [3] = 454,
    [4] = 607,
    [5] = 733,
    [6] = 919,
    [7] = 1131,
    [8] = 1460,
    [9] = 1468,
    [10] = 1597,
    [11] = 1777,
    [12] = 2219,
    [13] = 2732,
    [14] = 2961,
    [15] = 3048,
    [16] = 3138,
    [17] = 3302
}

-- Misc AOT variable imports
local WaxVersion = "0.4.1"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. ArgIndex .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])
