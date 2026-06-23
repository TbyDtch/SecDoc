-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)
local PROTOCOL_DOCS = "SecDocsPacket"
local docpage = 0

-- UI setup
function UI(name)
    sd.clean(true)
    sd.header("SecDoc Browser Interface: " .. name)
end

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        rednet.send(13, docpage, PROTOCOL_DOCS)
        local senderID, packet = rednet.receive(PROTOCOL_DOCS)
        if senderID == 13 then
            UI(packet.name)
            sleep(5)
            break
        end
    else
        sd.errorScreen("SecDoc Browser Interface: NULL", "NO MODEM FOUND", 10)
    end
end