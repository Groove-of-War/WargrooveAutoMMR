local Events = require "initialized/events"
local Wargroove = require "wargroove/wargroove"
local io = require "io"
local html = require "html"

local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["mmr_publish"] = Actions.publishMatchData
    dst["mmr_set_match_id"] = Actions.setMatchId
end

function Actions.setMatchId(context)

    Wargroove.spawnUnit( -1, {x=-85, y=-56 }, "soldier", true, "")
    Wargroove.waitFrame()
    local stateUnit = Wargroove.getUnitAt({x=-85, y=-56 })
    Wargroove.setUnitState(stateUnit, "MMR_MatchId", tostring(math.floor(Wargroove.pseudoRandomFromString("MMR") * 4294967295)))
    Wargroove.updateUnit(stateUnit)
    local nameFile = io.open("name.txt", "a+")
    local name = nameFile:read("a*")
    nameFile:close()
    if name == "" then
        Wargroove.showDialogueBox("neutral", "mercia", "Please create a name.txt in your Wargroove install folder and put your username in it", "")
        Wargroove.showDialogueBox("neutral", "mercia", "Your install folder is under Steam->Right click Wargroove->Properties->Browse Local files", "")
    end
    
end

function Actions.isMultiplayer()
    local isMp = 0;
    for i = 0, Wargroove.getNumPlayers(false) - 1 do
        if not Wargroove.isHuman(i) then
            return false
        end
        if Wargroove.isLocalPlayer(i) then
            isMp = isMp + 1;
        end
    end
    print("Player Count: " .. tostring(Wargroove.getNumPlayers(false)))
    return isMp == 1 and Wargroove.getNumPlayers(false) == 2
end

function Actions.publishMatchData(context)

    if Actions.isMultiplayer() then
        local nameFile = io.open("name.txt", "a+")
        local name = nameFile:read("a*")
        nameFile:close()
        local stateUnit = Wargroove.getUnitAt({x=-85, y=-56 } )
        local matchId = Wargroove.getUnitState(stateUnit, "MMR_MatchId")
        print("Name: " .. name)
        local victory = false;
        if Wargroove.isLocalPlayer(0) then
            victory = Wargroove.isPlayerVictorious(0)
        else
            victory = Wargroove.isPlayerVictorious(1)
        end
        if name ~= "" then
            local curlProc = io.popen("curl --location --request POST \"https://groove-of-war-mmr.herokuapp.com/publish\" --header \"Content-Type: application/json\" --data-raw \"{	\\\"authKey\\\": \\\"" .. name .."\\\", \\\"matchId\\\": " .. matchId .. ", \\\"victory\\\": " .. tostring(victory) .. ", \\\"modApiKey\\\": \\\"uEZEyLTRglClnWrie6ObIvo47La5CkDnnFgi18gHrdTxV7n229Sb5EGF3ebEvGjh9ZJ7Ds7FeiIXt4YHYWRk0YuTN2GhcjFAZoA\\\"}\"" , "r")
            local response = curlProc:read("a*")
            print("CURL ran")
            curlProc:close()
            if response == nil or response == "" then
                local htmlFile = io.open("send.html", "w")
                html = string.gsub(html, "<playerName>", name)
                html = string.gsub(html, "<matchId>", tostring(matchId))
                html = string.gsub(html, "<victory>", tostring(victory))
                htmlFile:write(html)
                htmlFile:close()
                local file = io.popen("start \"\" \"file://%cd%\\send.html\" --allow-file-access-from-files" , "r")
                print("HTML file used")
                file:close()
            end
        else
            Wargroove.showDialogueBox("neutral", "mercia", "Please create a name.txt in your Wargroove install folder and put your username in it", "")
            Wargroove.showDialogueBox("neutral", "mercia", "Your install folder is under Steam->Right click Wargroove->Properties->Browse Local files", "")
            Wargroove.showDialogueBox("neutral", "mercia", "This match will have to be entered manually", "")
        end
    end
end

return Actions
