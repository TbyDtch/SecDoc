-- Config / Setup
local sd = require("SecDocLib")

-- Protocols
local protoDocs = sd.PROTOCOL_DOCS

-- Log interactions for debugging and visual pleasure
local clientHits = 0
local serverHits = 0
local invalidHits = 0

-- Array for files server has
local fileListItems = sd.getFilesFromDir("docs/items")
local fileListEnts = sd.getFilesFromDir("docs/ents")

local function UI()
    sd.clean(true)
    sd.header("SecDoc Database Server")
    sd.centerText("Listening for packets...")
    sd.centerText("Login Server Hits: " .. serverHits)
    sd.centerText("Client Hits: " .. clientHits)
    sd.centerText("Invalid Hits: " .. invalidHits)
end

-- Start
while true do
    local listsPacket = {
        items = fileListItems,
        ents = fileListEnts
    }
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then -- Check if rednet is open
        -- Setup UI
        UI()

        -- Pickup ID from password server and send data to next client
        local senderID, message  = rednet.receive(protoDocs)
        
        -- check to see if we've receive a valid user info handoff and wait for client
        if senderID == 10 then
            rednet.send(senderID, true, protoDocs)
            serverHits = serverHits + 1
            UI()
            -- Take data from password packet
            local pcID = message.pcID
            local user = message.user

            while true do
                local senderID, message  = rednet.receive(protoDocs)
                if senderID == pcID and message == "REQUEST" then
                    clientHits = clientHits + 1
                    UI()
                    rednet.send(senderID, user, protoDocs)
                    rednet.send(senderID, listsPacket, protoDocs)
                    break
                else
                    invalidHits = invalidHits + 1
                end
            end
        end
    else
        sd.errorScreen("SecDoc Documentation Server", "NO MODEM FOUND", 10)
    end
end