---@description This module provides a wrapper for the MediaItem_Take type in REAPER.

local item = require("grim.item.item")

---Take provides a wrapper for the reaper MediaItem_Take type.
---@class Take
---@field _ MediaItem_Take -- The MediaItem_Take object that this class wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
local Take = {}

---Take.New returns a newly initialized Track object.
---@param mediaItemTake MediaItem_Take
---@return Take | nil, string | nil
function Take:New(mediaItemTake)
    if not mediaItemTake then
        return nil, "Take:New() requires a MediaItem_Take."
    end

	if not reaper.ValidatePtr(mediaItemTake, "MediaItem_Take*") then
		return nil, "Track:New() requires a valid MediaItem_Take."
	end
end