function get_current_project_path()
    local proj, str = reaper.EnumProjects(-1, "")
    return str
end

-- function get_parent_path(path)
--     local pattern1 = "^(.+)//"
--     local pattern2 = "^(.+)\\"

--     if (string.match(path, pattern1) == nil) then
--         return string.match(path, pattern2)
--     else
--         return string.match(path, pattern1)
--     end
-- end


function get_parent_path(subject, pattern)
    local start_index, end_index = string.find(subject, pattern)
    local new_name = selected_track_name:gsub(mark .. " ", "")
    if start_index ~= nil and end_index ~= nil then
        return true
    else
        return false
    end
end


