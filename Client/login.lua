-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)

-- Header txt
local header = "SecDoc Login Service"

-- Protocols
local protoLogin = sd.PROTOCOL_LOGIN

-- Easy UI Setup / Reset
local function UI()
    sd.clean(true)
    sd.header("SecDoc Login Service")
    sd.centerText("Enter Password:")
    term.setBackgroundColor(colors.gray)
    sd.spam(" ")
end

-- Call no modem error screen
local function noModem()
    sd.errorScreen(header,"NO MODEM FOUND",5)
end

-- For telling us we can move on (Make it better?)
local valid

-- Program start
while true do
    -- See if we have a modem and check if rednet is open
    peripheral.find("modem", rednet.open)

    if rednet.isOpen() then
        -- Draw UI, set cursor to password bar, and obscure password when typing
        UI()
        term.setCursorPos(1,5)
        local password = read("*") -- Displays text as "*"

        -- Send password to password server
        if rednet.isOpen() then
            rednet.send(10, password, protoLogin) -- ik hardcoded isn't good, but this is for my server and the others aren't programmers

            -- Was modem disconnected?
            if not rednet.isOpen() then
                noModem()
            end

            -- Wait for password server to send something back.
            -- Retry 3 times (6 seconds) and then error with "No response"
            for i = 1, 3 do

                -- Wait for password server packet
                local senderID, packet = rednet.receive(protoLogin, 2)
                if senderID == 10 and packet.message == "VALID" then
                    valid = true
                    break

                -- Server replied, but not with success
                elseif senderID == 10 and packet.message then
                    sd.errorScreen(header, packet.info, 5)
                    break

                -- No reply
                else
                    sd.errorScreen(header, "NO REPLY", 5)
                    break
                end
            end

            -- Break while loop if password returned valid
            -- This feels bad, but it gets the job done
            if valid then
                break
            end
        
        -- Modem was not active or present after password typed
        else
            noModem()
        end

    else -- Failed to find modem on start
        noModem()
    end
end

shell.run("docBrowse.lua")