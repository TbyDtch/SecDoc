-- Config / Setup
local sd = require("SecDocLib")
local sdd = require("SecDocServerData")

-- Log interactions for debugging and visual pleasure
local loginCount = 0
local validCount = 0

-- Bool to keep tabs on doc server life
local docsOnline

-- Protocol
local protoDocs = sd.PROTOCOL_DOCS
local protoLogin = sd.PROTOCOL_LOGIN


-- Start
while true do
    -- Clean/reset term and check/open rednet
    sd.clean(true)
    peripheral.find("modem", rednet.open)

    if rednet.isOpen() then -- Ensure rednet is open and don't hang

        -- Print screen
        sd.header("SecDoc Login Server")
        sd.centerText("Listening for pings and logins...")
        sd.centerText("Doc Server Live: ".. tostring(docsOnline))
        sd.centerText("Login Count:".. loginCount)
        sd.centerText("Valid Count:".. validCount)

        -- waiting for login packets
        local senderID, password = rednet.receive(protoLogin, 2)
        if senderID then
            loginCount = loginCount + 1
            -- Get password index for user info
            local passID = sd.findStringInList(sdd.passwords, password)
            if passID then -- Safely checks that passID isn't nil
            
                -- Create packet for doc server
                local databasePacket = {
                    pcID = senderID,
                    user = sdd.names[passID]
                }

                -- Speak to doc server and pass the info for user
                rednet.send(13, databasePacket, protoDocs)
                -- Did docs reply?
                for i = 1, 3 do
                    local docsSenderID, reply = rednet.receive(protoDocs, 1)
                    if docsSenderID == 13 and reply then
                        docsOnline = reply
                        break
                    end
                end

                -- Create packet for client and check if docs online
                if docsOnline then
                    local clientPacket = {
                        message = "VALID",
                        info = sdd.names[passID]
                    }
                    -- send to client
                    rednet.send(senderID, clientPacket, protoLogin) 

                -- Docs is offline
                else
                    local clientPacket = {
                        message = "DOCS OFFLINE",
                        info = "DOCS OFFLINE"
                    }
                    -- send to client
                    rednet.send(senderID, clientPacket, protoLogin) 
                end

                validCount = validCount + 1
            else
                local failPacket = {
                    message = "INVALID",
                    info = "INVALID LOGIN"
                }
                rednet.send(senderID, failPacket, protoLogin)
            end
        end
    else
        -- ERROR if modem isn't found
        sd.errorScreen("SecDoc Login Server", "NO MODEM FOUND", 10)
    end
end

