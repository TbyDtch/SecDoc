local secdoc = {} -- Create the library table

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
end

--- Prints with special character and then text : `C:/> Hello`
-- @param text string: the character you'd like to spam
function secdoc.symbol(sym, text)
    print(sym, text)
end

return secdoc -- Crucial: You must return the table at the end