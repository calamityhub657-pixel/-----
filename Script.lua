local Games = {
    [136801880565837] = "Flick.lua",
    [123557829667240] = "Cut%20down%20your%20tree.lua"
}

local BaseURL = "https://raw.githubusercontent.com/calamityhub657-pixel/-----/refs/heads/main/Games/"

local ScriptName = Games[game.PlaceId]
if ScriptName then
    loadstring(game:HttpGet(BaseURL .. ScriptName))()
end
