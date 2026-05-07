Item = {}

-- TODO: Wrap function body in pcall() for error-handling, especially in the
-- case that o is not passed or does not exist.
function Item:new(o, project, mediaItem) --> Item
    --
    -- Returns a wrapper for reaper.MediaItem.
    --
    -- o: table or nil
    -- mediaItem: reaper.MediaItem

    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.project = project
    self._ = mediaItem

    return o
end

function Item:getTrack() --> reaper.MediaTrack
    local track = reaper.GetMediaItemTake_Track(self._)

    -- TODO:
    if track == nil then
        -- raise error
    end

    return track
end

function Item:getTake() --> reaper.MediaItem_Take
    local take = reaper.GetMediaItemTake(self._,)

    -- TODO:
    if take == nil then
        -- raise error
    end

    return take
end

function Item:getSourceMedia() --> reaper.PCM_source
    local sourceMedia = reaper.GetMediaItemTake_Source(self.getTake())

    -- TODO:
    if sourceMedia == nil then
        -- raise error
    end

    return sourceMedia
end
