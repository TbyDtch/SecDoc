-- Config / Setup
local sd = require("SecDocLib")
local PROTOCOL_DOCS = "SecDocsPacket"
local hits = 0

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        sd.clean()
        sd.header("SecDoc Documentation Server")
        sd.centerText("Listening for packets...")
        sd.centerText("Hits: " .. hits)
        hits = hits + 1
        local senderID, docpage = rednet.receive(PROTOCOL_DOCS)
        local packet = {
            name = "Dr. Bubba"
        }
        rednet.send(senderID, packet)
        sleep(5)
        sd.clean()
        break
    else
        sd.clean()
        term.setBackgroundColor(colors.blue)
        sd.header("SecDoc Documentation Server")
        sd.centerText("AN ERROR HAS OCCURED: NO MODEM FOUND")
        sd.centerText("REBOOTING IN 10 SECONDS")
        sleep(10)
    end
end