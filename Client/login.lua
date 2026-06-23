-- Config / Setup
local sd = require("SecDocLib")

-- Easy UI Setup / Reset
function UI()
    term.clear()
    term.setCursorPos(1,1)
    sd.centerText("SecDoc OS Server Login")
    sd.spam("=")
    print()
    sd.centerText("Enter Password:")
    term.setBackgroundColor(colors.cyan)
    write()
end