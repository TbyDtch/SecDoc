-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)
-- array for docs
local fileList

-- UI setup
local function UI(name)
    sd.clean(true)
    sd.header("SecDoc Browser Interface: " .. name)
end

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        rednet.send(13, "REQUEST", sd.PROTOCOL_DOCS)
        local senderID, user = rednet.receive(sd.PROTOCOL_DOCS)
        if senderID == 13 then
            UI(user)
            senderID, fileList = rednet.receive(sd.PROTOCOL_DOCS)
            if senderID == 13 then
                for index, fileName in ipairs(fileList) do
                    sd.centerText(index .. ":" .. fileName)
                end
            end
            break
        end
    else
        sd.errorScreen("SecDoc Browser Interface: NULL", "NO MODEM FOUND", 10)
    end
end