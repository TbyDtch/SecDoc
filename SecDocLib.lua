local secdoc = {} -- Create the library table

-- Protocols
secdoc.PROTOCOL_LOGIN = "SecDocLoginPacket"
secdoc.SecDocsPacket = "SecDocsPacket"

-- Backup the original pullEvent function
local nativePullEventRaw = os.pullEventRaw

--- Centers text horizontally on the screen
-- @param text string: The message to print
function secdoc.centerText(text)
    local width, height = term.getSize()
    local x = math.floor((width - string.len(text)) / 2) + 1
    local _, y = term.getCursorPos()
    
    term.setCursorPos(x, y)
    print(text)
end

--- Toggles termination blocking on or off
-- @param shouldBlock boolean: true to block Ctrl+T/GUI termination, false to unblock
function secdoc.terminateBlock(shouldBlock)
    if shouldBlock then
        -- Override pullEventRaw to filter out "terminate"
        os.pullEventRaw = function()
            while true do
                local eventData = { nativePullEventRaw() }
                if eventData[1] ~= "terminate" then
                    return table.unpack(eventData)
                end
            end
        end
        os.pullEvent = os.pullEventRaw
    else
        -- Restore original functions
        os.pullEventRaw = nativePullEventRaw
        os.pullEvent = nativePullEventRaw
    end
end

--- Spams a character across one line of the screen
-- @param text string: the character you'd like to spam
function secdoc.spam(text)
    -- Get terminal size for spam
    local width, height = term.getSize()
    
    -- Loop character across screen and then next line
    for i = 1, width do
        write(text)
    end
    print()
    print()
end

--- Prints with special character and then text : `C:/> Hello`
-- @param text string: the character you'd like to spam
function secdoc.symbol(sym, text)
    print(sym, text)
end

function secdoc.header(title)
    secdoc.centerText(title)
    secdoc.spam("=")
end

--- Cleans console in one line
-- @param boolean color: clears color too
function secdoc.clean(color)
    if(color) then
        term.setBackgroundColor(colors.black)
    end
    term.clear()
    term.setCursorPos(1,1)
end

--- ERROR Codes
function secdoc.errorScreen(header, errortxt, time)
    term.setBackgroundColor(colors.blue)
    secdoc.clean(false)
    secdoc.header(header)
    secdoc.centerText("AN ERROR HAS OCCURED: " .. errortxt)
    secdoc.centerText("REBOOTING IN " .. time .. " SECONDS")
    sleep(time)
    secdoc.clean(true)
end

function secdoc.findStringInList(targetList, searchString)
    for index, value in ipairs(targetList) do
        if value == searchString then
            return index -- Found it! Return the position
        end
    end
    return nil -- Return nil if the string isn't in the list
end

-- Reusable function to get all files in a directory
function secdoc.getFilesFromDir(directoryPath)
    local fileArray = {}
    
    -- Default to root if no path is provided
    directoryPath = directoryPath or "" 

    if fs.exists(directoryPath) and fs.isDir(directoryPath) then
        local allItems = fs.list(directoryPath)
        
        for _, name in ipairs(allItems) do
            local fullPath = fs.combine(directoryPath, name)
            
            -- Only save actual files, skipping sub-folders
            if not fs.isDir(fullPath) then
                table.insert(fileArray, name)
            end
        end
    end
    
    return fileArray
end

return secdoc -- Crucial: You must return the table at the end