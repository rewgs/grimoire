-- dofile(reaper.GetResourcePath() .. "/Scripts/rewgs-reaper-scripts/modules/names.lua")

function get_current_project_path()
    local proj, str = reaper.EnumProjects(-1, "")
    return str
end

function get_project_info_as_obj()
    local project_name = reaper.GetProjectName(0)
    local _, project_path = reaper.EnumProjects(-1, "")
    local project_dir = project_path:gsub(project_name, "") -- full path, minus .rpp project name

    local project_info_obj = {
        name = project_name,
        path = project_path,
        dir = project_dir
    }

    return project_info_obj
end

-- TODO: FINISH ME
-- function confirm_project_name_parsing(parsed_project_name)
-- Get values from the user.
--
-- If a caption begins with *, for example "*password", the edit field will not display the input text.
-- Maximum fields is 16. Values are returned as a comma-separated string. Returns false if the
-- user canceled the dialog. You can supply special extra information via additional caption
-- fields: extrawidth=XXX to increase text field width, separator=X to use a different separator
-- for returned fields.
--
-- Lua: boolean retval, string retvals_csv = reaper.GetUserInputs(string title, integer num_inputs, string captions_csv, string retvals_csv)

-- local user_input, retvals_csv = reaper.GetUserInputs(
-- string "Please confirm project name parsing before continuing.",
-- num_inputs, captions_csv, retvals_csv
-- )
-- end

function remove_rpp_from_string(s)
    local start_index_lower, end_index_lower = string.find(s, ".rpp")
    local start_index_upper, end_index_upper = string.find(s, ".RPP")

    if start_index_lower ~= nil and end_index_lower ~= nil then
        return s:gsub("%.rpp", "")
    end
    if start_index_upper ~= nil and end_index_upper ~= nil then
        return s:gsub("%.RPP", "")
    end
end

function parse_project_name()
    -- Returns a table with the following key/value pairs:
    -- project_code
    -- cue_number
    -- cue_name
    -- cue_version
    -- misc_text
    -- exports_folder_name (all of the above, separated by `names.delimiter`)

    -- prints function name
    -- reaper.ShowConsoleMsg("Running function: " .. debug.getinfo(1, "n").name .. "()\n\n")

    local parts = {}
    local parsed_project_name = {}

    -- Removes whitespace from left and right of string
    local sep = names.delimiter:gsub("^%s*(.-)%s*$", "%1") or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(get_project_info_as_obj().name, pattern, function(c) parts[#parts + 1] = c end)

    local previous_part = nil
    for i, part in ipairs(parts) do
        if previous_part ~= sep then
            -- Removes whitespace from left and right of string
            -- Moved this function into `misc.lua` module
            -- local stripped_part = part:gsub("^%s*(.-)%s*$", "%1")
            local stripped_part = strip_whitespace_from_ends(part)
            if i == 1 then
                parsed_project_name.project_code = stripped_part
            elseif i == 2 then
                parsed_project_name.cue_number = stripped_part
            elseif i == 3 then
                parsed_project_name.cue_name = stripped_part
            elseif i == 4 then
                parsed_project_name.cue_version = stripped_part
            elseif i == 5 then
                parsed_project_name.misc_text = remove_rpp_from_string(stripped_part)
            else
                reaper.ShowConsoleMsg(
                    "This Reaper project's file name might not be following the correct naming convention. Potentially problematic part of the text: " ..
                    tostring(part[i]) .. ". Check the file name and then try again."
                )
            end
        end
        previous_part = part
    end
    parsed_project_name.exports_folder_name = parsed_project_name.project_code .. names.delimiter ..
        parsed_project_name.cue_number .. names.delimiter ..
        parsed_project_name.cue_name .. names.delimiter ..
        parsed_project_name.cue_version

    -- debug
    -- for key, value in pairs(parsed_project_name) do
    --     reaper.ShowConsoleMsg(key .. ": " .. value .. '\n')
    -- end

    return parsed_project_name
end
