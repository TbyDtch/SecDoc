-- Config / Setup
local sd = require("SecDocLib")
local loginCount = 0
local pingCount = 0
local validCount = 0
local PROTOCOL_LOGIN = "SecDocLoginPacket"

-- Start
while true do
    sd.clean()
    peripheral.find("modem",rednet.open)

    if rednet.isOpen() then
        sd.header("SecDoc Login Server")
        print("Listening for pings and logins...")
        print("Ping Count:",pingCount)
        print("Login Count:",loginCount)
        print("Valid Count:",validCount)
        local senderID, message, protocol = rednet.receive(PROTOCOL_LOGIN)
        loginCount = loginCount + 1
        if message == "fart" then
            local packet = {
            message = "VALID",
            name = "Dr. Bubba"
            }
            rednet.send(senderID, packet, PROTOCOL_LOGIN)
            validCount = validCount + 1
        end
    else
        term.setBackgroundColor(colors.blue)
        sd.header("SecDoc Login Server")
        sd.centerText("AN ERROR HAS OCCURED: NO MODEM FOUND")
        sd.centerText("REBOOTING IN 10 SECONDS")
        sleep(10)
    end
end

