-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)

-- Store network data
local user = "Connecting..."
local senderID
local listsPacket
local fileListItems = {}
local fileListEnts = {}

-- Protocol
local PROTOCOL = sd.PROTOCOL_DOCS

-- Movement for arrows
local position = 4

-- UI setup
local function UI(name, preLogin, pos)
    sd.clean(true)
    sd.header("SecDoc Browser Interface: " .. name)
    if not preLogin then
        term.setCursorPos(1, pos)
        term.setBackgroundColor(colors.white)
        sd.spam(" ")
        term.setBackgroundColor(colors.black)
        term.setCursorPos(1, 4)
        sd.centerText("Items/")
        sd.centerText("Ents/")
    end
end

-- Draw loading screen so the user doesn't see a black
UI(user, true, position)

-- Connect and get data
peripheral.find("modem", rednet.open)
if rednet.isOpen() then
    -- Try sending until the server replies
    while true do
        rednet.send(13, "REQUEST", PROTOCOL)
        senderID, user = rednet.receive(PROTOCOL, 2) -- 2 second timeout check
        
        if senderID == 13 then
            UI(user, false, position)
            senderID, listsPacket = rednet.receive(PROTOCOL)
            -- Fixed to match server table keys ("items" and "ents")
            fileListItems = listsPacket.items
            fileListEnts = listsPacket.ents
            break
        end
        sleep(0.5) -- Wait before retrying request
    end
else
    sd.errorScreen("SecDoc Browser Interface: NULL", "NO MODEM FOUND", 10)
end

-- Main Event Loop (Merged UI updates and key tracking safely)
while true do
    UI(user, false, position)
    
    -- Pull the key event INSIDE the loop
    local event, keyCode = os.pullEvent("key")
    
    if keyCode == keys.up then
        if position > 4 then
            position = position - 1
        end
    elseif keyCode == keys.down then
        if position < 5 then
            position = position + 1 -- Fixed from minus to plus
        end
    end
end