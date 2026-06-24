-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)

-- Protocols
local protoLogin = sd.PROTOCOL_LOGIN

-- Easy UI Setup / Reset
local function UI()
    sd.clean(true)
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
            rednet.send(10, password, protoLogin)
            local senderID, packet = rednet.receive(protoLogin, 2)
            if senderID == 10 and packet.message == "VALID" then
                sd.clean(true)
                sd.header("VALID PASSWORD")
                sd.centerText("Welcome, " .. packet.info)
                sleep(2)
                sd.clean(true)
                break
            elseif senderID then
                sd.errorScreen("SecDoc Login Service", packet.message, 5)
            elseif not rednet.isOpen() then
                sd.errorScreen("SecDoc Login Service","NO MODEM FOUND",5) -- Kinda bad
            end
        else
            sd.errorScreen("SecDoc Login Service","NO MODEM FOUND",5) -- Kinda bad
        end

    else -- Failed to find modem and reboot
        sd.errorScreen("SecDoc Login Service", "NO MODEM FOUND", 10)
    end
end

shell.run("docBrowse.lua")