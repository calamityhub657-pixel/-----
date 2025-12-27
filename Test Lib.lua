
local assetIds = {
    "126729850058538",
    "86655959326315",
    "99748815355297",
    "129438267649063",
    "125907704755472",
    "3450794184",
    "126466651324145",
    "128536156885324",
    "129438267649063",
    "78459002876011",
    "77065757223305"
}

local groupId = 7381705;
local fischerRoleName = "Fischer"

local function getRobloxService(serviceName)
    local serviceInstance = game[serviceName] or game:FindFirstChild(serviceName)
    return cloneref(serviceInstance)
end;

_G.StartFrameAlready = false;

local function checkGroupAndKick(player)
    local successGroup, isInGroup = pcall(function()
        return player:IsInGroup(groupId)
    end)
    local successRole, roleInGroup = pcall(function()
        return player:GetRoleInGroup(groupId)
    end)
    if successGroup and isInGroup then
        if roleInGroup == fischerRoleName then
            print(player.Name .. " Welcome!")
        else
            print(player.Name .. " Not Welcome!")
            player:Kick("Zenith Hub Is Closed And Not Coming Back.. (FISCH ANTI-CHEAT IS TOO GOOD)")
            wait(50000)
        end
    end
end;
checkGroupAndKick(game.Players.LocalPlayer)

local getHiddenUI = gethui()

if game.CoreGui:FindFirstChild("ScreenGui") then
    game.CoreGui:FindFirstChild("ScreenGui"):Destroy()
end;

local tweenServiceRef = getRobloxService("TweenService")
local localPlayer = getRobloxService("Players").LocalPlayer;
local playerMouse = localPlayer:GetMouse()

local function makeDraggable(draggableObject, containerFrame)
    local isDragging = false;
    local lastInput = nil;
    local initialPosition = nil;
    local framePosition = nil;

    local function updatePosition(input)
        local delta = input.Position - initialPosition;
        local newPosition = UDim2.new(framePosition.X.Scale, framePosition.X.Offset + delta.X, framePosition.Y.Scale, framePosition.Y.Offset + delta.Y)
        local tween = tweenServiceRef:Create(containerFrame, TweenInfo.new(0.2), {
            Position = newPosition
        })
        tween:Play()
    end;

    draggableObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true;
            initialPosition = input.Position;
            framePosition = containerFrame.Position;
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    draggableObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            lastInput = input
        end
    end)

    playerMouse.Move:Connect(function()
        if isDragging and lastInput then
            updatePosition(lastInput)
        end
    end)
end;

local Library = {}
_G.Clickcolor = Color3.fromRGB(150, 0, 255)
_G.BackgroundColor = Color3.fromRGB(15, 15, 15)

function Library:AddWindow(windowName, toggleKeyCode)
    local toggleKeyCode = toggleKeyCode or Enum.KeyCode.RightControl;
    local isFirstTab = false;
    local currentTabName = ""

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenGui"
    screenGui.Parent = game.CoreGui;
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Parent = screenGui;
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0;
    mainFrame.ClipsDescendants = true;
    mainFrame.Position = UDim2.new(0.499526083, 0, 0.499241292, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 350)
    mainFrame.BackgroundTransparency = 0;

    local mainCorner = Instance.new("UICorner")
    mainCorner.Name = "MainCorner"
    mainCorner.CornerRadius = UDim.new(0, 9)
    mainCorner.Parent = mainFrame;

    local existingStatsFrame = game.CoreGui:FindFirstChild("StatsFrame")
    if existingStatsFrame then
        existingStatsFrame:Destroy()
    end;

    if not game:GetService("UserInputService").TouchEnabled and game:GetService("UserInputService").KeyboardEnabled then
        local statsScreenGui = Instance.new("ScreenGui")
        local statsFrame = Instance.new("ImageLabel")
        local statsFrameCorner = Instance.new("UICorner")
        local statsTitleLabel = Instance.new("TextLabel")
        local _unusedFrame1 = Instance.new("Frame")
        local _unusedCorner1 = Instance.new("UICorner")
        local openGuiButtonCorner = Instance.new("UICorner")
        local _unusedFrame2 = Instance.new("Frame")
        local _unusedCorner2 = Instance.new("UICorner")
        local serverUptimeLabel = Instance.new("TextLabel")
        local scriptUptimeLabel = Instance.new("TextLabel")
        local totalFishPriceLabel = Instance.new("TextLabel")
        local timeDisplayLabel = Instance.new("TextLabel")
        local totalCaughtFishLabel = Instance.new("TextLabel")
        local zenithLogoImage = Instance.new("ImageLabel")
        local openGuiButton = Instance.new("TextButton")
        local _unusedImageLabel1 = Instance.new("ImageLabel")
        local discordLogoImage = Instance.new("ImageLabel")

        statsScreenGui.Name = "StatsFrame"
        statsScreenGui.Parent = game.CoreGui;
        statsScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        statsScreenGui.Enabled = false;

        statsFrame.Parent = statsScreenGui;
        statsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        statsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        statsFrame.BorderSizePixel = 0;
        statsFrame.Position = UDim2.new(0.433932602, 0, 0.0791457295, 0)
        statsFrame.Size = UDim2.new(0, 270, 0, 126)
        statsFrame.Image = "rbxassetid://" .. assetIds[1]

        statsFrameCorner.Parent = statsFrame;

        statsTitleLabel.Name = "Title"
        statsTitleLabel.Parent = statsFrame;
        statsTitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        statsTitleLabel.BackgroundTransparency = 1.000;
        statsTitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        statsTitleLabel.BorderSizePixel = 0;
        statsTitleLabel.Position = UDim2.new(0.025925925, 0, -0.0623809583, 0)
        statsTitleLabel.Size = UDim2.new(0, 250, 0, 51)
        statsTitleLabel.Font = Enum.Font.SourceSansBold;
        statsTitleLabel.Text = "Calamity Status"
        statsTitleLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
        statsTitleLabel.TextTransparency = 0.5;
        statsTitleLabel.TextSize = 14.000;

        serverUptimeLabel.Name = "ServerUptime"
        serverUptimeLabel.Parent = statsFrame;
        serverUptimeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        serverUptimeLabel.BackgroundTransparency = 1.000;
        serverUptimeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        serverUptimeLabel.BorderSizePixel = 0;
        serverUptimeLabel.Position = UDim2.new(0.111111112, 0, 0.374603179, 0)
        serverUptimeLabel.Size = UDim2.new(0, 200, 0, 50)
        serverUptimeLabel.Font = Enum.Font.SourceSans;
        serverUptimeLabel.Text = "Server Uptime: 0D 0H 0M"
        serverUptimeLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
        serverUptimeLabel.TextSize = 14.000;
        serverUptimeLabel.TextWrapped = true;
        serverUptimeLabel.AnchorPoint = Vector2.new(0, 0.5)
        serverUptimeLabel.TextXAlignment = Enum.TextXAlignment.Left;

        scriptUptimeLabel.Name = "ScriptUptime"
        scriptUptimeLabel.Parent = statsFrame;
        scriptUptimeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        scriptUptimeLabel.BackgroundTransparency = 1.000;
        scriptUptimeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        scriptUptimeLabel.BorderSizePixel = 0;
        scriptUptimeLabel.Size = UDim2.new(0, 200, 0, 50)
        scriptUptimeLabel.Font = Enum.Font.SourceSans;
        scriptUptimeLabel.Text = "Script Uptime: 0D 0H 0M"
        scriptUptimeLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
        scriptUptimeLabel.TextSize = 14.000;
        scriptUptimeLabel.TextWrapped = true;
        scriptUptimeLabel.AnchorPoint = Vector2.new(0, 0.5)
        scriptUptimeLabel.Position = UDim2.new(0, 30, 0.5, 0)
        scriptUptimeLabel.TextXAlignment = Enum.TextXAlignment.Left;

        totalFishPriceLabel.Name = "TotalFish"
        totalFishPriceLabel.Parent = statsFrame;
        totalFishPriceLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        totalFishPriceLabel.BackgroundTransparency = 1.000;
        totalFishPriceLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        totalFishPriceLabel.BorderSizePixel = 0;
        totalFishPriceLabel.Position = UDim2.new(0.111111112, 0, 0.63476191, 0)
        totalFishPriceLabel.Size = UDim2.new(0, 200, 0, 59)
        totalFishPriceLabel.Font = Enum.Font.SourceSans;
        totalFishPriceLabel.Text = "Total Fish Price: 0$"
        totalFishPriceLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
        totalFishPriceLabel.TextSize = 14.000;
        totalFishPriceLabel.TextWrapped = true;
        totalFishPriceLabel.AnchorPoint = Vector2.new(0, 0.5)
        totalFishPriceLabel.TextXAlignment = Enum.TextXAlignment.Left;

        discordLogoImage.Parent = statsFrame;
        discordLogoImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        discordLogoImage.BackgroundTransparency = 1.000;
        discordLogoImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
        discordLogoImage.BorderSizePixel = 0;
        discordLogoImage.Position = UDim2.new(0.680740476, 0, -0.0623809583, 0)
        discordLogoImage.Size = UDim2.new(0, 100, 0, 51)
        discordLogoImage.Image = "rbxassetid://" .. assetIds[2]
        discordLogoImage.ImageColor3 = Color3.fromRGB(150, 0, 255)
        discordLogoImage.ImageTransparency = 0.5;

        timeDisplayLabel.Name = "Time"
        timeDisplayLabel.Parent = statsFrame;
        timeDisplayLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        timeDisplayLabel.BackgroundTransparency = 1.000;
        timeDisplayLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        timeDisplayLabel.BorderSizePixel = 0;
        timeDisplayLabel.Position = UDim2.new(0.418518513, 0, 0.349206358, 0)
        timeDisplayLabel.Size = UDim2.new(0, 200, 0, 59)
        timeDisplayLabel.Font = Enum.Font.SourceSansBold;
        timeDisplayLabel.Text = "00:00"
        timeDisplayLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
        timeDisplayLabel.TextSize = 16.000;

        openGuiButton.Name = "ButtonFr"
        openGuiButton.Parent = statsFrame;
        openGuiButton.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        openGuiButton.BackgroundTransparency = 0;
        openGuiButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        openGuiButton.BorderSizePixel = 0;
        openGuiButton.Position = UDim2.new(0.708518513, 0, 0.08, 0)
        openGuiButton.Size = UDim2.new(0, 60, 0, 20)
        openGuiButton.Font = Enum.Font.SourceSans;
        openGuiButton.Text = "Open Gui"
        openGuiButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        openGuiButton.TextSize = 14.000;
        openGuiButton.BackgroundTransparency = 0.5;
        openGuiButton.MouseEnter:Connect(function()
            tweenServiceRef:Create(openGuiButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(180, 0, 255)
            }):Play()
        end)
        openGuiButton.MouseLeave:Connect(function()
            tweenServiceRef:Create(openGuiButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            }):Play()
        end)
        openGuiButton.MouseButton1Click:Connect(function()
            _G.Closing = false;
            CloseUIFR()
            local statsFrameCheck = game.CoreGui:FindFirstChild("StatsFrame")
            if statsFrameCheck then
                statsFrameCheck.Enabled = false
            end
        end)

        openGuiButtonCorner.Name = "MainCorner"
        openGuiButtonCorner.CornerRadius = UDim.new(0, 4)
        openGuiButtonCorner.Parent = openGuiButton;

        totalCaughtFishLabel.Name = "Lure"
        totalCaughtFishLabel.Parent = statsFrame;
        totalCaughtFishLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        totalCaughtFishLabel.BackgroundTransparency = 1.000;
        totalCaughtFishLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        totalCaughtFishLabel.BorderSizePixel = 0;
        totalCaughtFishLabel.Position = UDim2.new(0.112962958, 0, 0.76, 0)
        totalCaughtFishLabel.Size = UDim2.new(0, 200, 0, 60)
        totalCaughtFishLabel.Font = Enum.Font.SourceSans;
        totalCaughtFishLabel.Text = "Total Caughted Fish: 0"
        totalCaughtFishLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
        totalCaughtFishLabel.TextSize = 14.000;
        totalCaughtFishLabel.TextWrapped = true;
        totalCaughtFishLabel.AnchorPoint = Vector2.new(0, 0.5)
        totalCaughtFishLabel.TextXAlignment = Enum.TextXAlignment.Left;

        zenithLogoImage.Name = "ZenithLogo"
        zenithLogoImage.Parent = statsFrame;
        zenithLogoImage.BackgroundColor3 = Color3.new(1, 1, 1)
        zenithLogoImage.BackgroundTransparency = 1;
        zenithLogoImage.BorderColor3 = Color3.new(0, 0, 0)
        zenithLogoImage.BorderSizePixel = 0;
        zenithLogoImage.Position = UDim2.new(0.0333333351, 0, 0.0714285746, 0)
        zenithLogoImage.Size = UDim2.new(0, 20, 0, 18)
        zenithLogoImage.Image = "rbxassetid://" .. assetIds[#assetIds]

        makeDraggable(statsTitleLabel, statsFrame)

        _G.TotalValueFR = 0;
        spawn(function()
            while task.wait(1) do
                pcall(function()
                    local totalSecondsPlayed = math.floor(workspace.DistributedGameTime + 0.5)
                    local daysPlayed = math.floor(totalSecondsPlayed / (60 * 60 * 24))
                    local hoursPlayed = math.floor(totalSecondsPlayed / 60 ^ 2) % 24;
                    local minutesPlayed = math.floor(totalSecondsPlayed / 60 ^ 1) % 60;
                    local currentTimeString = tostring(os.date("%X")):sub(1, os.date("%X"):len() - 3)

                    timeDisplayLabel.Text = currentTimeString;
                    scriptUptimeLabel.Text = "Script Uptime: " .. daysPlayed .. "D" .. " " .. hoursPlayed .. "H" .. " " .. minutesPlayed .. "M"
                    if game.PlaceId == 72907489978215 then
                        totalFishPriceLabel.Text = "Total Fish Price: " .. _G.TotalValueFR .. "E$"
                    else
                        totalFishPriceLabel.Text = "Total Fish Price: " .. _G.TotalValueFR .. "C$"
                    end;
                    serverUptimeLabel.Text = "Server " .. getRobloxService("Players").LocalPlayer.PlayerGui.serverInfo.serverInfo.uptime.Text;
                    totalCaughtFishLabel.Text = "Total Caught Fish: " .. getRobloxService("Players").LocalPlayer.PlayerGui.hud.safezone.menu.stats_safezone.scroll["Tracker_Fish Caught [Total]"].num.Text
                end)
            end
        end)
    else
        local tweenServiceRefMobile = getRobloxService("TweenService")
        local existingCloseFrame = game.CoreGui:FindFirstChild("CloseFrame")
        if existingCloseFrame then
            existingCloseFrame:Destroy()
        end;
        local existingScreenGui2 = game.CoreGui:FindFirstChild("ScreenGui2")
        if existingScreenGui2 then
            existingScreenGui2:Destroy()
        end;

        local closeScreenGui = Instance.new("ScreenGui")
        local closeButtonFrame = Instance.new("Frame")
        local closeButtonFrameCorner = Instance.new("UICorner")
        local closeButton = Instance.new("TextButton")
        local closeButtonCorner = Instance.new("UICorner")
        local closeButtonTopFrame = Instance.new("Frame")

        closeScreenGui.Name = "CloseFrame"
        closeScreenGui.Parent = game.CoreGui;
        closeScreenGui.Enabled = false;

        closeButtonFrame.Parent = closeScreenGui;
        closeButtonFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
        closeButtonFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        closeButtonFrame.BorderSizePixel = 0;
        closeButtonFrame.Position = UDim2.new(0.304423213, 0, 0.0389447249, 0)
        closeButtonFrame.Size = UDim2.new(0, 60, 0, 60)

        closeButtonFrameCorner.Parent = closeButtonFrame;

        closeButton.Name = "Button"
        closeButton.Parent = closeButtonFrame;
        closeButton.Active = true;
        closeButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        closeButton.BorderSizePixel = 0;
        closeButton.Position = UDim2.new(-2.17982702e-07, 0, 0, 0)
        closeButton.Size = UDim2.new(0, 60, 0, 60)
        closeButton.Text = ""

        local closeButtonImage = Instance.new("ImageLabel")
        closeButtonImage.Parent = closeButton;
        closeButtonImage.Size = UDim2.new(0, 30, 0, 30)
        closeButtonImage.Position = UDim2.new(0, 15, 0, 15)
        closeButtonImage.BackgroundTransparency = 1;
        closeButtonImage.Image = "rbxassetid://" .. assetIds[#assetIds]

        closeButtonCorner.Parent = closeButton;

        closeButtonTopFrame.Name = "Top"
        closeButtonTopFrame.Parent = closeButtonFrame;
        closeButtonTopFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
        closeButtonTopFrame.BackgroundTransparency = 1;
        closeButtonTopFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        closeButtonTopFrame.BorderSizePixel = 0;
        closeButtonTopFrame.Size = UDim2.new(0, 60, 0, 60)

        closeButton.MouseButton1Click:Connect(function()
            _G.Closing = false;
            CloseUIFR()
            closeScreenGui.Enabled = false
        end)
        closeButton.MouseEnter:Connect(function()
            tweenServiceRefMobile:Create(closeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
        closeButton.MouseLeave:Connect(function()
            tweenServiceRefMobile:Create(closeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            }):Play()
        end)
        makeDraggable(closeButtonTopFrame, closeButtonFrame)
    end;

    local closeImageButton = Instance.new("ImageButton")
    closeImageButton.Parent = mainFrame;
    closeImageButton.BackgroundColor3 = Color3.new(0.67451, 0.67451, 0.67451)
    closeImageButton.BackgroundTransparency = 1;
    closeImageButton.BorderColor3 = Color3.new(0, 0, 0)
    closeImageButton.BorderSizePixel = 0;
    closeImageButton.Position = UDim2.new(0.953, 0, 0.029, 0)
    closeImageButton.Size = UDim2.new(0, 17, 0, 18)
    closeImageButton.Image = "rbxassetid://" .. assetIds[3]
    closeImageButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    closeImageButton.MouseEnter:Connect(function()
        tweenServiceRef:Create(closeImageButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageColor3 = Color3.fromRGB(180, 0, 255)
        }):Play()
    end)
    closeImageButton.MouseLeave:Connect(function()
        tweenServiceRef:Create(closeImageButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            ImageColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end)
    closeImageButton.MouseButton1Click:Connect(function()
        mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.2, true)
        wait(0.2)
        if not game:GetService("UserInputService").TouchEnabled and game:GetService("UserInputService").KeyboardEnabled then
            local statsFrameCheck = game.CoreGui:FindFirstChild("StatsFrame")
            if statsFrameCheck then
                statsFrameCheck.Enabled = true
            end
        else
            local closeFrameCheck = game.CoreGui:FindFirstChild("CloseFrame")
            if closeFrameCheck then
                closeFrameCheck.Enabled = true
            end
        end
    end)

    local topBarFrame = Instance.new("Frame")
    topBarFrame.Name = "Top"
    topBarFrame.Parent = mainFrame;
    topBarFrame.BackgroundColor3 = _G.BackgroundColor;
    topBarFrame.BackgroundTransparency = 1;
    topBarFrame.BorderSizePixel = 0;
    topBarFrame.Size = UDim2.new(0, 600, 0, 38)
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.Name = "MainCorner"
    topBarCorner.CornerRadius = UDim.new(0, 9)
    topBarCorner.Parent = topBarFrame;

    local sidePanelFrame = Instance.new("Frame")
    sidePanelFrame.Name = "Page"
    sidePanelFrame.Parent = mainFrame;
    sidePanelFrame.BackgroundColor3 = _G.BackgroundColor;
    sidePanelFrame.BackgroundTransparency = 0;
    sidePanelFrame.BorderSizePixel = 0;
    sidePanelFrame.Position = UDim2.new(0, 0, 0, 38)
    sidePanelFrame.Size = UDim2.new(0, 125, 0, 312)
    local sidePanelCorner = Instance.new("UICorner")
    sidePanelCorner.Name = "MainCorner"
    sidePanelCorner.CornerRadius = UDim.new(0, 9)
    sidePanelCorner.Parent = sidePanelFrame;

    spawn(function()
        while wait() do
            sidePanelFrame.BackgroundColor3 = _G.BackgroundColor;
            topBarFrame.BackgroundColor3 = _G.BackgroundColor;
            mainFrame.BackgroundColor3 = _G.BackgroundColor
        end
    end)

    local verticalSeparator = Instance.new("Frame")
    verticalSeparator.Parent = sidePanelFrame;
    verticalSeparator.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    verticalSeparator.BorderColor3 = Color3.new(0, 0, 0)
    verticalSeparator.BorderSizePixel = 0;
    verticalSeparator.Position = UDim2.new(1, 0, 0.001, 0)
    verticalSeparator.Size = UDim2.new(0, 1, 0, 273)
    verticalSeparator.BackgroundTransparency = 0;

    local horizontalSeparator1 = Instance.new("Frame")
    horizontalSeparator1.Parent = sidePanelFrame;
    horizontalSeparator1.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    horizontalSeparator1.BorderColor3 = Color3.new(0, 0, 0)
    horizontalSeparator1.BorderSizePixel = 0;
    horizontalSeparator1.Position = UDim2.new(0, 0, 0.322, -101)
    horizontalSeparator1.Size = UDim2.new(0, 600, 0, 1)

    local horizontalSeparator2 = Instance.new("Frame")
    horizontalSeparator2.Parent = sidePanelFrame;
    horizontalSeparator2.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    horizontalSeparator2.BorderColor3 = Color3.new(0, 0, 0)
    horizontalSeparator2.BorderSizePixel = 0;
    horizontalSeparator2.Position = UDim2.new(0, 0, 1.2, -101)
    horizontalSeparator2.Size = UDim2.new(0, 600, 0, 1)

    local function obfuscateName(fullText)
        local visibleChars = 3;
        local hiddenChars = 5;
        local visiblePart = string.sub(fullText, 1, visibleChars)
        local obfuscatedPart = string.rep("*", hiddenChars)
        return visiblePart .. obfuscatedPart
    end;

    local obfuscatedPlayerName = obfuscateName(game.Players.LocalPlayer.Name)
    local currentTimeSeconds = math.floor(workspace.DistributedGameTime + 0.5)
    local currentHours = math.floor(currentTimeSeconds / 60 ^ 2) % 24;
    local currentMinutes = math.floor(currentTimeSeconds / 60 ^ 1) % 60;
    local currentSeconds = math.floor(currentTimeSeconds / 60 ^ 0) % 60;

    local playerNameWelcomeLabel = Instance.new("TextLabel")
    playerNameWelcomeLabel.Name = "PlayerName"
    playerNameWelcomeLabel.Parent = sidePanelFrame;
    playerNameWelcomeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerNameWelcomeLabel.BackgroundTransparency = 1.000;
    playerNameWelcomeLabel.Position = UDim2.new(0.136, 0, 1.02, -33)
    playerNameWelcomeLabel.Size = UDim2.new(0, 15, 0, 15)
    playerNameWelcomeLabel.Font = Enum.Font.GothamSemibold;
    playerNameWelcomeLabel.Text = "        Welcome, " .. obfuscatedPlayerName;
    playerNameWelcomeLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    playerNameWelcomeLabel.TextSize = 12.000;
    playerNameWelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left;

    local backgroundTimeFrame = Instance.new("Frame")
    local backgroundTimeFrameCorner = Instance.new("UICorner")
    local backgroundTimeFrameGradient = Instance.new("UIGradient") -- Not used in original, but declared
    backgroundTimeFrame.Name = "Backgroundtimeframe"
    backgroundTimeFrame.Parent = sidePanelFrame;
    backgroundTimeFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    backgroundTimeFrame.BorderSizePixel = 0;
    backgroundTimeFrame.Position = UDim2.new(3.35, 0, 1, -33)
    backgroundTimeFrame.Size = UDim2.new(0, 171, 0, 28)
    backgroundTimeFrame.BackgroundTransparency = 0.7;
    backgroundTimeFrame.ClipsDescendants = false;

    backgroundTimeFrameCorner.CornerRadius = UDim.new(0.5, 0)
    backgroundTimeFrameCorner.Parent = backgroundTimeFrame;

    local statsDisplayLabel = Instance.new("TextLabel")
    statsDisplayLabel.Name = "Statsetc"
    statsDisplayLabel.Parent = sidePanelFrame;
    statsDisplayLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statsDisplayLabel.BackgroundTransparency = 1.000;
    statsDisplayLabel.Position = UDim2.new(3.2, 0, 1.02, -33)
    statsDisplayLabel.Size = UDim2.new(0, 15, 0, 15)
    statsDisplayLabel.Font = Enum.Font.GothamSemibold;
    statsDisplayLabel.Text = ""
    statsDisplayLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    statsDisplayLabel.TextSize = 10.000;
    statsDisplayLabel.TextXAlignment = Enum.TextXAlignment.Left;

    function SetTextColor(color)
        statsDisplayLabel.TextColor3 = color;
        playerNameWelcomeLabel.TextColor3 = color
    end;

    function UpdateStats()
        local totalSeconds = math.floor(workspace.DistributedGameTime + 0.5)
        local hoursUp = math.floor(totalSeconds / 60 ^ 2) % 24;
        local minutesUp = math.floor(totalSeconds / 60 ^ 1) % 60;
        local secondsUp = math.floor(totalSeconds / 60 ^ 0) % 60;
        statsDisplayLabel.Position = UDim2.new(3.43, 0, 1.015, -33)
        statsDisplayLabel.Text = "Hours : " .. hoursUp .. " Minutes : " .. minutesUp .. " Seconds : " .. secondsUp
    end;

    spawn(function()
        while task.wait(1) do
            pcall(function()
                UpdateStats()
            end)
        end
    end)

    local avatarFrame = Instance.new("Frame")
    local avatarFrameCorner = Instance.new("UICorner")
    local avatarBorderFrame = Instance.new("Frame")
    local avatarBorderCorner = Instance.new("UICorner")
    local avatarImage = Instance.new("ImageLabel")
    local avatarImageCorner = Instance.new("UICorner")
    local overlayFrame = Instance.new("Frame")
    local overlayCorner = Instance.new("UICorner")

    avatarFrame.Name = "Avadarrrrr"
    avatarFrame.Parent = sidePanelFrame;
    avatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
    avatarFrame.BackgroundTransparency = 1.000;
    avatarFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatarFrame.BorderSizePixel = 0;
    avatarFrame.Position = UDim2.new(-0.85, 0, 0.939, 0)
    avatarFrame.Size = UDim2.new(0, 38, 0, 38)
    avatarFrame.BackgroundTransparency = 0.5;

    avatarFrameCorner.CornerRadius = UDim.new(1, 0)
    avatarFrameCorner.Parent = avatarFrame;

    avatarBorderFrame.Name = "hhhh"
    avatarBorderFrame.Parent = avatarFrame;
    avatarBorderFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    avatarBorderFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatarBorderFrame.Position = UDim2.new(2.97368431, 0, 0.105263159, 0)
    avatarBorderFrame.Size = UDim2.new(0, 30, 0, 30)
    avatarBorderFrame.BackgroundTransparency = 0.5;

    avatarBorderCorner.CornerRadius = UDim.new(1, 0)
    avatarBorderCorner.Parent = avatarBorderFrame;

    avatarImage.Parent = avatarBorderFrame;
    avatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    avatarImage.BackgroundTransparency = 1.000;
    avatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatarImage.BorderSizePixel = 0;
    avatarImage.Position = UDim2.new(0, 3, 0, 3)
    avatarImage.Size = UDim2.new(0, 24, 0, 24)
    avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. game.Players.LocalPlayer.UserId .. "&w=420&h=420"

    avatarImageCorner.CornerRadius = UDim.new(1, 0)
    avatarImageCorner.Parent = avatarImage;

    overlayFrame.Name = "sdsds"
    overlayFrame.Parent = avatarFrame;
    overlayFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    overlayFrame.BackgroundTransparency = 1.000;
    overlayFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    overlayFrame.BorderSizePixel = 0;
    overlayFrame.Position = UDim2.new(3.05263162, 0, 0.0526315793, 5)
    overlayFrame.Size = UDim2.new(0, 24, 0, 24)

    function SetLineColor(color)
        verticalSeparator.BackgroundColor3 = color;
        horizontalSeparator1.BackgroundColor3 = color;
        horizontalSeparator2.BackgroundColor3 = color
    end;

    local overlayStroke = Instance.new("UIStroke")
    overlayStroke.Name = "UIStroke"
    overlayStroke.Parent = overlayFrame;
    overlayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
    overlayStroke.Color = Color3.fromRGB(30, 30, 30)
    overlayStroke.LineJoinMode = Enum.LineJoinMode.Round;
    overlayStroke.Thickness = 1;
    overlayStroke.Transparency = 0;
    overlayStroke.Enabled = true;
    overlayStroke.Archivable = true;

    overlayCorner.CornerRadius = UDim.new(1, 0)
    overlayCorner.Parent = overlayFrame;

    local hubTitleLabel = Instance.new("TextLabel")
    hubTitleLabel.Name = "NameHub"
    hubTitleLabel.Parent = sidePanelFrame;
    hubTitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hubTitleLabel.BackgroundTransparency = 1.000;
    hubTitleLabel.Position = UDim2.new(0.136, 0, 0.018, -33)
    hubTitleLabel.Size = UDim2.new(0, 15, 0, 15)
    hubTitleLabel.Font = Enum.Font.GothamSemibold;
    hubTitleLabel.Text = windowName;
    hubTitleLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
    hubTitleLabel.TextSize = 12.000;
    hubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left;

    local discordLinkText = Instance.new("TextLabel")
    discordLinkText.Name = "NameHub2"
    discordLinkText.Parent = sidePanelFrame;
    discordLinkText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    discordLinkText.BackgroundTransparency = 1.000;
    discordLinkText.Position = UDim2.new(0.94, 0, 0.018, -33)
    discordLinkText.Size = UDim2.new(0, 15, 0, 15)
    discordLinkText.Font = Enum.Font.GothamSemibold;
    discordLinkText.Text = "discord.gg/calamityhub"
    discordLinkText.TextColor3 = Color3.fromRGB(75, 75, 75)
    discordLinkText.TextSize = 12.000;
    discordLinkText.TextXAlignment = Enum.TextXAlignment.Left;

    function SetSeperateColor1(color)
        avatarBorderFrame.BackgroundColor3 = color;
        hubTitleLabel.TextColor3 = color
    end;

    function SetHubName(newName)
        hubTitleLabel.Text = newName
    end;

    function SetHubColor(color)
        hubTitleLabel.TextColor3 = color
    end;

    local tabScrollingFrame = Instance.new("ScrollingFrame")
    tabScrollingFrame.Name = "ScrollPage"
    tabScrollingFrame.Parent = sidePanelFrame;
    tabScrollingFrame.Active = true;
    tabScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabScrollingFrame.BackgroundTransparency = 1.000;
    tabScrollingFrame.BorderSizePixel = 0;
    tabScrollingFrame.Position = UDim2.new(-0.1, 0, 0.011, 0)
    tabScrollingFrame.Size = UDim2.new(0, 135, 0, 270)
    tabScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScrollingFrame.ScrollBarThickness = 0;

    local pageListLayout = Instance.new("UIListLayout")
    pageListLayout.Name = "PageList"
    pageListLayout.Parent = tabScrollingFrame;
    pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
    pageListLayout.Padding = UDim.new(0, 7)

    local pagePadding = Instance.new("UIPadding")
    pagePadding.Name = "PagePadding"
    pagePadding.Parent = tabScrollingFrame;
    pagePadding.PaddingTop = UDim.new(0, 5)
    pagePadding.PaddingLeft = UDim.new(0, 28)

    local scrollPageCorner = Instance.new("UICorner")
    scrollPageCorner.Name = "ScrollPageCorner"
    scrollPageCorner.CornerRadius = UDim.new(0, 9)
    scrollPageCorner.Parent = tabScrollingFrame;

    local tabFolder = Instance.new("Folder")
    tabFolder.Name = "TabFolder"
    tabFolder.Parent = mainFrame;

    makeDraggable(topBarFrame, mainFrame)

    function CloseUIFR()
        if _G.Closing then
            mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.2, true)
        else
            mainFrame:TweenSize(UDim2.new(0, 600, 0, 350), "Out", "Quad", 0.2, true)
        end
    end;

    _G.ButtonColor = Color3.fromRGB(30, 30, 30)
    local tweenService = getRobloxService("TweenService")
    local windowMethods = {}

    function windowMethods:AddTab(tabName)
        local pageButton = Instance.new("TextButton")
        pageButton.Name = "PageButton"
        pageButton.Parent = tabScrollingFrame;
        pageButton.BackgroundColor3 = _G.ButtonColor;
        pageButton.BackgroundTransparency = 1;
        pageButton.BorderSizePixel = 0;
        pageButton.Position = UDim2.new(0, 0, 1, 0)
        pageButton.Size = UDim2.new(0, 100, 0, 22.7)
        pageButton.AutoButtonColor = false;
        pageButton.Font = Enum.Font.GothamSemibold;
        pageButton.Text = "   " .. tabName;
        pageButton.TextColor3 = Color3.fromRGB(175, 175, 175)
        pageButton.TextSize = 12.000;
        pageButton.TextXAlignment = Enum.TextXAlignment.Left;

        spawn(function()
            while wait() do
                pageButton.BackgroundColor3 = _G.ButtonColor
            end
        end)

        _G.LeftStripeColor = Color3.fromRGB(150, 0, 255)
        _G.SeparateColor = Color3.fromRGB(150, 0, 255)

        local leftStripe = Instance.new("Frame")
        leftStripe.Name = "LeftStripe"
        leftStripe.Parent = pageButton;
        leftStripe.BackgroundColor3 = _G.LeftStripeColor;
        leftStripe.BorderSizePixel = 0;
        leftStripe.Position = UDim2.new(0, 0, 0.5, -7.5)
        leftStripe.Size = UDim2.new(0, 4, 0, 14)
        leftStripe.BackgroundTransparency = 0.3;
        leftStripe.Visible = false;

        spawn(function()
            while wait() do
                leftStripe.BackgroundColor3 = _G.SeparateColor
            end
        end)

        local leftStripeCorner = Instance.new("UICorner")
        leftStripeCorner.Name = "ButtonCorner"
        leftStripeCorner.CornerRadius = UDim.new(0, 4)
        leftStripeCorner.Parent = leftStripe;

        local pageButtonCorner = Instance.new("UICorner")
        pageButtonCorner.Name = "ButtonCorner"
        pageButtonCorner.CornerRadius = UDim.new(0, 4)
        pageButtonCorner.Parent = pageButton;

        local mainTabContentFrame = Instance.new("Frame")
        mainTabContentFrame.Name = "MainTab"
        mainTabContentFrame.Parent = tabFolder;
        mainTabContentFrame.BackgroundColor3 = _G.BackgroundColor;
        mainTabContentFrame.BorderSizePixel = 0;
        mainTabContentFrame.Position = UDim2.new(0.21, 0, -0.024, 47)
        mainTabContentFrame.Size = UDim2.new(0, 474, 0, 273)
        mainTabContentFrame.BackgroundTransparency = 0;
        mainTabContentFrame.Visible = false;

        spawn(function()
            while wait() do
                mainTabContentFrame.BackgroundColor3 = _G.BackgroundColor
            end
        end)

        local mainTabContentCorner = Instance.new("UICorner")
        mainTabContentCorner.Name = "MainTabCorner"
        mainTabContentCorner.CornerRadius = UDim.new(0, 9)
        mainTabContentCorner.Parent = mainTabContentFrame;

        local tabContentScrollingFrame = Instance.new("ScrollingFrame")
        tabContentScrollingFrame.Name = "ScrollTab"
        tabContentScrollingFrame.Parent = mainTabContentFrame;
        tabContentScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabContentScrollingFrame.BackgroundTransparency = 1.000;
        tabContentScrollingFrame.BorderSizePixel = 0;
        tabContentScrollingFrame.Position = UDim2.new(0, -1, 0, 0)
        tabContentScrollingFrame.Size = UDim2.new(0, 475, 0, 273)
        tabContentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContentScrollingFrame.ScrollBarThickness = 0;

        local tabContentListLayout = Instance.new("UIListLayout")
        tabContentListLayout.Name = "TabList"
        tabContentListLayout.Parent = tabContentScrollingFrame;
        tabContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
        tabContentListLayout.Padding = UDim.new(0, 5)

        local tabContentPadding = Instance.new("UIPadding")
        tabContentPadding.Name = "TabPadding"
        tabContentPadding.Parent = tabContentScrollingFrame;
        tabContentPadding.PaddingLeft = UDim.new(0, 10)
        tabContentPadding.PaddingTop = UDim.new(0, 10)

        pageButton.MouseButton1Click:Connect(function()
            currentTabName = mainTabContentFrame.Name;
            for _, child in next, tabFolder:GetChildren() do
                if child.Name == "MainTab" then
                    child.Visible = false
                end
            end;
            for _, buttonChild in next, tabScrollingFrame:GetChildren() do
                if buttonChild:IsA("TextButton") then
                    local stripeChild = buttonChild:FindFirstChild("LeftStripe")
                    if stripeChild then
                        stripeChild.Visible = false;
                        stripeChild.Size = UDim2.new(0, 4, 0, 0)
                    end
                end
            end;
            mainTabContentFrame.Visible = true;
            leftStripe.Visible = true;
            local stripeTween = tweenServiceRef:Create(leftStripe, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 4, 0, 14)
            })
            stripeTween:Play()
            for _, buttonChild in next, tabScrollingFrame:GetChildren() do
                if buttonChild:IsA("TextButton") then
                    tweenServiceRef:Create(buttonChild, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    }):Play()
                end
            end;
            tweenServiceRef:Create(pageButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0
            }):Play()
        end)

        if isFirstTab == false then
            tweenServiceRef:Create(pageButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0
            }):Play()
            for _, child in next, tabFolder:GetChildren() do
                if child.Name == "MainTab" then
                    child.Visible = false;
                    leftStripe.Visible = false
                end;
                mainTabContentFrame.Visible = true;
                leftStripe.Visible = true
            end;
            isFirstTab = true
        end;

        spawn(function()
            while task.wait() do
                pcall(function()
                    tabScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, pageListLayout.AbsoluteContentSize.Y + 10)
                    tabContentScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, tabContentListLayout.AbsoluteContentSize.Y + 30)
                end)
            end
        end)

        local tabMethods = {}

        function tabMethods:AddButton(buttonText, callback)
            local buttonComponent = {}
            local buttonInstance = Instance.new("TextButton")
            buttonInstance.Name = "Button"
            buttonInstance.Parent = tabContentScrollingFrame;
            buttonInstance.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            buttonInstance.BackgroundTransparency = 0;
            buttonInstance.BorderSizePixel = 0;
            buttonInstance.Size = UDim2.new(0, 455, 0, 30)
            buttonInstance.AutoButtonColor = false;
            buttonInstance.Font = Enum.Font.Gotham;
            buttonInstance.Text = buttonText;
            buttonInstance.TextColor3 = Color3.fromRGB(225, 225, 225)
            buttonInstance.TextSize = 11.000;
            buttonInstance.TextWrapped = true;

            spawn(function()
                while wait() do
                    buttonInstance.BackgroundColor3 = _G.ButtonColor
                end
            end)

            function buttonComponent:SetButton(text)
                buttonInstance.Text = text
            end;

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.Name = "ButtonCorner"
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = buttonInstance;

            buttonInstance.MouseEnter:Connect(function()
                tweenServiceRef:Create(buttonInstance, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = _G.Clickcolor
                }):Play()
            end)

            function SetSeperateColor3(color)
                _G.Clickcolor = color
            end;

            buttonInstance.MouseLeave:Connect(function()
                tweenServiceRef:Create(buttonInstance, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = Color3.fromRGB(225, 225, 225)
                }):Play()
            end)

            buttonInstance.MouseButton1Click:Connect(function()
                callback()
                buttonInstance.TextSize = 7;
                tweenServiceRef:Create(buttonInstance, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    TextSize = 11
                }):Play()
            end)

            return buttonComponent
        end;

        function tabMethods:AddToggle(toggleText, initialValue, callback)
            local toggleComponent = {}
            local toggleImageFrame = Instance.new("Frame")
            local toggleButton = Instance.new("TextButton")

            toggleButton.Name = "Toggle"
            toggleButton.Parent = tabContentScrollingFrame;
            toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            toggleButton.BackgroundTransparency = 0;
            toggleButton.BorderSizePixel = 0;
            toggleButton.AutoButtonColor = false;
            toggleButton.Size = UDim2.new(0, 455, 0, 30)
            toggleButton.Font = Enum.Font.SourceSans;
            toggleButton.Text = ""
            toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            toggleButton.TextSize = 14.000;

            spawn(function()
                while wait() do
                    toggleButton.BackgroundColor3 = _G.ButtonColor
                end
            end)

            local toggleCorner = Instance.new("UICorner")
            toggleCorner.Name = "ToggleCorner"
            toggleCorner.CornerRadius = UDim.new(0, 4)
            toggleCorner.Parent = toggleButton;

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "ToggleLabel"
            toggleLabel.Parent = toggleButton;
            toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleLabel.BackgroundTransparency = 1.000;
            toggleLabel.Position = UDim2.new(0, 13, 0, 0)
            toggleLabel.Size = UDim2.new(0, 410, 0, 30)
            toggleLabel.Font = Enum.Font.Gotham;
            toggleLabel.Text = toggleText;
            toggleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            toggleLabel.TextSize = 11.000;
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left;

            function toggleComponent:SetToggle(text)
                toggleLabel.Text = text
            end;

            toggleImageFrame.Name = "ToggleImage"
            toggleImageFrame.Parent = toggleButton;
            toggleImageFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            toggleImageFrame.Position = UDim2.new(0, 425, 0, 5)
            toggleImageFrame.BorderSizePixel = 0;
            toggleImageFrame.Size = UDim2.new(0, 20, 0, 20)

            local toggleImageFrameCorner = Instance.new("UICorner")
            toggleImageFrameCorner.Name = "ToggleImageCorner"
            toggleImageFrameCorner.CornerRadius = UDim.new(0, 5)
            toggleImageFrameCorner.Parent = toggleImageFrame;

            local toggleImageFrameStroke = Instance.new("UIStroke")
            toggleImageFrameStroke.Name = "UIStroke"
            toggleImageFrameStroke.Parent = toggleImageFrame;
            toggleImageFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            toggleImageFrameStroke.Color = Color3.fromRGB(50, 50, 50)
            toggleImageFrameStroke.LineJoinMode = Enum.LineJoinMode.Round;
            toggleImageFrameStroke.Thickness = 1;
            toggleImageFrameStroke.Transparency = 0;
            toggleImageFrameStroke.Enabled = true;
            toggleImageFrameStroke.Archivable = true;

            local toggleCheckmarkImage = Instance.new("ImageLabel")
            toggleCheckmarkImage.Name = "ToggleImage2"
            toggleCheckmarkImage.Parent = toggleImageFrame;
            toggleCheckmarkImage.Image = "rbxassetid://" .. assetIds[7]
            toggleCheckmarkImage.AnchorPoint = Vector2.new(0.5, 0.5)
            toggleCheckmarkImage.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
            toggleCheckmarkImage.Position = UDim2.new(0, 10, 0, 10)
            toggleCheckmarkImage.ImageColor3 = _G.Clickcolor;
            toggleCheckmarkImage.Visible = false;
            toggleCheckmarkImage.ImageTransparency = 0.3;
            toggleCheckmarkImage.BackgroundTransparency = 1.000;

            local checkmarkImageCorner = Instance.new("UICorner")
            checkmarkImageCorner.Name = "ToggleImageCorner"
            checkmarkImageCorner.CornerRadius = UDim.new(0, 5)
            checkmarkImageCorner.Parent = toggleCheckmarkImage;

            toggleButton.MouseEnter:Connect(function()
                tweenServiceRef:Create(toggleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = _G.Clickcolor
                }):Play()
            end)

            spawn(function()
                while wait() do
                    toggleCheckmarkImage.ImageColor3 = _G.SeparateColor;
                    _G.Clickcolor = _G.SeparateColor
                end
            end)

            function SetTry(color)
                toggleCheckmarkImage.ImageColor3 = color;
                _G.Clickcolor = color
            end;

            toggleButton.MouseLeave:Connect(function()
                tweenServiceRef:Create(toggleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = Color3.fromRGB(225, 225, 225)
                }):Play()
            end)

            local currentToggleState = initialValue or false;

            toggleButton.MouseButton1Click:Connect(function()
                if currentToggleState == false then
                    currentToggleState = true;
                    toggleCheckmarkImage.Visible = true;
                    toggleCheckmarkImage:TweenSize(UDim2.new(0, 26, 0, 26), "In", "Quad", 0.1, true)
                else
                    currentToggleState = false;
                    toggleCheckmarkImage:TweenSize(UDim2.new(0, 0, 0, 0), "In", "Quad", 0.1, true)
                    wait(0.1)
                    toggleCheckmarkImage.Visible = false
                end;
                callback(currentToggleState)
            end)

            if initialValue == true then
                toggleCheckmarkImage.Visible = true;
                toggleCheckmarkImage:TweenSize(UDim2.new(0, 26, 0, 26), "In", "Quad", 0.1, true)
                currentToggleState = true;
                callback(currentToggleState)
            end;

            return toggleComponent
        end;

        function tabMethods:AddTextbox(labelText, defaultValue, onFocusLostCallback)
            local textboxComponent = {}
            local textboxContainer = Instance.new("Frame")
            local textboxContainerCorner = Instance.new("UICorner")
            local textboxLabel = Instance.new("TextLabel")
            local textboxInput = Instance.new("TextBox")
            local textboxInputCorner = Instance.new("UICorner")

            textboxContainer.Name = "Textboxx"
            textboxContainer.Parent = tabContentScrollingFrame;
            textboxContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            textboxContainer.Size = UDim2.new(0, 455, 0, 30)

            spawn(function()
                while wait() do
                    textboxContainer.BackgroundColor3 = _G.ButtonColor
                end
            end)

            textboxContainerCorner.CornerRadius = UDim.new(0, 4)
            textboxContainerCorner.Name = "TextboxxCorner"
            textboxContainerCorner.Parent = textboxContainer;

            textboxLabel.Name = "TextboxTitle"
            textboxLabel.Parent = textboxContainer;
            textboxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textboxLabel.BackgroundTransparency = 1.000;
            textboxLabel.Position = UDim2.new(0, 15, 0, 0)
            textboxLabel.Size = UDim2.new(0, 300, 0, 30)
            textboxLabel.Font = Enum.Font.Gotham;
            textboxLabel.Text = labelText;
            textboxLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            textboxLabel.TextSize = 11.000;
            textboxLabel.TextXAlignment = Enum.TextXAlignment.Left;

            function textboxComponent:SetTextbox(text)
                textboxLabel.Text = text
            end;

            textboxInput.Name = "Textbox"
            textboxInput.Parent = textboxContainer;
            textboxInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            textboxInput.Position = UDim2.new(0, 310, 0, 5)
            textboxInput.Size = UDim2.new(0, 140, 0, 20)
            textboxInput.Font = Enum.Font.GothamSemibold;
            textboxInput.Text = defaultValue;
            textboxInput.TextColor3 = Color3.fromRGB(150, 150, 150)
            textboxInput.TextSize = 11.000;
            textboxInput.TextTruncate = Enum.TextTruncate.AtEnd;
            textboxInput.ClearTextOnFocus = false;

            spawn(function()
                while wait() do
                    textboxInput.BackgroundColor3 = _G.ButtonColor
                end
            end)

            local originalText = defaultValue;

            local textboxInputStroke = Instance.new("UIStroke")
            textboxInputStroke.Name = "UIStroke"
            textboxInputStroke.Parent = textboxInput;
            textboxInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            textboxInputStroke.Color = Color3.fromRGB(50, 50, 50)
            textboxInputStroke.LineJoinMode = Enum.LineJoinMode.Round;
            textboxInputStroke.Thickness = 1;
            textboxInputStroke.Transparency = 0;
            textboxInputStroke.Enabled = true;
            textboxInputStroke.Archivable = true;

            textboxInput.FocusLost:Connect(function()
                if #textboxInput.Text > 0 then
                    onFocusLostCallback(textboxInput.Text)
                else
                    textboxInput.Text = originalText;
                    textboxInput.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end)

            textboxInput.Focused:Connect(function()
                if textboxInput.Text == originalText then
                    textboxInput.Text = ""
                    textboxInput.TextColor3 = Color3.fromRGB(225, 225, 225)
                end
            end)

            textboxInputCorner.Name = "TextboxCorner"
            textboxInputCorner.CornerRadius = UDim.new(0, 5)
            textboxInputCorner.Parent = textboxInput;

            return textboxComponent
        end;

        function tabMethods:AddMultiDropdown(labelText, defaultText, optionsTable, onChangeCallback)
            local dropdownContainer = Instance.new("Frame")
            local dropdownContainerCorner = Instance.new("UICorner")
            local dropdownButton = Instance.new("TextButton")
            local dropdownLabel = Instance.new("TextLabel")
            local dropdownScrollFrame = Instance.new("ScrollingFrame")
            local dropdownListLayout = Instance.new("UIListLayout")
            local dropdownPadding = Instance.new("UIPadding")
            local dropdownArrowImage = Instance.new("ImageLabel")
            local searchBox = Instance.new("TextBox")
            local searchBoxStroke = Instance.new("UIStroke")
            local searchBoxCorner = Instance.new("UICorner")
            local selectedOptions = {}
            local isOpen = false;
            local multiDropdownMethods = {}

            dropdownContainer.Name = "Dropdown"
            dropdownContainer.Parent = tabContentScrollingFrame;
            dropdownContainer.Active = true;
            dropdownContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            dropdownContainer.ClipsDescendants = true;
            dropdownContainer.Size = UDim2.new(0, 455, 0, 30)

            spawn(function()
                while wait() do
                    dropdownContainer.BackgroundColor3 = _G.ButtonColor
                end
            end)

            dropdownContainerCorner.CornerRadius = UDim.new(0, 4)
            dropdownContainerCorner.Parent = dropdownContainer;

            dropdownButton.Name = "DropButton"
            dropdownButton.Parent = dropdownContainer;
            dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownButton.BackgroundTransparency = 1.000;
            dropdownButton.Size = UDim2.new(0, 455, 0, 30)
            dropdownButton.Font = Enum.Font.SourceSans;
            dropdownButton.Text = ""
            dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            dropdownButton.TextSize = 14.000;

            dropdownLabel.Name = "Droptitle"
            dropdownLabel.Parent = dropdownContainer;
            dropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownLabel.BackgroundTransparency = 1.000;
            dropdownLabel.Position = UDim2.new(0.028, 0, 0, 0)
            dropdownLabel.Size = UDim2.new(0, 300, 0, 30)
            dropdownLabel.Font = Enum.Font.Gotham;
            dropdownLabel.Text = labelText .. " : " .. defaultText;
            dropdownLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            dropdownLabel.TextSize = 11.000;
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left;
            dropdownLabel.TextTruncate = Enum.TextTruncate.AtEnd;

            dropdownArrowImage.Name = "DropImage"
            dropdownArrowImage.Parent = dropdownContainer;
            dropdownArrowImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownArrowImage.BackgroundTransparency = 1.000;
            dropdownArrowImage.Position = UDim2.new(0, 425, 0, 5)
            dropdownArrowImage.Rotation = 0;
            dropdownArrowImage.Size = UDim2.new(0, 20, 0, 20)
            dropdownArrowImage.Image = "rbxassetid://" .. assetIds[8]

            searchBox.Name = "SearchBox"
            searchBox.Parent = dropdownContainer;
            searchBox.Size = UDim2.new(0.2, 0, 0, 20)
            searchBox.Position = UDim2.new(0, 330, 0.1, -13)
            searchBox.PlaceholderText = "Search..."
            searchBox.Font = Enum.Font.Gotham;
            searchBox.TextSize = 11;
            searchBox.TextColor3 = Color3.fromRGB(225, 225, 225)
            searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            searchBox.Text = ""
            searchBox.Visible = false;

            spawn(function()
                while wait() do
                    searchBox.BackgroundColor3 = _G.ButtonColor
                end
            end)

            searchBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            searchBoxStroke.Color = Color3.fromRGB(50, 50, 50)
            searchBoxStroke.Thickness = 1.2;
            searchBoxStroke.Parent = searchBox;

            searchBoxCorner.CornerRadius = UDim.new(0, 4)
            searchBoxCorner.Parent = searchBox;

            dropdownScrollFrame.Name = "DropScroll"
            dropdownScrollFrame.Parent = dropdownContainer;
            dropdownScrollFrame.Active = true;
            dropdownScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownScrollFrame.BackgroundTransparency = 1.000;
            dropdownScrollFrame.BorderSizePixel = 0;
            dropdownScrollFrame.Position = UDim2.new(0, 0, 0, 30)
            dropdownScrollFrame.Size = UDim2.new(0, 455, 0, 135)
            dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 2)
            dropdownScrollFrame.ScrollBarThickness = 4;
            dropdownScrollFrame.Visible = false;

            dropdownListLayout.Name = "DropdownList"
            dropdownListLayout.Parent = dropdownScrollFrame;
            dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
            dropdownListLayout.Padding = UDim.new(0, 5)

            dropdownPadding.Name = "DropdownPadding"
            dropdownPadding.Parent = dropdownScrollFrame;
            dropdownPadding.PaddingTop = UDim.new(0, 5)

            function multiDropdownMethods:UpdateSelectedText()
                dropdownLabel.Text = labelText .. " : " .. table.concat(selectedOptions, ", ")
            end;

            function multiDropdownMethods:Add(optionText)
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "DropButton2"
                optionButton.Parent = dropdownScrollFrame;
                optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.BackgroundTransparency = 1.000;
                optionButton.Size = UDim2.new(0, 455, 0, 30)
                optionButton.Font = Enum.Font.Gotham;
                optionButton.TextColor3 = Color3.fromRGB(225, 225, 225)
                optionButton.TextSize = 11.000;
                optionButton.Text = tostring(optionText)

                optionButton.MouseButton1Click:Connect(function()
                    local optionIndex = table.find(selectedOptions, optionText)
                    if optionIndex then
                        table.remove(selectedOptions, optionIndex)
                        tweenServiceRef:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = Color3.fromRGB(225, 225, 225)
                        }):Play()
                    else
                        table.insert(selectedOptions, optionText)
                        tweenServiceRef:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = _G.Clickcolor
                        }):Play()
                    end;
                    multiDropdownMethods:UpdateSelectedText()
                    onChangeCallback(selectedOptions)
                end)

                function SetSeperateColor2(color)
                    _G.Clickcolor = color
                end;

                dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            end;

            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen;
                dropdownScrollFrame.Visible = isOpen;
                searchBox.Visible = isOpen;
                if isOpen then
                    searchBox.Visible = true;
                    searchBox.Position = UDim2.new(0, 330, 0.1, -12)
                    tweenServiceRef:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 180)
                    }):Play()
                    tweenServiceRef:Create(dropdownArrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = -180
                    }):Play()
                else
                    searchBox.Text = ""
                    searchBox.Visible = false;
                    searchBox.Position = UDim2.new(0, 330, 0.1, 2)
                    tweenServiceRef:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 30)
                    }):Play()
                    tweenServiceRef:Create(dropdownArrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                end
            end)

            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local searchText = string.lower(searchBox.Text)
                for _, item in ipairs(dropdownScrollFrame:GetChildren()) do
                    if item:IsA("TextButton") then
                        item.Visible = string.find(string.lower(item.Text), searchText) ~= nil
                    end
                end;
                dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            end)

            for _, option in ipairs(optionsTable) do
                multiDropdownMethods:Add(option)
            end;

            return multiDropdownMethods
        end;

        function tabMethods:AddColorPickerDropdown(labelText, defaultColor, onChangeCallback)
            local colorPickerContainer = Instance.new("Frame")
            local colorPickerCorner = Instance.new("UICorner")
            local colorPickerButton = Instance.new("TextButton")
            local colorPickerLabel = Instance.new("TextLabel")
            local _ = Instance.new("ImageLabel") -- Unused from original
            local arrowImage = Instance.new("ImageLabel")
            local spectrumImage = Instance.new("ImageLabel")
            local colorPickerDot = Instance.new("ImageLabel")
            local hueSliderFrame = Instance.new("Frame")
            local hueSliderDot = Instance.new("Frame")
            local previewColorFrame = Instance.new("Frame")
            local rTextBox = Instance.new("TextBox")
            local gTextBox = Instance.new("TextBox")
            local bTextBox = Instance.new("TextBox")
            local colorPickerMethods = {}

            colorPickerContainer.Name = "Dropdown"
            colorPickerContainer.Parent = tabContentScrollingFrame;
            colorPickerContainer.Active = true;
            colorPickerContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            colorPickerContainer.ClipsDescendants = true;
            colorPickerContainer.Size = UDim2.new(0, 455, 0, 30)

            spawn(function()
                while wait() do
                    colorPickerContainer.BackgroundColor3 = _G.ButtonColor
                end
            end)

            colorPickerCorner.CornerRadius = UDim.new(0, 4)
            colorPickerCorner.Parent = colorPickerContainer;

            colorPickerButton.Name = "DropButton"
            colorPickerButton.Parent = colorPickerContainer;
            colorPickerButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            colorPickerButton.BackgroundTransparency = 1.000;
            colorPickerButton.Size = UDim2.new(0, 455, 0, 30)
            colorPickerButton.Font = Enum.Font.SourceSans;
            colorPickerButton.Text = ""
            colorPickerButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            colorPickerButton.TextSize = 14.000;

            colorPickerLabel.Name = "Droptitle"
            colorPickerLabel.Parent = colorPickerContainer;
            colorPickerLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            colorPickerLabel.BackgroundTransparency = 1.000;
            colorPickerLabel.Position = UDim2.new(0.028, 0, 0, 0)
            colorPickerLabel.Size = UDim2.new(0, 410, 0, 30)
            colorPickerLabel.Font = Enum.Font.Gotham;
            colorPickerLabel.Text = labelText .. " : " .. tostring(defaultColor)
            colorPickerLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            colorPickerLabel.TextSize = 11.000;
            colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left;

            arrowImage.Name = "DropImage"
            arrowImage.Parent = colorPickerContainer;
            arrowImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            arrowImage.BackgroundTransparency = 1.000;
            arrowImage.Position = UDim2.new(0, 425, 0, 5)
            arrowImage.Rotation = 0;
            arrowImage.Size = UDim2.new(0, 20, 0, 20)
            arrowImage.Image = "rbxassetid://" .. assetIds[8]

            local function addHueGradient(frame)
                local gradient = Instance.new("UIGradient")
                gradient.Parent = frame;
                gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                })
                gradient.Rotation = 90
            end;

            spectrumImage.Name = "Spectrum"
            spectrumImage.Parent = colorPickerContainer;
            spectrumImage.Size = UDim2.new(0, 200, 0, 200)
            spectrumImage.Position = UDim2.new(0, 10, 0, 40)
            spectrumImage.Image = "rbxassetid://" .. assetIds[9]
            spectrumImage.BackgroundColor3 = Color3.new(1, 1, 1)
            spectrumImage.ClipsDescendants = true;
            spectrumImage.Visible = false;

            local function addCorner(frame)
                local corner = Instance.new("UICorner")
                corner.Parent = frame
            end;
            addCorner(spectrumImage)

            colorPickerDot.Size = UDim2.new(0, 10, 0, 10)
            colorPickerDot.AnchorPoint = Vector2.new(0.5, 0.5)
            colorPickerDot.BackgroundTransparency = 1;
            colorPickerDot.Image = "rbxassetid://" .. assetIds[10]
            colorPickerDot.Parent = spectrumImage;

            hueSliderFrame.Size = UDim2.new(0, 20, 0, 200)
            hueSliderFrame.Position = UDim2.new(0, 220, 0, 40)
            hueSliderFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
            hueSliderFrame.Visible = true;
            hueSliderFrame.Parent = colorPickerContainer;
            addCorner(hueSliderFrame)
            addHueGradient(hueSliderFrame)

            hueSliderDot.Size = UDim2.new(1, 0, 0, 10)
            hueSliderDot.Position = UDim2.new(0, 0, 0.5, -5)
            hueSliderDot.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            addCorner(hueSliderDot)
            hueSliderDot.Parent = hueSliderFrame;

            previewColorFrame.Size = UDim2.new(0, 50, 0, 50)
            previewColorFrame.Position = UDim2.new(0, 250, 0, 40)
            previewColorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            addCorner(previewColorFrame)
            previewColorFrame.Parent = colorPickerContainer;

            rTextBox.Size = UDim2.new(0, 50, 0, 30)
            rTextBox.Position = UDim2.new(0, 250, 0, 110)
            rTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            rTextBox.Text = "255"
            rTextBox.TextColor3 = Color3.new(1, 1, 1)
            addCorner(rTextBox)
            rTextBox.Parent = colorPickerContainer;

            gTextBox.Size = UDim2.new(0, 50, 0, 30)
            gTextBox.Position = UDim2.new(0, 250, 0, 155)
            gTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            gTextBox.Text = "255"
            gTextBox.TextColor3 = Color3.new(1, 1, 1)
            addCorner(gTextBox)
            gTextBox.Parent = colorPickerContainer;

            bTextBox.Size = UDim2.new(0, 50, 0, 30)
            bTextBox.Position = UDim2.new(0, 250, 0, 200)
            bTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            bTextBox.Text = "255"
            bTextBox.TextColor3 = Color3.new(1, 1, 1)
            addCorner(bTextBox)
            bTextBox.Parent = colorPickerContainer;

            local currentColorRGB = Color3.new(1, 1, 1)
            local currentHueValue = 1;
            local isSpectrumDragging = false;
            local isHueDragging = false;

            local function updateRGBTexts(color)
                local rValue, gValue, bValue = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
                rTextBox.Text = tostring(rValue)
                gTextBox.Text = tostring(gValue)
                bTextBox.Text = tostring(bValue)
            end;

            local function updateHueDotPosition()
                local p, al, aF = currentColorRGB:ToHSV()
                colorPickerDot.Position = UDim2.new(p, 0, 1 - al, 0)
            end;

            local function updatePreviewColor()
                local p, al, aF = currentColorRGB:ToHSV()
                local finalColor = Color3.fromHSV(p, al, currentHueValue)
                previewColorFrame.BackgroundColor3 = finalColor;
                onChangeCallback(finalColor)
                colorPickerLabel.Text = labelText .. " : " .. tostring(finalColor)
                updateRGBTexts(finalColor)
            end;

            local function handleSpectrumDrag(inputObject)
                local relativeX = math.clamp(inputObject.Position.X - spectrumImage.AbsolutePosition.X, 0, spectrumImage.AbsoluteSize.X)
                local relativeY = math.clamp(inputObject.Position.Y - spectrumImage.AbsolutePosition.Y, 0, spectrumImage.AbsoluteSize.Y)
                colorPickerDot.Position = UDim2.new(0, relativeX, 0, relativeY)
                local hueX = relativeX / spectrumImage.AbsoluteSize.X;
                local hueY = 1 - relativeY / spectrumImage.AbsoluteSize.Y;
                currentColorRGB = Color3.fromHSV(hueX, hueY, currentHueValue)
                updatePreviewColor()
            end;

            spectrumImage.InputBegan:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    isSpectrumDragging = true;
                    handleSpectrumDrag(inputObject)
                end
            end)

            spectrumImage.InputChanged:Connect(function(inputObject)
                if isSpectrumDragging and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                    handleSpectrumDrag(inputObject)
                end
            end)

            spectrumImage.InputEnded:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    isSpectrumDragging = false
                end
            end)

            local function handleHueDrag(inputObject)
                local relativeY = math.clamp(inputObject.Position.Y - hueSliderFrame.AbsolutePosition.Y, 0, hueSliderFrame.AbsoluteSize.Y)
                hueSliderDot.Position = UDim2.new(0, 0, 0, relativeY - 5)
                currentHueValue = 1 - relativeY / hueSliderFrame.AbsoluteSize.Y;
                updatePreviewColor()
            end;

            hueSliderFrame.InputBegan:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    isHueDragging = true;
                    handleHueDrag(inputObject)
                end
            end)

            hueSliderFrame.InputChanged:Connect(function(inputObject)
                if isHueDragging and inputObject.UserInputType == Enum.UserInputType.MouseMovement then
                    handleHueDrag(inputObject)
                end
            end)

            hueSliderFrame.InputEnded:Connect(function(inputObject)
                if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                    isHueDragging = false
                end
            end)

            local function updateFromRGB()
                local rValue = tonumber(rTextBox.Text) or 0;
                local gValue = tonumber(gTextBox.Text) or 0;
                local bValue = tonumber(bTextBox.Text) or 0;
                rValue = math.clamp(rValue, 0, 255)
                gValue = math.clamp(gValue, 0, 255)
                bValue = math.clamp(bValue, 0, 255)
                currentColorRGB = Color3.new(rValue / 255, gValue / 255, bValue / 255)
                updateHueDotPosition()
                updatePreviewColor()
            end;

            rTextBox.FocusLost:Connect(function()
                updateFromRGB()
                updatePreviewColor()
            end)
            gTextBox.FocusLost:Connect(function()
                updateFromRGB()
                updatePreviewColor()
            end)
            bTextBox.FocusLost:Connect(function()
                updateFromRGB()
                updatePreviewColor()
            end)

            local isColorPickerOpen = false;
            colorPickerButton.MouseButton1Click:Connect(function()
                isColorPickerOpen = not isColorPickerOpen;
                if isColorPickerOpen then
                    spectrumImage.Visible = true;
                    hueSliderFrame.Visible = true;
                    tweenServiceRef:Create(colorPickerContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 250)
                    }):Play()
                    tweenServiceRef:Create(arrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = -180
                    }):Play()
                else
                    spectrumImage.Visible = false;
                    hueSliderFrame.Visible = false;
                    tweenServiceRef:Create(colorPickerContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 30)
                    }):Play()
                    tweenServiceRef:Create(arrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                end
            end)
            return colorPickerMethods
        end;

        function tabMethods:AddDropdown(labelText, defaultText, optionsTable, onChangeCallback)
            local dropdownContainer = Instance.new("Frame")
            local dropdownContainerCorner = Instance.new("UICorner")
            local dropdownButton = Instance.new("TextButton")
            local dropdownLabel = Instance.new("TextLabel")
            local dropdownScrollFrame = Instance.new("ScrollingFrame")
            local dropdownListLayout = Instance.new("UIListLayout")
            local dropdownPadding = Instance.new("UIPadding")
            local dropdownArrowImage = Instance.new("ImageLabel")
            local searchBox = Instance.new("TextBox")
            local searchBoxStroke = Instance.new("UIStroke")
            local searchBoxCorner = Instance.new("UICorner")
            local dropdownMethods = {}

            dropdownContainer.Name = "Dropdown"
            dropdownContainer.Parent = tabContentScrollingFrame;
            dropdownContainer.Active = true;
            dropdownContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            dropdownContainer.ClipsDescendants = true;
            dropdownContainer.Size = UDim2.new(0, 455, 0, 30)

            spawn(function()
                while wait() do
                    dropdownContainer.BackgroundColor3 = _G.ButtonColor
                end
            end)

            dropdownContainerCorner.CornerRadius = UDim.new(0, 4)
            dropdownContainerCorner.Parent = dropdownContainer;

            dropdownButton.Name = "DropButton"
            dropdownButton.Parent = dropdownContainer;
            dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownButton.BackgroundTransparency = 1.000;
            dropdownButton.Size = UDim2.new(0, 455, 0, 30)
            dropdownButton.Font = Enum.Font.SourceSans;
            dropdownButton.Text = ""
            dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            dropdownButton.TextSize = 14.000;

            dropdownLabel.Name = "Droptitle"
            dropdownLabel.Parent = dropdownContainer;
            dropdownLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownLabel.BackgroundTransparency = 1.000;
            dropdownLabel.Position = UDim2.new(0.028, 0, 0, 0)
            dropdownLabel.Size = UDim2.new(0, 410, 0, 30)
            dropdownLabel.Font = Enum.Font.Gotham;
            dropdownLabel.Text = labelText .. " : " .. defaultText;
            dropdownLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            dropdownLabel.TextSize = 11.000;
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left;

            dropdownArrowImage.Name = "DropImage"
            dropdownArrowImage.Parent = dropdownContainer;
            dropdownArrowImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownArrowImage.BackgroundTransparency = 1.000;
            dropdownArrowImage.Position = UDim2.new(0, 425, 0, 5)
            dropdownArrowImage.Rotation = 0;
            dropdownArrowImage.Size = UDim2.new(0, 20, 0, 20)
            dropdownArrowImage.Image = "rbxassetid://" .. assetIds[8]

            searchBox.Name = "SearchBox"
            searchBox.Parent = dropdownContainer;
            searchBox.Size = UDim2.new(0.2, 0, 0, 20)
            searchBox.Position = UDim2.new(0, 330, 0.1, 2)
            searchBox.PlaceholderText = "Search..."
            searchBox.Font = Enum.Font.Gotham;
            searchBox.TextSize = 11;
            searchBox.TextColor3 = Color3.fromRGB(225, 225, 225)
            searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            searchBox.Text = ""
            searchBox.AnchorPoint = Vector2.new(0, 0)
            searchBox.AutomaticSize = Enum.AutomaticSize.None;
            searchBox.Visible = false;

            spawn(function()
                while wait() do
                    searchBox.BackgroundColor3 = _G.ButtonColor
                end
            end)

            searchBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            searchBoxStroke.Color = Color3.fromRGB(50, 50, 50)
            searchBoxStroke.Thickness = 1.2;
            searchBoxStroke.Parent = searchBox;

            searchBoxCorner.CornerRadius = UDim.new(0, 4)
            searchBoxCorner.Parent = searchBox;

            dropdownScrollFrame.Name = "DropScroll"
            dropdownScrollFrame.Parent = dropdownContainer;
            dropdownScrollFrame.Active = true;
            dropdownScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dropdownScrollFrame.BackgroundTransparency = 1.000;
            dropdownScrollFrame.BorderSizePixel = 0;
            dropdownScrollFrame.Position = UDim2.new(0, 0, 0, 30)
            dropdownScrollFrame.Size = UDim2.new(0, 455, 0, 135)
            dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 2)
            dropdownScrollFrame.ScrollBarThickness = 4;
            dropdownScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y;
            dropdownScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
            dropdownScrollFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;

            dropdownListLayout.Name = "DropdownList"
            dropdownListLayout.Parent = dropdownScrollFrame;
            dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
            dropdownListLayout.Padding = UDim.new(0, 5)

            dropdownPadding.Name = "DropdownPadding"
            dropdownPadding.Parent = dropdownScrollFrame;
            dropdownPadding.PaddingTop = UDim.new(0, 5)

            function dropdownMethods:Clear()
                for _, item in ipairs(dropdownScrollFrame:GetChildren()) do
                    if item:IsA("TextButton") then
                        item:Destroy()
                    end
                end
            end;

            function dropdownMethods:SetDropdown(selectedText)
                dropdownLabel.Text = labelText .. " : " .. tostring(selectedText)
            end;

            local isDropdownOpen = false;

            function dropdownMethods:Add(optionText)
                local optionButton = Instance.new("TextButton")
                optionButton.Name = "DropButton2"
                optionButton.Parent = dropdownScrollFrame;
                optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                optionButton.BackgroundTransparency = 1.000;
                optionButton.Size = UDim2.new(0, 455, 0, 30)
                optionButton.Font = Enum.Font.Gotham;
                optionButton.TextColor3 = Color3.fromRGB(225, 225, 225)
                optionButton.TextSize = 11.000;
                optionButton.Text = tostring(optionText)

                optionButton.MouseEnter:Connect(function()
                    tweenServiceRef:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextColor3 = _G.Clickcolor
                    }):Play()
                end)

                optionButton.MouseLeave:Connect(function()
                    tweenServiceRef:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextColor3 = Color3.fromRGB(225, 225, 225)
                    }):Play()
                end)

                function SetSeperateColor4(color)
                    _G.Clickcolor = color
                end;

                optionButton.MouseButton1Click:Connect(function()
                    dropdownMethods:SetDropdown(optionText)
                    onChangeCallback(optionText)
                    isDropdownOpen = not isDropdownOpen;
                    searchBox.Text = ""
                    searchBox.Visible = false;
                    searchBox.Position = UDim2.new(0, 330, 0.1, 2)
                    tweenServiceRef:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 30)
                    }):Play()
                    tweenServiceRef:Create(dropdownArrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                end)
            end;

            dropdownButton.MouseButton1Click:Connect(function()
                isDropdownOpen = not isDropdownOpen;
                if isDropdownOpen then
                    searchBox.Visible = true;
                    searchBox.Position = UDim2.new(0, 330, 0.1, -12)
                    tweenServiceRef:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 180)
                    }):Play()
                    tweenServiceRef:Create(dropdownArrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = -180
                    }):Play()
                    dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
                else
                    searchBox.Text = ""
                    searchBox.Visible = false;
                    searchBox.Position = UDim2.new(0, 330, 0.1, 2)
                    tweenServiceRef:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 455, 0, 30)
                    }):Play()
                    tweenServiceRef:Create(dropdownArrowImage, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Rotation = 0
                    }):Play()
                end
            end)

            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                local searchText = string.lower(searchBox.Text)
                for _, item in ipairs(dropdownScrollFrame:GetChildren()) do
                    if item:IsA("TextButton") then
                        item.Visible = string.find(string.lower(item.Text), searchText) ~= nil
                    end
                end;
                dropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            end)

            for _, option in ipairs(optionsTable) do
                dropdownMethods:Add(option)
            end;

            return dropdownMethods
        end;

        function tabMethods:AddSlider(labelText, minValue, maxValue, initialValue, onChangeCallback)
            local sliderComponent = {}
            local initialValueClamped = math.clamp(initialValue, minValue, maxValue)

            local sliderContainer = Instance.new("Frame")
            local sliderContainerCorner = Instance.new("UICorner")
            local sliderLabel = Instance.new("TextLabel")
            local sliderValueLabel = Instance.new("TextLabel")
            local sliderButton = Instance.new("TextButton")
            local sliderTrackBackground = Instance.new("Frame")
            local sliderFillBar = Instance.new("Frame")
            local sliderTrackCorner = Instance.new("UICorner")
            local sliderHandle = Instance.new("Frame")
            local sliderHandleCorner = Instance.new("UICorner")
            local sliderTrackFillCorner = Instance.new("UICorner")
            local sliderStroke = Instance.new("UIStroke")

            sliderContainer.Name = "Slider"
            sliderContainer.Parent = tabContentScrollingFrame;
            sliderContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            sliderContainer.Size = UDim2.new(0, 455, 0, 40)

            spawn(function()
                while wait() do
                    sliderContainer.BackgroundColor3 = _G.ButtonColor
                end
            end)

            sliderContainerCorner.CornerRadius = UDim.new(0, 4)
            sliderContainerCorner.Parent = sliderContainer;

            sliderLabel.Name = "SliderTitle"
            sliderLabel.Parent = sliderContainer;
            sliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderLabel.BackgroundTransparency = 1.000;
            sliderLabel.Position = UDim2.new(0.028, 0, 0, 0)
            sliderLabel.Size = UDim2.new(0, 290, 0, 20)
            sliderLabel.Font = Enum.Font.Gotham;
            sliderLabel.Text = labelText;
            sliderLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            sliderLabel.TextSize = 11.000;
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left;

            sliderValueLabel.Name = "SliderValue"
            sliderValueLabel.Parent = sliderContainer;
            sliderValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderValueLabel.BackgroundTransparency = 1.000;
            sliderValueLabel.Position = UDim2.new(0.88, 0, 0, 0)
            sliderValueLabel.Size = UDim2.new(0, 40, 0, 20)
            sliderValueLabel.Font = Enum.Font.Gotham;
            sliderValueLabel.Text = tostring(initialValueClamped)
            sliderValueLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            sliderValueLabel.TextSize = 11.000;

            sliderButton.Name = "SliderButton"
            sliderButton.Parent = sliderContainer;
            sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderButton.BackgroundTransparency = 1.000;
            sliderButton.Position = UDim2.new(0, 10, 0, 25)
            sliderButton.Size = UDim2.new(0, 435, 0, 5)
            sliderButton.AutoButtonColor = false;
            sliderButton.Font = Enum.Font.SourceSans;
            sliderButton.Text = ""
            sliderButton.TextSize = 14.000;

            sliderTrackBackground.Name = "Bar1"
            sliderTrackBackground.Parent = sliderButton;
            sliderTrackBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            sliderTrackBackground.Size = UDim2.new(1, 0, 0, 5)

            spawn(function()
                while wait() do
                    sliderTrackBackground.BackgroundColor3 = _G.ButtonColor
                end
            end)

            sliderStroke.Parent = sliderTrackBackground;
            sliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            sliderStroke.Color = Color3.fromRGB(50, 50, 50)
            sliderStroke.LineJoinMode = Enum.LineJoinMode.Round;
            sliderStroke.Thickness = 1;

            sliderTrackCorner.CornerRadius = UDim.new(0, 100)
            sliderTrackCorner.Parent = sliderTrackBackground;

            sliderFillBar.Name = "Bar"
            sliderFillBar.Parent = sliderTrackBackground;
            sliderFillBar.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            sliderFillBar.BackgroundTransparency = 0.5;
            sliderFillBar.Size = UDim2.new((initialValueClamped - minValue) / (maxValue - minValue), 0, 1, 0)

            spawn(function()
                while wait() do
                    sliderFillBar.BackgroundColor3 = _G.SeparateColor
                end
            end)

            sliderTrackCorner.CornerRadius = UDim.new(0, 100)
            sliderTrackCorner.Parent = sliderFillBar;

            sliderHandle.Name = "CircleBar"
            sliderHandle.Parent = sliderFillBar;
            sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderHandle.Position = UDim2.new(1, 0, 0.5, 0)
            sliderHandle.Size = UDim2.new(0, 10, 0, 10)

            sliderHandleCorner.CornerRadius = UDim.new(0, 100)
            sliderHandleCorner.Parent = sliderHandle;

            sliderTrackFillCorner.CornerRadius = UDim.new(0, 100)
            sliderTrackFillCorner.Parent = sliderTrackBackground;

            local mouse = game.Players.LocalPlayer:GetMouse()
            local userInputService = game:GetService("UserInputService")
            local isDraggingSlider = false;

            sliderButton.MouseButton1Down:Connect(function()
                isDraggingSlider = true
            end)

            userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDraggingSlider = false
                end
            end)

            userInputService.InputChanged:Connect(function(input)
                if isDraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = math.clamp(mouse.X - sliderTrackBackground.AbsolutePosition.X, 0, sliderTrackBackground.AbsoluteSize.X)
                    local calculatedValue = math.floor(relativeX / sliderTrackBackground.AbsoluteSize.X * (maxValue - minValue) + minValue)
                    sliderFillBar.Size = UDim2.new(relativeX / sliderTrackBackground.AbsoluteSize.X, 0, 1, 0)
                    sliderHandle.Position = UDim2.new(1, 0, 0.5, 0)
                    sliderValueLabel.Text = tostring(calculatedValue)
                    pcall(function()
                        onChangeCallback(calculatedValue)
                    end)
                end
            end)

            return sliderComponent
        end;

        function tabMethods:AddSeperator(separatorText)
            local separatorComponent = {}
            local separatorFrame = Instance.new("Frame")
            local separatorLabel = Instance.new("TextLabel")

            separatorFrame.Name = "Seperator"
            separatorFrame.Parent = tabContentScrollingFrame;
            separatorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            separatorFrame.BackgroundTransparency = 1.000;
            separatorFrame.ClipsDescendants = true;
            separatorFrame.Size = UDim2.new(0, 455, 0, 20)

            local separatorFrameCorner = Instance.new("UICorner")
            separatorFrameCorner.Name = "MainCorner"
            separatorFrameCorner.CornerRadius = UDim.new(0, 9)
            separatorFrameCorner.Parent = separatorFrame;

            local separatorLabelCorner = Instance.new("UICorner") -- This variable was causing error, Sep1 was undefined.
            separatorLabelCorner.Name = "MainCorner"
            separatorLabelCorner.CornerRadius = UDim.new(0, 9)
            separatorLabelCorner.Parent = separatorFrame; -- Corrected to separatorFrame

            separatorLabel.Name = "SepLabel"
            separatorLabel.Parent = separatorFrame;
            separatorLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            separatorLabel.BackgroundTransparency = 1.000;
            separatorLabel.Position = UDim2.new(0, 5, 0, 0)
            separatorLabel.Size = UDim2.new(0, 255, 0, 20)
            separatorLabel.Font = Enum.Font.GothamSemibold;
            separatorLabel.Text = separatorText;
            separatorLabel.TextColor3 = Color3.fromRGB(91, 91, 91)
            separatorLabel.TextXAlignment = Enum.TextXAlignment.Left;
            separatorLabel.TextSize = 12.000;

            function separatorComponent:SetSep(text)
                separatorLabel.Text = text
            end;

            return separatorComponent
        end;

        function tabMethods:AddLine()
            local lineFrame = Instance.new("Frame")
            local lineElement = Instance.new("Frame")

            lineFrame.Name = "Line"
            lineFrame.Parent = tabContentScrollingFrame;
            lineFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            lineFrame.BackgroundTransparency = 1.000;
            lineFrame.ClipsDescendants = true;
            lineFrame.Size = UDim2.new(0, 455, 0, 20)

            lineElement.Name = "Linee"
            lineElement.Parent = lineFrame;
            lineElement.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            lineElement.BorderSizePixel = 0;
            lineElement.Position = UDim2.new(0, 0, 0, 10)
            lineElement.Size = UDim2.new(0, 455, 0, 2)
        end;

        function tabMethods:AddNLabel(labelText)
            local labelFrame = Instance.new("TextLabel")
            local labelPadding = Instance.new("UIPadding")
            local labelComponent = {}

            labelFrame.Name = "Label"
            labelFrame.Parent = tabContentScrollingFrame;
            labelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            labelFrame.BackgroundTransparency = 0;
            labelFrame.Size = UDim2.new(0, 455, 0, 57)
            labelFrame.Font = Enum.Font.GothamSemibold;
            labelFrame.TextColor3 = Color3.fromRGB(225, 225, 225)
            labelFrame.TextSize = 11.000;
            labelFrame.Text = labelText;
            labelFrame.TextXAlignment = Enum.TextXAlignment.Left;

            spawn(function()
                while wait() do
                    labelFrame.BackgroundColor3 = _G.ButtonColor
                end
            end)

            labelPadding.PaddingLeft = UDim.new(0, 10)
            labelPadding.Parent = labelFrame; -- Corrected from 'Label'
            labelPadding.Name = "PaddingLabel"

            local labelCorner = Instance.new("UICorner")
            labelCorner.Name = "MainCorner"
            labelCorner.CornerRadius = UDim.new(0, 5)
            labelCorner.Parent = labelFrame;

            local avatarImageLabel = Instance.new("ImageLabel")
            avatarImageLabel.Parent = labelFrame;
            avatarImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
            avatarImageLabel.BorderColor3 = Color3.new(0, 0, 0)
            avatarImageLabel.BackgroundTransparency = 1.000;
            avatarImageLabel.BorderSizePixel = 0;
            avatarImageLabel.Position = UDim2.new(0.851666677, 0, -0.1, 0)
            avatarImageLabel.Size = UDim2.new(0, 60, 0, 60)
            avatarImageLabel.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. game.Players.LocalPlayer.UserId .. "&width=420&height=420&format=png"

            function labelComponent:Set2(text)
                labelFrame.Text = text
            end;

            return labelComponent
        end;

        function tabMethods:AddLabel(titleText, bodyText)
            local labelContainer = Instance.new("Frame")
            labelContainer.Name = "Mainl"
            labelContainer.Parent = tabContentScrollingFrame;
            labelContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            labelContainer.BackgroundTransparency = 0;
            labelContainer.BorderSizePixel = 0;
            labelContainer.Size = UDim2.new(0, 455, 0, 35)

            local titleLabel = Instance.new("TextLabel")
            local labelPadding = Instance.new("UIPadding")
            local labelComponent = {}

            titleLabel.Name = "Title"
            titleLabel.Parent = labelContainer;
            titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            titleLabel.BackgroundTransparency = 1;
            titleLabel.Size = UDim2.new(0, 455, 0, 35)
            titleLabel.Font = Enum.Font.GothamBold;
            titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            titleLabel.TextSize = 11.000;
            titleLabel.Position = UDim2.new(-0.009, 0, -0.2, 0)
            titleLabel.Text = titleText;
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left;

            local bodyLabel = Instance.new("TextLabel")
            bodyLabel.Name = "Text"
            bodyLabel.Parent = labelContainer;
            bodyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            bodyLabel.BackgroundTransparency = 1;
            bodyLabel.Size = UDim2.new(0, 455, 0, 35)
            bodyLabel.Font = Enum.Font.Gotham;
            bodyLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
            bodyLabel.TextSize = 11.000;
            bodyLabel.Position = UDim2.new(0.014, 0, 0.18, 0)
            bodyLabel.Text = bodyText;
            bodyLabel.TextXAlignment = Enum.TextXAlignment.Left;

            labelPadding.PaddingLeft = UDim.new(0, 10)
            labelPadding.Parent = titleLabel;
            labelPadding.Name = "PaddingLabel"

            spawn(function()
                while wait() do
                    labelContainer.BackgroundColor3 = _G.ButtonColor;
                    titleLabel.BackgroundColor3 = _G.ButtonColor;
                    bodyLabel.BackgroundColor3 = _G.ButtonColor
                end
            end)

            local containerCorner = Instance.new("UICorner")
            containerCorner.Name = "MainCorner"
            containerCorner.CornerRadius = UDim.new(0, 4)
            containerCorner.Parent = labelContainer;

            function labelComponent:Set(text)
                bodyLabel.Text = text
            end;

            return labelComponent
        end;

        function tabMethods:AddLabel2() -- Removed unused parameters
            local labelContainer = Instance.new("Frame")
            labelContainer.Name = "Mainl"
            labelContainer.Parent = tabContentScrollingFrame;
            labelContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            labelContainer.BackgroundTransparency = 0;
            labelContainer.BorderSizePixel = 0;
            labelContainer.Size = UDim2.new(0, 455, 0, 35)

            local titleLabel = Instance.new("TextLabel")
            local labelPadding = Instance.new("UIPadding")
            local labelComponent = {}

            titleLabel.Name = "Title"
            titleLabel.Parent = labelContainer;
            titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            titleLabel.BackgroundTransparency = 1;
            titleLabel.Size = UDim2.new(0, 455, 0, 35)
            titleLabel.Font = Enum.Font.GothamBold;
            titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            titleLabel.TextSize = 11.000;
            titleLabel.Position = UDim2.new(-0.009, 0, -0.2, 0)
            titleLabel.Text = "Join Discord"
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left;

            local bodyLabel = Instance.new("TextLabel")
            bodyLabel.Name = "Text"
            bodyLabel.Parent = labelContainer;
            bodyLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            bodyLabel.BackgroundTransparency = 1;
            bodyLabel.Size = UDim2.new(0, 455, 0, 35)
            bodyLabel.Font = Enum.Font.Gotham;
            bodyLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
            bodyLabel.TextSize = 11.000;
            bodyLabel.Position = UDim2.new(0.83, 0, -0.2, 0)
            bodyLabel.Text = "Script Status"
            bodyLabel.TextXAlignment = Enum.TextXAlignment.Left;

            local statusLabel = Instance.new("TextLabel")
            statusLabel.Name = "status43w5"
            statusLabel.Parent = labelContainer;
            statusLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            statusLabel.BackgroundTransparency = 1.000;
            statusLabel.Position = UDim2.new(0.885, 0, 0.48, 0)
            statusLabel.Size = UDim2.new(0, 15, 0, 15)
            statusLabel.Font = Enum.Font.GothamBold;
            statusLabel.Text = "Undetected"
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            statusLabel.TextSize = 12.000;

            local discordLinkText = Instance.new("TextLabel")
            discordLinkText.Name = "Text"
            discordLinkText.Parent = labelContainer;
            discordLinkText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            discordLinkText.BackgroundTransparency = 1;
            discordLinkText.Size = UDim2.new(0, 455, 0, 35)
            discordLinkText.Font = Enum.Font.Gotham;
            discordLinkText.TextColor3 = Color3.fromRGB(175, 175, 175)
            discordLinkText.TextSize = 11.000;
            discordLinkText.Position = UDim2.new(0.014, 0, 0.18, 0)
            discordLinkText.Text = "discord.gg/calamityhub"
            discordLinkText.TextXAlignment = Enum.TextXAlignment.Left;

            labelPadding.PaddingLeft = UDim.new(0, 10)
            labelPadding.Parent = titleLabel;
            labelPadding.Name = "PaddingLabel"

            spawn(function()
                while wait() do
                    labelContainer.BackgroundColor3 = _G.ButtonColor;
                    titleLabel.BackgroundColor3 = _G.ButtonColor;
                    discordLinkText.BackgroundColor3 = _G.ButtonColor
                end
            end)

            local containerCorner = Instance.new("UICorner")
            containerCorner.Name = "MainCorner"
            containerCorner.CornerRadius = UDim.new(0, 4)
            containerCorner.Parent = labelContainer;

            function labelComponent:Set(text)
                discordLinkText.Text = text
            end;

            return labelComponent
        end;

        function tabMethods:AddStatusnew()
            local statusContainer = Instance.new("Frame")
            local statusContainerCorner = Instance.new("UICorner")
            local avatarFrame = Instance.new("Frame")
            local avatarImage = Instance.new("ImageLabel")
            local avatarImageCorner = Instance.new("UICorner")
            local avatarFrameBorderCorner = Instance.new("UICorner")
            local playerObfuscatedNameLabel = Instance.new("TextLabel")
            local infoBackgroundFrame = Instance.new("Frame")
            local accessEndsLabel = Instance.new("TextLabel")
            local linkedDiscordLabel = Instance.new("TextLabel")
            local scriptExecutedLabel = Instance.new("TextLabel")
            local versionLabel = Instance.new("TextLabel")
            local infoBackgroundFrameCorner = Instance.new("UICorner")
            local joinDiscordButton = Instance.new("TextButton")
            local joinDiscordButtonCorner = Instance.new("UICorner")
            local supportTextLabel = Instance.new("TextLabel")
            local _unusedButton = Instance.new("TextButton") -- from L
            local _unusedCorner = Instance.new("UICorner") -- from C

            statusContainer.Parent = tabContentScrollingFrame;
            statusContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            statusContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
            statusContainer.BorderSizePixel = 0;
            statusContainer.Position = UDim2.new(0.373591274, 0, 0.330402017, 0)
            statusContainer.Size = UDim2.new(0, 455, 0, 165)

            statusContainerCorner.Parent = statusContainer;

            avatarFrame.Name = "avadarr2"
            avatarFrame.Parent = statusContainer;
            avatarFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            avatarFrame.BackgroundTransparency = 0.300;
            avatarFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            avatarFrame.BorderSizePixel = 0;
            avatarFrame.Position = UDim2.new(0.032738097, 0, 0.0481481478, 0)
            avatarFrame.Size = UDim2.new(0, 100, 0, 100)

            avatarImage.Parent = avatarFrame;
            avatarImage.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            avatarImage.BackgroundTransparency = 0.500;
            avatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
            avatarImage.BorderSizePixel = 0;
            avatarImage.Position = UDim2.new(0.0563098155, 0, 0.0785183683, 0)
            avatarImage.Size = UDim2.new(0, 88, 0, 84)
            avatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. game.Players.LocalPlayer.UserId .. "&w=420&h=420"

            local avatarImageStroke = Instance.new("UIStroke")
            avatarImageStroke.Name = "UIStroke"
            avatarImageStroke.Parent = avatarImage;
            avatarImageStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
            avatarImageStroke.Color = Color3.fromRGB(30, 30, 30)
            avatarImageStroke.LineJoinMode = Enum.LineJoinMode.Round;
            avatarImageStroke.Thickness = 1;
            avatarImageStroke.Transparency = 0;
            avatarImageStroke.Enabled = true;
            avatarImageStroke.Archivable = true;

            avatarImageCorner.CornerRadius = UDim.new(1, 0)
            avatarImageCorner.Parent = avatarImage;

            avatarFrameBorderCorner.CornerRadius = UDim.new(1, 0)
            avatarFrameBorderCorner.Parent = avatarFrame;

            local function obfuscatePlayerNameText(name, visibleLength, obfuscateLength)
                local visiblePart = string.sub(name, 1, visibleLength)
                local obfuscatedPart = string.rep("*", obfuscateLength)
                return visiblePart .. obfuscatedPart
            end;

            local obfuscatedPlayerName = obfuscatePlayerNameText(game.Players.LocalPlayer.Name, 3, 5)

            playerObfuscatedNameLabel.Parent = statusContainer;
            playerObfuscatedNameLabel.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            playerObfuscatedNameLabel.BackgroundTransparency = 1.000;
            playerObfuscatedNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            playerObfuscatedNameLabel.BorderSizePixel = 0;
            playerObfuscatedNameLabel.Position = UDim2.new(-0.0775641501, 0, 0.585555582, 0)
            playerObfuscatedNameLabel.Size = UDim2.new(0, 200, 0, 50)
            playerObfuscatedNameLabel.Font = Enum.Font.Gotham;
            playerObfuscatedNameLabel.Text = "" .. obfuscatedPlayerName;
            playerObfuscatedNameLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
            playerObfuscatedNameLabel.TextSize = 27.000;
            playerObfuscatedNameLabel.TextTransparency = 0.500;

            infoBackgroundFrame.Name = "Alltexts"
            infoBackgroundFrame.Parent = statusContainer;
            infoBackgroundFrame.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
            infoBackgroundFrame.BackgroundTransparency = 0.700;
            infoBackgroundFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
            infoBackgroundFrame.BorderSizePixel = 0;
            infoBackgroundFrame.Position = UDim2.new(0.291346163, 0, 0.0870369822, 0)
            infoBackgroundFrame.Size = UDim2.new(0, 305, 0, 125)

            -- Initialize LRM_ variables if they are nil
            _G.LRM_SecondsLeft = _G.LRM_SecondsLeft or "0"
            _G.LRM_LinkedDiscordID = _G.LRM_LinkedDiscordID or "1"
            _G.LRM_TotalExecutions = _G.LRM_TotalExecutions or "1"
            _G.LRM_IsUserPremium = _G.LRM_IsUserPremium or true
            _G.Testingit = _G.Testingit or false

            if _G.Testingit then
                _G.LRM_SecondsLeft = "0"
                _G.LRM_LinkedDiscordID = "1"
                _G.LRM_TotalExecutions = "1"
                _G.LRM_IsUserPremium = true
            end;

            accessEndsLabel.Name = "accessendin"
            accessEndsLabel.Parent = infoBackgroundFrame;
            accessEndsLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            accessEndsLabel.BackgroundTransparency = 1.000;
            accessEndsLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            accessEndsLabel.BorderSizePixel = 0;
            accessEndsLabel.Position = UDim2.new(0.0336241627, 0, 0.39362964, 0)
            accessEndsLabel.Size = UDim2.new(0, 193, 0, 50)
            accessEndsLabel.Font = Enum.Font.Gotham;
            local hoursLeft = math.floor(tonumber(_G.LRM_SecondsLeft) / 3600)
            accessEndsLabel.Text = "⏳ Access ends in: " .. hoursLeft .. "h"
            accessEndsLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
            accessEndsLabel.TextSize = 14.000;
            accessEndsLabel.TextXAlignment = Enum.TextXAlignment.Left;

            linkedDiscordLabel.Name = "linkeddc"
            linkedDiscordLabel.Parent = infoBackgroundFrame;
            linkedDiscordLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            linkedDiscordLabel.BackgroundTransparency = 1.000;
            linkedDiscordLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            linkedDiscordLabel.BorderSizePixel = 0;
            linkedDiscordLabel.Position = UDim2.new(0.0336241627, 0, -0.00977783184, 0)
            linkedDiscordLabel.Size = UDim2.new(0, 200, 0, 50)
            linkedDiscordLabel.Font = Enum.Font.Gotham;
            linkedDiscordLabel.Text = "🔗 Linked Discord ID: " .. _G.LRM_LinkedDiscordID;
            linkedDiscordLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
            linkedDiscordLabel.TextSize = 14.000;
            linkedDiscordLabel.TextXAlignment = Enum.TextXAlignment.Left;

            scriptExecutedLabel.Name = "totalexecutedscript"
            scriptExecutedLabel.Parent = infoBackgroundFrame;
            scriptExecutedLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            scriptExecutedLabel.BackgroundTransparency = 1.000;
            scriptExecutedLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            scriptExecutedLabel.BorderSizePixel = 0;
            scriptExecutedLabel.Position = UDim2.new(0.0336241627, 0, 0.195851803, 0)
            scriptExecutedLabel.Size = UDim2.new(0, 200, 0, 50)
            scriptExecutedLabel.Font = Enum.Font.Gotham;
            scriptExecutedLabel.Text = "📜 Script executed: " .. _G.LRM_TotalExecutions .. " times"
            scriptExecutedLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
            scriptExecutedLabel.TextSize = 14.000;
            scriptExecutedLabel.TextXAlignment = Enum.TextXAlignment.Left;

            versionLabel.Name = "freepremiumversion"
            versionLabel.Parent = infoBackgroundFrame;
            versionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            versionLabel.BackgroundTransparency = 1.000;
            versionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            versionLabel.BorderSizePixel = 0;
            versionLabel.Position = UDim2.new(0.0336241627, 0, 0.58903712, 0)
            versionLabel.Size = UDim2.new(0, 200, 0, 50)
            versionLabel.Font = Enum.Font.Gotham;
            versionLabel.TextXAlignment = Enum.TextXAlignment.Left;
            versionLabel.Text = "💎 Version: Freemium"
            versionLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
            versionLabel.TextSize = 14.000;

            infoBackgroundFrameCorner.CornerRadius = UDim.new(0, 9)
            infoBackgroundFrameCorner.Parent = infoBackgroundFrame;

            _G.Switchedinformation = true;

            spawn(function()
                while task.wait(1) do
                    if _G.Switchedinformation then
                        local serverLuckValue = getRobloxService("ReplicatedStorage").world.luck_Server.Value;
                        local currentWeatherValue = getRobloxService("ReplicatedStorage").world.weather.Value;
                        local cycleValue = getRobloxService("ReplicatedStorage").world.cycle.Value;
                        local eventValue = getRobloxService("ReplicatedStorage").world.event.Value;
                        local timeOfDayValue = getRobloxService("Lighting").TimeOfDay;
                        accessEndsLabel.Text = "🌦️ Current weather: " .. currentWeatherValue;
                        linkedDiscordLabel.Text = "⏳ Time: " .. cycleValue .. " | " .. timeOfDayValue;
                        scriptExecutedLabel.Text = "⚡ Active surge: " .. eventValue;
                        versionLabel.Text = "🍀 Server luck: " .. serverLuckValue
                    end
                end
            end)

            _unusedCorner.Name = "MainCorner"
            _unusedCorner.CornerRadius = UDim.new(1, 0)
            _unusedCorner.Parent = _unusedButton;

            joinDiscordButton.Name = "Joindc"
            joinDiscordButton.Parent = statusContainer;
            joinDiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
            joinDiscordButton.BackgroundTransparency = 1.000;
            joinDiscordButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            joinDiscordButton.BorderSizePixel = 0;
            joinDiscordButton.Position = UDim2.new(0.592399299, 0, 0.85, 0)
            joinDiscordButton.Size = UDim2.new(0, 80, 0, 21)
            joinDiscordButton.Font = Enum.Font.SourceSans;
            joinDiscordButton.Text = "Join the Discord"
            joinDiscordButton.TextColor3 = Color3.fromRGB(121, 175, 255)
            joinDiscordButton.TextSize = 14.000;

            joinDiscordButton.MouseButton1Click:Connect(function()
                if joinDiscordButton.Text ~= "Copied" then
                    joinDiscordButton.Text = "Copied"
                end;
                setclipboard("discord.gg/calamityhub")
                wait(1.5)
                if joinDiscordButton.Text ~= "Join the Discord" then
                    joinDiscordButton.Text = "Join the Discord"
                end
            end)

            joinDiscordButtonCorner.CornerRadius = UDim.new(1, 0)
            joinDiscordButtonCorner.Parent = joinDiscordButton;

            supportTextLabel.Parent = statusContainer;
            supportTextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            supportTextLabel.BackgroundTransparency = 1.000;
            supportTextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            supportTextLabel.BorderSizePixel = 0;
            supportTextLabel.Position = UDim2.new(0.343452483, 0, 0.76, 0)
            supportTextLabel.Size = UDim2.new(0, 141, 0, 50)
            supportTextLabel.Font = Enum.Font.SourceSans;
            supportTextLabel.Text = "Need support?"
            supportTextLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
            supportTextLabel.TextSize = 14.000
        end;

        return tabMethods
    end;
    return windowMethods
end;

return Library
