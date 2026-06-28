-- Config / Setup
local sd = require("SecDocLib")
sd.terminateBlock(true)

-- Store network data
local user = "Connecting..."
local senderID
local listsPacket
local fileListItems = {}
local fileListEnts = {}

-- Our arrays (Kept uppercase for UI visuals if preferred, or lowercase to match fs)
local cats = {
    [1] = "ents/",
    [2] = "items/"
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
    ["ents/"] = fileListEnts,
    ["items/"] = fileListItems
}

-- State Initialization
local currentList = cats
local selectedIndex = 1
local START_Y = 4
local needsRedraw = true
local currentCategoryPrefix = "" -- ADD THIS LINE HERE

local viewingFile = false
local fileLines = {}       
local scrollOffset = 0     
local maxDisplayLines = height - 5

local function wrapAndSplitText(text, maxWidth)
    local lines = {}
    
    -- Force-convert any literal "\n" text sequences into true newline characters
    text = string.gsub(text, "\\n", "\n")
    
    -- Split the text into lines based on physical newline characters (\n)
    for rawLine in string.gmatch(text .. "\n", "([^\n]*)\n") do
        if #rawLine == 0 then
            -- Preserve blank lines/paragraphs
            table.insert(lines, "")
        else
            -- If a line is too long for the monitor, wrap it chunk-by-chunk
            local remainingText = rawLine
            while #remainingText > 0 do
                if #remainingText <= maxWidth then
                    table.insert(lines, remainingText)
                    break
                else
                    local chunk = string.sub(remainingText, 1, maxWidth)
                    table.insert(lines, chunk)
                    remainingText = string.sub(remainingText, maxWidth + 1)
                end
            end
        end
    end
    
    return lines
end

-- Main Event Loop
while true do
    -- 1. Render based on current state
    if needsRedraw then
        if viewingFile then
            sd.clean(true)
            sd.header("SecDox Viewer: " .. currentList[selectedIndex])
            
            local startLine = 1 + scrollOffset
            local endLine = math.min(#fileLines, startLine + maxDisplayLines)
            
            local currentY = 4
            for i = startLine, endLine do
                term.setCursorPos(1, currentY)
                term.clearLine() 
                term.write(fileLines[i])
                currentY = currentY + 1
            end
            
            if currentY <= height - 2 then
                for y = currentY, height - 2 do
                    term.setCursorPos(1, y)
                    term.clearLine()
                end
            end
            
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(1, height)
            term.clearLine()
            
            local footerText = "LEFT: Return"
            if #fileLines > maxDisplayLines then
                local maxScroll = #fileLines - maxDisplayLines
                footerText = footerText .. " | UP/DOWN: Scroll (" .. scrollOffset .. "/" .. maxScroll .. ")"
            end
            term.write(footerText)
            term.setBackgroundColor(colors.black)
        else
            -- Render the directory browser
            UI(user, false, selectedIndex + (START_Y - 1), currentList)
            
            -- Add an expanded guide menu bar to the footer
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(1, height)
            term.clearLine()
            if currentList == cats then
                term.write("R: Refresh List | W: Write New Doc")
            else
                term.write("LEFT/BACKSPACE: Go Back To Main Menu")
            end
            term.setBackgroundColor(colors.black)
        end
        needsRedraw = false
    end
    
    local event, keyCode = os.pullEvent("key")
    
    -- 2. Input routing based on state
    if viewingFile then
        if keyCode == keys.up then
            if scrollOffset > 0 then
                scrollOffset = scrollOffset - 1
                needsRedraw = true
            end
            
        elseif keyCode == keys.down then
            local maxScroll = #fileLines - maxDisplayLines
            if scrollOffset < maxScroll then
                scrollOffset = scrollOffset + 1
                needsRedraw = true
            end
            
        elseif keyCode == keys.left or keyCode == keys.backspace then
            viewingFile = false
            scrollOffset = 0
            fileLines = {}
            needsRedraw = true
            sleep(.2)
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
            
        elseif keyCode == keys.r then
            sd.clean(true)
            sd.header("Refreshing database...")
            print("Fetching updated file lists...")
            
            rednet.send(13, "REFRESH", PROTOCOL)
            local id, listsPacket = rednet.receive(PROTOCOL, 2)
            
            if id == 13 and listsPacket then
                fileListItems = listsPacket.items
                fileListEnts = listsPacket.ents
                categoryMap = {
                    ["Ents/"] = fileListEnts,
                    ["Items/"] = fileListItems
                }
                currentList = cats
                selectedIndex = 1
                currentCategoryPrefix = ""
                print("Successfully updated!")
                sleep(0.5)
            else
                print("Refresh failed: Server timed out.")
                sleep(1)
            end
            needsRedraw = true

        -- NEW FEATURE: WRITE DOCUMENT INTERFACE
        elseif keyCode == keys.w and currentList == cats then
            sd.clean(true)
            sd.header("SecDox: Create Document")
            
            -- Step 1: Select Folder Directory Destination
            print("Select target destination folder:")
            print("1. Ents/")
            print("2. Items/")
            write("Choice (1-2): ")
            sleep(.25)
            local folderChoice = read()
            
            local targetPrefix = ""
            if folderChoice == "1" then 
                targetPrefix = "ents/" 
            elseif folderChoice == "2" then 
                targetPrefix = "items/" 
            end
            
            if targetPrefix ~= "" then
                -- Step 2: Get a File Name
                print("\nEnter filename (e.g., scp_173.txt):")
                write("Name: ")
                local filename = read()
                
                if #filename > 0 then
                    -- Step 3: Input content string
                    print("\nEnter text content (use \\n for newlines):")
                    write("> ")
                    local contentInput = read()
                    
                    -- Clean text format swap
                    contentInput = string.gsub(contentInput, "\\n", "\n")
                    
                    local combinedPath = targetPrefix .. filename
                    print("\nUploading " .. combinedPath .. " to database...")
                    
                    -- Send save request payload data down rednet wire
                    rednet.send(13, {"SAVE_DOC", combinedPath, contentInput}, PROTOCOL)
                    
                    local id, statusResponse = rednet.receive(PROTOCOL, 3)
                    if id == 13 and type(statusResponse) == "table" and statusResponse[1] == "SAVE_STATUS" then
                        if statusResponse[2] == true then
                            print("Success: Document saved on server.")
                        else
                            print("Error: Server failed to write document to disk.")
                        end
                    else
                        print("Error: Server communication timeout.")
                    end
                else
                    print("Cancelled: Filename cannot be empty.")
                end
            else
                print("Cancelled: Invalid folder destination option choice.")
            end
            
            -- Automatically force a menu refresh to sync arrays up right away
            print("\nUpdating index cache...")
            rednet.send(13, "REFRESH", PROTOCOL)
            local id, listsPacket = rednet.receive(PROTOCOL, 2)
            if id == 13 and listsPacket then
                fileListItems = listsPacket.items
                fileListEnts = listsPacket.ents
                categoryMap = { ["ents/"] = fileListEnts, ["items/"] = fileListItems }
            end
            
            currentList = cats
            selectedIndex = 1
            currentCategoryPrefix = "" -- Ensure there is no 'local' keyword here
            sleep(1.5)
            needsRedraw = true
            
        elseif keyCode == keys.space then
            local selectedString = currentList[selectedIndex]
            
            if categoryMap[selectedString] then
                currentCategoryPrefix = selectedString
                currentList = categoryMap[selectedString]
                selectedIndex = 1
                needsRedraw = true
            else
                local fullPath = currentCategoryPrefix .. selectedString
                
                sd.clean(true)
                sd.header("Fetching " .. fullPath .. "...")
                
                print("Requesting: " .. fullPath)
                rednet.send(13, {"GET_DOC", fullPath}, PROTOCOL)
                
                local id, msg = rednet.receive(PROTOCOL, 2)
                
                if id == 13 and msg then
                    fileLines = wrapAndSplitText(msg, width)
                    scrollOffset = 0
                    viewingFile = true
                    needsRedraw = true
                else
                    needsRedraw = true
                end
            end
            sleep(.2)
            
        elseif keyCode == keys.left or keyCode == keys.backspace then
            if currentList ~= cats then
                currentList = cats
                currentCategoryPrefix = ""
                selectedIndex = 1
                needsRedraw = true
                sleep(.2)
            end
        end
    end
end