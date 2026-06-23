-- Config / Setup
local sd = require("SecDocLib")
local loginCount = 0
local pingCount = 0
local validCount = 0
local PROTOCOL_LOGIN = "SecDocLoginPacket"

-- Start
while true do
    sd.clean(true)
    peripheral.find("modem",rednet.open)

    if rednet.isOpen() then
        sd.header("SecDoc Login Server")
        print("Listening for pings and logins...")
        print("Ping Count:",pingCount)
        print("Login Count:",loginCount)
        print("Valid Count:",validCount)
        local senderID, message = rednet.receive(PROTOCOL_LOGIN)
        loginCount = loginCount + 1
        if message == "fart" then
            local packet = {
            message = "VALID",
            info = "Dr. Bubba"
            }
            rednet.send(senderID, packet, PROTOCOL_LOGIN)
            validCount = validCount + 1
        else
            local packet = {
                message = "INVALID",
                info = "INVALID LOGIN"
            }
            rednet.send(senderID, packet, PROTOCOL_LOGIN)
            loginCount = loginCount + 1
        end
    else
        sd.errorScreen("SecDoc Login Server", "NO MODEM FOUND", 10)
    end
end

