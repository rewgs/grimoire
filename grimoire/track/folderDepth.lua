---FolderDepth defines a common interface for folder depth objects.
---The ReaScript API defines several folder depth values:
---I_FOLDERDEPTH : int * : folder depth change, 0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder, -2=track is the last in the innermost and next-innermost folders, etc
---This class makes the folder depth values more readable by providing a description for each integer value.
---@class FolderDepth
---@field num integer
---@field desc string | nil
local FolderDepth = {}

local desc = {
    { num = 0,  desc = "Normal track" },
    { num = 1,  desc = "Folder parent track" },
    { num = -1, desc = "Last track in innermost folder" },
    { num = -2, desc = "Last track in innermost and next-innermost folders" },
    -- { num = -3, desc = "Last track in innermost and next-innermost and next-next-innermost folders" },
}

---match_desc matches the given number with a description from the desc table.
---Returns nil if no match is found.
---@param num integer
---@return string | nil
local function match_desc(num)
    for _, d in ipairs(desc) do
        if d.num == num then
            return d.desc
        end
    end
    return nil
end

---num_is_valid checks if the given number is a valid folder depth value.
---@param num integer
---@return boolean
local function num_is_valid(num) --> boolean
    for _, d in ipairs(desc) do
        if d.num == num then
            return true
        end
    end
    return false
end

---new() returns a new FolderDepth object.
---@param num integer
---@return FolderDepth | nil, string | nil
function FolderDepth:New(num)
    if type(num) ~= "number" then
        return nil, "FolderDepth:New() expects a number, got " .. type(num)
    end

    if not num_is_valid(num) then
        return nil, "FolderDepth:New() expects a valid folder depth number, got " .. num
    end

    local new = {}
    setmetatable(new, self)
    self.__index = self

    ---@type integer
    self.num = num

    ---@type string
    self.desc = match_desc(num)

    return new, nil
end

return {
    FolderDepth = FolderDepth,
}
