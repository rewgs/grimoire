-- This is a function that enables single-line, relative path imports of other lua files.
-- Written by Xenakios in this thread: https://forums.cockos.com/showthread.php?t=174073
function reaDoFile(file)
    local info = debug.getinfo(1, 'S')
    local script_path = info.source:match [[^@?(.*[\/])[^\/]-$]]
    dofile(script_path .. file)
end
-- reaDoFile("modules/file-hierarchy.lua")
-- reaDoFile("modules/helper-functions.lua")
-- reaDoFile("modules/render-tables.lua")
-- reaDoFile("modules/render-functions.lua")


-- expects `file` to be `debug.getinfo(1, 'S')`
function get_file_name(file)
    return file:match("[^/]*.lua$")
end


-- FIXME
function print_function_name()
    -- Prints the name of the currently-running function to the Reaper console.
    -- If function is `main()`, print the name of the file instead.

    local function_name = debug.getinfo(1, "n").name
    local file_name = debug.getinfo(1, "S")

    if function_name == "main" then
        reaper.ShowConsoleMsg("Running function: " .. file_name .. "()\n\n")
    else
        reaper.ShowConsoleMsg("Running function: " .. function_name .. "()\n\n")
    end
end

function strip_whitespace_from_ends(str)
    local stripped_str = str:gsub("^%s*(.-)%s*$", "%1")
    return stripped_str
end

function reaprint(msg)
    reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end
