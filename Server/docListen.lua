-- Config / Setup
local sd = require("SecDocLib")
local sdd = require("SecDocServerData")
-- Protocol for rednet
local PROTOCOL_DOCS = "SecDocsPacket"
-- Log interactions for debugging and visual pleasure
local clientHits = 0
local serverHits = 0

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then -- Check if rednet is open
        -- Setup UI
        sd.clean(true)
        sd.header("SecDoc Database Server")
        sd.centerText("Listening for packets...")
        sd.centerText("Login Server Hits: " .. serverHits)
        sd.centerText("Client Hits: " .. clientHits)
        -- Pickup ID from password server and send data to next client
        local senderID, loginPacket  = rednet.receive(PROTOCOL_DOCS)
        -- check to see if we've receive a valid user info handoff and wait for client
        if senderID == 10 then
            -- Take data from password packet
            local pcID = loginPacket.ID
            local userID = loginPacket.passID

            while true do
                local senderID  = rednet.receive(PROTOCOL_DOCS)
                if senderID == pcID then
                    rednet.send(senderID,sdd.names[userID])
                    break
                end
            end
        end
    else
        sd.errorScreen("SecDoc Documentation Server", "NO MODEM FOUND", 10)
    end
end