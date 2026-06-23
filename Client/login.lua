-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean()
-- Add startup ping for background security and such
local PROTOCOL_LOGIN = "SecDocLoginPacket"

-- Easy UI Setup / Reset
function UI()
    sd.centerText("Enter Password:")
    term.setBackgroundColor(colors.cyan)
    sd.spam(" ")
    term.setCursorPos(1,1)
end

-- Program start
while true do
    peripheral.find("modem", rednet.open)

    if rednet.isOpen() then
        -- Text slop & read password
        sd.header("SecDoc Login Service")
        UI()
        local password = read("*")

        -- Send password
        rednet.send(10, password, PROTOCOL_LOGIN)
        local senderID, message, protocol = rednet.receive(PROTOCOL_LOGIN)
        if senderID == 10 & message == "VALID" then
            sd.centerText("VALID PASSWORD")
            sleep(5)
            break
        end

    else -- Failed to find modem and reboot
        term.setBackgroundColor(colors.blue)
        sd.header("SecDoc Login Service")
        sd.centerText("AN ERROR HAS OCCURED: NO MODEM FOUND")
        sd.centerText("REBOOTING IN 10 SECONDS")
        sleep(10)
    end
end