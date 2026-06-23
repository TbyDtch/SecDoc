-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)
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
        if rednet.isOpen() then
            rednet.send(10, password, PROTOCOL_LOGIN)
            local senderID, packet = rednet.receive(PROTOCOL_LOGIN)
            if not senderID then -- disable later
                print("failed...")
            end
            if senderID == 10 and packet.message == "VALID" then
                sd.clean(true)
                sd.header("VALID PASSWORD")
                sd.centerText("Welcome, " .. packet.info)
                sleep(5)
                sd.clean(true)
                break
            else
                term.setBackgroundColor(colors.blue)
                sd.clean(false)
                sd.header("ERROR")
                sd.centerText("SERVER: " .. packet.info)
                sleep(5)
                sd.clean(true)
            end
        else
            sd.errorScreen("SecDoc Login Service","NO MODEM FOUND", 10)
        end

    else -- Failed to find modem and reboot
        sd.errorScreen("SecDoc Login Service", "NO MODEM FOUND", 10)
    end
end

shell.run("docBrowse.lua")