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
end

-- Program start
while true do
    peripheral.find("modem", rednet.open)

    if rednet.isOpen() then
        -- Text slop & read password
        sd.header("SecDoc Login Service")
        UI()
        term.setCursorPos(1,5)
        local password = read("*")

        -- Send password
        rednet.send(10, password, PROTOCOL_LOGIN)
        local senderID, packet = rednet.receive(PROTOCOL_LOGIN)
        if senderID == 10 and packet.message == "VALID" then
            sd.clean()
            sd.centerText("VALID PASSWORD")
            print("\n\n\n")
            sd.centerText("Welcome, " .. packet.info)
            sleep(5)
            sd.clean()
            break
        else
            term.setBackgroundColor(colors.blue)
            sd.clean()
            sd.centerText("ERROR")
            print("\n\n\n")
            sd.centerText("SERVER: " .. packet.info)
            sleep(5)
            sd.clean()
        end

    else -- Failed to find modem and reboot
        term.setBackgroundColor(colors.blue)
        sd.header("SecDoc Login Service")
        sd.centerText("AN ERROR HAS OCCURED: NO MODEM FOUND")
        sd.centerText("REBOOTING IN 10 SECONDS")
        sleep(10)
    end
end

term.shell("docBrowse")