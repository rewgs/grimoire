-- The entrypoint for the azrael library.

local function fileExists(file) --> bool
    local f = io.open(file, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Loads the Ultraschall API into the Reaify namespace.
local function loadUltraschall(ultraschall_path)
    -- TODO:
    -- Installs Ultraschall via `git clone`:
    -- https://github.com/Ultraschall/ultraschall-lua-api-for-reaper
    -- local function installUltraschall()
    -- end

    if fileExists(ultraschall_path) then
        dofile(ultraschall_path)
    end

    if not ultraschall or not ultraschall.GetApiVersion then
        reaper.MB(
        "Please install Ultraschall API, available via Reapack. Check online doc of the script for more infos.\nhttps://github.com/Ultraschall/ultraschall-lua-api-for-reaper",
            "Error", 0)
        return
    end
end


local function loadReaify(reaify)
    -- Returns all subdirectories and files within a given path.
    -- Might take some time with many folders/files.
    -- Optionally, you can filter for specific keywords(follows Lua's pattern-matching)
    -- Returns -1 in case of an error.
    --
    -- Lua: integer found_dirs, array dirs_array, integer found_files, array files_array = ultraschall.GetAllRecursiveFilesAndSubdirectories(string path, optional string dir_filter, optional string dir_case_sensitive, optional string file_filter, optional string file_case_sensitive)
    local num_found_dirs, dirs_array, num_found_files, files_array = ultraschall.GetAllRecursiveFilesAndSubdirectories(
    reaify.root)

    -- Imports all files found in the reaify directory.
    -- Never imports the name of the file that's calling it -- this allows modules to use the same
    -- `dofile()` line as scripts: dofile(reaper.GetResourcePath() .. "/Scripts/rewgs-reaper-scripts/modules/init.lua")
    -- TODO: filter only .lua files
    local filesWithErrs = {}
    for _, file in ipairs(files_array) do
        if file ~= reaify.initFile then
            -- reaper.ShowConsoleMsg(file .. "\n")

            -- dofile(file)

            -- FIXME:
            -- Looking to track which files are problematic and then *only* `dofile()` the non-problematic ones.
            -- According to this, this should work: https://stackoverflow.com/questions/53343443/load-lua-file-and-catch-any-syntax-errors
            -- But it doesn't. Why?
            local success, err = loadfile(file)
            if not success then
                table.insert({ file, err })
            end
        end
    end
    if #filesWithErrs > 0 then
        reaper.ShowConsoleMsg("The following files had the following errors:\n")
        for _, file in filesWithErrs do
            reaper.ShowConsoleMsg("File: " .. file[1])
            reaper.ShowConsoleMsg("Error: " .. file[2])
        end
    end
end


local function main()
    local thisFileName = debug.getinfo(1, 'S').source:match("[^/]*.lua$")

    local path = {}
    path.reaperResources = reaper.GetResourcePath()
    path.userPlugins = path.reaperResources .. "/UserPlugins/"

    -- The actual location of this path.
    path.this = {}
    path.this.file = debug.getinfo(1, "S").source
    path.this.parentDir = debug.getinfo(2, "S").source:sub(2):match("(.*/)")

    -- This is what the path *should* be, not necessarily what it *is.*
    path.reaify = {}
    path.reaify.root = path.userPlugins .. "reaify/" .. "reaify"
    path.reaify.initFile = path.reaify.root .. "/" .. thisFileName

    path.ultraschall = path.userPlugins .. "ultraschall_api.lua"

    -- Checking paths.
    if not path.this.file == path.reaify.initFile then
        local title = "Error loading Reaify!"
        local msg = "Reaify is not properly installed! It should be located at: " ..
        path.reaify.initFile .. "; but is instead at: " .. path.this.file .. "!"
        _ = reaper.ShowMessageBox(msg, title, 0)
        -- NOTE: Only present for debugging. Usually leave this commented out.
        -- else
        --     local title = "Successfully loaded Reaify!"
        --     local msg = "Reaify was successfully found at: " .. path.this.file .. ". Enjoy!"
        --     _ = reaper.ShowMessageBox(msg, title, 0)
    end

    loadUltraschall(path.ultraschall)
    loadReaify(path.reaify)
end
main()




-- NOTE: Using this library as reference/inspiration:
-- https://gitlab.com/adamnejm/lazy-lua/-/blob/master/init.lua?ref_type=heads
-- return {
-- 	_VERSION        = "Reaify v0.0.1a",
-- 	_DESCRIPTION    = "Rewgs' Extension for the Reaper and Ultraschall Lua APIs",
-- 	_URL            = "https://github.com/rewgs/reaify",
--     -- TODO:
-- 	_LICENSE        = [[
-- 	]],

-- os     = require_relative("os"),     ---@module "lazy.os"
-- math   = require_relative("math"),   ---@module "lazy.math"
-- table  = require_relative("table"),  ---@module "lazy.table"
-- string = require_relative("string"), ---@module "lazy.string"
-- }
