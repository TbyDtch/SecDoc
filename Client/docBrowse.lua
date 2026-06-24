-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)
sd.clean(true)
-- Store user
local user
local senderID
-- Keys for navigation
local event, keyCode = os.pullEvent("key")
-- array for docs
local listsPacket
local fileListItems
local fileListEnts
-- Movement for arrows
local position = 4

-- UI setup
local function UI(name, preLogin, pos)
    sd.clean(true)
    sd.header("SecDoc Browser Interface: " .. name)
    if not preLogin then
        term.setCursorPos(1,pos)
        sd.spam(" ")
        term.setCursorPos(1,4)
        sd.centerText("Items/")
    end
end

-- Start
while true do
    peripheral.find("modem", rednet.open)
    if rednet.isOpen() then
        rednet.send(13, "REQUEST", sd.PROTOCOL_DOCS)
        senderID, user = rednet.receive(sd.PROTOCOL_DOCS)
        if senderID == 13 then
            UI(user, true, position)
            senderID, listsPacket = rednet.receive(sd.PROTOCOL_DOCS)
            fileListItems = listsPacket.fileListItems
            fileListEnts = listsPacket.fileListEnts
            break
        end
    else
        sd.errorScreen("SecDoc Browser Interface: NULL", "NO MODEM FOUND", 10)
    end
end

while true do
    if keyCode == keys.up then
        if position > 4 then
            position = position - 1
            UI(user, false, position)
        end
    elseif keyCode == keys.down then
        if position < 5 then
            position = position - 1
            UI(user, false, position)
        end
    end
end