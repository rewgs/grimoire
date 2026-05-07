---@description This module provides a wrapper for the MediaItem type in REAPER.

---Item provides a wrapper for the reaper MediaItem type.
---It provides methods to interact with the item, such as getting its name,
---index, and track, as well as methods to select or deselect the item.
---@class Item
---@field _ MediaItem -- The MediaItem object that this Item wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
---@field isMIDI boolean -- Whether the item is a MIDI item.
---@field isAudio boolean -- Whether the item is an audio item.
---@field isVideo boolean -- Whether the item is a video item.
local Item = {}

---Item.New returns a newly initialized Track object.
---@param reaProject ReaProject
---@param  mediaItem MediaItem
---@return Item | nil, string | nil
function Item:New(reaProject, mediaItem)
	if not reaProject or not mediaItem then
		return nil, "Item:New() requires a ReaProject and a MediaItem."
	end

	if not reaper.ValidatePtr(reaProject, "ReaProject*") then
		return nil, "Item:New() requires a valid ReaProject."
	end

	if not reaper.ValidatePtr(mediaItem, "MediaItem*") then
		return nil, "Item:New() requires a valid MediaItem."
	end

	local new = {}

	setmetatable(new, self)
	self.__index = self

	---@type MediaItem
	self._ = mediaItem

	return new, nil
end

-- TODO:
function Item:GetTrack() --> Track
end

-- TODO:
function Item:GetTake() --> Take
end

-- TODO:
function Item:GetSourceMedia() --> Media (this will be a wrapper for reaper.PCM_source or whatever it's called)
end

return {
	Item = Item,
}

