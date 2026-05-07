---@description This module provides a wrapper for the ReaProject type in REAPER.

local track = require("grim.track.track")

---Project provides a wrapper for the reaper ReaProject type.
---@class Project
---@field _ ReaProject -- The ReaProject that this class wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
---@field Name string -- The name of the project.
---@field RecordingPath string -- The recording path of the project.
---@field Path string -- The file path of the .rpp file.
local Project = {}

---Project.New returns a newly initialized Project object.
---@param reaProject ReaProject
---@return Project | nil, nil | string
function Project:New(reaProject)
	if not reaper.ValidatePtr(reaProject, "ReaProject*") then
		return nil, "Project:New() requires a valid ReaProject."
	end

	local new = {}

	setmetatable(new, self)
	self.__index = self

	---@type ReaProject
	self._ = reaProject

	---@type string
	self.Name = reaper.GetProjectName(self._)

	---@type string
	self.RecordingPath = reaper.GetProjectPath()

	---@type string
	-- gsub("Media" .. "$", "") removes the trailing "Media" from self.RecordingPath.
	-- This is used to assume the path of the project file, as it is usually in the same directory as the Media folder.
	local assumedPath = self.RecordingPath:gsub("Media" .. "$", "")
	local assumedFile = assumedPath .. self.Name .. ".rpp"
	if reaper.file_exists(assumedFile) then
		self.Path = assumedFile
	else
		-- NOTE: This will happen if the project is not saved yet, or if self.RecordingPath has been manually changed by the user.
		return nil, "Project:New() could not find project file at assumed path: " .. assumedFile
	end

	return new, nil
end

---Project.GetTracks Returns a table of all Tracks in the current project.
---If no tracks are found, it returns nil.
---@return Track[] | nil
function Project:GetTracks()
	local numTracks = reaper.CountTracks(self._)

	if numTracks == 0 then
		return nil
	end

	local tracks = {}
	for i = 0, numTracks - 1 do
		local mediaTrack = reaper.GetTrack(self._, i)
		local newTrack, err = track.Track:New(self._, mediaTrack)
		if newTrack == nil or newTrack == err then
			error("Project:GetTracks() failed to create Track: " .. (err or "unknown error"))
		end
		table.insert(tracks, newTrack)
	end

	if #tracks >= 1 then
		return tracks
	end

	return nil
end

---Project.SelectAllTracks selects all Tracks in the current project.
---If no tracks are found, it returns an error message.
---@return string | nil
function Project:SelectAllTracks()
	local tracks = self:GetTracks()
	if not tracks then
		return "Project:SelectAllTracks() failed to get tracks."
	end

	for _, track in ipairs(tracks) do
		local err = track:Select()
		if err then
			return "Project:SelectAllTracks() failed to select track: " .. (err or "unknown error")
		end
	end

	return nil
end

---Project.DeselectAllTracks deselects all Tracks in the current project.
---If no tracks are found, it returns an error message.
---@return string | nil
function Project:DeselectAllTracks()
	local tracks = self:GetTracks()
	if not tracks then
		return "Project:DeselectAllTracks() failed to get tracks."
	end

	for _, track in ipairs(tracks) do
		local err = track:Deselect()
		if err then
			return "Project:DeselectAllTracks() failed to deselect track: " .. (err or "unknown error")
		end
	end

	return nil
end

---Project.GetTrackByName retrieves a Track by its name in the current project.
---Retuns a table of Tracks, even if only one match is found.
---If no track with the given name is found, it returns nil.
---@param name string
---@return Track[] | nil
function Project:GetAllTracksByName(name)
	local tracks = {}
	local numTracks = reaper.CountTracks(self._)
	for i = 0, numTracks - 1 do
		local mediaTrack = reaper.GetTrack(self._, i)
		-- Returns "MASTER" for master track, "Track N" if track has no name.
		local _, mediaTrackName = reaper.GetTrackName(mediaTrack)
		if mediaTrackName == name then
			local newTrack, err = track.Track:New(self._, mediaTrack)
			if newTrack == nil or newTrack == err then
				-- TODO: Wrap this in pcall()
				error("Project:GetTracksByName() failed to create Track: " .. (err or "unknown error"))
			else
				table.insert(tracks, newTrack)
			end
		end
	end
	if #tracks >= 1 then
		return tracks
	end
	return nil
end

-- TODO: in progress
---track.GetTrackByName retrieves a Track by its name in the current project.
---If multiple tracks have the same name, it returns the Track with the lowest track number/index.
---If no track with the given name is found, it returns nil.
---@param name string
---@return Track | nil
function Project:GetTrackByName(name)
	-- TODO: call GetTracksByName and then return Track with lowest index.
end

-- TODO:
function Project:GetFramerate() end

-- TODO:
function Project:ChangeFramerate() end

return {
	Project = Project,
}
