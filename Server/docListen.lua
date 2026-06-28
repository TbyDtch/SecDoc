-- Config / Setup
local sd = require("SecDocLib")

-- Protocols
local protoDocs = sd.PROTOCOL_DOCS

-- Log interactions for debugging and visual pleasure
local clientHits = 0
local serverHits = 0
local invalidHits = 0

-- Track active authenticated sessions: [computerID] = username
local activeSessions = {}

local function UI()
    sd.clean(true)
    sd.header("SecDoc Database Server")
    sd.centerText("Listening for packets...")
    sd.centerText("Login Server Hits: " .. serverHits)
    sd.centerText("Client Logins: " .. clientHits)
    sd.centerText("Invalid Hits: " .. invalidHits)
end

-- Helper to safely get lists
local function getDirectoryLists()
    return {
        items = sd.getFilesFromDir("docs/items"),
        ents = sd.getFilesFromDir("docs/ents")
    }
end

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        UI()

        -- Listen globally for any incoming packet without timing out
        local senderID, message = rednet.receive(protoDocs)
        
        if senderID then
            -- CASE 1: Auth server (ID 10) is broadcasting a new authenticated client session
            if senderID == 10 and type(message) == "table" and message.pcID and message.user then
                rednet.send(senderID, true, protoDocs)
                activeSessions[message.pcID] = message.user -- Register session
                serverHits = serverHits + 1
                UI()

            -- CASE 2: Message is coming from an actively registered client session
            elseif activeSessions[senderID] then
                local user = activeSessions[senderID]

                if message == "REQUEST" then
                    clientHits = clientHits + 1
                    UI()
                    rednet.send(senderID, user, protoDocs)
                    rednet.send(senderID, getDirectoryLists(), protoDocs)
                    
                elseif message == "REFRESH" then
                    rednet.send(senderID, getDirectoryLists(), protoDocs)

                elseif type(message) == "table" and message[1] == "GET_DOC" then
                    -- Sanitize path to lowercase to match Ubuntu file system storage structure
                    local requestedPath = string.lower(message[2])
                    local fileData = "Error: File not found or unreadable."
                    local fullPath = "docs/" .. requestedPath
                    
                    if fs.exists(fullPath) and not fs.isDir(fullPath) then
                        local file = fs.open(fullPath, "r")
                        if file then
                            fileData = file.readAll()
                            file.close()
                        end
                    end
                    rednet.send(senderID, fileData, protoDocs)
                    UI()

                elseif type(message) == "table" and message[1] == "SAVE_DOC" then
                    -- Convert target prefix pathing to lowercase for safety
                    local savePath = "docs/" .. string.lower(message[2])
                    local content = message[3]
                    
                    local success = false
                    local file = fs.open(savePath, "w")
                    if file then
                        file.write(content)
                        file.close()
                        success = true
                    end
                    
                    rednet.send(senderID, { "SAVE_STATUS", success }, protoDocs)
                    UI()
                end

            -- CASE 3: Packet received, but computer ID is unauthorized/not logged in
            else
                invalidHits = invalidHits + 1
                UI()
            end
        end
    else
        sd.errorScreen("SecDoc Documentation Server", "NO MODEM FOUND", 10)
    end
end