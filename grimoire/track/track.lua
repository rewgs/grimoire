---@description This module provides a wrapper for the MediaTrack type in REAPER.

local folderDepth = require("grim.track.folderDepth")
local item = require("grim.item.item")

---Track provides a wrapper for the reaper MediaTrack type.
---It provides methods to interact with the track, such as getting its name,
---index, and parent track, as well as methods to select or deselect the track.
---It also provides methods to get the track's folder depth and media items.
---@class Track
---@field project ReaProject -- The ReaProject that this Track belongs to.
---@field _ MediaTrack -- The MediaTrack object that this Track wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
---@field exists boolean -- Whether the track exists in the project.
---@field isMaster boolean -- Whether the track is the master track.
---@field isParent boolean -- Whether the track has child tracks. This is set to true if the track has at least one child track, and false otherwise.
---@field parent Track | nil -- The parent Track of this Track, if it exists. If the track has no parent, this is nil.
---@field isChild boolean -- Whether the track is a child track. This is set to true if the track has a parent, and false otherwise.
---@field GUID string | nil -- The GUID of the track, if it exists. If the track does not have a GUID, this is nil.
local Track = {}

---Track.New returns a newly initialized Track object.
---@param reaProject ReaProject
---@param mediaTrack MediaTrack
---@return Track | nil, string | nil
function Track:New(reaProject, mediaTrack)
	if not reaProject or not mediaTrack then
		return nil, "Track:New() requires a ReaProject and a MediaTrack."
	end

	if not reaper.ValidatePtr(reaProject, "ReaProject*") then
		return nil, "Track:New() requires a valid ReaProject."
	end

	if not reaper.ValidatePtr(mediaTrack, "MediaTrack*") then
		return nil, "Track:New() requires a valid MediaTrack."
	end

	local new = {}

	setmetatable(new, self)
	self.__index = self

	---@type ReaProject
	self.project = reaProject

	---@type MediaTrack
	self._ = mediaTrack

	---@type boolean
	self.exists = nil

	---@type boolean
	self.isMaster = nil

	return new, nil
end

---Track.GetTrackNumber returns the 1-based track number (as represented in the Reaper GUI).
---@return integer
function Track:GetTrackNumber()
	local trackNumber = reaper.GetMediaTrackInfo_Value(self._, "IP_TRACKNUMBER")

	if trackNumber == 0 then
		self.exists = false
	else
		self.exists = true
		if trackNumber == -1 then
			self.isMaster = true
		else
			self.isMaster = false
		end
	end

	return trackNumber
end

---Track.GetTrackIndex returns the 0-based track index (as represented in the Reaper GUI).
---@return integer
function Track:GetTrackIndex()
	local trackNumber = self:GetTrackNumber()
	return trackNumber - 1
end

---Track.GetName returns the track's name. If the track has no name, it returns nil instead of an empty string.
---@return string | nil
function Track:GetName()
	local _, name = reaper.GetTrackName(self._)
	if name == "" then
		return nil
	else
		return name
	end
end

---Track.GetParentTrack retrieves the parent MediaTrack of the current track, and then returns a newly-initialized Track object for it.
---If the track has no parent, it returns nil.
---@return Track | nil
function Track:GetParentTrack()
	local parentTrack = reaper.GetParentTrack(self._)
	if not parentTrack then
		return nil
	end

	local parent, err = Track:New(self.project, parentTrack)
	if parent == nil or err ~= nil then
		-- TODO: encapsulate in pcall()
		error("Track:GetParentTrack() failed to create Track: " .. (err or "unknown error"))
	end
	parent.exists = true
	parent.isMaster = false
	return parent
end

---Track.GetFolderDepth retrieves the numerical folder depth of the track, and then returns a newly-initialized FolderDepth object for it,
---which contains the number's corresponding descriptive string.
---@return FolderDepth
function Track:GetFolderDepth()
	local num = reaper.GetMediaTrackInfo_Value(self._, "I_FOLDERDEPTH")
	local newFolderDepth, err = folderDepth.FolderDepth:New(num)
	if newFolderDepth == nil or err ~= nil then
		-- TODO: encapsulate in pcall()
		error("Track:GetFolderDepth() failed to create FolderDepth: " .. (err or "unknown error"))
	end
	return newFolderDepth
end

---Track.GetItems returns a list of media items in the track.
---Returns nil if the track has no media items.
---@return Item[] | nil
function Track:GetItems()
	local items = {}

	local numMediaItems = reaper.CountTrackMediaItems(self._)

	if numMediaItems == 0 then
		return nil
	end

	for i = 0, numMediaItems - 1 do
		local mediaItem = reaper.GetTrackMediaItem(self._, i)
		if mediaItem then
			local newItem, err = item.Item:New(self.project, mediaItem)
			if newItem == nil or err ~= nil then
				error("Track:GetItems() failed to create Item: " .. (err or "unknown error"))
			else
				table.insert(items, newItem)
			end
		end
	end

	return items
end

---Track.IsSelected returns whether the Track is selected in the Reaper GUI.
---@return boolean
function Track:IsSelected()
	local isSelected = reaper.GetMediaTrackInfo_Value(self._, "I_SELECTED")
	if isSelected == 1 then
		return true
	end
	return false
end

---Track.Select selects the Track in the Reaper GUI.
---If the Track is already selected, it does nothing.
---If the Track does not exist, it does nothing.
---If the Track is the master track, it does nothing.
---If not successful, it returns an error message.
---@return string | nil
function Track:Select()
	if not self:IsSelected() then
		-- This return value is a boolean, but I'm not sure what it means. I'm guessing it indicates success.
		local success = reaper.SetMediaTrackInfo_Value(self._, "I_SELECTED", 1)
		if not success then
			return "Track:Select() failed to select track: " .. (self:GetName() or "unknown track")
		end
	end
	return nil
end

---Track.Deselect deselects the Track in the Reaper GUI.
---If the Track is already deselected, it does nothing.
---If the Track does not exist, it does nothing.
---If the Track is the master track, it does nothing.
---If not successful, it returns an error message.
---@return string | nil
function Track:Deselect()
	if self:IsSelected() then
		-- This return value is a boolean, but I'm not sure what it means. I'm guessing it indicates success.
		local success = reaper.SetMediaTrackInfo_Value(self._, "I_SELECTED", 0)
		if not success then
			return "Track:Deselect() failed to deselect track: " .. (self:GetName() or "unknown track")
		end
	end
	return nil
end

---Track.ToggleSelected toggles the selection state of the Track in the Reaper GUI.
---If the Track is selected, it deselects it.
---If the Track is not selected, it selects it.
---If the Track does not exist, it does nothing.
---If the Track is the master track, it does nothing.
---@return nil
function Track:ToggleSelected()
	if self:IsSelected() then
		self:Deselect()
	else
		self:Select()
	end
end

---Track.GetChildTracks returns a table of child Tracks of the current Track.
---Returns nil if the track has no child Tracks.
---@return Track[] | nil
function Track:GetChildTracks()
	local childTracks = {}
	local numTracks = reaper.CountTracks(self.project)

	for i = 0, numTracks - 1 do
		local track = reaper.GetTrack(self.project, i)
		if track and reaper.GetParentTrack(track) == self._ then
			local child, err = Track:New(self.project, track)
			if child == nil or err ~= nil then
				error("Track:GetChildTracks() failed to create Track: " .. (err or "unknown error"))
			else
				child.exists = true
				child.isMaster = false
				child.parent = self
				table.insert(childTracks, child)
			end
		end
	end

	if #childTracks == 0 then
		return nil
	end

	Track.IsParent = true
	return childTracks
end

-- TODO:
-- function Track:SetColor()
-- end

-- TODO:
-- function Track:GetParentColor()
-- end

---Track.IsMuted returns whether the Track is muted in the Reaper GUI.
---@return boolean
function Track:IsMuted()
	local isMuted = reaper.GetMediaTrackInfo_Value(self._, "B_MUTE")
	if isMuted == 1 then
		return true
	end
	return false
end

---Track.Mute mutes the Track in the Reaper GUI.
---If the Track is already muted, it does nothing.
---@return nil
function Track:Mute()
	if not self:IsMuted() then
		reaper.SetMediaTrackInfo_Value(self._, "B_MUTE", 0)
	end
end

---Track.Unmute unmutes the Track in the Reaper GUI.
---If the Track is already not muted, it does nothing.
---@return nil
function Track:Unmute()
	if self:IsMuted() then
		reaper.SetMediaTrackInfo_Value(self._, "B_MUTE", 1)
	end
end

---Track.ToggleMute toggles the mute state of the Track in the Reaper GUI.
---If the Track is muted, it unmutes it.
---If the Track is not muted, it mutes it.
---@return nil
function Track:ToggleMute()
	if self:IsMuted() then
		self:Unmute()
	else
		self:Mute()
	end
end

---Track.IsSoloed returns whether the Track is soloed in the Reaper GUI.
---@return boolean	
function Track:IsSoloed()
	local isSoloed = reaper.GetMediaTrackInfo_Value(self._, "B_SOLO")
	if isSoloed == 1 then
		return true
	end
	return false
end

---Track.Solo solos the Track in the Reaper GUI.
---If the Track is already soloed, it does nothing.
---@return nil
function Track:Solo()
	if not self:IsSoloed() then
		reaper.SetMediaTrackInfo_Value(self._, "B_SOLO", 1)
	end
end

--- Track.Unsolo unsolos the Track in the Reaper GUI.
--- If the Track is already not soloed, it does nothing.
---@return nil
function Track:Unsolo()
	if self:IsSoloed() then
		reaper.SetMediaTrackInfo_Value(self._, "B_SOLO", 0)
	end
end

function Track:ToggleSolo()
	if self:IsSoloed() then
		self:Unsolo()
	else
		self:Solo()
	end
end

---Track.GetGUID returns the GUID of the Track.
---If the Track does not have a GUID, it returns nil.
---
-- TODO: Check if the following comment suggested by Copilot is correct:
---This is a cached value, so it will only be retrieved once per Track object.
---Subsequent calls will return the cached value.
---This is useful for performance, as getting the GUID can be expensive.
---@return string | nil
function Track:GetGUID()
	if not self.GUID then
		self.GUID = reaper.GetTrackGUID(self._)
	end

	if not self.GUID or self.GUID == "" then
		return nil
	end

	return self.GUID
end

return {
	Track = Track,
}
