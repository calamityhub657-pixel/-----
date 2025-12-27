
-- =========================================================================================
--                                   CALAMITY HUB LIBRARY
-- =========================================================================================

-- IDs Externos
local EXTERNAL_IDS = loadstring(game:HttpGet("https://raw.githubusercontent.com/SaltyHB/Poggers/refs/heads/main/ids2"))()

-- Validação de EXTERNAL_IDS: Se o script remoto falhar ou retornar nil/tipo incorreto,
-- usa valores placeholder para evitar erros.
if not EXTERNAL_IDS or type(EXTERNAL_IDS) ~= "table" then
    warn("Failed to load EXTERNAL_IDS from remote source. Using placeholder values.")
    EXTERNAL_IDS = {
        "rbxassetid://0", -- Placeholder para a[1]
        "rbxassetid://0", -- Placeholder para a[2]
        "rbxassetid://0", -- Placeholder para a[3]
        "rbxassetid://0", -- Placeholder (se houver mais IDs, adicione aqui)
        "rbxassetid://0",
        "rbxassetid://0",
        "rbxassetid://0", -- Placeholder para a[7] (checkmark)
        "rbxassetid://0", -- Placeholder para a[8] (dropdown arrow)
        "rbxassetid://0", -- Placeholder para a[9] (color picker spectrum)
        "rbxassetid://0"  -- Placeholder para a[10] (color picker selector)
        -- Certifique-se de que o número de placeholders corresponda ao uso máximo no script,
        -- ou ajuste dinamicamente EXTERNAL_IDS[#EXTERNAL_IDS]
    }
end


-- Roblox Services
local function getServiceRef(serviceName)
    local service = game:GetService(serviceName)
    -- Proteção contra cloneref inexistente: Nem todos os executores têm cloneref.
    if cloneref then
        return cloneref(service)
    end
    return service
end

local Players = getServiceRef("Players")
local TweenService = getServiceRef("TweenService")
local UserInputService = getServiceRef("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Variáveis Globais (controladas para evitar poluição do _G)
_G.Clickcolor = Color3.fromRGB(150, 0, 255) -- Cor roxa
_G.BackgroundColor = Color3.fromRGB(15, 15, 15)
_G.SeparateColor = Color3.fromRGB(150, 0, 255) -- Cor roxa
_G.ButtonColor = Color3.fromRGB(30, 30, 30) -- Definido para consistência

-- Constantes de UI
local UI_CORNER_RADIUS = UDim.new(0, 9)
local BUTTON_CORNER_RADIUS = UDim.new(0, 4)
local TEXTBOX_CORNER_RADIUS = UDim.new(0, 5)
local TOGGLE_CORNER_RADIUS = UDim.new(0, 5)
local SLIDER_CORNER_RADIUS = UDim.new(0, 100) -- Para o círculo do slider

-- Tabela principal da biblioteca
local Library = {}

-- =========================================================================================
--                                    FUNÇÕES AUXILIARES
-- =========================================================================================

--[[
    Torna um Frame arrastável na tela.
    @param draggableElement GuiObject - O elemento da UI que o usuário clica para arrastar.
    @param targetFrame GuiObject - O Frame que será movido.
]]
local function makeDraggable(draggableElement, targetFrame)
    assert(typeof(draggableElement) == "GuiObject", "makeDraggable: draggableElement must be a GuiObject.")
    assert(typeof(targetFrame) == "GuiObject", "makeDraggable: targetFrame must be a GuiObject.")

    local isDragging = false
    local dragStartPosition
    local frameStartPosition
    local inputChangedConnection = nil -- Conexão local para Input.Changed

    trackConnection(draggableElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPosition = input.Position
            frameStartPosition = targetFrame.Position
            
            -- Desconecta conexão anterior se existir para evitar duplicação ou vazamento
            if inputChangedConnection and inputChangedConnection.Connected then
                pcall(function() inputChangedConnection:Disconnect() end)
            end
            
            -- Rastreia a mudança de estado do input para saber quando parar de arrastar
            inputChangedConnection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                    if inputChangedConnection then
                        pcall(function() inputChangedConnection:Disconnect() end)
                        inputChangedConnection = nil
                    end
                end
            end)
        end
    end))

    trackConnection(draggableElement.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPosition
            local newPosition = UDim2.new(
                frameStartPosition.X.Scale, frameStartPosition.X.Offset + delta.X,
                frameStartPosition.Y.Scale, frameStartPosition.Y.Offset + delta.Y
            )
            TweenService:Create(targetFrame, TweenInfo.new(0.01), {Position = newPosition}):Play()
        end
    end))
end

--[[
    Cria um UICorner e o parenta a um GuiObject.
    @param parent GuiObject - O GuiObject pai do UICorner.
    @param radius UDim - O raio do canto (padrão: UI_CORNER_RADIUS).
    @return UICorner - O objeto UICorner criado.
]]
local function createCorner(parent, radius)
    assert(typeof(parent) == "GuiObject", "createCorner: parent must be a GuiObject.")
    assert(typeof(radius) == "UDim" or radius == nil, "createCorner: radius must be a UDim or nil.")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UI_CORNER_RADIUS
    corner.Parent = parent
    return corner
end

-- Gerenciamento de Conexões (para evitar memory leaks)
local activeConnections = {}
--[[
    Rastreia uma conexão de evento para que possa ser desconectada posteriormente.
    @param connection RBXScriptConnection - A conexão de evento a ser rastreada.
]]
local function trackConnection(connection)
    if connection and connection.Connected then -- Garante que a conexão existe e está ativa antes de rastrear
        table.insert(activeConnections, connection)
    end
end

--[[
    Desconecta e remove todas as conexões de evento rastreadas.
    Chamado ao destruir a janela da biblioteca.
]]
local function cleanupConnections()
    for i = #activeConnections, 1, -1 do -- Itera de trás para frente para remoção segura
        local connection = activeConnections[i]
        if connection and connection.Connected then
            pcall(function() connection:Disconnect() end) -- Protege contra erros ao desconectar
        end
        activeConnections[i] = nil -- Remove a referência da tabela
    end
end

--[[
    Acessa um valor aninhado dentro da PlayerGui de forma segura.
    @param path table<string> - Uma tabela de strings representando o caminho para o objeto.
    @return Instance? - O objeto encontrado, ou nil se não for encontrado.
]]
local function getPlayerGuiValue(path)
    assert(type(path) == "table", "getPlayerGuiValue: path must be a table.")

    local current = Players.LocalPlayer.PlayerGui
    for _, name in ipairs(path) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current
end

--[[
    Esconde parte do nome de um jogador com asteriscos.
    @param name string - O nome completo.
    @param numVisible number - Quantos caracteres iniciais devem ser visíveis (padrão: 3).
    @param numHidden number - Quantos caracteres devem ser escondidos (padrão: restante).
    @return string - O nome formatado.
]]
local function hidePlayerNamePart(name, numVisible, numHidden)
    assert(type(name) == "string", "hidePlayerNamePart: name must be a string.")
    assert(type(numVisible) == "number" or numVisible == nil, "hidePlayerNamePart: numVisible must be a number or nil.")
    assert(type(numHidden) == "number" or numHidden == nil, "hidePlayerNamePart: numHidden must be a number or nil.")

    numVisible = numVisible or 3
    numHidden = numHidden or math.max(0, string.len(name) - numVisible) -- Garante que numHidden não seja negativo
    local visiblePart = string.sub(name, 1, numVisible)
    local hiddenPart = string.rep("*", numHidden)
    return visiblePart .. hiddenPart
end

-- =========================================================================================
--                                    ESTRUTURA DA JANELA
-- =========================================================================================

--[[
    Cria uma nova janela para a biblioteca.
    @param windowName string - O título da janela.
    @param toggleKey Enum.KeyCode - A tecla para abrir/fechar a janela (padrão: RightControl).
    @return table - Tabela com métodos para adicionar abas e controlar a janela.
]]
function Library:AddWindow(windowName, toggleKey)
    assert(type(windowName) == "string", "AddWindow: windowName must be a string.")
    assert(typeof(toggleKey) == "EnumItem" and toggleKey:IsA("KeyCode") or toggleKey == nil, "AddWindow: toggleKey must be an Enum.KeyCode or nil.")

    local currentWindow = {} -- Objeto que será retornado para a janela
    toggleKey = toggleKey or Enum.KeyCode.RightControl
    local isWindowOpen = true
    
    local mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "CalamityHubScreenGui"
    mainScreenGui.Parent = CoreGui
    mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Parent = mainScreenGui
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = _G.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Position = UDim2.new(0.499526083, 0, 0.499241292, 0)
    mainFrame.Size = UDim2.new(0, 600, 0, 350)
    mainFrame.BackgroundTransparency = 0
    createCorner(mainFrame)

    -- Referência para o título do hub na janela principal
    local hubNameLabel = Instance.new("TextLabel") -- Declarado aqui para ser acessível pelo SetWindowTitle
    hubNameLabel.Name = "NameHub"
    hubNameLabel.Parent = mainFrame -- Temporariamente no mainFrame, será realocado
    hubNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hubNameLabel.BackgroundTransparency = 1.000
    hubNameLabel.Position = UDim2.new(0.136, 0, 0.018, -33) -- Posição inicial, será ajustada
    hubNameLabel.Size = UDim2.new(0, 15, 0, 15)
    hubNameLabel.Font = Enum.Font.GothamSemibold
    hubNameLabel.Text = windowName -- Usa o nome da janela
    hubNameLabel.TextColor3 = _G.SeparateColor
    hubNameLabel.TextSize = 12.000
    hubNameLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Função para fechar a UI, agora local
    local function closeUI()
        if not isWindowOpen then -- Se já estiver fechando, não faz nada
            return
        end
        isWindowOpen = false
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        local statsFrame = CoreGui:FindFirstChild("StatsFrame")
        local closeFrame = CoreGui:FindFirstChild("CloseFrame")
        
        -- Lógica corrigida para detectar se é touch, gamepad ou teclado
        if UserInputService:IsGamepadEnabled() or UserInputService.TouchEnabled then
            if closeFrame then closeFrame.Enabled = true end
        else -- Para teclado e mouse (Desktop)
            if statsFrame then statsFrame.Enabled = true end
        end
    end

    -- Função para abrir a UI, agora local
    local function openUI()
        if isWindowOpen then -- Se já estiver aberta, não faz nada
            return
        end
        isWindowOpen = true
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)}):Play()
        local statsFrame = CoreGui:FindFirstChild("StatsFrame")
        local closeFrame = CoreGui:FindFirstChild("CloseFrame")
        if statsFrame then statsFrame.Enabled = false end
        if closeFrame then closeFrame.Enabled = false end
    end

    -- Toggle da UI com a tecla
    trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == toggleKey and not gameProcessedEvent then
            if isWindowOpen then
                closeUI()
            else
                openUI()
            end
        end
    end))

    -- Botão de fechar (X)
    local closeButton = Instance.new("ImageButton")
    closeButton.Parent = mainFrame
    closeButton.BackgroundColor3 = Color3.new(0.67451, 0.67451, 0.67451)
    closeButton.BackgroundTransparency = 1
    closeButton.BorderColor3 = Color3.new(0, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(0.953, 0, 0.029, 0)
    closeButton.Size = UDim2.new(0, 17, 0, 18)
    closeButton.Image = EXTERNAL_IDS[3]
    closeButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    trackConnection(closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = _G.Clickcolor}):Play()
    end))
    trackConnection(closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
    end))
    trackConnection(closeButton.MouseButton1Click:Connect(closeUI))

    -- Barra superior da janela
    local topBar = Instance.new("Frame")
    topBar.Name = "Top"
    topBar.Parent = mainFrame
    topBar.BackgroundColor3 = _G.BackgroundColor
    topBar.BackgroundTransparency = 1
    topBar.BorderSizePixel = 0
    topBar.Size = UDim2.new(0, 600, 0, 38)
    createCorner(topBar)
    makeDraggable(topBar, mainFrame)

    -- Frame da página (onde as abas serão adicionadas)
    local pageFrame = Instance.new("Frame")
    pageFrame.Name = "Page"
    pageFrame.Parent = mainFrame
    pageFrame.BackgroundColor3 = _G.BackgroundColor
    pageFrame.BackgroundTransparency = 0
    pageFrame.BorderSizePixel = 0
    pageFrame.Position = UDim2.new(0, 0, 0, 38)
    pageFrame.Size = UDim2.new(0, 125, 0, 312)
    createCorner(pageFrame)

    -- Reparenta hubNameLabel para pageFrame (posição mais lógica)
    hubNameLabel.Parent = pageFrame

    -- Separadores da UI
    local separatorVertical = Instance.new("Frame")
    separatorVertical.Parent = pageFrame
    separatorVertical.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    separatorVertical.BorderColor3 = Color3.new(0, 0, 0)
    separatorVertical.BorderSizePixel = 0
    separatorVertical.Position = UDim2.new(1, 0, 0.001, 0)
    separatorVertical.Size = UDim2.new(0, 1, 0, 273)
    separatorVertical.BackgroundTransparency = 0

    local separatorHorizontalTop = Instance.new("Frame")
    separatorHorizontalTop.Parent = pageFrame
    separatorHorizontalTop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    separatorHorizontalTop.BorderColor3 = Color3.new(0, 0, 0)
    separatorHorizontalTop.BorderSizePixel = 0
    separatorHorizontalTop.Position = UDim2.new(0, 0, 0.322, -101)
    separatorHorizontalTop.Size = UDim2.new(0, 600, 0, 1)

    local separatorHorizontalBottom = Instance.new("Frame")
    separatorHorizontalBottom.Parent = pageFrame
    separatorHorizontalBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    separatorHorizontalBottom.BorderColor3 = Color3.new(0, 0, 0)
    separatorHorizontalBottom.BorderSizePixel = 0
    separatorHorizontalBottom.Position = UDim2.new(0, 0, 1.2, -101)
    separatorHorizontalBottom.Size = UDim2.new(0, 600, 0, 1)

    -- Player Info
    local playerNameLabel = Instance.new("TextLabel")
    playerNameLabel.Name = "PlayerName"
    playerNameLabel.Parent = pageFrame
    playerNameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerNameLabel.BackgroundTransparency = 1.000
    playerNameLabel.Position = UDim2.new(0.136, 0, 1.02, -33)
    playerNameLabel.Size = UDim2.new(0, 15, 0, 15)
    playerNameLabel.Font = Enum.Font.GothamSemibold
    playerNameLabel.Text = "        Welcome, " .. hidePlayerNamePart(Players.LocalPlayer.Name, 3, 5)
    playerNameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    playerNameLabel.TextSize = 12.000
    playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Time/Stats Background
    local timeBackgroundFrame = Instance.new("Frame")
    timeBackgroundFrame.Name = "Backgroundtimeframe"
    timeBackgroundFrame.Parent = pageFrame
    timeBackgroundFrame.BackgroundColor3 = _G.SeparateColor
    timeBackgroundFrame.BorderSizePixel = 0
    timeBackgroundFrame.Position = UDim2.new(3.35, 0, 1, -33)
    timeBackgroundFrame.Size = UDim2.new(0, 171, 0, 28)
    timeBackgroundFrame.BackgroundTransparency = 0.7
    timeBackgroundFrame.ClipsDescendants = false
    createCorner(timeBackgroundFrame, UDim.new(0.5, 0))

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "Statsetc"
    statsLabel.Parent = pageFrame
    statsLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    statsLabel.BackgroundTransparency = 1.000
    statsLabel.Position = UDim2.new(3.2, 0, 1.02, -33)
    statsLabel.Size = UDim2.new(0, 15, 0, 15)
    statsLabel.Font = Enum.Font.GothamSemibold
    statsLabel.Text = ""
    statsLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    statsLabel.TextSize = 10.000
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Avatar do jogador
    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "PlayerAvatarFrame"
    avatarFrame.Parent = pageFrame
    avatarFrame.AnchorPoint = Vector2.new(0, 0.5)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
    avatarFrame.BackgroundTransparency = 1.000
    avatarFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatarFrame.BorderSizePixel = 0
    avatarFrame.Position = UDim2.new(-0.85, 0, 0.939, 0)
    avatarFrame.Size = UDim2.new(0, 38, 0, 38)
    avatarFrame.BackgroundTransparency = 0.5
    createCorner(avatarFrame, UDim.new(1, 0))

    local avatarHighlightFrame = Instance.new("Frame")
    avatarHighlightFrame.Name = "AvatarHighlight"
    avatarHighlightFrame.Parent = avatarFrame
    avatarHighlightFrame.BackgroundColor3 = _G.SeparateColor
    avatarHighlightFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    avatarHighlightFrame.Position = UDim2.new(2.97368431, 0, 0.105263159, 0)
    avatarHighlightFrame.Size = UDim2.new(0, 30, 0, 30)
    avatarHighlightFrame.BackgroundTransparency = 0.5
    createCorner(avatarHighlightFrame, UDim.new(1, 0))

    local playerAvatarImage = Instance.new("ImageLabel")
    playerAvatarImage.Parent = avatarHighlightFrame
    playerAvatarImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerAvatarImage.BackgroundTransparency = 1.000
    playerAvatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
    playerAvatarImage.BorderSizePixel = 0
    playerAvatarImage.Position = UDim2.new(0, 3, 0, 3)
    playerAvatarImage.Size = UDim2.new(0, 24, 0, 24)
    playerAvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Players.LocalPlayer.UserId .. "&w=420&h=420"
    createCorner(playerAvatarImage, UDim.new(1, 0))

    local discordLink = Instance.new("TextLabel")
    discordLink.Name = "DiscordLink"
    discordLink.Parent = pageFrame
    discordLink.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    discordLink.BackgroundTransparency = 1.000
    discordLink.Position = UDim2.new(0.94, 0, 0.018, -33)
    discordLink.Size = UDim2.new(0, 15, 0, 15)
    discordLink.Font = Enum.Font.GothamSemibold
    discordLink.Text = "discord.gg/calamityhub"
    discordLink.TextColor3 = Color3.fromRGB(75, 75, 75)
    discordLink.TextSize = 12.000
    discordLink.TextXAlignment = Enum.TextXAlignment.Left

    -- Scrolling Frame para as abas
    local pageScrollFrame = Instance.new("ScrollingFrame")
    pageScrollFrame.Name = "PageScrollFrame"
    pageScrollFrame.Parent = pageFrame
    pageScrollFrame.Active = true
    pageScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pageScrollFrame.BackgroundTransparency = 1.000
    pageScrollFrame.BorderSizePixel = 0
    pageScrollFrame.Position = UDim2.new(-0.1, 0, 0.011, 0)
    pageScrollFrame.Size = UDim2.new(0, 135, 0, 270)
    pageScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    pageScrollFrame.ScrollBarThickness = 0
    createCorner(pageScrollFrame)

    local pageListLayout = Instance.new("UIListLayout")
    pageListLayout.Name = "PageList"
    pageListLayout.Parent = pageScrollFrame
    pageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageListLayout.Padding = UDim.new(0, 7)

    local pagePadding = Instance.new("UIPadding")
    pagePadding.Name = "PagePadding"
    pagePadding.Parent = pageScrollFrame
    pagePadding.PaddingTop = UDim.new(0, 5)
    pagePadding.PaddingLeft = UDim.new(0, 28)

    local tabFolder = Instance.new("Folder")
    tabFolder.Name = "TabFolder"
    tabFolder.Parent = mainFrame

    -- Update de tempo e stats (otimizado para 1 segundo)
    local lastStatsUpdate = 0
    local function updateStatsDisplay()
        local scriptUptimeSeconds = math.floor(workspace.DistributedGameTime + 0.5)
        local days = math.floor(scriptUptimeSeconds / (60 * 60 * 24))
        local hours = math.floor(scriptUptimeSeconds / (60 * 60)) % 24
        local minutes = math.floor(scriptUptimeSeconds / 60) % 60
        local seconds = scriptUptimeSeconds % 60

        statsLabel.Text = string.format("Hours: %02d Minutes: %02d Seconds: %02d", hours, minutes, seconds)
    end
    trackConnection(RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastStatsUpdate >= 1 then -- Atualiza apenas a cada 1 segundo
            lastStatsUpdate = currentTime
            updateStatsDisplay()
        end
    end))

    -- =========================================================================================
    --                                    MÉTODOS DA ABA (TAB)
    -- =========================================================================================

    local tabMethods = {} -- Tabela de métodos para as abas individuais

    --[[
        Cria um novo botão dentro de uma aba.
        @param buttonText string - O texto exibido no botão.
        @param callback function - A função a ser chamada quando o botão é clicado (opcional).
        @param iconId number? - O AssetId da imagem do ícone (opcional).
        @return table - Um objeto com o método `SetButtonText(text)`.
    ]]
    function tabMethods:AddButton(buttonText, callback, iconId)
        assert(type(buttonText) == "string", "AddButton: buttonText must be a string.")
        assert(type(callback) == "function" or callback == nil, "AddButton: callback must be a function or nil.")
        assert(type(iconId) == "number" or iconId == nil, "AddButton: iconId must be a number or nil.")

        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Parent = self.scrollFrame -- self.scrollFrame é o ScrollTab da aba
        button.BackgroundColor3 = _G.ButtonColor
        button.BackgroundTransparency = 0
        button.BorderSizePixel = 0
        button.Size = UDim2.new(0, 455, 0, 30)
        button.AutoButtonColor = false
        button.Font = Enum.Font.Gotham
        button.Text = buttonText
        button.TextColor3 = Color3.fromRGB(225, 225, 225)
        button.TextSize = 11.000
        button.TextWrapped = true
        button.TextXAlignment = Enum.TextXAlignment.Left -- Padrão, ajustado se tiver ícone
        createCorner(button, BUTTON_CORNER_RADIUS)

        if iconId then
            local icon = Instance.new("ImageLabel")
            icon.Parent = button
            icon.Size = UDim2.new(0, 16, 0, 16)
            icon.Position = UDim2.new(0, 10, 0, 7)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://" .. tostring(iconId)
            
            button.TextXAlignment = Enum.TextXAlignment.Center -- Ajusta o texto para não sobrepor o ícone
        end

        trackConnection(button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
        end))
        trackConnection(button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
        end))
        trackConnection(button.MouseButton1Click:Connect(function()
            if type(callback) == "function" then
                pcall(callback) -- Protege o callback de erros
            end
            TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 7}):Play()
            TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 11}):Play()
        end))

        return {
            SetButtonText = function(text)
                assert(type(text) == "string", "SetButtonText: text must be a string.")
                button.Text = text
            end
        }
    end;

    --[[
        Cria um novo toggle (liga/desliga) dentro de uma aba.
        @param toggleText string - O texto exibido ao lado do toggle.
        @param initialValue boolean - O estado inicial do toggle (true para ligado, false para desligado).
        @param callback function - A função a ser chamada quando o toggle muda de estado. Recebe o novo estado como argumento.
        @return table - Um objeto com métodos: SetToggleText(text), GetState(), SetState(state).
    ]]
    function tabMethods:AddToggle(toggleText, initialValue, callback)
        assert(type(toggleText) == "string", "AddToggle: toggleText must be a string.")
        assert(type(initialValue) == "boolean" or initialValue == nil, "AddToggle: initialValue must be a boolean or nil.")
        assert(type(callback) == "function" or callback == nil, "AddToggle: callback must be a function or nil.")

        local toggleContainer = Instance.new("TextButton")
        toggleContainer.Name = "Toggle"
        toggleContainer.Parent = self.scrollFrame
        toggleContainer.BackgroundColor3 = _G.ButtonColor
        toggleContainer.BackgroundTransparency = 0
        toggleContainer.BorderSizePixel = 0
        toggleContainer.AutoButtonColor = false
        toggleContainer.Size = UDim2.new(0, 455, 0, 30)
        toggleContainer.Font = Enum.Font.SourceSans
        toggleContainer.Text = "" -- O texto vai para o ToggleLabel
        toggleContainer.TextColor3 = Color3.fromRGB(0, 0, 0)
        toggleContainer.TextSize = 14.000
        createCorner(toggleContainer, BUTTON_CORNER_RADIUS)

        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "ToggleLabel"
        toggleLabel.Parent = toggleContainer
        toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleLabel.BackgroundTransparency = 1.000
        toggleLabel.Position = UDim2.new(0, 13, 0, 0)
        toggleLabel.Size = UDim2.new(0, 410, 0, 30)
        toggleLabel.Font = Enum.Font.Gotham
        toggleLabel.Text = toggleText
        toggleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        toggleLabel.TextSize = 11.000
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local toggleImageFrame = Instance.new("Frame")
        toggleImageFrame.Name = "ToggleImage"
        toggleImageFrame.Parent = toggleContainer
        toggleImageFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        toggleImageFrame.Position = UDim2.new(0, 425, 0, 5)
        toggleImageFrame.BorderSizePixel = 0
        toggleImageFrame.Size = UDim2.new(0, 20, 0, 20)
        createCorner(toggleImageFrame, TOGGLE_CORNER_RADIUS)

        local toggleStroke = Instance.new("UIStroke")
        toggleStroke.Parent = toggleImageFrame
        toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        toggleStroke.Color = Color3.fromRGB(50, 50, 50)
        toggleStroke.LineJoinMode = Enum.LineJoinMode.Round
        toggleStroke.Thickness = 1
        toggleStroke.Transparency = 0
        toggleStroke.Enabled = true

        local toggleCheckmark = Instance.new("ImageLabel")
        toggleCheckmark.Name = "ToggleImage2"
        toggleCheckmark.Parent = toggleImageFrame
        toggleCheckmark.Image = EXTERNAL_IDS[7] -- ID da imagem do checkmark
        toggleCheckmark.AnchorPoint = Vector2.new(0.5, 0.5)
        toggleCheckmark.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
        toggleCheckmark.Position = UDim2.new(0, 10, 0, 10)
        toggleCheckmark.ImageColor3 = _G.Clickcolor
        toggleCheckmark.Visible = false
        toggleCheckmark.ImageTransparency = 0.3
        toggleCheckmark.BackgroundTransparency = 1.000
        createCorner(toggleCheckmark, TOGGLE_CORNER_RADIUS)

        trackConnection(toggleContainer.MouseEnter:Connect(function()
            TweenService:Create(toggleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
        end))
        trackConnection(toggleContainer.MouseLeave:Connect(function()
            TweenService:Create(toggleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
        end))

        local isOn = initialValue or false
        local function updateToggleVisual()
            toggleCheckmark.ImageColor3 = _G.SeparateColor -- Mantém a cor da imagem consistente
            if isOn then
                toggleCheckmark.Visible = true
                TweenService:Create(toggleCheckmark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 26, 0, 26)}):Play()
            else
                TweenService:Create(toggleCheckmark, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                task.wait(0.1) -- Pequeno delay para a animação
                toggleCheckmark.Visible = false
            end
            if type(callback) == "function" then
                pcall(callback, isOn) -- Passa o novo estado
            end
        end

        trackConnection(toggleContainer.MouseButton1Click:Connect(function()
            isOn = not isOn
            updateToggleVisual()
        end))

        -- Define o estado inicial
        updateToggleVisual()

        return {
            SetToggleText = function(text)
                assert(type(text) == "string", "SetToggleText: text must be a string.")
                toggleLabel.Text = text
            end,
            GetState = function() return isOn end,
            SetState = function(state)
                assert(type(state) == "boolean", "SetState: state must be a boolean.")
                isOn = state; updateToggleVisual()
            end
        }
    end;

    --[[
        Cria uma nova caixa de texto para entrada de dados.
        @param titleText string - O título exibido ao lado da caixa de texto.
        @param defaultValue string - O valor padrão da caixa de texto.
        @param callback function - A função a ser chamada quando o foco da caixa de texto é perdido e o texto é alterado. Recebe o novo texto como argumento.
        @return table - Um objeto com métodos: SetTextboxText(text), GetTextboxText().
    ]]
    function tabMethods:AddTextbox(titleText, defaultValue, callback)
        assert(type(titleText) == "string", "AddTextbox: titleText must be a string.")
        assert(type(defaultValue) == "string" or type(defaultValue) == "number", "AddTextbox: defaultValue must be a string or number.")
        assert(type(callback) == "function" or callback == nil, "AddTextbox: callback must be a function or nil.")

        local textboxContainer = Instance.new("Frame")
        textboxContainer.Name = "TextboxContainer"
        textboxContainer.Parent = self.scrollFrame
        textboxContainer.BackgroundColor3 = _G.ButtonColor
        textboxContainer.Size = UDim2.new(0, 455, 0, 30)
        createCorner(textboxContainer, BUTTON_CORNER_RADIUS)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "TextboxTitle"
        titleLabel.Parent = textboxContainer
        titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1.000
        titleLabel.Position = UDim2.new(0, 15, 0, 0)
        titleLabel.Size = UDim2.new(0, 300, 0, 30)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.Text = titleText
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local textBox = Instance.new("TextBox")
        textBox.Name = "ValueTextbox"
        textBox.Parent = textboxContainer
        textBox.BackgroundColor3 = _G.ButtonColor
        textBox.Position = UDim2.new(0, 310, 0, 5)
        textBox.Size = UDim2.new(0, 140, 0, 20)
        textBox.Font = Enum.Font.GothamSemibold
        textBox.Text = tostring(defaultValue)
        textBox.TextColor3 = Color3.fromRGB(150, 150, 150)
        textBox.TextSize = 11.000
        textBox.TextTruncate = Enum.TextTruncate.AtEnd
        textBox.ClearTextOnFocus = false
        createCorner(textBox, TEXTBOX_CORNER_RADIUS)

        local textBoxStroke = Instance.new("UIStroke")
        textBoxStroke.Parent = textBox
        textBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        textBoxStroke.Color = Color3.fromRGB(50, 50, 50)
        textBoxStroke.LineJoinMode = Enum.LineJoinMode.Round
        textBoxStroke.Thickness = 1
        textBoxStroke.Transparency = 0
        textBoxStroke.Enabled = true

        local originalValue = tostring(defaultValue)

        trackConnection(textBox.FocusLost:Connect(function()
            if #textBox.Text > 0 then
                if type(callback) == "function" then
                    pcall(callback, textBox.Text)
                end
                textBox.TextColor3 = Color3.fromRGB(225, 225, 225)
            else
                textBox.Text = originalValue
                textBox.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end))

        trackConnection(textBox.Focused:Connect(function()
            if textBox.Text == originalValue then
                textBox.Text = ""
                textBox.TextColor3 = Color3.fromRGB(225, 225, 225)
            end
        end))

        return {
            SetTextboxText = function(text)
                assert(type(text) == "string", "SetTextboxText: text must be a string.")
                textBox.Text = text
            end,
            GetTextboxText = function() return textBox.Text end
        }
    end;

    --[[
        Cria um dropdown de múltiplas seleções.
        @param titleText string - O título exibido no dropdown.
        @param initialValues table - Uma tabela de valores selecionados inicialmente.
        @param optionsTable table - Uma tabela de todas as opções disponíveis para seleção.
        @param callback function - A função a ser chamada quando as seleções mudam. Recebe a tabela de seleções atuais como argumento.
        @return table - Um objeto com métodos: GetSelectedOptions(), SetOptions(newOptions).
    ]]
    function tabMethods:AddMultiDropdown(titleText, initialValues, optionsTable, callback)
        assert(type(titleText) == "string", "AddMultiDropdown: titleText must be a string.")
        assert(type(initialValues) == "table" or initialValues == nil, "AddMultiDropdown: initialValues must be a table or nil.")
        assert(type(optionsTable) == "table", "AddMultiDropdown: optionsTable must be a table.")
        assert(type(callback) == "function" or callback == nil, "AddMultiDropdown: callback must be a function or nil.")

        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = "MultiDropdown"
        dropdownContainer.Parent = self.scrollFrame
        dropdownContainer.Active = true
        dropdownContainer.BackgroundColor3 = _G.ButtonColor
        dropdownContainer.ClipsDescendants = true
        dropdownContainer.Size = UDim2.new(0, 455, 0, 30) -- Altura inicial
        createCorner(dropdownContainer, BUTTON_CORNER_RADIUS)

        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownToggle"
        dropdownButton.Parent = dropdownContainer
        dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.BackgroundTransparency = 1.000
        dropdownButton.Size = UDim2.new(0, 455, 0, 30)
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.Text = "" -- Texto será no título
        dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        dropdownButton.TextSize = 14.000

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "DropdownTitle"
        titleLabel.Parent = dropdownContainer
        titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1.000
        titleLabel.Position = UDim2.new(0.028, 0, 0, 0)
        titleLabel.Size = UDim2.new(0, 300, 0, 30)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local dropdownArrow = Instance.new("ImageLabel")
        dropdownArrow.Name = "DropdownArrow"
        dropdownArrow.Parent = dropdownContainer
        dropdownArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownArrow.BackgroundTransparency = 1.000
        dropdownArrow.Position = UDim2.new(0, 425, 0, 5)
        dropdownArrow.Rotation = 0
        dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
        dropdownArrow.Image = EXTERNAL_IDS[8]

        local searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Parent = dropdownContainer
        searchBox.Size = UDim2.new(0.2, 0, 0, 20)
        searchBox.Position = UDim2.new(0, 330, 0.1, -12) -- Posição inicial escondida/no topo
        searchBox.PlaceholderText = "Search..."
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextSize = 11
        searchBox.TextColor3 = Color3.fromRGB(225, 225, 225)
        searchBox.BackgroundColor3 = _G.ButtonColor
        searchBox.Text = ""
        searchBox.Visible = false
        createCorner(searchBox, TEXTBOX_CORNER_RADIUS)

        local searchBoxStroke = Instance.new("UIStroke")
        searchBoxStroke.Parent = searchBox
        searchBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        searchBoxStroke.Color = Color3.fromRGB(50, 50, 50)
        searchBoxStroke.Thickness = 1.2

        local dropdownScroll = Instance.new("ScrollingFrame")
        dropdownScroll.Name = "DropdownScroll"
        dropdownScroll.Parent = dropdownContainer
        dropdownScroll.Active = true
        dropdownScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownScroll.BackgroundTransparency = 1.000
        dropdownScroll.BorderSizePixel = 0
        dropdownScroll.Position = UDim2.new(0, 0, 0, 30)
        dropdownScroll.Size = UDim2.new(0, 455, 0, 135) -- Altura fixa para scroll
        dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 2)
        dropdownScroll.ScrollBarThickness = 4
        dropdownScroll.Visible = false
        dropdownScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        dropdownScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        dropdownScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.Name = "DropdownList"
        dropdownListLayout.Parent = dropdownScroll
        dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownListLayout.Padding = UDim.new(0, 5)

        local dropdownPadding = Instance.new("UIPadding")
        dropdownPadding.Name = "DropdownPadding"
        dropdownPadding.Parent = dropdownScroll
        dropdownPadding.PaddingTop = UDim.new(0, 5)

        local selectedOptions = {}
        if initialValues then
            for _, v in ipairs(initialValues) do table.insert(selectedOptions, v) end
        end

        local isOpen = false
        local optionButtons = {} -- Para referência dos botões de opção

        local function updateTitleText()
            local display = ""
            if #selectedOptions > 0 then
                display = table.concat(selectedOptions, ", ")
                if #display > 20 then -- Limita o tamanho do texto no título
                    display = string.sub(display, 1, 17) .. "..."
                end
            else
                display = "None"
            end
            titleLabel.Text = titleText .. " : " .. display
        end

        local function addOption(optionValue)
            local optionButton = Instance.new("TextButton")
            optionButton.Name = "OptionButton"
            optionButton.Parent = dropdownScroll
            optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            optionButton.BackgroundTransparency = 1.000
            optionButton.Size = UDim2.new(0, 455, 0, 30)
            optionButton.Font = Enum.Font.Gotham
            optionButton.TextColor3 = Color3.fromRGB(225, 225, 225)
            optionButton.TextSize = 11.000
            optionButton.Text = tostring(optionValue)
            optionButtons[optionValue] = optionButton -- Armazena para referência

            local isSelected = table.find(selectedOptions, optionValue) ~= nil
            if isSelected then
                optionButton.TextColor3 = _G.Clickcolor
            end

            trackConnection(optionButton.MouseButton1Click:Connect(function()
                local index = table.find(selectedOptions, optionValue)
                if index then
                    table.remove(selectedOptions, index)
                    TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
                else
                    table.insert(selectedOptions, optionValue)
                    TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
                end
                updateTitleText()
                if type(callback) == "function" then
                    pcall(callback, selectedOptions)
                end
            end))

            trackConnection(optionButton.MouseEnter:Connect(function()
                if table.find(selectedOptions, optionValue) == nil then -- Não muda se já estiver selecionado
                    TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
                end
            end))
            trackConnection(optionButton.MouseLeave:Connect(function()
                if table.find(selectedOptions, optionValue) == nil then
                    TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
                end
            end))
            dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
        end

        trackConnection(dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownScroll.Visible = isOpen
            searchBox.Visible = isOpen

            local targetSize = UDim2.new(0, 455, 0, isOpen and 180 or 30)
            local targetRotation = isOpen and -180 or 0
            local searchBoxTargetPos = UDim2.new(0, 330, 0.1, isOpen and -12 or 2)

            TweenService:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            TweenService:Create(dropdownArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
            TweenService:Create(searchBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = searchBoxTargetPos}):Play()

            if not isOpen then
                searchBox.Text = "" -- Reseta a caixa de pesquisa ao fechar
                for _, btn in pairs(optionButtons) do btn.Visible = true end -- Mostra todas as opções
                dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            end
        end))

        trackConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = string.lower(searchBox.Text)
            for optionValue, optionButton in pairs(optionButtons) do
                optionButton.Visible = string.find(string.lower(tostring(optionValue)), searchText) ~= nil
            end
            dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
        end))

        for _, option in ipairs(optionsTable) do
            addOption(option)
        end
        updateTitleText()

        return {
            GetSelectedOptions = function() return selectedOptions end,
            SetOptions = function(newOptions)
                assert(type(newOptions) == "table", "SetOptions: newOptions must be a table.")
                -- Limpa as opções atuais
                for _, btn in pairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                selectedOptions = {}
                -- Adiciona novas opções
                for _, option in ipairs(newOptions) do addOption(option) end
                updateTitleText()
            end
        }
    end;

    --[[
        Cria um color picker dropdown para seleção de cores.
        @param titleText string - O título exibido no color picker.
        @param initialColor Color3 - A cor inicial do color picker.
        @param callback function - A função a ser chamada quando a cor é alterada. Recebe a nova cor (Color3) como argumento.
        @return table - Um objeto com métodos: GetColor(), SetColor(color).
    ]]
    function tabMethods:AddColorPickerDropdown(titleText, initialColor, callback)
        assert(type(titleText) == "string", "AddColorPickerDropdown: titleText must be a string.")
        assert(typeof(initialColor) == "Color3", "AddColorPickerDropdown: initialColor must be a Color3.")
        assert(type(callback) == "function" or callback == nil, "AddColorPickerDropdown: callback must be a function or nil.")

        local colorPickerContainer = Instance.new("Frame")
        colorPickerContainer.Name = "ColorPickerDropdown"
        colorPickerContainer.Parent = self.scrollFrame
        colorPickerContainer.Active = true
        colorPickerContainer.BackgroundColor3 = _G.ButtonColor
        colorPickerContainer.ClipsDescendants = true
        colorPickerContainer.Size = UDim2.new(0, 455, 0, 30)
        createCorner(colorPickerContainer, BUTTON_CORNER_RADIUS)

        local dropdownToggle = Instance.new("TextButton")
        dropdownToggle.Name = "DropdownToggle"
        dropdownToggle.Parent = colorPickerContainer
        dropdownToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownToggle.BackgroundTransparency = 1.000
        dropdownToggle.Size = UDim2.new(0, 455, 0, 30)
        dropdownToggle.Font = Enum.Font.SourceSans
        dropdownToggle.Text = ""
        dropdownToggle.TextColor3 = Color3.fromRGB(0, 0, 0)
        dropdownToggle.TextSize = 14.000

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "DropdownTitle"
        titleLabel.Parent = colorPickerContainer
        titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1.000
        titleLabel.Position = UDim2.new(0.028, 0, 0, 0)
        titleLabel.Size = UDim2.new(0, 410, 0, 30)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local dropdownArrow = Instance.new("ImageLabel")
        dropdownArrow.Name = "DropdownArrow"
        dropdownArrow.Parent = colorPickerContainer
        dropdownArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownArrow.BackgroundTransparency = 1.000
        dropdownArrow.Position = UDim2.new(0, 425, 0, 5)
        dropdownArrow.Rotation = 0
        dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
        dropdownArrow.Image = EXTERNAL_IDS[8]

        -- Componentes do Color Picker
        local spectrumImage = Instance.new("ImageLabel")
        spectrumImage.Name = "Spectrum"
        spectrumImage.Parent = colorPickerContainer
        spectrumImage.Size = UDim2.new(0, 200, 0, 200)
        spectrumImage.Position = UDim2.new(0, 10, 0, 40)
        spectrumImage.Image = EXTERNAL_IDS[9]
        spectrumImage.BackgroundColor3 = Color3.new(1, 1, 1)
        spectrumImage.ClipsDescendants = true
        spectrumImage.Visible = false
        createCorner(spectrumImage, UDim.new(0, 0)) -- Sem corner radius para o espectro

        local spectrumSelector = Instance.new("ImageLabel")
        spectrumSelector.Size = UDim2.new(0, 10, 0, 10)
        spectrumSelector.AnchorPoint = Vector2.new(0.5, 0.5)
        spectrumSelector.BackgroundTransparency = 1
        spectrumSelector.Image = EXTERNAL_IDS[10]
        spectrumSelector.Parent = spectrumImage

        local hueBar = Instance.new("Frame")
        hueBar.Name = "HueBar"
        hueBar.Parent = colorPickerContainer
        hueBar.Size = UDim2.new(0, 20, 0, 200)
        hueBar.Position = UDim2.new(0, 220, 0, 40)
        hueBar.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
        hueBar.Visible = false
        createCorner(hueBar, UDim.new(0, 0))

        local hueGradient = Instance.new("UIGradient")
        hueGradient.Parent = hueBar
        hueGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.166, Color3.fromHSV(0.166, 1, 1)),
            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.666, Color3.fromHSV(0.666, 1, 1)),
            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        }
        hueGradient.Rotation = 90

        local hueSelector = Instance.new("Frame")
        hueSelector.Size = UDim2.new(1, 0, 0, 10)
        hueSelector.Position = UDim2.new(0, 0, 0.5, -5)
        hueSelector.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        createCorner(hueSelector, UDim.new(0, 0))
        hueSelector.Parent = hueBar

        local previewColorFrame = Instance.new("Frame")
        previewColorFrame.Size = UDim2.new(0, 50, 0, 50)
        previewColorFrame.Position = UDim2.new(0, 250, 0, 40)
        previewColorFrame.BackgroundColor3 = initialColor
        previewColorFrame.Visible = false
        createCorner(previewColorFrame, UDim.new(0, 0))
        previewColorFrame.Parent = colorPickerContainer

        local rTextBox = Instance.new("TextBox")
        rTextBox.Size = UDim2.new(0, 50, 0, 30)
        rTextBox.Position = UDim2.new(0, 250, 0, 110)
        rTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        rTextBox.TextColor3 = Color3.new(1, 1, 1)
        rTextBox.Text = tostring(math.floor(initialColor.R * 255))
        rTextBox.Visible = false
        createCorner(rTextBox, UDim.new(0, 0))
        rTextBox.Parent = colorPickerContainer

        local gTextBox = Instance.new("TextBox")
        gTextBox.Size = UDim2.new(0, 50, 0, 30)
        gTextBox.Position = UDim2.new(0, 250, 0, 155)
        gTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        gTextBox.TextColor3 = Color3.new(1, 1, 1)
        gTextBox.Text = tostring(math.floor(initialColor.G * 255))
        gTextBox.Visible = false
        createCorner(gTextBox, UDim.new(0, 0))
        gTextBox.Parent = colorPickerContainer

        local bTextBox = Instance.new("TextBox")
        bTextBox.Size = UDim2.new(0, 50, 0, 30)
        bTextBox.Position = UDim2.new(0, 250, 0, 200)
        bTextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        bTextBox.TextColor3 = Color3.new(1, 1, 1)
        bTextBox.Text = tostring(math.floor(initialColor.B * 255))
        bTextBox.Visible = false
        createCorner(bTextBox, UDim.new(0, 0))
        bTextBox.Parent = colorPickerContainer

        local currentColor = initialColor
        local isSpectrumDragging = false
        local isHueDragging = false

        local function updateRGBFields(color)
            rTextBox.Text = tostring(math.floor(color.R * 255))
            gTextBox.Text = tostring(math.floor(color.G * 255))
            bTextBox.Text = tostring(math.floor(color.B * 255))
        end

        local function updateColorVisuals()
            previewColorFrame.BackgroundColor3 = currentColor
            titleLabel.Text = titleText .. " : " .. tostring(currentColor)
            updateRGBFields(currentColor)
            if type(callback) == "function" then
                pcall(callback, currentColor)
            end
        end

        local function updateSpectrumSelector()
            local h, s, v = currentColor:ToHSV()
            spectrumSelector.Position = UDim2.new(h, 0, 1 - s, 0)
        end

        local function updateHueSelector()
            local h, s, v = currentColor:ToHSV()
            hueSelector.Position = UDim2.new(0, 0, 1 - v, -5)
        end

        local function calculateSpectrumColor(input)
            local x = math.clamp(input.Position.X - spectrumImage.AbsolutePosition.X, 0, spectrumImage.AbsoluteSize.X)
            local y = math.clamp(input.Position.Y - spectrumImage.AbsolutePosition.Y, 0, spectrumImage.AbsoluteSize.Y)
            spectrumSelector.Position = UDim2.new(0, x, 0, y)

            local hue = x / spectrumImage.AbsoluteSize.X
            local saturation = 1 - (y / spectrumImage.AbsoluteSize.Y)
            local _, _, currentValue = currentColor:ToHSV() -- Extrai o valor V atual
            currentColor = Color3.fromHSV(hue, saturation, currentValue) -- Mantém V
            updateColorVisuals()
        end

        trackConnection(spectrumImage.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSpectrumDragging = true
                calculateSpectrumColor(input)
            end
        end))
        trackConnection(spectrumImage.InputChanged:Connect(function(input)
            if isSpectrumDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                calculateSpectrumColor(input)
            end
        end))
        trackConnection(spectrumImage.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isSpectrumDragging = false
            end
        end))

        local function calculateHueColor(input)
            local y = math.clamp(input.Position.Y - hueBar.AbsolutePosition.Y, 0, hueBar.AbsoluteSize.Y)
            hueSelector.Position = UDim2.new(0, 0, 0, y - 5)

            local value = 1 - (y / hueBar.AbsoluteSize.Y)
            local currentHue, currentSat, _ = currentColor:ToHSV() -- Extrai H e S atuais
            currentColor = Color3.fromHSV(currentHue, currentSat, value) -- Atualiza apenas V
            updateColorVisuals()
        end

        trackConnection(hueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isHueDragging = true
                calculateHueColor(input)
            end
        end))
        trackConnection(hueBar.InputChanged:Connect(function(input)
            if isHueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                calculateHueColor(input)
            end
        end))
        trackConnection(hueBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isHueDragging = false
            end
        end))

        local function updateColorFromRGBFields()
            local r = tonumber(rTextBox.Text) or 0
            local g = tonumber(gTextBox.Text) or 0
            local b = tonumber(bTextBox.Text) or 0

            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)

            currentColor = Color3.new(r / 255, g / 255, b / 255)
            updateSpectrumSelector()
            updateHueSelector()
            updateColorVisuals()
        end

        trackConnection(rTextBox.FocusLost:Connect(updateColorFromRGBFields))
        trackConnection(gTextBox.FocusLost:Connect(updateColorFromRGBFields))
        trackConnection(bTextBox.FocusLost:Connect(updateColorFromRGBFields))

        local isColorPickerOpen = false
        trackConnection(dropdownToggle.MouseButton1Click:Connect(function()
            isColorPickerOpen = not isColorPickerOpen
            spectrumImage.Visible = isColorPickerOpen
            hueBar.Visible = isColorPickerOpen
            previewColorFrame.Visible = isColorPickerOpen
            rTextBox.Visible = isColorPickerOpen
            gTextBox.Visible = isColorPickerOpen
            bTextBox.Visible = isColorPickerOpen

            local targetSize = UDim2.new(0, 455, 0, isColorPickerOpen and 250 or 30)
            local targetRotation = isColorPickerOpen and -180 or 0

            TweenService:Create(colorPickerContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            TweenService:Create(dropdownArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()

            if isColorPickerOpen then
                updateSpectrumSelector()
                updateHueSelector()
                updateColorVisuals()
            end
        end))
        updateColorVisuals() -- Define o texto inicial

        return {
            GetColor = function() return currentColor end,
            SetColor = function(color)
                assert(typeof(color) == "Color3", "SetColor: color must be a Color3.")
                currentColor = color; updateColorVisuals()
            end
        }
    end;

    --[[
        Cria um dropdown de seleção única.
        @param titleText string - O título exibido no dropdown.
        @param initialValue any - O valor selecionado inicialmente.
        @param optionsTable table - Uma tabela de todas as opções disponíveis para seleção.
        @param callback function - A função a ser chamada quando a seleção muda. Recebe o valor selecionado como argumento.
        @return table - Um objeto com métodos: GetSelectedValue(), SetOptions(newOptions), SetSelectedValue(value).
    ]]
    function tabMethods:AddDropdown(titleText, initialValue, optionsTable, callback)
        assert(type(titleText) == "string", "AddDropdown: titleText must be a string.")
        assert(type(optionsTable) == "table", "AddDropdown: optionsTable must be a table.")
        assert(type(callback) == "function" or callback == nil, "AddDropdown: callback must be a function or nil.")

        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = "Dropdown"
        dropdownContainer.Parent = self.scrollFrame
        dropdownContainer.Active = true
        dropdownContainer.BackgroundColor3 = _G.ButtonColor
        dropdownContainer.ClipsDescendants = true
        dropdownContainer.Size = UDim2.new(0, 455, 0, 30)
        createCorner(dropdownContainer, BUTTON_CORNER_RADIUS)

        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownToggle"
        dropdownButton.Parent = dropdownContainer
        dropdownButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownButton.BackgroundTransparency = 1.000
        dropdownButton.Size = UDim2.new(0, 455, 0, 30)
        dropdownButton.Font = Enum.Font.SourceSans
        dropdownButton.Text = ""
        dropdownButton.TextColor3 = Color3.fromRGB(0, 0, 0)
        dropdownButton.TextSize = 14.000

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "DropdownTitle"
        titleLabel.Parent = dropdownContainer
        titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1.000
        titleLabel.Position = UDim2.new(0.028, 0, 0, 0)
        titleLabel.Size = UDim2.new(0, 410, 0, 30)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local dropdownArrow = Instance.new("ImageLabel")
        dropdownArrow.Name = "DropdownArrow"
        dropdownArrow.Parent = dropdownContainer
        dropdownArrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownArrow.BackgroundTransparency = 1.000
        dropdownArrow.Position = UDim2.new(0, 425, 0, 5)
        dropdownArrow.Rotation = 0
        dropdownArrow.Size = UDim2.new(0, 20, 0, 20)
        dropdownArrow.Image = EXTERNAL_IDS[8]

        local searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Parent = dropdownContainer
        searchBox.Size = UDim2.new(0.2, 0, 0, 20)
        searchBox.Position = UDim2.new(0, 330, 0.1, 2)
        searchBox.PlaceholderText = "Search..."
        searchBox.Font = Enum.Font.Gotham
        searchBox.TextSize = 11
        searchBox.TextColor3 = Color3.fromRGB(225, 225, 225)
        searchBox.BackgroundColor3 = _G.ButtonColor
        searchBox.Text = ""
        searchBox.AnchorPoint = Vector2.new(0, 0)
        searchBox.AutomaticSize = Enum.AutomaticSize.None
        searchBox.Visible = false
        createCorner(searchBox, TEXTBOX_CORNER_RADIUS)

        local searchBoxStroke = Instance.new("UIStroke")
        searchBoxStroke.Parent = searchBox
        searchBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        searchBoxStroke.Color = Color3.fromRGB(50, 50, 50)
        searchBoxStroke.Thickness = 1.2

        local dropdownScroll = Instance.new("ScrollingFrame")
        dropdownScroll.Name = "DropdownScroll"
        dropdownScroll.Parent = dropdownContainer
        dropdownScroll.Active = true
        dropdownScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownScroll.BackgroundTransparency = 1.000
        dropdownScroll.BorderSizePixel = 0
        dropdownScroll.Position = UDim2.new(0, 0, 0, 30)
        dropdownScroll.Size = UDim2.new(0, 455, 0, 135)
        dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 2)
        dropdownScroll.ScrollBarThickness = 4
        dropdownScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        dropdownScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        dropdownScroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        dropdownScroll.Visible = false -- Inicia fechado

        local dropdownListLayout = Instance.new("UIListLayout")
        dropdownListLayout.Name = "DropdownList"
        dropdownListLayout.Parent = dropdownScroll
        dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownListLayout.Padding = UDim.new(0, 5)

        local dropdownPadding = Instance.new("UIPadding")
        dropdownPadding.Name = "DropdownPadding"
        dropdownPadding.Parent = dropdownScroll
        dropdownPadding.PaddingTop = UDim.new(0, 5)

        local currentSelectedValue = initialValue
        local isOpen = false
        local optionButtons = {}

        local function updateTitleLabel()
            titleLabel.Text = titleText .. " : " .. tostring(currentSelectedValue)
        end

        local function addOptionButton(optionValue)
            local optionButton = Instance.new("TextButton")
            optionButton.Name = "OptionButton_" .. tostring(optionValue)
            optionButton.Parent = dropdownScroll
            optionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            optionButton.BackgroundTransparency = 1.000
            optionButton.Size = UDim2.new(0, 455, 0, 30)
            optionButton.Font = Enum.Font.Gotham
            optionButton.TextColor3 = Color3.fromRGB(225, 225, 225)
            optionButton.TextSize = 11.000
            optionButton.Text = tostring(optionValue)
            optionButtons[tostring(optionValue)] = optionButton

            if optionValue == currentSelectedValue then
                optionButton.TextColor3 = _G.Clickcolor
            end

            trackConnection(optionButton.MouseEnter:Connect(function()
                TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
            end))
            trackConnection(optionButton.MouseLeave:Connect(function()
                if optionValue ~= currentSelectedValue then
                    TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
                end
            end))
            trackConnection(optionButton.MouseButton1Click:Connect(function()
                -- Resetar a cor do item anteriormente selecionado
                if optionButtons[tostring(currentSelectedValue)] then
                    TweenService:Create(optionButtons[tostring(currentSelectedValue)], TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
                end

                currentSelectedValue = optionValue
                updateTitleLabel()
                if type(callback) == "function" then
                    pcall(callback, currentSelectedValue)
                end
                -- Colore o item recém-selecionado
                TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()

                -- Fecha o dropdown
                isOpen = false
                dropdownScroll.Visible = false
                searchBox.Text = ""
                searchBox.Visible = false
                TweenService:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 455, 0, 30)}):Play()
                TweenService:Create(dropdownArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                for _, btn in pairs(optionButtons) do btn.Visible = true end -- Mostra todas as opções para a próxima abertura
            end))
        end

        trackConnection(dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownScroll.Visible = isOpen
            searchBox.Visible = isOpen

            local targetSize = UDim2.new(0, 455, 0, isOpen and 180 or 30)
            local targetRotation = isOpen and -180 or 0
            local searchBoxTargetPos = UDim2.new(0, 330, 0.1, isOpen and -12 or 2)

            TweenService:Create(dropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            TweenService:Create(dropdownArrow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = targetRotation}):Play()
            TweenService:Create(searchBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = searchBoxTargetPos}):Play()

            if isOpen then
                dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            else
                searchBox.Text = "" -- Reseta a caixa de pesquisa
                for _, btn in pairs(optionButtons) do btn.Visible = true end -- Mostra todas as opções
            end
        end))

        trackConnection(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local searchText = string.lower(searchBox.Text)
            for _, btn in pairs(optionButtons) do
                btn.Visible = string.find(string.lower(btn.Text), searchText) ~= nil
            end
            dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
        end))

        for _, option in ipairs(optionsTable) do
            addOptionButton(option)
        end
        updateTitleLabel()

        return {
            GetSelectedValue = function() return currentSelectedValue end,
            SetOptions = function(newOptionsTable)
                assert(type(newOptionsTable) == "table", "SetOptions: newOptionsTable must be a table.")
                -- Limpa as opções atuais
                for _, btn in pairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                -- Adiciona novas opções
                for _, option in ipairs(newOptionsTable) do addOptionButton(option) end
                dropdownScroll.CanvasSize = UDim2.new(0, 0, 0, dropdownListLayout.AbsoluteContentSize.Y + 10)
            end,
            SetSelectedValue = function(value)
                -- Reseta a cor do item anteriormente selecionado
                if optionButtons[tostring(currentSelectedValue)] then
                    TweenService:Create(optionButtons[tostring(currentSelectedValue)], TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(225, 225, 225)}):Play()
                end
                currentSelectedValue = value
                updateTitleLabel()
                -- Colore o item recém-selecionado
                if optionButtons[tostring(currentSelectedValue)] then
                    TweenService:Create(optionButtons[tostring(currentSelectedValue)], TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = _G.Clickcolor}):Play()
                end
            end
        }
    end;

    --[[
        Cria um slider para seleção de valores numéricos.
        @param titleText string - O título exibido ao lado do slider.
        @param minValue number - O valor mínimo do slider.
        @param maxValue number - O valor máximo do slider.
        @param initialValue number - O valor inicial do slider.
        @param decimalPlaces number - O número de casas decimais para exibir (0 para inteiros).
        @param callback function - A função a ser chamada quando o valor do slider muda. Recebe o novo valor como argumento.
        @return table - Um objeto com métodos: GetValue(), SetValue(value).
    ]]
    function tabMethods:AddSlider(titleText, minValue, maxValue, initialValue, decimalPlaces, callback)
        assert(type(titleText) == "string", "AddSlider: titleText must be a string.")
        assert(type(minValue) == "number", "AddSlider: minValue must be a number.")
        assert(type(maxValue) == "number", "AddSlider: maxValue must be a number.")
        assert(type(initialValue) == "number", "AddSlider: initialValue must be a number.")
        assert(type(decimalPlaces) == "number" or decimalPlaces == nil, "AddSlider: decimalPlaces must be a number or nil.")
        assert(type(callback) == "function" or callback == nil, "AddSlider: callback must be a function or nil.")

        decimalPlaces = decimalPlaces or 0 -- Padrão para inteiros

        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = "Slider"
        sliderContainer.Parent = self.scrollFrame
        sliderContainer.BackgroundColor3 = _G.ButtonColor
        sliderContainer.Size = UDim2.new(0, 455, 0, 40)
        createCorner(sliderContainer, BUTTON_CORNER_RADIUS)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "SliderTitle"
        titleLabel.Parent = sliderContainer
        titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.BackgroundTransparency = 1.000
        titleLabel.Position = UDim2.new(0.028, 0, 0, 0)
        titleLabel.Size = UDim2.new(0, 290, 0, 20)
        titleLabel.Font = Enum.Font.Gotham
        titleLabel.Text = titleText
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "SliderValue"
        valueLabel.Parent = sliderContainer
        valueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.BackgroundTransparency = 1.000
        valueLabel.Position = UDim2.new(0.88, 0, 0, 0)
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        valueLabel.TextSize = 11.000

        local sliderButton = Instance.new("TextButton")
        sliderButton.Name = "SliderButton"
        sliderButton.Parent = sliderContainer
        sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderButton.BackgroundTransparency = 1.000
        sliderButton.Position = UDim2.new(0, 10, 0, 25)
        sliderButton.Size = UDim2.new(0, 435, 0, 5)
        sliderButton.AutoButtonColor = false
        sliderButton.Font = Enum.Font.SourceSans
        sliderButton.Text = ""
        sliderButton.TextSize = 14.000

        local barBackground = Instance.new("Frame")
        barBackground.Name = "BarBackground"
        barBackground.Parent = sliderButton
        barBackground.BackgroundColor3 = _G.ButtonColor
        barBackground.Size = UDim2.new(1, 0, 0, 5)
        createCorner(barBackground, SLIDER_CORNER_RADIUS)

        local barStroke = Instance.new("UIStroke")
        barStroke.Parent = barBackground
        barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        barStroke.Color = Color3.fromRGB(50, 50, 50)
        barStroke.LineJoinMode = Enum.LineJoinMode.Round
        barStroke.Thickness = 1

        local fillBar = Instance.new("Frame")
        fillBar.Name = "FillBar"
        fillBar.Parent = barBackground
        fillBar.BackgroundColor3 = _G.SeparateColor
        fillBar.BackgroundTransparency = 0.5
        createCorner(fillBar, SLIDER_CORNER_RADIUS)

        local circleIndicator = Instance.new("Frame")
        circleIndicator.Name = "CircleIndicator"
        circleIndicator.Parent = fillBar
        circleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circleIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
        circleIndicator.Position = UDim2.new(1, 0, 0.5, 0)
        circleIndicator.Size = UDim2.new(0, 10, 0, 10)
        createCorner(circleIndicator, SLIDER_CORNER_RADIUS)

        local currentSliderValue = math.clamp(initialValue, minValue, maxValue)
        local isDragging = false

        local function updateSliderVisuals()
            local normalizedValue = (currentSliderValue - minValue) / (maxValue - minValue)
            fillBar.Size = UDim2.new(normalizedValue, 0, 1, 0)
            circleIndicator.Position = UDim2.new(1, 0, 0.5, 0)

            local displayValue = decimalPlaces > 0
                and string.format("%." .. decimalPlaces .. "f", currentSliderValue)
                or tostring(math.floor(currentSliderValue))

            valueLabel.Text = displayValue

            if type(callback) == "function" then
                pcall(callback, currentSliderValue)
            end
        end

        trackConnection(sliderButton.MouseButton1Down:Connect(function()
            isDragging = true
        end))
        trackConnection(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end))
        trackConnection(UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = input.Position.X
                local barAbsoluteX = barBackground.AbsolutePosition.X
                local barAbsoluteSizeX = barBackground.AbsoluteSize.X

                local relativeX = math.clamp(mouseX - barAbsoluteX, 0, barAbsoluteSizeX)
                local normalizedValue = relativeX / barAbsoluteSizeX
                local newValue = normalizedValue * (maxValue - minValue) + minValue

                currentSliderValue = newValue
                if decimalPlaces == 0 then -- Força para inteiro se decimalPlaces for 0
                    currentSliderValue = math.floor(currentSliderValue)
                end
                currentSliderValue = math.clamp(currentSliderValue, minValue, maxValue) -- Garante que o valor permaneça dentro do range
                updateSliderVisuals()
            end
        end))

        updateSliderVisuals() -- Define o estado inicial

        return {
            GetValue = function() return currentSliderValue end,
            SetValue = function(value)
                assert(type(value) == "number", "SetValue: value must be a number.")
                currentSliderValue = math.clamp(value, minValue, maxValue);
                if decimalPlaces == 0 then
                    currentSliderValue = math.floor(currentSliderValue)
                end
                updateSliderVisuals()
            end
        }
    end;

    --[[
        Cria um separador com texto.
        @param separatorText string - O texto exibido no separador.
        @return table - Um objeto com o método `SetSeparatorText(text)`.
    ]]
    function tabMethods:AddSeperator(separatorText)
        assert(type(separatorText) == "string", "AddSeperator: separatorText must be a string.")

        local separatorContainer = Instance.new("Frame")
        separatorContainer.Name = "Seperator"
        separatorContainer.Parent = self.scrollFrame
        separatorContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        separatorContainer.BackgroundTransparency = 1.000
        separatorContainer.ClipsDescendants = true
        separatorContainer.Size = UDim2.new(0, 455, 0, 20)
        createCorner(separatorContainer, UI_CORNER_RADIUS)

        local separatorLabel = Instance.new("TextLabel")
        separatorLabel.Name = "SepLabel"
        separatorLabel.Parent = separatorContainer
        separatorLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        separatorLabel.BackgroundTransparency = 1.000
        separatorLabel.Position = UDim2.new(0, 5, 0, 0)
        separatorLabel.Size = UDim2.new(0, 255, 0, 20)
        separatorLabel.Font = Enum.Font.GothamSemibold
        separatorLabel.Text = separatorText
        separatorLabel.TextColor3 = Color3.fromRGB(91, 91, 91)
        separatorLabel.TextXAlignment = Enum.TextXAlignment.Left
        separatorLabel.TextSize = 12.000

        return {
            SetSeparatorText = function(text)
                assert(type(text) == "string", "SetSeparatorText: text must be a string.")
                separatorLabel.Text = text
            end
        }
    end;

    --[[
        Cria uma linha horizontal como separador visual.
    ]]
    function tabMethods:AddLine()
        local lineContainer = Instance.new("Frame")
        lineContainer.Name = "Line"
        lineContainer.Parent = self.scrollFrame
        lineContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        lineContainer.BackgroundTransparency = 1.000
        lineContainer.ClipsDescendants = true
        lineContainer.Size = UDim2.new(0, 455, 0, 20)

        local line = Instance.new("Frame")
        line.Name = "LineVisual"
        line.Parent = lineContainer
        line.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        line.BorderSizePixel = 0
        line.Position = UDim2.new(0, 0, 0, 10)
        line.Size = UDim2.new(0, 455, 0, 2)
    end;

    --[[
        Cria uma label que inclui o avatar do jogador local.
        @param labelText string - O texto principal da label.
        @return table - Um objeto com o método `SetLabelText(text)`.
    ]]
    function tabMethods:AddNLabel(labelText)
        assert(type(labelText) == "string", "AddNLabel: labelText must be a string.")

        local label = Instance.new("TextLabel")
        label.Name = "NLabel"
        label.Parent = self.scrollFrame
        label.BackgroundColor3 = _G.ButtonColor
        label.BackgroundTransparency = 0
        label.Size = UDim2.new(0, 455, 0, 57)
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = Color3.fromRGB(225, 225, 225)
        label.TextSize = 11.000
        label.Text = labelText
        label.TextXAlignment = Enum.TextXAlignment.Left
        createCorner(label, BUTTON_CORNER_RADIUS)

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = label
        padding.Name = "PaddingNLabel"

        local playerAvatar = Instance.new("ImageLabel")
        playerAvatar.Parent = label
        playerAvatar.BackgroundColor3 = Color3.new(1, 1, 1)
        playerAvatar.BorderColor3 = Color3.new(0, 0, 0)
        playerAvatar.BackgroundTransparency = 1.000
        playerAvatar.BorderSizePixel = 0
        playerAvatar.Position = UDim2.new(0.851666677, 0, -0.1, 0)
        playerAvatar.Size = UDim2.new(0, 60, 0, 60)
        playerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Players.LocalPlayer.UserId .. "&width=420&height=420&format=png"

        return {
            SetLabelText = function(text)
                assert(type(text) == "string", "SetLabelText: text must be a string.")
                label.Text = text
            end
        }
    end;

    --[[
        Cria uma label com título e descrição.
        @param title string - O título da label.
        @param description string - A descrição/texto secundário da label.
        @return table - Um objeto com o método `SetDescriptionText(text)`.
    ]]
    function tabMethods:AddLabel(title, description)
        assert(type(title) == "string", "AddLabel: title must be a string.")
        assert(type(description) == "string", "AddLabel: description must be a string.")

        local labelFrame = Instance.new("Frame")
        labelFrame.Name = "LabelFrame"
        labelFrame.Parent = self.scrollFrame
        labelFrame.BackgroundColor3 = _G.ButtonColor
        labelFrame.BackgroundTransparency = 0
        labelFrame.BorderSizePixel = 0
        labelFrame.Size = UDim2.new(0, 455, 0, 35)
        createCorner(labelFrame, BUTTON_CORNER_RADIUS)

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Parent = labelFrame
        titleLabel.BackgroundColor3 = _G.ButtonColor
        titleLabel.BackgroundTransparency = 1
        titleLabel.Size = UDim2.new(0, 455, 0, 35)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        titleLabel.TextSize = 11.000
        titleLabel.Position = UDim2.new(-0.009, 0, -0.2, 0)
        titleLabel.Text = title
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local descriptionLabel = Instance.new("TextLabel")
        descriptionLabel.Name = "Description"
        descriptionLabel.Parent = labelFrame
        descriptionLabel.BackgroundColor3 = _G.ButtonColor
        descriptionLabel.BackgroundTransparency = 1
        descriptionLabel.Size = UDim2.new(0, 455, 0, 35)
        descriptionLabel.Font = Enum.Font.Gotham
        descriptionLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
        descriptionLabel.TextSize = 11.000
        descriptionLabel.Position = UDim2.new(0.014, 0, 0.18, 0)
        descriptionLabel.Text = description
        descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = titleLabel
        padding.Name = "PaddingLabel"

        return {
            SetDescriptionText = function(text)
                assert(type(text) == "string", "SetDescriptionText: text must be a string.")
                descriptionLabel.Text = text
            end
        }
    end;

    --[[
        Cria uma label especial com link para Discord e status do script.
        @param joinDiscordText string - Texto para o convite do Discord.
        @param scriptStatusText string - Texto para o status do script.
        @return table - Um objeto com o método `SetScriptStatus(status, color)`.
    ]]
    function tabMethods:AddLabel2(joinDiscordText, scriptStatusText)
        assert(type(joinDiscordText) == "string", "AddLabel2: joinDiscordText must be a string.")
        assert(type(scriptStatusText) == "string", "AddLabel2: scriptStatusText must be a string.")

        local labelFrame = Instance.new("Frame")
        labelFrame.Name = "LabelFrame2"
        labelFrame.Parent = self.scrollFrame
        labelFrame.BackgroundColor3 = _G.ButtonColor
        labelFrame.BackgroundTransparency = 0
        labelFrame.BorderSizePixel = 0
        labelFrame.Size = UDim2.new(0, 455, 0, 35)
        createCorner(labelFrame, BUTTON_CORNER_RADIUS)

        local joinDiscordLabel = Instance.new("TextLabel")
        joinDiscordLabel.Name = "JoinDiscordTitle"
        joinDiscordLabel.Parent = labelFrame
        joinDiscordLabel.BackgroundColor3 = _G.ButtonColor
        joinDiscordLabel.BackgroundTransparency = 1
        joinDiscordLabel.Size = UDim2.new(0, 455, 0, 35)
        joinDiscordLabel.Font = Enum.Font.GothamBold
        joinDiscordLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        joinDiscordLabel.TextSize = 11.000
        joinDiscordLabel.Position = UDim2.new(-0.009, 0, -0.2, 0)
        joinDiscordLabel.Text = joinDiscordText
        joinDiscordLabel.TextXAlignment = Enum.TextXAlignment.Left

        local scriptStatusLabel = Instance.new("TextLabel")
        scriptStatusLabel.Name = "ScriptStatusTitle"
        scriptStatusLabel.Parent = labelFrame
        scriptStatusLabel.BackgroundColor3 = _G.ButtonColor
        scriptStatusLabel.BackgroundTransparency = 1
        scriptStatusLabel.Size = UDim2.new(0, 455, 0, 35)
        scriptStatusLabel.Font = Enum.Font.Gotham
        scriptStatusLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
        scriptStatusLabel.TextSize = 11.000
        scriptStatusLabel.Position = UDim2.new(0.83, 0, -0.2, 0)
        scriptStatusLabel.Text = scriptStatusText -- Pode ser "Script Status" ou similar
        scriptStatusLabel.TextXAlignment = Enum.TextXAlignment.Left

        local statusIndicator = Instance.new("TextLabel")
        statusIndicator.Name = "ScriptStatusIndicator"
        statusIndicator.Parent = labelFrame
        statusIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        statusIndicator.BackgroundTransparency = 1.000
        statusIndicator.Position = UDim2.new(0.885, 0, 0.48, 0)
        statusIndicator.Size = UDim2.new(0, 15, 0, 15)
        statusIndicator.Font = Enum.Font.GothamBold
        statusIndicator.Text = "Undetected"
        statusIndicator.TextColor3 = Color3.fromRGB(0, 255, 0)
        statusIndicator.TextSize = 12.000

        local discordLinkText = Instance.new("TextLabel")
        discordLinkText.Name = "DiscordLinkText"
        discordLinkText.Parent = labelFrame
        discordLinkText.BackgroundColor3 = _G.ButtonColor
        discordLinkText.BackgroundTransparency = 1
        discordLinkText.Size = UDim2.new(0, 455, 0, 35)
        discordLinkText.Font = Enum.Font.Gotham
        discordLinkText.TextColor3 = Color3.fromRGB(175, 175, 175)
        discordLinkText.TextSize = 11.000
        discordLinkText.Position = UDim2.new(0.014, 0, 0.18, 0)
        discordLinkText.Text = "discord.gg/calamityhub"
        discordLinkText.TextXAlignment = Enum.TextXAlignment.Left

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = joinDiscordLabel
        padding.Name = "PaddingJoinDiscord"

        return {
            SetScriptStatus = function(status, color)
                assert(type(status) == "string", "SetScriptStatus: status must be a string.")
                assert(typeof(color) == "Color3", "SetScriptStatus: color must be a Color3.")
                statusIndicator.Text = status; statusIndicator.TextColor3 = color
            end
        }
    end;

    --[[
        Cria um painel de status exibindo informações do mundo e do jogador.
        @return table - Um objeto com métodos para atualizar as informações: SetWeather(), SetTime(), SetEvent(), SetLuck().
    ]]
    function tabMethods:AddStatusPanel()
        local statusPanel = Instance.new("Frame")
        statusPanel.Name = "StatusPanel"
        statusPanel.Parent = self.scrollFrame
        statusPanel.BackgroundColor3 = _G.ButtonColor
        statusPanel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        statusPanel.BorderSizePixel = 0
        statusPanel.Position = UDim2.new(0.373591274, 0, 0.330402017, 0) -- Posição pode precisar de ajuste
        statusPanel.Size = UDim2.new(0, 455, 0, 165)
        createCorner(statusPanel)

        local avatarContainer = Instance.new("Frame")
        avatarContainer.Name = "AvatarContainer"
        avatarContainer.Parent = statusPanel
        avatarContainer.BackgroundColor3 = _G.SeparateColor
        avatarContainer.BackgroundTransparency = 0.300
        avatarContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
        avatarContainer.BorderSizePixel = 0
        avatarContainer.Position = UDim2.new(0.032738097, 0, 0.0481481478, 0)
        avatarContainer.Size = UDim2.new(0, 100, 0, 100)
        createCorner(avatarContainer, UDim.new(1, 0))

        local playerAvatarImage = Instance.new("ImageLabel")
        playerAvatarImage.Parent = avatarContainer
        playerAvatarImage.BackgroundColor3 = _G.SeparateColor
        playerAvatarImage.BackgroundTransparency = 0.500
        playerAvatarImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
        playerAvatarImage.BorderSizePixel = 0
        playerAvatarImage.Position = UDim2.new(0.0563098155, 0, 0.0785183683, 0)
        playerAvatarImage.Size = UDim2.new(0, 88, 0, 84)
        playerAvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Players.LocalPlayer.UserId .. "&w=420&h=420"
        createCorner(playerAvatarImage, UDim.new(1, 0))

        local avatarStroke = Instance.new("UIStroke")
        avatarStroke.Name = "AvatarStroke"
        avatarStroke.Parent = playerAvatarImage
        avatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        avatarStroke.Color = Color3.fromRGB(30, 30, 30)
        avatarStroke.LineJoinMode = Enum.LineJoinMode.Round
        avatarStroke.Thickness = 1
        avatarStroke.Transparency = 0
        avatarStroke.Enabled = true

        local playerNameLabel = Instance.new("TextLabel")
        playerNameLabel.Parent = statusPanel
        playerNameLabel.BackgroundColor3 = _G.SeparateColor
        playerNameLabel.BackgroundTransparency = 1.000
        playerNameLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        playerNameLabel.BorderSizePixel = 0
        playerNameLabel.Position = UDim2.new(-0.0775641501, 0, 0.585555582, 0)
        playerNameLabel.Size = UDim2.new(0, 200, 0, 50)
        playerNameLabel.Font = Enum.Font.Gotham
        playerNameLabel.Text = hidePlayerNamePart(Players.LocalPlayer.Name, 3, 5)
        playerNameLabel.TextColor3 = _G.SeparateColor
        playerNameLabel.TextSize = 27.000
        playerNameLabel.TextTransparency = 0.500

        local infoBackground = Instance.new("Frame")
        infoBackground.Name = "InfoBackground"
        infoBackground.Parent = statusPanel
        infoBackground.BackgroundColor3 = _G.SeparateColor
        infoBackground.BackgroundTransparency = 0.700
        infoBackground.BorderColor3 = Color3.fromRGB(0, 0, 0)
        infoBackground.BorderSizePixel = 0
        infoBackground.Position = UDim2.new(0.291346163, 0, 0.0870369822, 0)
        infoBackground.Size = UDim2.new(0, 305, 0, 125)
        createCorner(infoBackground)

        local weatherLabel = Instance.new("TextLabel")
        weatherLabel.Name = "WeatherInfo"
        weatherLabel.Parent = infoBackground
        weatherLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        weatherLabel.BackgroundTransparency = 1.000
        weatherLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        weatherLabel.BorderSizePixel = 0
        weatherLabel.Position = UDim2.new(0.0336241627, 0, 0.39362964, 0)
        weatherLabel.Size = UDim2.new(0, 193, 0, 50)
        weatherLabel.Font = Enum.Font.Gotham
        weatherLabel.Text = "🌦️ Current weather: N/A"
        weatherLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
        weatherLabel.TextSize = 14.000
        weatherLabel.TextXAlignment = Enum.TextXAlignment.Left

        local timeLabel = Instance.new("TextLabel")
        timeLabel.Name = "TimeInfo"
        timeLabel.Parent = infoBackground
        timeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        timeLabel.BackgroundTransparency = 1.000
        timeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        timeLabel.BorderSizePixel = 0
        timeLabel.Position = UDim2.new(0.0336241627, 0, -0.00977783184, 0)
        timeLabel.Size = UDim2.new(0, 200, 0, 50)
        timeLabel.Font = Enum.Font.Gotham
        timeLabel.Text = "⏳ Time: N/A | N/A"
        timeLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
        timeLabel.TextSize = 14.000
        timeLabel.TextXAlignment = Enum.TextXAlignment.Left

        local eventLabel = Instance.new("TextLabel")
        eventLabel.Name = "EventInfo"
        eventLabel.Parent = infoBackground
        eventLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        eventLabel.BackgroundTransparency = 1.000
        eventLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        eventLabel.BorderSizePixel = 0
        eventLabel.Position = UDim2.new(0.0336241627, 0, 0.195851803, 0)
        eventLabel.Size = UDim2.new(0, 200, 0, 50)
        eventLabel.Font = Enum.Font.Gotham
        eventLabel.Text = "⚡ Active surge: N/A"
        eventLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
        eventLabel.TextSize = 14.000
        eventLabel.TextXAlignment = Enum.TextXAlignment.Left

        local luckLabel = Instance.new("TextLabel")
        luckLabel.Name = "LuckInfo"
        luckLabel.Parent = infoBackground
        luckLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        luckLabel.BackgroundTransparency = 1.000
        luckLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        luckLabel.BorderSizePixel = 0
        luckLabel.Position = UDim2.new(0.0336241627, 0, 0.58903712, 0)
        luckLabel.Size = UDim2.new(0, 200, 0, 50)
        luckLabel.Font = Enum.Font.Gotham
        luckLabel.TextXAlignment = Enum.TextXAlignment.Left
        luckLabel.Text = "🍀 Server luck: N/A"
        luckLabel.TextColor3 = Color3.fromRGB(226, 226, 226)
        luckLabel.TextSize = 14.000

        -- Atualiza informações do mundo Roblox (acessa ReplicatedStorage diretamente)
        trackConnection(RunService.Heartbeat:Connect(function()
            pcall(function()
                local worldFolder = ReplicatedStorage:FindFirstChild("world")
                if worldFolder then
                    local serverLuck = worldFolder:FindFirstChild("luck_Server")
                    local weather = worldFolder:FindFirstChild("weather")
                    local cycle = worldFolder:FindFirstChild("cycle")
                    local event = worldFolder:FindFirstChild("event")
                    local timeOfDay = Lighting.TimeOfDay

                    weatherLabel.Text = "🌦️ Current weather: " .. tostring(weather and weather.Value or "N/A")
                    timeLabel.Text = "⏳ Time: " .. tostring(cycle and cycle.Value or "N/A") .. " | " .. tostring(timeOfDay)
                    eventLabel.Text = "⚡ Active surge: " .. tostring(event and event.Value or "N/A")
                    luckLabel.Text = "🍀 Server luck: " .. tostring(serverLuck and serverLuck.Value or "N/A")
                end
            end)
        end))

        local joinDiscordButton = Instance.new("TextButton")
        joinDiscordButton.Name = "JoinDiscordButton"
        joinDiscordButton.Parent = statusPanel
        joinDiscordButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218) -- Cor do Discord
        joinDiscordButton.BackgroundTransparency = 1.000
        joinDiscordButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        joinDiscordButton.BorderSizePixel = 0
        joinDiscordButton.Position = UDim2.new(0.592399299, 0, 0.85, 0)
        joinDiscordButton.Size = UDim2.new(0, 80, 0, 21)
        joinDiscordButton.Font = Enum.Font.SourceSans
        joinDiscordButton.Text = "Join the Discord"
        joinDiscordButton.TextColor3 = Color3.fromRGB(121, 175, 255)
        joinDiscordButton.TextSize = 14.000
        createCorner(joinDiscordButton, UDim.new(1, 0))

        trackConnection(joinDiscordButton.MouseButton1Click:Connect(function()
            if joinDiscordButton.Text ~= "Copied" then
                joinDiscordButton.Text = "Copied"
            end
            setclipboard("discord.gg/calamityhub")
            task.wait(1.5)
            if joinDiscordButton.Text ~= "Join the Discord" then
                joinDiscordButton.Text = "Join the Discord"
            end
        end))

        local supportText = Instance.new("TextLabel")
        supportText.Parent = statusPanel
        supportText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        supportText.BackgroundTransparency = 1.000
        supportText.BorderColor3 = Color3.fromRGB(0, 0, 0)
        supportText.BorderSizePixel = 0
        supportText.Position = UDim2.new(0.343452483, 0, 0.76, 0)
        supportText.Size = UDim2.new(0, 141, 0, 50)
        supportText.Font = Enum.Font.SourceSans
        supportText.Text = "Need support?"
        supportText.TextColor3 = Color3.fromRGB(225, 225, 225)
        supportText.TextSize = 14.000

        return {
            SetWeather = function(text) assert(type(text) == "string", "SetWeather: text must be a string."); weatherLabel.Text = text end,
            SetTime = function(text) assert(type(text) == "string", "SetTime: text must be a string."); timeLabel.Text = text end,
            SetEvent = function(text) assert(type(text) == "string", "SetEvent: text must be a string."); eventLabel.Text = text end,
            SetLuck = function(text) assert(type(text) == "string", "SetLuck: text must be a string."); luckLabel.Text = text end
        }
    end;

    -- =========================================================================================
    --                                    MÉTODOS DA JANELA
    -- =========================================================================================

    local windowMethods = {} -- Tabela de métodos para a janela principal

    --[[
        Adiciona uma nova aba à janela.
        @param tabName string - O nome da aba.
        @return table - Um objeto com métodos para adicionar elementos à aba (AddButton, AddToggle, etc.).
    ]]
    function windowMethods:AddTab(tabName)
        assert(type(tabName) == "string", "AddTab: tabName must be a string.")

        local tabButton = Instance.new("TextButton")
        tabButton.Name = "TabButton_" .. tabName
        tabButton.Parent = pageScrollFrame
        tabButton.BackgroundColor3 = _G.ButtonColor
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Position = UDim2.new(0, 0, 1, 0)
        tabButton.Size = UDim2.new(0, 100, 0, 22.7)
        tabButton.AutoButtonColor = false
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Text = "   " .. tabName
        tabButton.TextColor3 = Color3.fromRGB(175, 175, 175)
        tabButton.TextSize = 12.000
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        createCorner(tabButton, BUTTON_CORNER_RADIUS)

        local leftStripe = Instance.new("Frame")
        leftStripe.Name = "LeftStripe"
        leftStripe.Parent = tabButton
        leftStripe.BackgroundColor3 = _G.SeparateColor
        leftStripe.BorderSizePixel = 0
        leftStripe.Position = UDim2.new(0, 0, 0.5, -7.5)
        leftStripe.Size = UDim2.new(0, 4, 0, 0) -- Inicia com tamanho 0
        leftStripe.BackgroundTransparency = 0.3
        leftStripe.Visible = false
        createCorner(leftStripe, BUTTON_CORNER_RADIUS)

        local mainTabFrame = Instance.new("Frame")
        mainTabFrame.Name = "MainTab_" .. tabName
        mainTabFrame.Parent = tabFolder
        mainTabFrame.BackgroundColor3 = _G.BackgroundColor
        mainTabFrame.BorderSizePixel = 0
        mainTabFrame.Position = UDim2.new(0.21, 0, -0.024, 47)
        mainTabFrame.Size = UDim2.new(0, 474, 0, 273)
        mainTabFrame.BackgroundTransparency = 0
        mainTabFrame.Visible = false
        createCorner(mainTabFrame)

        local tabScrollFrame = Instance.new("ScrollingFrame")
        tabScrollFrame.Name = "TabScrollFrame"
        tabScrollFrame.Parent = mainTabFrame
        tabScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabScrollFrame.BackgroundTransparency = 1.000
        tabScrollFrame.BorderSizePixel = 0
        tabScrollFrame.Position = UDim2.new(0, -1, 0, 0)
        tabScrollFrame.Size = UDim2.new(0, 475, 0, 273)
        tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabScrollFrame.ScrollBarThickness = 0
        createCorner(tabScrollFrame)

        local tabListLayout = Instance.new("UIListLayout")
        tabListLayout.Name = "TabList"
        tabListLayout.Parent = tabScrollFrame
        tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabListLayout.Padding = UDim.new(0, 5)

        local tabPadding = Instance.new("UIPadding")
        tabPadding.Name = "TabPadding"
        tabPadding.Parent = tabScrollFrame
        tabPadding.PaddingLeft = UDim.new(0, 10)
        tabPadding.PaddingTop = UDim.new(0, 10)

        -- Passa o scrollFrame para os métodos da aba para que eles saibam onde criar elementos
        local currentTabMethods = setmetatable({scrollFrame = tabScrollFrame}, {__index = tabMethods})

        trackConnection(tabButton.MouseButton1Click:Connect(function()
            -- Esconde todas as outras abas e listras
            for _, child in next, tabFolder:GetChildren() do
                if child:IsA("Frame") and string.find(child.Name, "MainTab_") then
                    child.Visible = false
                end
            end
            for _, button in next, pageScrollFrame:GetChildren() do
                if button:IsA("TextButton") and string.find(button.Name, "TabButton_") then
                    local stripe = button:FindFirstChild("LeftStripe")
                    if stripe then
                        TweenService:Create(stripe, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0, 0)}):Play()
                        stripe.Visible = false
                    end
                    TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
                end
            end

            -- Mostra a aba selecionada e sua listra
            mainTabFrame.Visible = true
            leftStripe.Visible = true
            TweenService:Create(leftStripe, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0, 14)}):Play()
            TweenService:Create(tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        end))

        -- Ajusta o CanvasSize das scroll frames
        trackConnection(RunService.Stepped:Connect(function()
            pageScrollFrame.CanvasSize = UDim2.new(0, 0, 0, pageListLayout.AbsoluteContentSize.Y + 10)
            tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 30)
        end))

        -- Ativa a primeira aba por padrão
        if not currentWindow.firstTabSet then
            currentWindow.firstTabSet = true
            task.spawn(function()
                task.wait(0.1) -- Pequeno delay para garantir que a UI renderizou
                tabButton.MouseButton1Click:Fire()
            end)
        end
        return currentTabMethods
    end;

    --[[
        Define um novo título para a janela da biblioteca.
        @param newTitle string - O novo título da janela.
    ]]
    function windowMethods:SetWindowTitle(newTitle)
        assert(type(newTitle) == "string", "SetWindowTitle: newTitle must be a string.")
        hubNameLabel.Text = newTitle
    end

    --[[
        Destrói a janela da biblioteca e limpa todas as conexões de eventos.
    ]]
    function windowMethods:Destroy()
        cleanupConnections() -- Desconecta todos os eventos
        mainScreenGui:Destroy() -- Destrói a ScreenGui e todos os seus filhos
        local statsFrame = CoreGui:FindFirstChild("StatsFrame")
        if statsFrame then statsFrame.Enabled = false end
        local closeFrame = CoreGui:FindFirstChild("CloseFrame")
        if closeFrame then closeFrame.Enabled = false end
    end

    -- Inicializa a janela como aberta
    openUI()

    return windowMethods
end;

--[[
    Define o tema de cores globais da biblioteca.
    @param colors table - Uma tabela contendo as novas cores (ClickColor, BackgroundColor, SeparateColor, ButtonColor).
                        Exemplo: {ClickColor = Color3.fromRGB(0, 255, 0), BackgroundColor = Color3.fromRGB(10, 10, 10)}
]]
function Library:SetTheme(colors)
    assert(type(colors) == "table", "SetTheme: colors must be a table.")
    if colors.ClickColor then _G.Clickcolor = colors.ClickColor end
    if colors.BackgroundColor then _G.BackgroundColor = colors.BackgroundColor end
    if colors.SeparateColor then _G.SeparateColor = colors.SeparateColor end
    if colors.ButtonColor then _G.ButtonColor = colors.ButtonColor end
    -- Note: UI já renderizada pode precisar de uma chamada de atualização manual
    -- para aplicar as novas cores a todos os elementos. Um sistema de "recarga"
    -- da UI seria necessário para isso, ou reconectar eventos que leem _G.Colors.
end

-- =========================================================================================
--                                    SISTEMA DE STATUS (Inicial)
-- =========================================================================================

-- Limpa instâncias antigas de StatsFrame ou CloseFrame se existirem
for _, child in ipairs(CoreGui:GetChildren()) do
    if child.Name == "StatsFrame" or child.Name == "CloseFrame" then
        child:Destroy()
    end
end

local isGamepadOrTouch = UserInputService:IsGamepadEnabled() or UserInputService.TouchEnabled

if isGamepadOrTouch then -- Se for touch ou gamepad, mostra o CloseFrame (para reabrir a UI)
    local closeFrameGui = Instance.new("ScreenGui")
    closeFrameGui.Name = "CloseFrame"
    closeFrameGui.Parent = CoreGui
    closeFrameGui.Enabled = false -- Começa desativado

    local closeButtonFrame = Instance.new("Frame")
    closeButtonFrame.Parent = closeFrameGui
    closeButtonFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
    closeButtonFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    closeButtonFrame.BorderSizePixel = 0
    closeButtonFrame.Position = UDim2.new(0.304423213, 0, 0.0389447249, 0)
    closeButtonFrame.Size = UDim2.new(0, 60, 0, 60)
    createCorner(closeButtonFrame)

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Parent = closeButtonFrame
    button.Active = true
    button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(-2.17982702e-07, 0, 0, 0)
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Text = ""
    createCorner(button)

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = button
    imageLabel.Size = UDim2.new(0, 30, 0, 30)
    imageLabel.Position = UDim2.new(0, 15, 0, 15)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = EXTERNAL_IDS[#EXTERNAL_IDS] -- Último ID

    local topFrame = Instance.new("Frame")
    topFrame.Name = "Top"
    topFrame.Parent = closeButtonFrame
    topFrame.BackgroundColor3 = Color3.fromRGB(9, 8, 8)
    topFrame.BackgroundTransparency = 1
    topFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    topFrame.BorderSizePixel = 0
    topFrame.Size = UDim2.new(0, 60, 0, 60)

    trackConnection(button.MouseButton1Click:Connect(function()
        local mainScreen = CoreGui:FindFirstChild("CalamityHubScreenGui")
        if mainScreen then
            local mainFrame = mainScreen:FindFirstChild("Main")
            if mainFrame then
                TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)}):Play()
                closeFrameGui.Enabled = false
            end
        end
    end))
    trackConnection(button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end))
    trackConnection(button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
    end))
    makeDraggable(topFrame, closeButtonFrame)
else -- Para Teclado e Mouse (computador)
    local statsFrameGui = Instance.new("ScreenGui")
    statsFrameGui.Name = "StatsFrame"
    statsFrameGui.Parent = CoreGui
    statsFrameGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    statsFrameGui.Enabled = false -- Começa desativado

    local statsPanel = Instance.new("ImageLabel")
    statsPanel.Parent = statsFrameGui
    statsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    statsPanel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    statsPanel.BorderSizePixel = 0
    statsPanel.Position = UDim2.new(0.433932602, 0, 0.0791457295, 0)
    statsPanel.Size = UDim2.new(0, 270, 0, 126)
    statsPanel.Image = EXTERNAL_IDS[1]
    createCorner(statsPanel)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = statsPanel
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0.025925925, 0, -0.0623809583, 0)
    title.Size = UDim2.new(0, 250, 0, 51)
    title.Font = Enum.Font.SourceSansBold
    title.Text = "Calamity Status"
    title.TextColor3 = _G.Clickcolor
    title.TextTransparency = 0.5
    title.TextSize = 14.000

    local serverUptimeLabel = Instance.new("TextLabel")
    serverUptimeLabel.Name = "ServerUptime"
    serverUptimeLabel.Parent = statsPanel
    serverUptimeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    serverUptimeLabel.BackgroundTransparency = 1.000
    serverUptimeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    serverUptimeLabel.BorderSizePixel = 0
    serverUptimeLabel.Position = UDim2.new(0.111111112, 0, 0.374603179, 0)
    serverUptimeLabel.Size = UDim2.new(0, 200, 0, 50)
    serverUptimeLabel.Font = Enum.Font.SourceSans
    serverUptimeLabel.Text = "Server Uptime: N/A" -- Será atualizado
    serverUptimeLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
    serverUptimeLabel.TextSize = 14.000
    serverUptimeLabel.TextWrapped = true
    serverUptimeLabel.AnchorPoint = Vector2.new(0, 0.5)
    serverUptimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local scriptUptimeLabel = Instance.new("TextLabel")
    scriptUptimeLabel.Name = "ScriptUptime"
    scriptUptimeLabel.Parent = statsPanel
    scriptUptimeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scriptUptimeLabel.BackgroundTransparency = 1.000
    scriptUptimeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    scriptUptimeLabel.BorderSizePixel = 0
    scriptUptimeLabel.Size = UDim2.new(0, 200, 0, 50)
    scriptUptimeLabel.Font = Enum.Font.SourceSans
    scriptUptimeLabel.Text = "Script Uptime: 0D 0H 0M"
    scriptUptimeLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
    scriptUptimeLabel.TextSize = 14.000
    scriptUptimeLabel.TextWrapped = true
    scriptUptimeLabel.AnchorPoint = Vector2.new(0, 0.5)
    scriptUptimeLabel.Position = UDim2.new(0, 30, 0.5, 0)
    scriptUptimeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local totalFishPriceLabel = Instance.new("TextLabel")
    totalFishPriceLabel.Name = "TotalFishPrice"
    totalFishPriceLabel.Parent = statsPanel
    totalFishPriceLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    totalFishPriceLabel.BackgroundTransparency = 1.000
    totalFishPriceLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    totalFishPriceLabel.BorderSizePixel = 0
    totalFishPriceLabel.Position = UDim2.new(0.111111112, 0, 0.63476191, 0)
    totalFishPriceLabel.Size = UDim2.new(0, 200, 0, 59)
    totalFishPriceLabel.Font = Enum.Font.SourceSans
    totalFishPriceLabel.Text = "Total Fish Price: 0$"
    totalFishPriceLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
    totalFishPriceLabel.TextSize = 14.000
    totalFishPriceLabel.TextWrapped = true
    totalFishPriceLabel.AnchorPoint = Vector2.new(0, 0.5)
    totalFishPriceLabel.TextXAlignment = Enum.TextXAlignment.Left

    local calamityLogo = Instance.new("ImageLabel")
    calamityLogo.Parent = statsPanel
    calamityLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    calamityLogo.BackgroundTransparency = 1.000
    calamityLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    calamityLogo.BorderSizePixel = 0
    calamityLogo.Position = UDim2.new(0.680740476, 0, -0.0623809583, 0)
    calamityLogo.Size = UDim2.new(0, 100, 0, 51)
    calamityLogo.Image = EXTERNAL_IDS[2]
    calamityLogo.ImageColor3 = _G.Clickcolor
    calamityLogo.ImageTransparency = 0.5

    local currentTimeLabel = Instance.new("TextLabel")
    currentTimeLabel.Name = "Time"
    currentTimeLabel.Parent = statsPanel
    currentTimeLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    currentTimeLabel.BackgroundTransparency = 1.000
    currentTimeLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    currentTimeLabel.BorderSizePixel = 0
    currentTimeLabel.Position = UDim2.new(0.418518513, 0, 0.349206358, 0)
    currentTimeLabel.Size = UDim2.new(0, 200, 0, 59)
    currentTimeLabel.Font = Enum.Font.SourceSansBold
    currentTimeLabel.Text = "00:00"
    currentTimeLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
    currentTimeLabel.TextSize = 16.000

    local openGuiButton = Instance.new("TextButton")
    openGuiButton.Name = "OpenGuiButton"
    openGuiButton.Parent = statsPanel
    openGuiButton.BackgroundColor3 = _G.Clickcolor
    openGuiButton.BackgroundTransparency = 0
    openGuiButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    openGuiButton.BorderSizePixel = 0
    openGuiButton.Position = UDim2.new(0.708518513, 0, 0.08, 0)
    openGuiButton.Size = UDim2.new(0, 60, 0, 20)
    openGuiButton.Font = Enum.Font.SourceSans
    openGuiButton.Text = "Open Gui"
    openGuiButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    openGuiButton.TextSize = 14.000
    openGuiButton.BackgroundTransparency = 0.5
    createCorner(openGuiButton, BUTTON_CORNER_RADIUS)

    trackConnection(openGuiButton.MouseEnter:Connect(function()
        TweenService:Create(openGuiButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(180, 0, 255)}):Play()
    end))
    trackConnection(openGuiButton.MouseLeave:Connect(function()
        TweenService:Create(openGuiButton, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = _G.Clickcolor}):Play()
    end))
    trackConnection(openGuiButton.MouseButton1Click:Connect(function()
        local mainScreen = CoreGui:FindFirstChild("CalamityHubScreenGui")
        if mainScreen then
            local mainFrame = mainScreen:FindFirstChild("Main")
            if mainFrame then
                TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 350)}):Play()
                statsFrameGui.Enabled = false
            end
        end
    end))

    local totalCaughtFishLabel = Instance.new("TextLabel")
    totalCaughtFishLabel.Name = "TotalCaughtFish"
    totalCaughtFishLabel.Parent = statsPanel
    totalCaughtFishLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    totalCaughtFishLabel.BackgroundTransparency = 1.000
    totalCaughtFishLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    totalCaughtFishLabel.BorderSizePixel = 0
    totalCaughtFishLabel.Position = UDim2.new(0.112962958, 0, 0.76, 0)
    totalCaughtFishLabel.Size = UDim2.new(0, 200, 0, 60)
    totalCaughtFishLabel.Font = Enum.Font.SourceSans
    totalCaughtFishLabel.Text = "Total Caught Fish: 0"
    totalCaughtFishLabel.TextColor3 = Color3.fromRGB(243, 243, 243)
    totalCaughtFishLabel.TextSize = 14.000
    totalCaughtFishLabel.TextWrapped = true
    totalCaughtFishLabel.AnchorPoint = Vector2.new(0, 0.5)
    totalCaughtFishLabel.TextXAlignment = Enum.TextXAlignment.Left

    local playerAvatarTiny = Instance.new("ImageLabel")
    playerAvatarTiny.Name = "CalamityLogo"
    playerAvatarTiny.Parent = statsPanel
    playerAvatarTiny.BackgroundColor3 = Color3.new(1, 1, 1)
    playerAvatarTiny.BackgroundTransparency = 1
    playerAvatarTiny.BorderColor3 = Color3.new(0, 0, 0)
    playerAvatarTiny.BorderSizePixel = 0
    playerAvatarTiny.Position = UDim2.new(0.0333333351, 0, 0.0714285746, 0)
    playerAvatarTiny.Size = UDim2.new(0, 20, 0, 18)
    playerAvatarTiny.Image = EXTERNAL_IDS[#EXTERNAL_IDS]

    makeDraggable(title, statsPanel)

    local scriptStartTime = os.time()
    _G.TotalValueFR = 0 -- Mantido para compatibilidade, mas o uso de _G é desencorajado

    -- Otimização do loop de atualização de stats
    local lastPanelStatsUpdate = 0
    trackConnection(RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime - lastPanelStatsUpdate >= 1 then -- Atualiza apenas a cada 1 segundo
            lastPanelStatsUpdate = currentTime
            pcall(function()
                local elapsedSeconds = currentTime - scriptStartTime
                local days = math.floor(elapsedSeconds / (60 * 60 * 24))
                local hours = math.floor(elapsedSeconds / (60 * 60)) % 24
                local minutes = math.floor(elapsedSeconds / 60) % 60

                currentTimeLabel.Text = os.date("%H:%M") -- Apenas hora atual
                scriptUptimeLabel.Text = string.format("Script Uptime: %dD %dH %dM", days, hours, minutes)

                -- Acessando valores da PlayerGui de forma segura
                local serverInfoUptime = getPlayerGuiValue({"serverInfo", "serverInfo", "uptime"})
                serverUptimeLabel.Text = "Server " .. (serverInfoUptime and serverInfoUptime.Text or "N/A")

                local trackerFishCaughtNum = getPlayerGuiValue({"hud", "safezone", "menu", "stats_safezone", "scroll", "Tracker_Fish Caught [Total]", "num"})
                totalCaughtFishLabel.Text = "Total Caught Fish: " .. tostring(trackerFishCaughtNum and trackerFishCaughtNum.Text or "0")

                if game.PlaceId == 72907489978215 then -- Exemplo de PlaceId, ajuste conforme necessário
                    totalFishPriceLabel.Text = "Total Fish Price: " .. _G.TotalValueFR .. "E$"
                else
                    totalFishPriceLabel.Text = "Total Fish Price: " .. _G.TotalValueFR .. "C$"
                end
            end)
        end
    end))
end

-- =========================================================================================
--                                    RETORNO DA BIBLIOTECA
-- =========================================================================================

return Library
