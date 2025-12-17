
-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

local ImportGlobals

local ClosureBindings = {
    function()
        local wax, script, require = ImportGlobals(1)
        local ImportGlobals
        return (function(...)
            task.wait(1)

            function generateRandomString(length)
                local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:',.<>?/`~"
                local randomString = ""
                math.randomseed(os.time())

                for i = 1, length do
                    local randomIndex = math.random(1, #charset)
                    randomString = randomString .. charset:sub(randomIndex, randomIndex)
                end

                return randomString
            end

            local UserInputService = game:GetService("UserInputService")
            local TweenService = game:GetService("TweenService")
            local gethui = gethui or function()
                local player = game.Players.LocalPlayer
                if player then
                    local playerGui = player:FindFirstChild("PlayerGui")
                    if playerGui then
                        return playerGui
                    else
                        local result
                        task.defer(function()
                            result = player:WaitForChild("PlayerGui")
                        end)
                        return result
                    end
                end
                return nil
            end


            local ElementsTable = require(script.elements)
            local Tools = require(script.tools)
            local Components = script.components

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection
            local AddScrollAnim = Tools.AddScrollAnim
            local isMobile = Tools.isMobile()
            local CurrentThemeProps = Tools.GetPropsCurrentTheme()

            local function MakeDraggable(DragPoint, Main)
                local Dragging, MousePos, FramePos = false
                AddConnection(DragPoint.InputBegan, function(Input)
                    if
                        Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Input.UserInputType == Enum.UserInputType.Touch
                    then
                        Dragging = true
                        MousePos = Input.Position
                        FramePos = Main.Position
                    end
                end)
                AddConnection(UserInputService.InputChanged, function(Input)
                    if
                        (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
                        and Dragging
                    then
                        local Delta = Input.Position - MousePos
                        Main.Position =
                            UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                    end
                end)
                AddConnection(UserInputService.InputEnded, function(Input)
                    if
                        (Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Input.UserInputType == Enum.UserInputType.Touch)
                        and Dragging
                    then
                        Dragging = false
                    end
                end)
            end

            local Library = {
                Window = nil,
                Flags = {},
                Signals = {},
                ToggleBind = nil,
            }

            local GUI = Create("ScreenGui", {
                Name = generateRandomString(16),
                Parent = gethui(),
                ResetOnSpawn = false,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            })

            require(Components.notif):Init(GUI)

            function Library:SetTheme(themeName)
                Tools.SetTheme(themeName)
            end

            function Library:GetTheme()
                return Tools.GetPropsCurrentTheme()
            end

            function Library:AddTheme(themeName, themeProps)
                Tools.AddTheme(themeName, themeProps)
            end

            function Library:IsRunning()
                return GUI.Parent == gethui()
            end

            task.spawn(function()
                while Library:IsRunning() do
                    task.wait()
                end
                for i, Connection in pairs(Tools.Signals) do
                    Connection:Disconnect()
                end
            end)

            local Elements = {}
            Elements.__index = Elements
            Elements.__namecall = function(Table, Key, ...)
                return Elements[Key](...)
            end

            for _, ElementComponent in ipairs(ElementsTable) do
                assert(ElementComponent.__type, "ElementComponent missing __type")
                assert(type(ElementComponent.New) == "function", "ElementComponent missing New function")

                Elements["Add" .. ElementComponent.__type] = function(self, Idx, Config)
                    return ElementComponent:New(Idx, Config, self.Container, self.Type, self.ScrollFrame, Library)
                end
            end

            Library.Elements = Elements

            function Library:Callback(Callback, ...)
                local success, result = pcall(Callback, ...)

                if success then
                    return result
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
                    warn(errorInfo)
                end
            end

            function Library:Notification(titleText, descriptionText, duration)
                require(Components.notif):ShowNotification(titleText, descriptionText, duration)
            end

            function Library:Dialog(config)
                return require(Components.dialog):Create(config, self.LoadedWindow)
            end

            function Library:Load(cfgs)

                cfgs = cfgs or {}
                cfgs.Title = cfgs.Title or "Window"
                cfgs.ToggleButton = cfgs.ToggleButton or ""
                cfgs.BindGui = cfgs.BindGui or Enum.KeyCode.RightControl

                if Library.Window then
                    warn("Cannot create more than one window.")
                    GUI:Destroy()
                    return nil
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
                    Visible = false,
                    GroupTransparency = 1,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                    }),
                })

                if isMobile then
                    canvas_group.Size = UDim2.new(0.8, 0, 0.8, 0)
                end

                local togglebtn = Create("ImageButton", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    AutoButtonColor = false,
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                        ImageColor3 = "togglebuttoncolor",
                    },
                    Position = UDim2.new(0.5, 8, 0, 0),
                    Size = UDim2.new(0, 45, 0, 45),
                    Parent = GUI,
                    Image = cfgs.ToggleButton,
                    BackgroundTransparency = 0,
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
                        Archivable = true,
                    }),
                })

                local function ToggleVisibility()
                    local isVisible = canvas_group.Visible and (canvas_group.GroupTransparency < 1)
                    local targetPosition = isVisible and UDim2.new(0.5, 0, -1, 0) or UDim2.new(0.5, 0, 0.5, 0)
                    local targetTransparency = isVisible and 1 or 0
                    local toggleBtnTargetTransparency = isVisible and 0 or 1

                    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

                    canvas_group.Visible = true
                    if cfgs.ToggleButton ~= "" then
                        togglebtn.Visible = true
                    end

                    TweenService:Create(canvas_group, tweenInfo, {
                        Position = targetPosition,
                        GroupTransparency = targetTransparency
                    }):Play()

                    if cfgs.ToggleButton ~= "" then
                        TweenService:Create(togglebtn, tweenInfo, {
                            BackgroundTransparency = toggleBtnTargetTransparency,
                            ImageTransparency = toggleBtnTargetTransparency,
                        }):Play()

                        local stroke = togglebtn:FindFirstChildOfClass("UIStroke")
                        if stroke then
                            TweenService:Create(stroke, tweenInfo, {
                                Transparency = toggleBtnTargetTransparency,
                            }):Play()
                        end
                    end

                    if isVisible then
                        local connection
                        connection = AddConnection(TweenService:Create(canvas_group, tweenInfo, {}).Completed, function()
                            canvas_group.Visible = false
                            if cfgs.ToggleButton ~= "" then
                                togglebtn.Visible = true
                            end
                            connection:Disconnect()
                        end)
                    else
                        if cfgs.ToggleButton ~= "" then
                            togglebtn.Visible = false
                        end
                    end
                end

                if cfgs.ToggleButton == "" then
                    togglebtn:Destroy()
                else
                    togglebtn.Visible = false
                    canvas_group.GroupTransparency = 1
                    canvas_group.Visible = false

                    MakeDraggable(togglebtn, togglebtn)
                    AddConnection(togglebtn.MouseButton1Click, ToggleVisibility)
                    AddConnection(UserInputService.InputBegan, function(value)
                        if value.KeyCode == cfgs.BindGui then
                            ToggleVisibility()
                        end
                    end)
                end

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
                            ImageColor3 = "titlecolor",
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
                            ImageColor3 = "titlecolor",
                        },
                        BorderSizePixel = 0,
                        ZIndex = 11,
                    }),
                })

                AddConnection(minimizebtn.MouseButton1Click, ToggleVisibility)
                AddConnection(closebtn.MouseButton1Click, function()
                    canvas_group:Destroy()
                    if cfgs.ToggleButton ~= "" then
                        togglebtn:Destroy()
                    end
                    Library.Window = nil
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

                local TabModule = require(Components.tab):Init(containerFolder)
                function Tabs:AddTab(title)
                    return TabModule:New(title, TabHolder, Library)
                end
                function Tabs:SelectTab(Tab)
                    Tab = Tab or 1
                    TabModule:SelectTab(Tab)
                end

                return Tabs
            end
            return Library

        end)()
    end,
    [3] = function()
        local wax, script, require = ImportGlobals(3)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local ButtonComponent = require(script.Parent.Parent.elements.buttons)

            local Create = Tools.Create

            local DialogModule = {}
            local ActiveDialog = nil

            function DialogModule:Create(config, parent)
                if ActiveDialog and ActiveDialog.Parent then
                    ActiveDialog:Destroy()
                end

                local blocker = Create("Frame", {
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 100,
                    Parent = parent,
                    Active = true,
                })

                local uipadding_3 = Instance.new("UIPadding")
                uipadding_3.PaddingBottom = UDim.new(0, 45)
                uipadding_3.PaddingTop = UDim.new(0, 45)
                uipadding_3.Parent = blocker

                local dialog = Create("CanvasGroup", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0, 400, 0, 0),
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                    },
                    Parent = blocker,
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "bordercolor" },
                        Thickness = 1,
                    }),
                })

                local uilist_layout = Instance.new("UIListLayout")
                uilist_layout.SortOrder = Enum.SortOrder.LayoutOrder
                uilist_layout.Parent = dialog

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

                local uipadding = Instance.new("UIPadding")
                uipadding.PaddingBottom = UDim.new(0, 8)
                uipadding.PaddingLeft = UDim.new(0, 12)
                uipadding.PaddingRight = UDim.new(0, 12)
                uipadding.PaddingTop = UDim.new(0, 8)
                uipadding.Parent = content

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

                for i, buttonConfig in ipairs(config.Buttons) do
                    local wrappedCallback = function()
                        buttonConfig.Callback()
                        blocker:Destroy()
                    end

                    local tempElementSelf = { Container = buttonContainer }
                    local button = setmetatable(tempElementSelf, ButtonComponent):New({
                        Title = buttonConfig.Title,
                        Variant = buttonConfig.Variant or (i == 1 and "Primary" or "Ghost"),
                        Callback = wrappedCallback,
                    })
                end

                ActiveDialog = blocker
                return dialog

            end)()
    end,
    [4] = function()
        local wax, script, require = ImportGlobals(4)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local Create = Tools.Create

            return function(title, desc, parent)
                local Element = {}
                Element.Frame = Create("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    Name = "Element",
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
                    Name = "Title",
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 0),
                        PaddingLeft = UDim.new(0, 0),
                        PaddingRight = UDim.new(0, 36),
                        PaddingTop = UDim.new(0, 2),
                        Archivable = true,
                    }),
                })

                local description = Create("TextLabel", {
                    Font = Enum.Font.Gotham,
                    RichText = true,
                    Name = "Description",
                    ThemeProps = {
                        TextColor3 = "elementdescription",
                        BackgroundColor3 = "maincolor",
                    },
                    TextSize = 14,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = desc,
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 23),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = true,
                    Parent = Element.Frame,
                }, {})

                function Element:SetTitle(Set)
                    name.Text = Set
                end

                function Element:SetDesc(Set)
                    if Set == nil or Set == "" then
                        description.Visible = false
                        description.Text = ""
                    else
                        description.Visible = true
                        description.Text = Set
                    end
                end

                Element:SetDesc(desc)
                Element:SetTitle(title)

                function Element:Destroy()
                    Element.Frame:Destroy()
                end

                return Element
            end

        end)()
    end,
    [5] = function()
        local wax, script, require = ImportGlobals(5)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local TweenService = game:GetService("TweenService")

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            local Notif = {}

            function Notif:Init(Gui)
                self.MainHolder = Create("Frame", {
                    AnchorPoint = Vector2.new(1, 1),
                    BackgroundTransparency = 1,
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
                        Archivable = true,
                    }),
                    Create("UIListLayout", {
                        HorizontalAlignment = Enum.HorizontalAlignment.Right,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
                        Padding = UDim.new(0, 8),
                    })
                })

            end

            function Notif:ShowNotification(titleText, descriptionText, duration)
                duration = duration or 5

                local main = Create("CanvasGroup", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    GroupTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Size = UDim2.new(0, 300, 0, 0),
                    Position = UDim2.new(1, -10, 0.5, -150),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Visible = true,
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                    },
                    Parent = self.MainHolder,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = {
                            Color = "bordercolor",
                        },
                        Thickness = 1,
                    }),
                })

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

                local topframe = Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Visible = true,
                    Parent = holderin,
                })

                local user = Create("ImageLabel", {
                    Image = "rbxassetid://10723415903",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 18, 0, 18),
                    Visible = true,
                    ThemeProps = {
                        ImageColor3 = "notificationiconcolor",
                    },
                    Parent = topframe,
                })

                local title = Create("TextLabel", {
                    Font = Enum.Font.GothamMedium,
                    LineHeight = 1.2,
                    RichText = true,
                    TextSize = 18,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    BackgroundTransparency = 1,
                    Text = titleText,
                    Visible = true,
                    ThemeProps = {
                        TextColor3 = "notificationtitlecolor",
                    },
                    Parent = topframe,
                }, {
                    Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 24),
                    }),
                })

                local description = Create("TextLabel", {
                    Font = Enum.Font.Gotham,
                    RichText = true,
                    TextSize = 16,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    LayoutOrder = 1,
                    BackgroundTransparency = 1,
                    Text = descriptionText,
                    Visible = true,
                    ThemeProps = {
                        TextColor3 = "notificationdescriptioncolor",
                    },
                    Parent = holderin,
                })

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

                local progressindicator = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 2),
                    Visible = true,
                    ThemeProps = {
                        BackgroundColor3 = "notificationprogresscolor",
                    },
                    Parent = progress,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    }),
                })

                local fadeInTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local fadePositionTween = TweenService:Create(main, fadeInTweenInfo, {
                    Position = UDim2.new(1, -10, 1, -10),
                    GroupTransparency = 0,
                })
                fadePositionTween:Play()

                local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
                local tween = TweenService:Create(progressindicator, tweenInfo, { Size = UDim2.new(0, 0, 0, 2) })
                tween:Play()

                local fadeOutTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                tween.Completed:Connect(function()
                    local fadeOutTween = TweenService:Create(main, fadeOutTweenInfo, {
                        GroupTransparency = 1,
                        Position = UDim2.new(1, -10, 1, 50)
                    })
                    fadeOutTween:Play()
                    fadeOutTween.Completed:Connect(function()
                        main:Destroy()
                    end)
                end)

            end

            return Notif

        end)()
    end,
    [6] = function()
        local wax, script, require = ImportGlobals(6)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            return function(cfgs, Parent)
                cfgs = cfgs or {}
                cfgs.Title = cfgs.Title or nil
                cfgs.Description = cfgs.Description or nil
                cfgs.Defualt = cfgs.Defualt or false
                cfgs.Locked = cfgs.Locked or false
                cfgs.TitleTextSize = cfgs.TitleTextSize or 14

                local Section = {}

                Section.SectionFrame = Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Name = "Section",
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
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = {
                            Color = "bordercolor"
                        },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 6),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

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
                    Active = not cfgs.Locked,
                    Selectable = not cfgs.Locked,
                    AutoButtonColor = not cfgs.Locked,
                }, {
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, {}),
                })

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
                    Rotation = 90,
                    Name = "chevron-down",
                    ZIndex = 99,
                    Parent = topbox,
                })

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
                }, {})

                if cfgs.Title ~= nil and cfgs.Title ~= "" then
                    name.Text = cfgs.Title
                    name.TextSize = cfgs.TitleTextSize
                    name.Visible = true
                end

                if cfgs.Description ~= nil and cfgs.Description ~= "" then
                    local description = Create("TextLabel", {
                        Font = Enum.Font.Gotham,
                        RichText = true,
                        ThemeProps = {
                            TextColor3 = "descriptioncolor",
                            BackgroundColor3 = "maincolor",
                        },
                        TextSize = 14,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Text = cfgs.Description,
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 23),
                        Size = UDim2.new(1, 0, 0, 16),
                        Visible = true,
                        Parent = topbox,
                    }, {})
                end


                Section.SectionContainer = Create("Frame", {
                    Name = "SectionContainer",
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
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 1),
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 1),
                        PaddingTop = UDim.new(0, 1),
                        Archivable = true,
                    }),
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 12),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local isExpanded = cfgs.Defualt
                if cfgs.Defualt == true then
                    chevronIcon.Rotation = 0
                    Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18)
                end

                local function toggleSection()
                    isExpanded = not isExpanded
                    local targetRotation = isExpanded and 0 or 90

                    game:GetService("TweenService"):Create(chevronIcon, TweenInfo.new(0.3), {
                        Rotation = targetRotation
                    }):Play()

                    local targetSize = isExpanded and UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18) or UDim2.new(1, 0, 0, 0)
                    game:GetService("TweenService"):Create(Section.SectionContainer, TweenInfo.new(0.3), {
                        Size = targetSize
                    }):Play()
                end

                if not cfgs.Locked then
                    AddConnection(topbox.MouseButton1Click, toggleSection)
                    AddConnection(chevronIcon.MouseButton1Click, toggleSection)
                end

                AddConnection(Section.SectionContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    if isExpanded then
                        Section.SectionContainer.Size = UDim2.new(1, 0, 0, Section.SectionContainer.UIListLayout.AbsoluteContentSize.Y + 18)
                    end
                end)

                return Section
            end
        end)()
    end,
    [7] = function()
        local wax, script, require = ImportGlobals(7)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local TweenService = game:GetService("TweenService")
            local RunService = game:GetService("RunService")

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection
            local AddScrollAnim = Tools.AddScrollAnim
            local CurrentThemeProps = Tools.GetPropsCurrentTheme()

            local TabModule = {
                Window = nil,
                Tabs = {},
                Containers = {},
                SelectedTab = 0,
                TabCount = 0,
                Library = nil,
            }

            function TabModule:Init(Window)
                TabModule.Window = Window
                return TabModule
            end

            function TabModule:New(Title, Parent, Library)
                local Window = TabModule.Window
                local Elements = Library.Elements

                TabModule.TabCount = TabModule.TabCount + 1
                local TabIndex = TabModule.TabCount

                local Tab = {
                    Selected = false,
                    Name = Title,
                    Type = "Tab",
                    Container = nil,
                    Library = Library,
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
                        Name = "Title",
                        Font = Enum.Font.Gotham,
                        ThemeProps = {
                            TextColor3 = "offTextBtn",
                            BackgroundColor3 = "maincolor",
                        },
                        TextSize = 14,
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
                        ThemeProps = {
                            BackgroundColor3 = "offBgLineBtn",
                        },
                        Position = UDim2.new(0, 4, 0, 0),
                        Size = UDim2.new(0, 2, 1, 0),
                        BorderSizePixel = 0,
                    }),
                })
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
                    Parent = Window,
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 12),
                        PaddingTop = UDim.new(0, 12),
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                    }),
                    Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 12),
                    }),
                })

                AddScrollAnim(Tab.Container)

                AddConnection(Tab.Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    Tab.Container.CanvasSize = UDim2.new(0, 0, 0, Tab.Container.UIListLayout.AbsoluteContentSize.Y + 28)
                end)

                Tab.ContainerFrame = Tab.Container

                AddConnection(Tab.TabBtn.MouseButton1Click, function()
                    TabModule:SelectTab(TabIndex)
                end)

                TabModule.Containers[TabIndex] = Tab.ContainerFrame
                TabModule.Tabs[TabIndex] = Tab

                function Tab:AddSection(cfgs)
                    cfgs = cfgs or {}
                    cfgs.Title = cfgs.Title or nil
                    cfgs.Description = cfgs.Description or nil
                    local Section = { Type = "Section" }

                    local SectionFrame = require(script.Parent.section)(cfgs, Tab.Container)
                    Section.Container = SectionFrame.SectionContainer

                    function Section:AddGroupButton()
                        local GroupButton = { Type = "Group" }
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

                        GroupButton.Container = GroupButton.GroupContainer

                        local tempSelf = {
                            Container = GroupButton.Container,
                            Type = GroupButton.Type,
                            ScrollFrame = self.ScrollFrame,
                            Library = Tab.Library,
                        }
                        setmetatable(GroupButton, Elements)
                        return GroupButton
                    end

                    local tempSelf = {
                        Container = Section.Container,
                        Type = Section.Type,
                        ScrollFrame = self.ScrollFrame,
                        Library = Tab.Library,
                    }
                    setmetatable(Section, Elements)
                    return Section
                end

                return Tab
            end

            function TabModule:SelectTab(Tab)
                TabModule.SelectedTab = Tab

                local currentThemeProps = Tools.GetPropsCurrentTheme()

                for _, v in next, TabModule.Tabs do
                    TweenService:Create(
                        v.TabBtn.Title,
                        TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { TextColor3 = currentThemeProps.offTextBtn }
                    ):Play()
                    TweenService:Create(
                        v.TabBtn.Line,
                        TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        { BackgroundColor3 = currentThemeProps.offBgLineBtn }
                    ):Play()
                    v.Selected = false
                end

                local selectedTab = TabModule.Tabs[Tab]
                if not selectedTab then
                    warn("Attempted to select a non-existent tab:", Tab)
                    return
                end

                TweenService:Create(
                    selectedTab.TabBtn.Title,
                    TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { TextColor3 = currentThemeProps.onTextBtn }
                ):Play()
                TweenService:Create(
                    selectedTab.TabBtn.Line,
                    TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    { BackgroundColor3 = currentThemeProps.onBgLineBtn }
                ):Play()

                task.spawn(function()
                    for _, Container in pairs(TabModule.Containers) do
                        Container.Visible = false
                    end

                    TabModule.Containers[Tab].Visible = true
                end)
            end

            return TabModule

        end)()
    end,
    [8] = function()
        local wax, script, require = ImportGlobals(8)
        local ImportGlobals
        return (function(...)
            local Elements = {}

            for _, Theme in next, script:GetChildren() do
                table.insert(Elements, require(Theme))
            end

            return Elements
        end)()
    end,
    [9] = function()
        local wax, script, require = ImportGlobals(9)
        local ImportGlobals
        return (function(...)
            local UserInputService = game:GetService("UserInputService")
            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            local BlacklistedKeys = {
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

            local Element = {}
            Element.__index = Element
            Element.__type = "Bind"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Bind - Missing Title")
                Config.Description = Config.Description or nil
                Config.Hold = Config.Hold or false
                Config.Callback = Config.Callback or function() end
                Config.ChangeCallback = Config.ChangeCallback or function() end
                Config.Default = Config.Default or "None"

                local Bind = { Value = nil, Binding = false, Type = "Bind" }
                local Holding = false

                local BindFrame = require(Components.element)(Config.Title, Config.Description, Container)

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
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Archivable = true,
                    }),
                })

                AddConnection(BindFrame.Frame.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if Bind.Binding then
                            return
                        end
                        Bind.Binding = true
                        value.Text = "..."
                    end
                end)

                function Bind:Set(Key)
                    Bind.Binding = false
                    Bind.Value = Key and (Key.Name or Key) or Bind.Value
                    value.Text = tostring(Bind.Value)
                    Config.ChangeCallback(Bind.Value)
                end

                AddConnection(UserInputService.InputBegan, function(Input)
                    if UserInputService:GetFocusedTextBox() then
                        return
                    end
                    local isMatchingBind = (Input.KeyCode.Name == tostring(Bind.Value)) or (Input.UserInputType.Name == tostring(Bind.Value))

                    if isMatchingBind and not Bind.Binding then
                        if Config.Hold then
                            Holding = true
                            Config.Callback(Holding)
                        else
                            Config.Callback()
                        end
                    elseif Bind.Binding then
                        local Key = Input.KeyCode
                        if Input.UserInputType ~= Enum.UserInputType.Keyboard then
                            Key = Input.UserInputType
                        end

                        if table.find(BlacklistedKeys, Key) then
                            Key = Bind.Value
                        end
                        Bind:Set(Key)
                    end
                end)

                AddConnection(UserInputService.InputEnded, function(Input)
                    local isMatchingBind = (Input.KeyCode.Name == tostring(Bind.Value)) or (Input.UserInputType.Name == tostring(Bind.Value))
                    if isMatchingBind then
                        if Config.Hold and Holding then
                            Holding = false
                            Config.Callback(Holding)
                        end
                    end
                end)

                Bind:Set(Config.Default)

                Library.Flags[Idx] = Bind
                return Bind
            end

            return Element

        end)()
    end,
    [10] = function()
        local wax, script, require = ImportGlobals(10)
        local ImportGlobals
        return (function(...)
            local TweenService = game:GetService("TweenService")
            local Tools = require(script.Parent.Parent.tools)

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            local ButtonStyles = {
                Primary = {
                    ThemeProps = {
                        TextColor3 = "primaryButtonTextColor",
                        BackgroundColor3 = "primarycolor",
                    },
                    BackgroundTransparency = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    HoverConfig = {
                        ThemeProps = { BackgroundColor3 = "primaryButtonHoverBgColor" },
                        BackgroundTransparency = 0.1,
                    },
                    FocusConfig = {
                        ThemeProps = { BackgroundColor3 = "primaryButtonFocusBgColor" },
                        BackgroundTransparency = 0.2,
                    },
                },
                Ghost = {
                    ThemeProps = {
                        TextColor3 = "ghostButtonTextColor",
                        BackgroundColor3 = "ghostButtonBgColor",
                    },
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    HoverConfig = {
                        ThemeProps = { BackgroundColor3 = "ghostButtonHoverBgColor" },
                        BackgroundTransparency = 0.98,
                    },
                    FocusConfig = {
                        ThemeProps = { BackgroundColor3 = "ghostButtonFocusBgColor" },
                        BackgroundTransparency = 0.94,
                    },
                },
                Outline = {
                    ThemeProps = {
                        TextColor3 = "outlineButtonTextColor",
                        BackgroundColor3 = "outlineButtonBgColor",
                    },
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 1,
                    UIStroke = {
                        ThemeProps = { Color = "outlineButtonStrokeColor" },
                        Thickness = 1,
                    },
                    HoverConfig = {
                        ThemeProps = { BackgroundColor3 = "outlineButtonHoverBgColor" },
                        BackgroundTransparency = 0.94,
                    },
                    FocusConfig = {
                        ThemeProps = { BackgroundColor3 = "outlineButtonFocusBgColor" },
                        BackgroundTransparency = 0.98,
                    },
                },
            }

            local function ApplyTweens(button, config, uiStroke)
                local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                if config.ThemeProps then
                    local currentThemeProps = Tools.GetPropsCurrentTheme()
                    for propName, themeKey in pairs(config.ThemeProps) do
                        if currentThemeProps[themeKey] then
                            button[propName] = currentThemeProps[themeKey]
                        end
                    end
                end

                local tweenGoals = {}
                for property, value in pairs(config) do
                    if property ~= "UIStroke" and property ~= "ThemeProps" then
                        tweenGoals[property] = value
                    end
                end

                if next(tweenGoals) then
                    local tween = TweenService:Create(button, tweenInfo, tweenGoals)
                    tween:Play()
                end


                if uiStroke and config.UIStroke then
                    if config.UIStroke.ThemeProps then
                        local currentThemeProps = Tools.GetPropsCurrentTheme()
                        for propName, themeKey in pairs(config.UIStroke.ThemeProps) do
                            if currentThemeProps[themeKey] then
                                uiStroke[propName] = currentThemeProps[themeKey]
                            end
                        end
                    end

                    local strokeTweenGoals = {}
                    for property, value in pairs(config.UIStroke) do
                        if property ~= "ThemeProps" then
                            strokeTweenGoals[property] = value
                        end
                    end
                    if next(strokeTweenGoals) then
                        local strokeTween = TweenService:Create(uiStroke, tweenInfo, strokeTweenGoals)
                        strokeTween:Play()
                    end
                end
            end

            local function CreateButton(style, text, parent)
                local config = ButtonStyles[style]
                assert(config, "Invalid button style: " .. style)

                local button = Create("TextButton", {
                    Font = Enum.Font.Gotham,
                    LineHeight = 1.25,
                    Text = text,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Visible = true,
                    Parent = parent,
                    ThemeProps = config.ThemeProps,
                    BackgroundTransparency = config.BackgroundTransparency,
                    BorderColor3 = config.BorderColor3,
                    BorderSizePixel = config.BorderSizePixel,
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 16),
                        PaddingRight = UDim.new(0, 16),
                        PaddingTop = UDim.new(0, 8),
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Archivable = true,
                    }),
                })

                local uiStroke
                if config.UIStroke then
                    uiStroke = Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = config.UIStroke.Thickness,
                        Archivable = true,
                        Parent = button,
                        ThemeProps = config.UIStroke.ThemeProps,
                    })
                end

                local initialState = {
                    BackgroundTransparency = config.BackgroundTransparency,
                    BorderColor3 = config.BorderColor3,
                    BorderSizePixel = config.BorderSizePixel,
                    ThemeProps = config.ThemeProps,
                    UIStroke = config.UIStroke and {
                        Thickness = config.UIStroke.Thickness,
                        ThemeProps = config.UIStroke.ThemeProps,
                    } or nil,
                }


                AddConnection(button.MouseEnter, function()
                    if config.HoverConfig then
                        ApplyTweens(button, config.HoverConfig, uiStroke)
                    end
                end)

                AddConnection(button.MouseLeave, function()
                    ApplyTweens(button, initialState, uiStroke)
                end)

                AddConnection(button.MouseButton1Down, function()
                    if config.FocusConfig then
                        ApplyTweens(button, config.FocusConfig, uiStroke)
                    end
                end)

                AddConnection(button.MouseButton1Up, function()
                    if button:IsMouseOver() and config.HoverConfig then
                        ApplyTweens(button, config.HoverConfig, uiStroke)
                    else
                        ApplyTweens(button, initialState, uiStroke)
                    end
                end)

                return button
            end

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Button - Missing Title")
                Config.Variant = Config.Variant or "Primary"
                Config.Callback = Config.Callback or function() end
                local Button = {}

                Button.StyledButton = CreateButton(Config.Variant, Config.Title, Container)
                AddConnection(Button.StyledButton.MouseButton1Click, Config.Callback)

                return Button
            end

            return Element

        end)()
    end,
    [11] = function()
        local wax, script, require = ImportGlobals(11)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components
            local TweenService = game:GetService("TweenService")
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local mouse = LocalPlayer:GetMouse()

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            local RainbowColorValue = 0
            local rainbowIncrement = 1 / 255
            local hueSelectionPosition = 0

            local rainbowUpdateConnection = nil

            local Element = {}
            Element.__index = Element
            Element.__type = "Colorpicker"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Colorpicker - Missing Title")
                Config.Description = Config.Description or nil
                assert(Config.Default, "AddColorPicker: Missing default value.")

                local Colorpicker = {
                    Value = Config.Default,
                    Transparency = Config.Transparency or 0,
                    Type = "Colorpicker",
                    Callback = Config.Callback or function(Color) end,
                    RainbowMode = false,
                    ColorpickerToggle = false,
                    Hue = 0,
                    Sat = 0,
                    Vib = 0,
                }

                function Colorpicker:SetHSVFromRGB(Color)
                    local H, S, V = Color3.toHSV(Color)
                    Colorpicker.Hue = H
                    Colorpicker.Sat = S
                    Colorpicker.Vib = V
                end
                Colorpicker:SetHSVFromRGB(Colorpicker.Value)

                local ColorpickerFrame = require(Components.element)(Config.Title, Config.Description, Container)

                local InputFrame = Create("CanvasGroup", {
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Visible = true,
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                    },
                    Parent = ColorpickerFrame.Frame,
                }, {
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "bordercolor" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Archivable = true,
                    }),
                })

                local colorBox = Create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Colorpicker.Value,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.new(0, 30, 1, 0),
                    Visible = true,
                    Parent = InputFrame,
                }, {
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "bordercolor" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                })

                local inputHex = Create("TextBox", {
                    Font = Enum.Font.GothamMedium,
                    LineHeight = 1.2000000476837158,
                    PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
                    Text = "#" .. Colorpicker.Value:ToHex(),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Visible = true,
                    ThemeProps = {
                        TextColor3 = "titlecolor",
                        PlaceholderColor3 = "descriptioncolor",
                    },
                    Parent = InputFrame,
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 0),
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                        PaddingTop = UDim.new(0, 0),
                        Archivable = true,
                    }),
                })

                AddConnection(inputHex.FocusLost, function(Enter)
                    if Enter then
                        local Success, Result = pcall(Color3.fromHex, inputHex.Text)
                        if Success and typeof(Result) == "Color3" then
                            Colorpicker:SetHSVFromRGB(Result)
                            UpdateColorPicker()
                        else
                            inputHex.Text = "#" .. Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib):ToHex()
                        end
                    end
                end)

                local colorpicker_frame = Create("TextButton", {
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 20,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 46),
                    Size = UDim2.new(1, 0, 0, 166),
                    Visible = false,
                    ThemeProps = {
                        BackgroundColor3 = "containeritemsbg",
                    },
                    Parent = ColorpickerFrame.Frame,
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                        PaddingTop = UDim.new(0, 6),
                        Archivable = true,
                    }),
                })

                local color = Create("ImageLabel", {
                    Image = "rbxassetid://4155801252",
                    BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1),
                    Size = UDim2.new(1, -10, 0, 127),
                    Visible = true,
                    ZIndex = 10,
                    Parent = colorpicker_frame,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 8),
                        Archivable = true,
                    }),
                })

                local color_selection = Create("Frame", {
                    BackgroundColor3 = Colorpicker.Value,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 12, 0, 12),
                    Visible = true,
                    Parent = color,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                        Color = Color3.fromRGB(255, 255, 255),
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1.2000000476837158,
                        Archivable = true,
                    }),
                })

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
                        Archivable = true,
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
                        Archivable = true,
                    }),
                })

                local hue_selection = Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, Colorpicker.Hue, 0),
                    Size = UDim2.new(0, 8, 0, 8),
                    Visible = true,
                    Parent = hue,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                        Color = Color3.fromRGB(255, 255, 255),
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1.2000000476837158,
                        Archivable = true,
                    }),
                })

                local rainbowtoggle = Create("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    AnchorPoint = Vector2.new(0, 1),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, 16),
                    Visible = true,
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                    },
                    Parent = colorpicker_frame,
                })

                local togglebox = Create("Frame", {
                    BackgroundTransparency = (Colorpicker.RainbowMode and 0 or 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 16, 0, 16),
                    Visible = true,
                    ThemeProps = {
                        BackgroundColor3 = "togglebg",
                        BorderColor3 = "toggleborder",
                    },
                    Parent = rainbowtoggle,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 5),
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = {
                            Color = "toggleborder",
                        },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),

                    Create("ImageLabel", {
                        Image = "http://www.roblox.com/asset/?id=6031094667",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        Visible = true,
                        ThemeProps = {
                            ImageColor3 = "maincolor",
                        },
                    }),
                    Create("TextLabel", {
                        Font = Enum.Font.Gotham,
                        Text = "Rainbow",
                        TextColor3 = Color3.fromRGB(234, 234, 234),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 26, 0, 0),
                        Size = UDim2.new(1, 0, 0, 16),
                        Visible = true,
                        ThemeProps = {
                            TextColor3 = "titlecolor",
                        },
                    }),
                })

                local function UpdateColorPicker()
                    if not (Colorpicker.Hue ~= nil and Colorpicker.Sat ~= nil and Colorpicker.Vib ~= nil) then
                        warn("Missing HSV values in UpdateColorPicker")
                        return
                    end

                    local newColor = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
                    colorBox.BackgroundColor3 = newColor
                    color.BackgroundColor3 = Color3.fromHSV(Colorpicker.Hue, 1, 1)
                    color_selection.BackgroundColor3 = newColor
                    color_selection.Position = UDim2.new(Colorpicker.Sat, 0, 1 - Colorpicker.Vib, 0)

                    if inputHex then
                        inputHex.Text = "#" .. newColor:ToHex()
                    end

                    pcall(Colorpicker.Callback, newColor)
                end

                local function UpdateColorPickerPosition()
                    local ColorX = math.clamp(mouse.X - color.AbsolutePosition.X, 0, color.AbsoluteSize.X)
                    local ColorY = math.clamp(mouse.Y - color.AbsolutePosition.Y, 0, color.AbsoluteSize.Y)
                    Colorpicker.Sat = ColorX / color.AbsoluteSize.X
                    Colorpicker.Vib = 1 - (ColorY / color.AbsoluteSize.Y)
                    UpdateColorPicker()
                end

                local function UpdateHuePickerPosition()
                    local HueY = math.clamp(mouse.Y - hue.AbsolutePosition.Y, 0, hue.AbsoluteSize.Y)
                    hue_selection.Position = UDim2.new(0.5, 0, HueY / hue.AbsoluteSize.Y, 0)
                    Colorpicker.Hue = HueY / hue.AbsoluteSize.Y
                    UpdateColorPicker()
                end

                local ColorInput, HueInput = nil, nil

                AddConnection(color.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if Colorpicker.RainbowMode then
                            return
                        end
                        if ColorInput then
                            ColorInput:Disconnect()
                        end
                        ColorInput = AddConnection(mouse.Move, UpdateColorPickerPosition)
                        UpdateColorPickerPosition()
                    end
                end)

                AddConnection(color.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if ColorInput then
                            ColorInput:Disconnect()
                            ColorInput = nil
                        end
                    end
                end)

                AddConnection(hue.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if Colorpicker.RainbowMode then
                            return
                        end
                        if HueInput then
                            HueInput:Disconnect()
                        end
                        HueInput = AddConnection(mouse.Move, UpdateHuePickerPosition)
                        UpdateHuePickerPosition()
                    end
                end)

                AddConnection(hue.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if HueInput then
                            HueInput:Disconnect()
                            HueInput = nil
                        end
                    end
                end)

                AddConnection(ColorpickerFrame.Frame.MouseButton1Click, function()
                    Colorpicker.ColorpickerToggle = not Colorpicker.ColorpickerToggle
                    colorpicker_frame.Visible = Colorpicker.ColorpickerToggle
                end)

                local function startRainbowMode()
                    rainbowUpdateConnection = AddConnection(game:GetService("RunService").RenderStepped, function()
                        RainbowColorValue = (RainbowColorValue + rainbowIncrement) % 1
                        Colorpicker.Hue = RainbowColorValue
                        Colorpicker.Sat = 1
                        Colorpicker.Vib = 1
                        hue_selection.Position = UDim2.new(0.5, 0, RainbowColorValue, 0)
                        UpdateColorPicker()
                    end)
                end

                local function stopRainbowMode()
                    if rainbowUpdateConnection then
                        rainbowUpdateConnection:Disconnect()
                        rainbowUpdateConnection = nil
                    end
                end

                AddConnection(rainbowtoggle.MouseButton1Click, function()
                    Colorpicker.RainbowMode = not Colorpicker.RainbowMode
                    TweenService:Create(
                        togglebox,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = (Colorpicker.RainbowMode and 0 or 1) }
                    ):Play()

                    if Colorpicker.RainbowMode then
                        startRainbowMode()
                    else
                        stopRainbowMode()
                        Colorpicker:SetHSVFromRGB(Colorpicker.Value)
                        UpdateColorPicker()
                    end
                end)

                function Colorpicker:Set(newColor)
                    if typeof(newColor) ~= "Color3" then
                        warn("Invalid color value provided to Set:", newColor)
                        return
                    end

                    self.Value = newColor
                    self:SetHSVFromRGB(newColor)

                    if color_selection and colorBox and hue_selection then
                        hue_selection.Position = UDim2.new(0.5, 0, self.Hue, 0)
                        color_selection.Position = UDim2.new(self.Sat, 0, 1 - self.Vib, 0)
                        UpdateColorPicker()
                    end
                end

                UpdateColorPicker()

                Library.Flags[Idx] = Colorpicker
                return Colorpicker
            end

            return Element

        end)()
    end,
    [12] = function()
        local wax, script, require = ImportGlobals(12)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components
            local TweenService = game:GetService("TweenService")
            local UserInputService = game:GetService("UserInputService")

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection
            local CurrentThemeProps = Tools.GetPropsCurrentTheme()

            local Element = {}
            Element.__index = Element
            Element.__type = "Dropdown"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Dropdown - Missing Title")
                Config.Description = Config.Description or nil

                Config.Options = Config.Options or {}
                Config.Default = Config.Default or ""
                Config.IgnoreFirst = Config.IgnoreFirst or false
                Config.Multiple = Config.Multiple or false
                Config.MaxOptions = Config.MaxOptions or math.huge
                Config.PlaceHolder = Config.PlaceHolder or ""
                Config.Callback = Config.Callback or function() end

                local Dropdown = {
                    Value = Config.Default,
                    Options = Config.Options,
                    Buttons = {},
                    Toggled = false,
                    Type = "Dropdown",
                    Multiple = Config.Multiple,
                    Callback = Config.Callback,
                }
                local MaxElements = 5

                local DropdownFrame = require(Components.element)(Config.Title, Config.Description, Container)

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
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Archivable = true,
                    }),
                    Create("UIListLayout", {
                        Wraps = true,
                        FillDirection = Enum.FillDirection.Horizontal,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4),
                    }, {}),
                })

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
                        Archivable = true,
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

                local search = Create("TextBox", {
                    CursorPosition = -1,
                    Font = Enum.Font.Gotham,
                    PlaceholderText = Config.PlaceHolder,
                    Text = "",
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ThemeProps = {
                        BackgroundColor3 = "maincolor",
                        TextColor3 = "titlecolor",
                        PlaceholderColor3 = "descriptioncolor",
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
                        Archivable = true,
                    }),
                    Create("UIFlexItem", {
                        FlexMode = Enum.UIFlexMode.Fill,
                    }),
                })

                local dropcont = Create("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ThemeProps = { BackgroundColor3 = "containeritemsbg" },
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    Parent = DropdownFrame.Frame,
                    ZIndex = DropdownFrame.Frame.ZIndex + 1,
                }, {
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "bordercolor" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 6),
                        Archivable = true,
                    }),
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10),
                        PaddingTop = UDim.new(0, 10),
                        Archivable = true,
                    }),
                    Create("UIListLayout", {
                        Padding = UDim.new(0, 4),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }),
                })

                local function toggleDropcontVisibility(isVisible)
                    Dropdown.Toggled = isVisible
                    dropcont.Visible = isVisible
                end

                AddConnection(search.Focused, function()
                    toggleDropcontVisibility(true)
                end)

                AddConnection(UserInputService.InputBegan, function(input)
                    if Dropdown.Toggled and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mousePosition = input.Position
                        local dropcontAbsolutePosition = dropcont.AbsolutePosition
                        local dropcontAbsoluteSize = dropcont.AbsoluteSize

                        local isMouseOverDropdown = (mousePosition.X >= dropcontAbsolutePosition.X and mousePosition.X <= dropcontAbsolutePosition.X + dropcontAbsoluteSize.X) and
                            (mousePosition.Y >= dropcontAbsolutePosition.Y and mousePosition.Y <= dropcontAbsolutePosition.Y + dropcontAbsoluteSize.Y)

                        local isMouseOverDropdownElement = (mousePosition.X >= DropdownElement.AbsolutePosition.X and mousePosition.X <= DropdownElement.AbsolutePosition.X + DropdownElement.AbsoluteSize.X) and
                            (mousePosition.Y >= DropdownElement.AbsolutePosition.Y and mousePosition.Y <= DropdownElement.AbsolutePosition.Y + DropdownElement.AbsoluteSize.Y)

                        if not isMouseOverDropdown and not isMouseOverDropdownElement then
                            toggleDropcontVisibility(false)
                        end
                    end
                end)


                function SearchOptions()
                    local searchText = string.lower(search.Text)
                    for _, v in ipairs(dropcont:GetChildren()) do
                        if v:IsA("TextButton") then
                            local textLabel = v:FindFirstChildOfClass("TextLabel")
                            if textLabel then
                                local buttonText = string.lower(textLabel.Text)
                                if string.find(buttonText, searchText, 1, true) then
                                    v.Visible = true
                                else
                                    v.Visible = false
                                end
                            end
                        end
                    end
                end

                AddConnection(search:GetPropertyChangedSignal("Text"), SearchOptions)

                local function AddOptions(Options)
                    for _, Option in ipairs(Options) do
                        local check = Create("ImageLabel", {
                            Image = "rbxassetid://15269180838",
                            ThemeProps = { ImageColor3 = "itemcheckmarkcolor", },
                            ImageRectOffset = Vector2.new(514, 257),
                            ImageRectSize = Vector2.new(256, 256),
                            AnchorPoint = Vector2.new(1, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(1, -9, 0.5, 0),
                            Size = UDim2.new(0, 14, 0, 14),
                            Visible = true,
                        })

                        local text_label_2 = Create("TextLabel", {
                            Font = Enum.Font.Gotham,
                            Text = Option,
                            LineHeight = 0,
                            ThemeProps = { TextColor3 = "itemTextOff" },
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            Visible = true,
                            Name = "TextLabel",
                        }, {
                            Create("UIPadding", {
                                PaddingBottom = UDim.new(0, 0),
                                PaddingLeft = UDim.new(0, 14),
                                PaddingRight = UDim.new(0, 0),
                                PaddingTop = UDim.new(0, 0),
                                Archivable = true,
                            }),
                        })

                        local dropbtn = Create("TextButton", {
                            Font = Enum.Font.SourceSans,
                            Text = "",
                            TextSize = 14,
                            ThemeProps = { BackgroundColor3 = "itembg" },
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, 0, 0, 30),
                            Visible = true,
                            Parent = dropcont,
                            Name = Option,
                        }, {
                            Create("UICorner", {
                                CornerRadius = UDim.new(0, 6),
                                Archivable = true,
                            }),
                            text_label_2,
                            check,
                        })

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
                                toggleDropcontVisibility(false)
                            end
                        end)

                        Dropdown.Buttons[Option] = dropbtn
                    end
                end

                function Dropdown:Refresh(Options, Delete)
                    if Delete then
                        for _, v in pairs(Dropdown.Buttons) do
                            v:Destroy()
                        end
                        Dropdown.Buttons = {}
                    end
                    Dropdown.Options = Options
                    AddOptions(Dropdown.Options)
                    Dropdown:Set(Dropdown.Value, true)
                end

                function Dropdown:Set(Value, ignore)
                    CurrentThemeProps = Tools.GetPropsCurrentTheme()

                    local function updateButtonAppearance(button, isSelected)
                        local transparency = isSelected and 0 or 1
                        local textColor = isSelected and CurrentThemeProps.itemTextOn or CurrentThemeProps.itemTextOff
                        local imageTransparency = isSelected and 0 or 1

                        TweenService:Create(
                            button,
                            TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { BackgroundTransparency = transparency }
                        ):Play()

                        local checkImage = button:FindFirstChildOfClass("ImageLabel")
                        if checkImage then
                            TweenService:Create(
                                checkImage,
                                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                { ImageTransparency = imageTransparency }
                            ):Play()
                        end

                        local textLabel = button:FindFirstChildOfClass("TextLabel")
                        if textLabel then
                            TweenService:Create(
                                textLabel,
                                TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                                { TextColor3 = textColor }
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

                    local function addValueText(text)
                        local tagBtn = Create("TextButton", {
                            Font = Enum.Font.SourceSans,
                            Text = "",
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
                                Archivable = true,
                            }),
                            Create("UIPadding", {
                                PaddingBottom = UDim.new(0, 0),
                                PaddingLeft = UDim.new(0, 10),
                                PaddingRight = UDim.new(0, 10),
                                PaddingTop = UDim.new(0, 0),
                                Archivable = true,
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
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Size = UDim2.new(0, 0, 1, 0),
                            }, {}),
                        })

                        local closebtn = Create("TextButton", {
                            Font = Enum.Font.SourceSans,
                            Text = "",
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            TextSize = 14,
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
                                BackgroundTransparency = 1,
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 0,
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                Size = UDim2.new(0, 16, 0, 16),
                                Visible = true,
                                ThemeProps = { ImageColor3 = "valuetext" },
                            }, {}),
                        })

                        local function removeTag()
                            if Config.Multiple then
                                local index = table.find(Dropdown.Value, text)
                                if index then
                                    table.remove(Dropdown.Value, index)
                                end
                            else
                                Dropdown.Value = ""
                            end
                            Dropdown:Set(Dropdown.Value)
                        end

                        AddConnection(tagBtn.MouseButton1Click, removeTag)
                        AddConnection(closebtn.MouseButton1Click, removeTag)
                    end

                    if Config.Multiple then
                        if type(Value) == "table" then
                            Dropdown.Value = Value
                        elseif Value ~= "" then
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
                        else
                            Dropdown.Value = {}
                        end
                    else
                        Dropdown.Value = Value
                    end

                    if Config.Multiple then
                        local newSelectedValues = {}
                        for _, val in ipairs(Dropdown.Value) do
                            if table.find(Dropdown.Options, val) then
                                table.insert(newSelectedValues, val)
                            end
                        end
                        Dropdown.Value = newSelectedValues
                    else
                        if Dropdown.Value ~= "" and not table.find(Dropdown.Options, Dropdown.Value) then
                            Dropdown.Value = ""
                        end
                    end

                    clearValueText()

                    local isSelectionEmpty = (Config.Multiple and #Dropdown.Value == 0) or (not Config.Multiple and Dropdown.Value == "")

                    if isSelectionEmpty then
                        for _, button in pairs(Dropdown.Buttons) do
                            updateButtonAppearance(button, false)
                        end
                        if not ignore then
                            Config.Callback(Config.Multiple and {} or "")
                        end
                        return
                    end

                    if Config.Multiple then
                        for _, val in ipairs(Dropdown.Value) do
                            addValueText(val)
                        end
                    else
                        addValueText(Dropdown.Value)
                    end

                    for optionText, button in pairs(Dropdown.Buttons) do
                        local isSelected = (Config.Multiple and table.find(Dropdown.Value, optionText))
                            or (not Config.Multiple and optionText == Dropdown.Value)
                        updateButtonAppearance(button, isSelected)
                    end

                    if not ignore then
                        Config.Callback(Dropdown.Value)
                    end
                end

                Dropdown:Refresh(Dropdown.Options, false)
                Dropdown:Set(Config.Default, Config.IgnoreFirst)

                Library.Flags[Idx] = Dropdown
                return Dropdown
            end

            return Element

        end)()
    end,
    [13] = function()
        local wax, script, require = ImportGlobals(13)
        local ImportGlobals
        return (function(...)
            local Components = script.Parent.Parent.components

            local Element = {}
            Element.__index = Element
            Element.__type = "Paragraph"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Paragraph - Missing Title")
                Config.Description = Config.Description or nil

                local paragraph = require(Components.element)(Config.Title, Config.Description, Container)

                return paragraph
            end

            return Element

        end)()
    end,
    [14] = function()
        local wax, script, require = ImportGlobals(14)
        local ImportGlobals
        return (function(...)
            local UserInputService = game:GetService("UserInputService")
            local TweenService = game:GetService("TweenService")

            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection
            local function Round(Number, Factor)
                local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
                if Result < 0 then
                    Result = Result + Factor
                end
                return Result
            end

            local Element = {}
            Element.__index = Element
            Element.__type = "Slider"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Slider - Missing Title")
                Config.Description = Config.Description or nil

                Config.Min = Config.Min or 0
                Config.Max = Config.Max or 100
                Config.Increment = Config.Increment or 1
                Config.Default = Config.Default or Config.Min
                Config.IgnoreFirst = Config.IgnoreFirst or false

                local Slider = {
                    Value = Config.Default,
                    Min = Config.Min,
                    Max = Config.Max,
                    Increment = Config.Increment,
                    IgnoreFirst = Config.IgnoreFirst,
                    Callback = Config.Callback or function(Value) end,
                    Type = "Slider",
                }

                local Dragging = false
                local DraggingDot = false

                local SliderFrame = require(Components.element)(Config.Title, Config.Description, Container)

                local ValueText = Create("TextLabel", {
                    Font = Enum.Font.Gotham,
                    RichText = true,
                    Text = "",
                    ThemeProps = {
                        TextColor3 = "titlecolor",
                    },
                    TextSize = 16,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.754537523, 8, 0, 0),
                    Size = UDim2.new(0, 90, 0, 16),
                    Visible = true,
                    Parent = SliderFrame.topbox,
                })

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
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "sliderbarstroke" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                })

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
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "sliderprogressborder" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                })

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
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                        Archivable = true,
                    }),
                })

                function Slider:Set(Value, ignore)
                    self.Value = math.clamp(Round(Value, Config.Increment), Config.Min, Config.Max)
                    ValueText.Text = string.format("%s<font transparency='0.5'>/%s </font>", tostring(self.Value), Config.Max)

                    local range = Config.Max - Config.Min
                    local newPosition = (range == 0) and 0 or (self.Value - Config.Min) / range

                    if DraggingDot then
                        SliderDot.Position = UDim2.new(newPosition, 0, 0.5, 0)
                        SliderProgress.Size = UDim2.fromScale(newPosition, 1)
                    else
                        TweenService:Create(SliderDot, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Position = UDim2.new(newPosition, 0, 0.5, 0)
                        }):Play()

                        TweenService:Create(SliderProgress, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Size = UDim2.fromScale(newPosition, 1)
                        }):Play()
                    end

                    if not ignore then
                        return Config.Callback(self.Value)
                    end
                end

                local function updateSliderFromInput(inputPosition)
                    if Dragging then
                        local barPosition = SliderBar.AbsolutePosition
                        local barSize = SliderBar.AbsoluteSize
                        local relativeX = (inputPosition.X - barPosition.X) / barSize.X
                        local clampedPosition = math.clamp(relativeX, 0, 1)
                        local newValue = Config.Min + (Config.Max - Config.Min) * clampedPosition
                        Slider:Set(newValue)
                    end
                end

                AddConnection(SliderBar.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        updateSliderFromInput(input.Position)
                    end
                end)

                AddConnection(SliderDot.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        DraggingDot = true
                        updateSliderFromInput(input.Position)
                    end
                end)

                AddConnection(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        DraggingDot = false
                    end
                end)

                AddConnection(UserInputService.InputChanged, function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSliderFromInput(input.Position)
                    end
                end)

                Slider:Set(Config.Default, Config.IgnoreFirst)

                Library.Flags[Idx] = Slider
                return Slider
            end

            return Element
        end)()
    end,
    [15] = function()
        local wax, script, require = ImportGlobals(15)
        local ImportGlobals
        return (function(...)
            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection
            local Element = {}
            Element.__index = Element
            Element.__type = "Textbox"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config, "Textbox - Missing Config table")
                assert(Config.Title, "Textbox - Missing Title")
                Config.Description = Config.Description or nil
                Config.PlaceHolder = Config.PlaceHolder or ""
                Config.Default = Config.Default or ""
                Config.TextDisappear = Config.TextDisappear or false
                Config.Callback = Config.Callback or function() end

                local Textbox = {
                    Value = Config.Default or "",
                    Callback = Config.Callback,
                    Type = "Textbox",
                }

                local TextboxFrame = require(Components.element)(Config.Title, Config.Description, Container)

                local textbox = Create("TextBox", {
                    CursorPosition = -1,
                    Font = Enum.Font.Gotham,
                    PlaceholderText = Config.PlaceHolder,
                    Text = Textbox.Value,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Visible = true,
                    ThemeProps = {
                        TextColor3 = "titlecolor",
                        PlaceholderColor3 = "descriptioncolor",
                        BackgroundColor3 = "maincolor",
                    },
                    Parent = TextboxFrame.Frame,
                }, {
                    Create("UIPadding", {
                        PaddingBottom = UDim.new(0, 0),
                        PaddingLeft = UDim.new(0, 12),
                        PaddingRight = UDim.new(0, 12),
                        PaddingTop = UDim.new(0, 0),
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = { Color = "bordercolor" },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Archivable = true,
                    }),
                })

                function Textbox:Set(value)
                    textbox.Text = value
                    Textbox.Value = value
                    Config.Callback(value)
                end

                AddConnection(textbox.FocusLost, function(enterPressed)
                    Textbox.Value = textbox.Text
                    Config.Callback(Textbox.Value)
                    if Config.TextDisappear then
                        textbox.Text = ""
                    end
                end)

                return Textbox
            end

            return Element

        end)()
    end,
    [16] = function()
        local wax, script, require = ImportGlobals(16)
        local ImportGlobals
        return (function(...)
            local TweenService = game:GetService("TweenService")
            local Tools = require(script.Parent.Parent.tools)
            local Components = script.Parent.Parent.components

            local Create = Tools.Create
            local AddConnection = Tools.AddConnection

            local Element = {}
            Element.__index = Element
            Element.__type = "Toggle"

            function Element:New(Idx, Config, Container, Type, ScrollFrame, Library)
                assert(Config.Title, "Toggle - Missing Title")
                Config.Description = Config.Description or nil
                Config.Default = Config.Default or false
                Config.IgnoreFirst = Config.IgnoreFirst or false

                local Toggle = {
                    Value = Config.Default,
                    Callback = Config.Callback or function(Value) end,
                    IgnoreFirst = Config.IgnoreFirst,
                    Type = "Toggle",
                    FirstUpdate = true,
                }

                local ToggleFrame = require(Components.element)(Config.Title, Config.Description, Container)

                local titleLabel = ToggleFrame.topbox:FindFirstChild("Title")
                if titleLabel then
                    local padding = titleLabel:FindFirstChildOfClass("UIPadding")
                    if padding then
                        padding.PaddingLeft = UDim.new(0, 24)
                    else
                        Create("UIPadding", {
                            PaddingLeft = UDim.new(0, 24),
                            Parent = titleLabel,
                        })
                    end
                end


                local box_frame = Create("Frame", {
                    ThemeProps = {
                        BackgroundColor3 = "togglebg",
                    },
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 16, 0, 16),
                    Visible = true,
                    Position = UDim2.new(0, 0, 0, 0),
                    Parent = ToggleFrame.topbox,
                }, {
                    Create("UICorner", {
                        CornerRadius = UDim.new(0, 5),
                        Archivable = true,
                    }),
                    Create("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                        ThemeProps = {
                            Color = "toggleborder",
                        },
                        Enabled = true,
                        LineJoinMode = Enum.LineJoinMode.Round,
                        Thickness = 1,
                        Archivable = true,
                    }),
                    Create("ImageLabel", {
                        Image = "http://www.roblox.com/asset/?id=6031094667",
                        ThemeProps = {
                            ImageColor3 = "togglecheckcolor"
                        },
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.new(0, 12, 0, 12),
                        Visible = true,
                    })
                })

                function Toggle:Set(Value, ignore)
                    self.Value = Value
                    TweenService:Create(box_frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundTransparency = self.Value and 0 or 1
                    }):Play()

                    local checkmark = box_frame:FindFirstChildOfClass("ImageLabel")
                    if checkmark then
                        TweenService:Create(checkmark, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            ImageTransparency = self.Value and 0 or 1
                        }):Play()
                    end


                    if not ignore and (not self.IgnoreFirst or not self.FirstUpdate) then
                        Library:Callback(Toggle.Callback, self.Value)
                    end
                    self.FirstUpdate = false
                end

                AddConnection(ToggleFrame.Frame.MouseButton1Click, function()
                    Toggle:Set(not Toggle.Value)
                end)

                Toggle:Set(Toggle.Value, Config.IgnoreFirst)

                Library.Flags[Idx] = Toggle
                return Toggle
            end

            return Element

        end)()
    end,
    [17] = function()
        local wax, script, require = ImportGlobals(17)
        local ImportGlobals
        return (function(...)
            local TweenService = game:GetService("TweenService")
            local UserInputService = game:GetService("UserInputService")
            local RunService = game:GetService("RunService")

            local tools = { Signals = {} }

            local themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/Just3itx/3itx-UI-LIB/refs/heads/main/themes"))()

            local currentTheme = themes.default
            local themedObjects = {}

            function tools.SetTheme(themeName)
                if themes[themeName] then
                    currentTheme = themes[themeName]
                    for _, item in pairs(themedObjects) do
                        local obj = item.object
                        local props = item.props
                        for propName, themeKey in next, props do
                            if currentTheme[themeKey] then
                                obj[propName] = currentTheme[themeKey]
                            end
                        end
                    end
                else
                    warn("Theme not found: " .. themeName)
                end
            end

            function tools.GetPropsCurrentTheme()
                return currentTheme
            end

            function tools.AddTheme(themeName, themeProps)
                themes[themeName] = themeProps
            end

            function tools.isMobile()
                return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
            end

            function tools.AddConnection(Signal, Function)
                local connection = Signal:Connect(Function)
                table.insert(tools.Signals, connection)
                return connection
            end

            function tools.DisconnectAll()
                for key = #tools.Signals, 1, -1 do
                    local Connection = table.remove(tools.Signals, key)
                    Connection:Disconnect()
                end
                themedObjects = {}
            end

            function tools.Create(Name, Properties, Children)
                local Object = Instance.new(Name)
                local themeProps = Properties.ThemeProps

                if themeProps then
                    for propName, themeKey in next, themeProps do
                        if currentTheme[themeKey] then
                            Object[propName] = currentTheme[themeKey]
                        end
                    end
                    table.insert(themedObjects, { object = Object, props = themeProps })
                    Properties.ThemeProps = nil
                end

                for i, v in next, Properties or {} do
                    Object[i] = v
                end
                for i, v in next, Children or {} do
                    v.Parent = Object
                end
                return Object
            end

            function tools.AddScrollAnim(scrollbar)
                local visibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 0 })
                local invisibleTween = TweenService:Create(scrollbar, TweenInfo.new(0.25), { ScrollBarImageTransparency = 1 })
                local lastInteraction = tick()
                local delayTime = 0.6

                local function showScrollbar()
                    visibleTween:Play()
                end

                local function hideScrollbar()
                    if tick() - lastInteraction >= delayTime then
                        invisibleTween:Play()
                    end
                end

                AddConnection(scrollbar.MouseEnter, function()
                    lastInteraction = tick()
                    showScrollbar()
                end)

                AddConnection(scrollbar.MouseLeave, function()
                    task.delay(delayTime, hideScrollbar)
                end)

                AddConnection(scrollbar.InputChanged, function(input)
                    if
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    then
                        lastInteraction = tick()
                        showScrollbar()
                    end
                end)

                AddConnection(scrollbar:GetPropertyChangedSignal("CanvasPosition"), function()
                    lastInteraction = tick()
                    showScrollbar()
                end)

                AddConnection(UserInputService.InputChanged, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseWheel then
                        lastInteraction = tick()
                        showScrollbar()
                    end
                end)

                AddConnection(RunService.RenderStepped, function()
                    if tick() - lastInteraction >= delayTime then
                        hideScrollbar()
                    end
                end)
            end

            return tools

        end)()
    end
}

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
    [14] = 2750,
    [15] = 2961,
    [16] = 3048,
    [17] = 3138
}

local WaxVersion = "0.4.1"
local EnvName = "WaxRuntime"

local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
    string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {}

local ScriptClosures = {}
local ScriptClosureRefIds = {}
local StoredModuleValues = {}
local ScriptsToRun = {}

local SharedEnvironment = {}

local RefChildren = {}

local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

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

    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

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
    local StringValue_Value

    local Children = setmetatable({}, {__mode = "k"})

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
        if index == "ClassName" then
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            return StringValue_Value
        else
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            if value == Ref then
                return
            end

            if parent ~= nil then
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            StringValue_Value = value
        else
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

local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3]
    local Children = object[4]

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent)
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

    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

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
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

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

    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

return LoadScript(RealObjectRoot:GetChildren()[1])
