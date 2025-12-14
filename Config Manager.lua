local httpService = game:GetService("HttpService")

local FlagsManager = {}

FlagsManager.Folder = "3itx"
FlagsManager.Ignore = {}
FlagsManager.Flags = {}
FlagsManager.Library = nil
FlagsManager.Parser = {
    Toggle = {
        Save = function(idx, object)
            return { type = "Toggle", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if FlagsManager.Flags[idx] then
                FlagsManager.Flags[idx]:Set(data.value)
            end
        end,
    },
    Slider = {
        Save = function(idx, object)
            return { type = "Slider", idx = idx, value = tostring(object.Value) }
        end,
        Load = function(idx, data)
            if FlagsManager.Flags[idx] then
                FlagsManager.Flags[idx]:Set(tonumber(data.value))
            end
        end,
    },
    Dropdown = {
        Save = function(idx, object)
            return { type = "Dropdown", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if FlagsManager.Flags[idx] then
                FlagsManager.Flags[idx]:Set(data.value)
            end
        end,
    },
    Bind = {
        Save = function(idx, object)
            return { type = "Bind", idx = idx, value = object.Value }
        end,
        Load = function(idx, data)
            if FlagsManager.Flags[idx] then
                local success = pcall(function()
                    FlagsManager.Flags[idx]:Set(Enum.KeyCode[data.value])
                end)
                if not success then
                    pcall(function()
                        FlagsManager.Flags[idx]:Set(Enum.UserInputType[data.value])
                    end)
                end
            end
        end,
    },
    Colorpicker = {
        Save = function(idx, object)
            return { type = "Colorpicker", idx = idx, value = object.Value:ToHex() }
        end,
        Load = function(idx, data)
            if FlagsManager.Flags[idx] then
                FlagsManager.Flags[idx]:Set(Color3.fromHex(data.value))
            end
        end,
    },
}

function FlagsManager:SetIgnoreIndexes(list)
    for _, key in next, list do
        FlagsManager.Ignore[key] = true
    end
end

function FlagsManager:SetFolder(folder)
    FlagsManager.Folder = folder
    FlagsManager:BuildFolderTree()
end

function FlagsManager:Save(name)
    if not name then
        return false, "no config file is selected"
    end

    local fullPath = FlagsManager.Folder .. "/settings/" .. name .. ".json"

    local data = {
        objects = {},
    }

    for idx, option in next, FlagsManager.Flags do
        if not FlagsManager.Parser[option.Type] then
            continue
        end
        if FlagsManager.Ignore[idx] then
            continue
        end

        table.insert(data.objects, FlagsManager.Parser[option.Type].Save(idx, option))
    end

    local success, encoded = pcall(httpService.JSONEncode, httpService, data)
    if not success then
        return false, "failed to encode data"
    end

    writefile(fullPath, encoded)
    return true
end

function FlagsManager:Load(name)
    if not name then
        return false, "no config file is selected"
    end

    local file = FlagsManager.Folder .. "/settings/" .. name .. ".json"
    if not isfile(file) then
        return false, "invalid file"
    end

    local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
    if not success then
        return false, "decode error"
    end

    for _, option in next, decoded.objects do
        if FlagsManager.Parser[option.type] then
            task.spawn(function()
                FlagsManager.Parser[option.type].Load(option.idx, option)
            end)
        end
    end

    return true
end

function FlagsManager:BuildFolderTree()
    local paths = {
        FlagsManager.Folder,
        FlagsManager.Folder .. "/settings",
    }

    for i = 1, #paths do
        local str = paths[i]
        if not isfolder(str) then
            makefolder(str)
        end
    end
end

function FlagsManager:RefreshConfigList()
    local list = listfiles(FlagsManager.Folder .. "/settings")

    local out = {}
    for i = 1, #list do
        local file = list[i]
        if file:sub(-5) == ".json" then
            local pos = file:find(".json", 1, true)
            local start = pos

            local char = file:sub(pos, pos)
            while char ~= "/" and char ~= "\\" and char ~= "" do
                pos = pos - 1
                char = file:sub(pos, pos)
            end

            if char == "/" or char == "\\" then
                local name = file:sub(pos + 1, start - 1)
                if name ~= "options" then
                    table.insert(out, name)
                end
            end
        end
    end

    return out
end

function FlagsManager:SetLibrary(library)
    FlagsManager.Library = library
    FlagsManager.Flags = library.Flags
end

function FlagsManager:InitSaveSystem(tab)
    local SaveManager_ConfigName = ""

    local ConfigSection = tab:AddSection({
        Title = "Configurations",
        Description = "Section for using your saved configs, or those you copied and added to the sections folder.",
        Default = true,
        Locked = false
    })

    ConfigSection:AddTextbox({
        Title = "Config Name",
        Description = "Before you click on the create config button, enter a name!",
        PlaceHolder = "Enter config name...",
        Default = "",
        Callback = function(val)
            SaveManager_ConfigName = val
        end
    })

    ConfigSection:AddDropdown("SaveManager_ConfigurationList", {
        Title = "Configuration List",
        Description = "List with all configurations from the folder.",
        Options = FlagsManager:RefreshConfigList(),
        Default = "",
    })

    -- ✅ CORREÇÃO: Usar AddGroupButton corretamente
    local ButtonGroup = ConfigSection:AddGroupButton()

    -- ✅ Adicionar botões diretamente no Container do grupo
    ButtonGroup:AddButton({
        Title = "Create Config",
        Variant = "Primary",
        Callback = function()
            local name = SaveManager_ConfigName

            if name:gsub(" ", "") == "" then
                FlagsManager.Library:Notification("Config Manager", "Invalid config name (empty)", 3)
                return
            end

            local success, err = FlagsManager:Save(name)
            if not success then
                FlagsManager.Library:Notification("Config Manager", "Failed to create: " .. tostring(err), 3)
                return
            end

            FlagsManager.Library:Notification("Config Manager", "Config '" .. name .. "' created!", 3)
            
            FlagsManager.Flags.SaveManager_ConfigurationList:Refresh(FlagsManager:RefreshConfigList(), true)
            FlagsManager.Flags.SaveManager_ConfigurationList:Set("")
        end,
    })

    ButtonGroup:AddButton({
        Title = "Load Config",
        Variant = "Outline",
        Callback = function()
            local name = FlagsManager.Flags.SaveManager_ConfigurationList.Value

            if not name or name == "" then
                FlagsManager.Library:Notification("Config Manager", "Select a config first", 3)
                return
            end

            local success, err = FlagsManager:Load(name)
            if not success then
                FlagsManager.Library:Notification("Config Manager", "Failed to load: " .. tostring(err), 3)
                return
            end

            FlagsManager.Library:Notification("Config Manager", "Config '" .. name .. "' loaded!", 3)
        end,
    })

    ButtonGroup:AddButton({
        Title = "Save Config",
        Variant = "Outline",
        Callback = function()
            local name = FlagsManager.Flags.SaveManager_ConfigurationList.Value

            if not name or name == "" then
                FlagsManager.Library:Notification("Config Manager", "Select a config first", 3)
                return
            end

            local success, err = FlagsManager:Save(name)
            if not success then
                FlagsManager.Library:Notification("Config Manager", "Failed to save: " .. tostring(err), 3)
                return
            end

            FlagsManager.Library:Notification("Config Manager", "Config '" .. name .. "' saved!", 3)
        end,
    })

    ButtonGroup:AddButton({
        Title = "Refresh List",
        Variant = "Ghost",
        Callback = function()
            FlagsManager.Flags.SaveManager_ConfigurationList:Refresh(FlagsManager:RefreshConfigList(), true)
            FlagsManager.Flags.SaveManager_ConfigurationList:Set("")
            FlagsManager.Library:Notification("Config Manager", "List refreshed!", 2)
        end,
    })

    FlagsManager:BuildFolderTree()
end

return FlagsManager
