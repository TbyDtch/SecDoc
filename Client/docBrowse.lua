-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean()
local PROTOCOL_DOCS = "SecDocLoginPacket"
local docpage = 0

-- UI setup
function UI(name)
    sd.clear()
    sd.header("SecDoc Browser Interface: " .. name)
end

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        rednet.send(13,  docpage, PROTOCOL_DOCS)
        local senderID, packet = rednet.receive(PROTOCOL_DOCS)
        if senderID == 13 then
            UI(packet.name)
            sleep(5)
            break
        end
    else

    end
end