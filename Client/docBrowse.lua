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

-- Add these variables right above your while loop
local selectedIndex = 1
local START_Y = 4
local needsRedraw = true

-- A dynamic map to route folder names to their contents
local categoryMap = {
    ["Ents/"] = fileListEnts,
    ["Items/"] = fileListItems
    -- You can easily add more categories here later without touching the loop
}

-- State Initialization (Fixes the startup bug)
local currentList = cats
local selectedIndex = 1
local START_Y = 4
local needsRedraw = true

-- New state variables for file viewing
local viewingFile = false
local currentFileText = ""

local categoryMap = {
    ["Ents/"] = fileListEnts,
    ["Items/"] = fileListItems
}

-- Main Event Loop (I got lazy and drunk here)
while true do
    -- 1. Render based on current state
    if needsRedraw then
        if viewingFile then
            -- Render the file contents
            sd.clean(true)
            sd.header("SecDox Viewer: " .. currentList[selectedIndex])
            
            -- Print the text below the header
            term.setCursorPos(1, 4)
            print(currentFileText)
            
            -- Print a footer for instructions
            term.setCursorPos(1, height)
            term.write("Press LEFT to return")
        else
            -- Render the directory browser
            UI(user, false, selectedIndex + (START_Y - 1), currentList)
        end
        needsRedraw = false
    end
    
    local event, keyCode = os.pullEvent("key")
    
    -- 2. Input routing based on state
    if viewingFile then
        -- When reading a file, restrict inputs to just going back
        if keyCode == keys.left or keyCode == keys.backspace then
            viewingFile = false
            needsRedraw = true
        end
    else
        -- Normal directory navigation
        if keyCode == keys.up then
            if selectedIndex > 1 then
                selectedIndex = selectedIndex - 1
                needsRedraw = true
            end
            
        elseif keyCode == keys.down then
            if selectedIndex < #currentList then
                selectedIndex = selectedIndex + 1
                needsRedraw = true
            end
            
        elseif keyCode == keys.space then
            local selectedString = currentList[selectedIndex]
            
            if categoryMap[selectedString] then
                -- It's a folder: open it
                currentList = categoryMap[selectedString]
                selectedIndex = 1
                needsRedraw = true
            else
                -- It's a file: request it from server 13!
                sd.clean(true)
                sd.header("Fetching " .. selectedString .. "...")
                
                -- Send the request. (You may need to change the payload table 
                -- to match whatever your server script expects to receive)
                rednet.send(13, {"GET_DOC", selectedString}, PROTOCOL)
                
                -- Wait for the server to send the text back
                local id, msg = rednet.receive(PROTOCOL, 2)
                
                if id == 13 and msg then
                    currentFileText = msg
                    viewingFile = true
                    needsRedraw = true
                else
                    -- Timeout: Server didn't respond in 2 seconds.
                    -- You could add an sd.errorScreen here, but for now 
                    -- it just silently kicks you back to the menu.
                    needsRedraw = true
                end
            end
            
        elseif keyCode == keys.left or keyCode == keys.backspace then
            -- Go back to root category list
            if currentList ~= cats then
                currentList = cats
                selectedIndex = 1
                needsRedraw = true
            end
        end
    end
end