-- Config / Setup
local sd = require("SecDocLib")
local PROTOCOL_DOCS = "SecDocsPacket"
local hits = 0

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        sd.clean(true)
        sd.header("SecDoc Documentation Server")
        sd.centerText("Listening for packets...")
        sd.centerText("Hits: " .. hits)
        hits = hits + 1
        local senderID, docpage = rednet.receive(PROTOCOL_DOCS)
        if senderID then
            local packet = {
                name = "Dr. Bubba",
                index = {}
            }
            rednet.send(senderID, packet, PROTOCOL_DOCS)
            sd.clean(true)
        end
    else
        sd.errorScreen("SecDoc Documentation Server", "NO MODEM FOUND", 10)
    end
end