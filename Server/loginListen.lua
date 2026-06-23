-- Config / Setup
local sd = require("SecDocLib")
local sdd = require("SecDocServerData")
-- Log interactions for debugging and visual pleasure
local loginCount = 0
local validCount = 0
-- Protocol for rednet

-- Start
while true do
    sd.clean(true)
    peripheral.find("modem",rednet.open)

    if rednet.isOpen() then -- Ensure rednet is open and don't hang (look into hanging)
        -- Print screen
        sd.header("SecDoc Login Server")
        sd.centerText("Listening for pings and logins...")
        sd.centerText("Login Count:".. loginCount)
        sd.centerText("Valid Count:".. validCount)
        -- waiting for login packets
        local senderID, password = rednet.receive(sd.sd.PROTOCOL_LOGIN)
        loginCount = loginCount + 1
        local passID = sd.findStringInList(sdd.passwords, password)
        if passID then -- Safely checks that passID isn't nil
            -- Create packet for doc server
            local databasePacket = {
                pcID = senderID,
                user = sdd.names[passID]
            }
            rednet.send(13, databasePacket, sd.PROTOCOL_DOCS) -- speak to doc server and pass the ID for user
            -- Create packet for client and send
            local clientPacket = {
                message = "VALID",
                info = sdd.names[passID]
            }
            rednet.send(senderID, clientPacket, sd.sd.PROTOCOL_LOGIN) -- send to client
            validCount = validCount + 1
        else
            local failPacket = {
                message = "INVALID",
                info = "INVALID LOGIN"
            }
            rednet.send(senderID, failPacket, sd.sd.PROTOCOL_LOGIN)
        end
    else
        sd.errorScreen("SecDoc Login Server", "NO MODEM FOUND", 10)
    end
end

