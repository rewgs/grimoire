---@description grim
---@author Alex Ruger aka rewgs
---@version 0.0.1-alpha
---@about This library significantly speeds up ReaScript development by providing a more object-oriented approach for interacting with Reaper's ReaScript Lua API.

local envelope = require("grim.envelope.envelope")
local item = require("grim.item.item")
local media = require("grim.media.media")
local project = require("grim.project.project")
local track = require("grim.track.track")
local tracks = require("grim.tracks.tracks")

local function init() end

return {
	envelope = envelope,
	item = item,
	media = media,
	project = project,
	track = track,
	tracks = tracks,
}
