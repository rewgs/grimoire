---@description This module provides a wrapper for the ReaProject type in REAPER.

local track = require("grim.track.track")

---Project provides a wrapper for the reaper ReaProject type.
---@class Project
---@field _ ReaProject -- The ReaProject that this class wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
---@field _name string | nil -- The name of the project.
---@field _path string | nil -- The file path of the .rpp file.
---@field _recordingPath string | nil -- The recording path of the project.
---@field _tracks []Track | nil -- The project's tracks.
local projectT = {}

---Project.New returns a newly initialized Project object.
---@param reaProject ReaProject
---@return Project | nil, nil | string
local function newProject(reaProject)
	if not reaper.ValidatePtr(reaProject, "ReaProject*") then
		return nil, "Project:New() requires a valid ReaProject."
	end

	---@type Project
	local new = {
		_ = reaProject,
		_name = nil,
		_path = nil,
		_recordingPath = nil,
	}

	setmetatable(new, self)
	self.__index = self

	return new, nil
end

---@return string | nil
function projectT:Name()
	if self._name == nil then
		self._name = reaper.GetProjectName(self._)
	end
	return self._name
end

function projectT:RecordingPath()
	if self._recordingPath == nil then
		self._recordingPath = reaper.GetProjectPath()
	end
	return self._recordingPath
end

---description Path checks self._path and, if nil, gets the Project's path; if not found, returns nil and an error message. Analogous to a Python @property.
---@return string | nil, string | nil
function projectT:Path()
	if self._path == nil then
		local name = self.Name()
		if name == nil then
			return nil, "could not get name of project"
		end

		local recordingPath = self.RecordingPath()
		if recordingPath == nil then
			return nil, "could not get name of recording path of project: " .. name .. "\n"
		end

		-- This is used to assume the path of the project file, as it is usually in the same directory as the Media folder.
		---@type string
		local path = recordingPath:gsub("Media" .. "$", "") .. name .. ".rpp" -- gsub("Media" .. "$", "") removes the trailing "Media" from self.RecordingPath.

		if not reaper.file_exists(path) then
			-- NOTE: This will happen if the project is not saved yet, or if self.RecordingPath has been manually changed by the user.
			return nil, "could not find project file at assumed path: " .. path .. "\n"
		end

		self._path = path
	end

	return self._path, nil
end

---Project.GetTracks Returns a table of all Tracks in the current project.
---If no tracks are found, it returns nil.
---@return Track[] | nil
function projectT:GetTracks()
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
function projectT:SelectAllTracks()
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
function projectT:DeselectAllTracks()
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
function projectT:GetAllTracksByName(name)
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
function projectT:GetTrackByName(name)
	-- TODO: call GetTracksByName and then return Track with lowest index.
end

-- TODO:
function projectT:GetFramerate() end

-- TODO:
function projectT:ChangeFramerate() end

return {
	Project = projectT,
	NewProject = newProject,
}
