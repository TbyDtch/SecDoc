-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)

-- Store network data
local user = "Connecting..."
local senderID
local listsPacket
local fileListItems = {}
local fileListEnts = {}

-- Our arrays
local cats = {
    [1] = "Ents/",
    [2] = "Items/"
}

local currentList = cats -- Our current array selected

-- Protocol
local PROTOCOL = sd.PROTOCOL_DOCS

-- Movement for arrows
local position = 4

-- Screen slop
local width, height = term.getSize()

-- UI setup
local function UI(name, preLogin, pos, array)
    sd.clean(true)
    sd.header("SecDoc Browser Interface: " .. name)
    if not preLogin then
        -- Stupid bullshit for selection and key guide
        term.setBackgroundColor(colors.gray)
        term.setCursorPos(1,pos)
        sd.spam(" ")

        -- Actual entries (please make it do arrays for dynamic stuff) : (I did that)
        term.setBackgroundColor(colors.black)
        term.setCursorPos(1, 4)
        for i = 1, #array do -- # Prints the size???
            sd.centerText(array[i])
        end
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
            UI(user, false, position, currentList)
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
-- Please add min and max and make dynamic. Refer to (currently unused) array local
while true do
    UI(user, false, position, currentList)
    
    -- Pull the key event INSIDE the loop
    local event, keyCode = os.pullEvent("key")
    
    if keyCode == keys.up then
        if position > 4 then
            position = position - 1
        end
    elseif keyCode == keys.down then
        if position < #currentList + 3 then
            position = position + 1
        end
    elseif keyCode == keys.space then
        if currentList[position - 3] == "Ents/" then
            currentList = fileListEnts
            position = 4
        elseif currentList[position - 3] == "Items/" then
            currentList = fileListItems
            position = 4
        end
    elseif keyCode == keys.left then
        currentList = cats
        position = 4
    end
end