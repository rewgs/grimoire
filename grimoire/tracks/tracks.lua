local track = require("grim.track.track")

---Tracks provides methods for working with a group of Track objects in a REAPER project.
---@class Tracks
---@field _ Track[] -- The Tracks object that this class wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
local Tracks = {}

---Tracks.New returns a newly initialized Tracks object.
---@param tracks Track[] -- A table of Track objects.
---@return Tracks | nil, nil | string
function Tracks:New(tracks)
    if not tracks or type(tracks) ~= "table" then
        return nil, "Tracks:New() requires a table of Track objects."
    end

    for _, t in ipairs(tracks) do
        if not reaper.ValidatePtr(t._, "MediaTrack*") then
            return nil, "Tracks:New() requires valid MediaTrack pointers in the tracks table."
        end
    end

    local new = {}

    setmetatable(new, self)
    self.__index = self

    ---@type {}Track
    self.tracks = {}

    return new
end

-- TODO: Another function like this where the first track in Tracks._ is the parent. Or make that a boolean arg?
-- It also might be helpful to create a Folder class.
--
---Tracks.AddToFolder adds all Track objects in self._ to a folder under the specified parent Track.
---@param parentTrack Track -- The parent Track to which the tracks will be added as children.
---@return nil | string
---If successful, returns nil. If an error occurs, returns n error message.
function Tracks:AddToFolder(parentTrack)
    if not parentTrack then
        return "Tracks:AddToFolder() requires a Track and a parent Track."
    end

    if not reaper.ValidatePtr(parentTrack._, "MediaTrack*") then
        return "Tracks:AddToFolder() requires valid MediaTrack pointers."
    end

    -- TODO: Check if this is good code -- was suggested by Copilot.
    -- reaper.SetMediaTrackInfo_Value(track._, "I_FOLDERDEPTH", folderDepth.FOLDER_DEPTH_FOLDER)
    -- reaper.SetMediaTrackInfo_Value(track._, "I_FOLDERCOMPACT", 0)
    -- reaper.SetMediaTrackInfo_Value(track._, "I_FOLDERCHILDREN", 1)
    -- reaper.SetMediaTrackInfo_Value(parentTrack._, "I_FOLDERCOMPACT", 0)

    return nil
end

-- TODO:
-- Optional toIndex arg? 
--
-- Tracks.RemoveFromFolder removes all Track objects in self._ from their parent folder.
-- ---@return nil | string
-- ---If successful, returns nil. If an error occurs, returns an error message.
-- function Tracks:RemoveFromFolder()
-- end

-- TODO:
-- function Tracks.SetColor()
--     for _, track in ipairs(self.tracks) do
--         track.SetColor()
--     end 
-- end

