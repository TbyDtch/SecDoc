-- Config / Setup
local sd = require("SecDocLib")
local loginCount
local pingCount
local validCount
local PROTOCOL_LOGIN = "SecDocLoginPacket"

-- Start
while true do
    sd.clean()
    peripheral.find("modem",rednet.open)

    if rednet.isOpen() then
        sd.header("SecDoc Login Server")
        print()
        print("Listening for pings and logins...")
        print("Ping Count:",pingCount)
        print("Login Count:",loginCount)
        print("Valid Count:",validCount)
        local senderID, message, protocol = rednet.receive(PROTOCOL_LOGIN)
        loginCount = loginCount + 1
        if message == "fart" then
            rednet.send(senderID, "VALID", PROTOCOL_LOGIN)
            validCount = validCount + 1
        end
    else
        term.setBackgroundColor(colors.blue)
        sd.header("SecDoc Login Server")
        print()
        sd.centerText("AN ERROR HAS OCCURED: NO MODEM FOUND")
        sd.centerText("REBOOTING IN 10 SECONDS")
        sleep(10)
    end
end

