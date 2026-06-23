-- Config / Setup
local sd = require("SecDocLib")
local sdd = require("SecDocServerData")
-- Log interactions for debugging and visual pleasure
local loginCount = 0
local validCount = 0
-- Protocol for rednet
local PROTOCOL_LOGIN = "SecDocLoginPacket"
local PROTOCOL_DOCS = "SecDocsPacket"

-- Start
while true do
    sd.clean(true)
    peripheral.find("modem",rednet.open)

    if rednet.isOpen() then -- Ensure rednet is open and don't hang (look into hanging)
        -- Print screen
        sd.header("SecDoc Login Server")
        print("Listening for pings and logins...")
        print("Login Count:",loginCount)
        print("Valid Count:",validCount)
        -- waiting for login packets
        local senderID, password = rednet.receive(PROTOCOL_LOGIN)
        loginCount = loginCount + 1
        local passID = sd.findStringInList(sdd.passwords, password)
        if passID > 0 then -- If password is valid hardcoded password
            -- Create packet for doc server
            local databasePacket = {
                pcID = senderID,
                userID = passID
            }
            rednet.send(13, databasePacket, PROTOCOL_DOCS) -- speak to doc server and pass the ID for user
            -- Create packet for client and send
            local clientPacket = {
                message = "VALID",
                info = sdd.names[passID]
            }
            rednet.send(senderID, clientPacket, PROTOCOL_LOGIN) -- send to client
            validCount = validCount + 1
        else
            local failPacket = {
                message = "INVALID",
                info = "INVALID LOGIN"
            }
            rednet.send(senderID, failPacket, PROTOCOL_LOGIN)
        end
    else
        sd.errorScreen("SecDoc Login Server", "NO MODEM FOUND", 10)
    end
end

