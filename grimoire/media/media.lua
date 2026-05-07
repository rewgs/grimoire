---Media provides a wrapper for the reaper PCM_source type.
---It provides methods to interact with the media source, such as getting its file name, length, number of channels, sample rate, and type.
---@class Media
---@field _ PCM_source -- The PCM_source object that this Media wraps. As it is intended to be ignored/not intended to be modified directly, it is simply called _.
---@field take Take
local Media = {}