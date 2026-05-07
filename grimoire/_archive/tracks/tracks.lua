-- dofile(reaper.GetResourcePath() .. "/Scripts/rewgs-reaper-scripts/modules/track-marks.lua")


-- TODO: Use reaproject arg to specify which project.
function GetAllTracks(reaproject)
    local all_tracks = GetAllTracks()
    for _, track in ipairs(all_tracks) do
        track.children = GetChildrenOf(track)
    end

    return all_tracks
end

-- Returns a tree-like representation of tracks (w/r/t child/parent relationship).
---@type tracks: list, reaper.MediaTrack
function GetTree(tracks)
end

---@type parent: reaper.MediaItem
function GetChildrenOf(parent)
    -- args:
    -- track:
    --  a track (as returned in get_all_tracks_as_objects() -- *not* a media_track (though,
    --  `media_track` is a property of `track`)), and returns all of its children (including
    --  children which are parent tracks themselves).
    --
    local children = {}
    for i, track in ipairs(GetAllTracks()) do
        --  0 = normal
        --  1 = track is a folder parent
        -- -1 = track is the last in the innermost folder,
        -- -2 = track is the last in the innermost and next-innermost folders, etc...
        -- if track.media_track == parent.media_track then
        -- reaper.ShowConsoleMsg("The index of " .. track.name .. " is " .. parent.index .. ".\n")
        -- end
        if track.parent == parent.media_track then
            -- if track.depth == 1 then
            -- local new_generation
            -- get_children_of(track)
            -- else
            table.insert(children, track)
            -- end
        end
    end

    return children
end

-- Returns all tracks in project as MediaTrack objects with all available properties.
function GetAllTracks()
    local all_tracks = {}
    for i = 0, reaper.CountTracks(0) - 1 do
        local _media_track = reaper.GetTrack(0, i)

        --  0 = normal
        --  1 = track is a folder parent
        -- -1 = track is the last in the innermost folder,
        -- -2 = track is the last in the innermost and next-innermost folders, etc...
        local _depth = reaper.GetMediaTrackInfo_Value(_media_track, "I_FOLDERDEPTH")
        local _, _name = reaper.GetTrackName(_media_track)
        local _parent = reaper.GetMediaTrackInfo_Value(_media_track, "P_PARTRACK")
        local _num_media_items = reaper.CountTrackMediaItems(_media_track)
        local is_selected = reaper.IsTrackSelected(_media_track)
        local track_mute_state = reaper.GetMediaTrackInfo_Value(_media_track, "B_MUTE")

        local _items = {}
        for m = 0, _num_media_items - 1 do
            local __item_obj = {}
            local _media_item = reaper.GetMediaItem(0, m)
            -- NOTE: This genuienly does not work, nor does `"B_MUTE"`. This is literally broken in the API.
            local _mute_state = reaper.GetMediaItemInfo_Value(_media_item, "B_MUTE_ACTUAL")

            __item_obj.index = m
            __item_obj.media_item = _media_item
            __item_obj.mute_state = _mute_state
            table.insert(_items, __item_obj)
        end

        local track_obj = {
            media_track = _media_track,
            index = i,
            name = _name,
            depth = _depth,
            parent = _parent,
            is_selected = is_selected,
            track_mute_state = track_mute_state,
            num_media_items = _num_media_items, -- this is redundant; delete and just run `#items` when needed
            items = _items
        }

        table.insert(all_tracks, track_obj)
    end

    return all_tracks
end

-- args are parent tracks to ignore i.e. not include them or their child tracks in `child_tracks`
-- TODO: This currently only ignores immediate non-folder children of the ignored parent; folders under parent are not ignored.
function get_all_child_tracks(args)
    local parents_to_ignore = args

    local all_tracks = GetAllTracks()
    local child_tracks = {}

    if parents_to_ignore ~= nil and #parents_to_ignore > 0 then
        for _, track in ipairs(all_tracks) do
            if not table_contains(parents_to_ignore, get_parent_track_name(track.parent)) and track.depth < 1 then
                table.insert(child_tracks, track)
            end
        end
    else
        for _, track in ipairs(all_tracks) do
            if track.depth < 1 then
                table.insert(child_tracks, track)
            end
        end
    end

    return child_tracks
end

-- This is intended to be an improvement over get_all_child_tracks
-- Allows the ability to ignore muted and empty tracks.
function get_all_child_tracks_2(args)
    --@type table
    local parents_to_ignore = args.parents_to_ignore
    --@type bool
    local ignore_silent = args.ignore_silent

    local all_tracks = GetAllTracks()
    local child_tracks = {}

    if parents_to_ignore ~= nil and #parents_to_ignore > 0 then
        for _, track in ipairs(all_tracks) do
            if not table_contains(parents_to_ignore, get_parent_track_name(track.parent)) and track.depth < 1 then
                if ignore_silent then
                    if not track.num_media_items == 0 and not track.track_mute_state then
                        table.insert(child_tracks, track)
                    end
                else
                    table.insert(child_tracks, track)
                end
            end
        end
    else
        for _, track in ipairs(all_tracks) do
            if ignore_silent then
                if not track.num_media_items == 0 and not track.track_mute_state then
                    table.insert(child_tracks, track)
                end
            else
                table.insert(child_tracks, track)
            end
        end
    end

    return child_tracks
end

-- TODO
function get_all_child_tracks_2(args)
    -- Ignores all tracks, including other folders, below ignored parent tracks
    -- NOTE: args is a table of strings representing track names to ignore

    local function get_tracks_with_forbidden_parents(args)
        local all_tracks = args.all_tracks
        local parents_to_ignore = args.parents_to_ignore
        local tracks_with_forbidden_parent = args.tracks_with_forbidden_parent

        for _, track in ipairs(all_tracks) do
            for _, p in ipairs(parents_to_ignore) do
                if p == get_parent_track_name(track.parent) then
                    if track.depth == 1 then
                        table.insert(parents_to_ignore, track)
                        -- FIXME:
                        --  Currently this causes endless recursion due to the return statement.
                        --  Need to return on a condition, ideally based on len of a table, but that's being buggy...
                        tracks_with_forbidden_parent = get_tracks_with_forbidden_parents {
                            all_tracks = all_tracks,
                            parents_to_ignore = parents_to_ignore,
                            tracks_with_forbidden_parent = tracks_with_forbidden_parent
                        }
                    else
                        table.insert(tracks_with_forbidden_parent, track)
                    end
                end
            end
        end

        return tracks_with_forbidden_parent
    end

    local all_tracks = GetAllTracks()
    local child_tracks = {}

    if args ~= nil and #args > 0 then
        local func_args = args
        -- reaper.ShowConsoleMsg("Taking the if")
        -- reaper.ShowConsoleMsg(tostring(#args) .. "\n")
        local tracks_with_forbidden_parent = get_tracks_with_forbidden_parents {
            all_tracks = all_tracks,
            parents_to_ignore = func_args,
            tracks_with_forbidden_parent = {}
        }

        -- for _, track in ipairs(tracks_with_forbidden_parent) do
        -- reaper.ShowConsoleMsg(track.name .. " has a forbidden parent.\n")
        -- end

        for _, track in ipairs(all_tracks) do
            if not table_contains(tracks_with_forbidden_parent, track) and track.depth < 1 then
                table.insert(child_tracks, track)
            end
        end
    else
        -- reaper.ShowConsoleMsg("Taking the else")
        for _, track in ipairs(all_tracks) do
            if track.depth < 1 then
                table.insert(child_tracks, track)
            end
        end
    end

    return child_tracks
end

function get_parent_track_name(parent_track)
    for i = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, i)

        if track == parent_track then
            local _, track_name = reaper.GetTrackName(track)
            if track_name ~= nil then
                -- reaper.ShowConsoleMsg(track_name .. "\n")
                return track_name
            end
        end
    end
end

function CreateClickTrack(name="Click")
    local function get_click_tracks()
        total_num_tracks = reaper.CountTracks(0)
        click_tracks = {}
        for i = 0, total_num_tracks - 1 do
            local track = reaper.GetTrack(0, i)
            local _, track_name = reaper.GetTrackName(track)

            if track_name == "Click" then
                table.insert(click_tracks, track)
            end
        end
        return click_tracks
    end

    local function confirm_only_one_click_track(click_tracks)
        local function delete_final_tracks_with_no_name(total_num_tracks)
            for i = 0, total_num_tracks - 1 do
                local track = reaper.GetTrack(0, i)
                local _, track_name = reaper.GetTrackName(track)
                local track_num = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
                -- FIX ME: would prefer to do this this way, but need to remove the `.0` from the end of track_num
                -- local empty = "Track " .. tostring(track_num)
                local empty = "Track " .. tostring(total_num_tracks)
                if track_name == empty then
                    reaper.DeleteTrack(track)
                    total_num_tracks = reaper.CountTracks(0)
                    delete_final_tracks_with_no_name(total_num_tracks)
                end
            end
        end

        -- first, get rid of any tracks that have been added but not yet named "Click"
        -- operates only on all the final tracks with no name
        total_num_tracks = reaper.CountTracks(0)
        delete_final_tracks_with_no_name(total_num_tracks)

        if #click_tracks == 0 then
            -- create track called "Click"
            reaper.InsertTrackAtIndex(total_num_tracks, true)
            local total_num_tracks = reaper.CountTracks(0)
            local click_track = reaper.GetTrack(0, total_num_tracks - 1)
            reaper.GetSetMediaTrackInfo_String(click_track, "P_NAME", "Click", true)
            -- return true
        end
        if #click_tracks > 1 then
            for i, track in ipairs(click_tracks) do
                local _, track_name = reaper.GetTrackName(track)
                reaper.DeleteTrack(track)
            end
        end
        return true
    end

    local function create_click_source()
        local total_num_tracks = reaper.CountTracks(0)
        for i = 0, total_num_tracks - 1 do
            local track = reaper.GetTrack(0, i)
            local _, track_name = reaper.GetTrackName(track)

            if track_name == "Click" then
                set_bounds_to_items { clear_track_selection_after_running = true }
                reaper.SetOnlyTrackSelected(track)

                -- 'Insert click source' (i.e. print click to audio)
                reaper.Main_OnCommand(40013, 0)
            end
        end
    end

    -- I shouldn't need this but in the interest of getting this to work quickly...
    local function rename_final_track_to_click()
        local total_num_tracks = reaper.CountTracks(0)

        for i = 0, total_num_tracks - 1 do
            local track = reaper.GetTrack(0, i)
            local _, track_name = reaper.GetTrackName(track)
            -- FIX ME: would prefer to do this this way, but need to remove the `.0` from the end of track_num
            -- local track_num = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
            -- if track_name == "Track " .. tostring(track_num) then
            local empty = "Track " .. tostring(total_num_tracks)
            if track_name == empty then
                reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "Click", true)
            end
        end
    end

    local function make_click_track_first_track()
        local total_num_tracks = reaper.CountTracks(0)
        for i = 0, total_num_tracks - 1 do
            local track = reaper.GetTrack(0, i)

            -- FIXME: these have decimals, need to not in order for this to work
            local track_num = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
            -- if track_name == "Click" then
            --     reaper.SetMediaTrackInfo_Value(track, "IP_TRACKNUMBER", 1)
            -- end
        end
    end

    click_tracks = get_click_tracks()

    if confirm_only_one_click_track(click_tracks) then
        create_click_source()
        rename_final_track_to_click()
        -- make_click_track_first_track()
    end
end

-- IN PROGRESS
-- function remove_silent_stems(stems_table)
--     for i, stem in ipairs(get_children_of(stems_table)) do
--         if stem.num_media_items == 0 then
--             table.remove(stems_table, i)
--         else
--             for
--         end
--     end
-- end


function get_skinny_stems(all_tracks)
    -- Returns a table containing all folder tracks one level below "Music Sub Mix," except for
    --  Orchestra and Effects.
    --
    -- Includes folder tracks whose children are only muted tracks, or the track of which only
    --  contain muted media items or don't contain any media items, i.e. stems that would print
    --  silence.
    -- To get *only* the stems that would print silence, run `get_silent_skinny_stems()` instead.

    local skinny_stems = {}
    skinny_stems.which = "skinny"

    for i, track in ipairs(all_tracks) do
        local parent_track_name = get_parent_track_name(track.parent)

        -- Lua lacks a `continue` statement, so the if/then branch here effectively `continue`s past
        -- `parent_track_name`s with a value of `nil`.
        --
        if parent_track_name ~= nil then
            if parent_track_name == "Music Sub Mix" then
                if track.name ~= "Orchestra" and track.name ~= "Effects" then
                    table.insert(skinny_stems, track)
                end
            elseif parent_track_name == "Orchestra" then
                table.insert(skinny_stems, track)
            end
        end
    end

    return skinny_stems
end

function get_wide_stems(all_tracks)
    -- Returns a table containing the lowest-depth folder tracks below those specified in
    --  `get_skinny_stems()`.
    --
    -- Includes folder tracks whose children are only muted tracks, or the track of which only
    --  contain muted media items or don't contain any media items, i.e. stems that would print
    --  silence.
    -- To get *only* the stems that would print silence, run `get_wide_silent_stems()` instead.

    local wide_stems = {}
    wide_stems.which = "wide"

    -- This will gather some tracks that don't belong in the final `wide_stems` table
    local candidates = {}
    for i, track in ipairs(all_tracks) do
        if track.depth < 0 then
            table.insert(candidates, track.parent)
        end
    end

    for i, track in ipairs(all_tracks) do
        for j, candidate in ipairs(candidates) do
            if track.media_track == candidate then
                table.insert(wide_stems, track)
            end
        end
    end

    -- This removes the tracks that don't belong
    for i, stem in ipairs(wide_stems) do
        if stem.name == "Movie" or stem.name == "Effects" then
            table.remove(wide_stems, i)
        end
    end

    -- debug
    -- for i, stem in ipairs(wide_stems) do
    --     reaper.ShowConsoleMsg(stem.name .. "\n")
    -- end

    return wide_stems
end

function get_silent_skinny_stems()
    -- Returns a table containing only the stems returned by `get_skinny_stems()` that will print
    --  silence.
    print("Running get_silent_skinny_stems()")
end

function get_silent_wide_stems()
    print("Running get_silent_wide_stems()")
end

function get_family_tree(t)
    -- Takes a table `t` and returns a table `family` where each item in `t` is the value of key
    -- `parent`, and each child is added to a table `children` within table `family`, like so:
    --
    --  t {
    --      item_0,
    --      item_1,
    --      item_2,
    --      etc
    --  }
    --
    --  family {
    --      {
    --          parent: item_0,
    --          children: {
    --              child_0,
    --              child_1,
    --              child_2,
    --              etc
    --      },
    --      {
    --          parent: item_0,
    --          children: {
    --              child_0,
    --              child_1,
    --              child_2,
    --              etc
    --      }
    --  }

    local family_tree = {}
    for i, track in ipairs(GetAllTracks()) do
        local children = {}
        if track.depth <= 0 then
            for j, item in ipairs(t) do
                -- if get_parent_track_name(track.parent) == item.name then
                if track.parent == item.media_track then
                    reaper.ShowConsoleMsg(track.name .. "\n")
                    table.insert(children, track)
                end
            end
        end
    end

    return family_tree
end

function get_next_track_obj(current_track, all_tracks)
    local next_track = reaper.GetTrack(0, current_track.number + 1)

    for i, track in ipairs(all_tracks) do
        if next_track == track.media_track then
            return track
        end
    end
end

function get_child_folder_tracks_of(parent_folder_track, next_folder_track, all_tracks)
    local child_folder_tracks = {}

    local next_track = get_next_track_obj(parent_folder_track, all_tracks)
    -- reaper.ShowConsoleMsg(next_track.name)

    -- This loops through all the parent folder track's children
    -- for i = next_track.number, i < next_folder_track.number, i += 1
    -- reaper.ShowConsoleMsg()
    -- end

    -- for i, track in ipairs(all_tracks) do
    -- end


    -- for i, track in ipairs(all_tracks) do
    --     if track.media_track == parent_folder_track.media_track then
    --         -- This is the next track immediately after parent_folder_track.
    --         local current_track = all_tracks[i+1]
    --         -- reaper.ShowConsoleMsg("The track immediately after " .. parent_folder_track.name .. " is " .. current_track.name .. "\n.")
    --         reaper.ShowConsoleMsg("The depth of " .. current_track.name .. " is " .. current_track.depth .. ".\n")

    --         if current_track.depth == 1 then
    --             table.insert(child_folder_tracks, current_track)
    --         end

    --     end
    -- end
end

function get_tracks_to_print()
    local tracks_to_print = {}

    for t = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, t)

        -- 0 = normal, 1 = track is a folder parent, -1 = track is the last in the innermost folder,
        -- -2 = track is the last in the innermost and next-innermost folders, etc...
        local depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
        local _, track_name = reaper.GetTrackName(track)
        local num_media_items = reaper.CountTrackMediaItems(track)
        local parent_track = reaper.GetMediaTrackInfo_Value(track, "P_PARTRACK")
        local parent_track_name = get_parent_track_name(parent_track)

        if (depth <= 0) and (num_media_items > 0) and (parent_track_name ~= "Movie") then
            local num_muted_media_items = 0

            for i = 0, num_media_items - 1 do
                local media_item = reaper.GetTrackMediaItem(track, i)
                local mute_state = reaper.GetMediaItemInfo_Value(media_item, "B_MUTE")

                -- Since `mute_state` == 0 for unmuted and 1 for muted, the following line simply
                -- adds the number of muted media items, i.e. `num_muted_media_items = num_muted_media_items + 1`
                num_muted_media_items = num_muted_media_items + mute_state
            end

            -- reaper.ShowConsoleMsg(track_name .. " has " .. tostring(num_muted_media_items) .. " muted media items out of a total of " .. tostring(num_media_items) .. ".\n")
            if num_muted_media_items < num_media_items then
                table.insert(tracks_to_print, track_name)
            end
        end
    end

    return tracks_to_print
end

function search_up_family_tree(track, table)
    for i = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, i)
        local parent_track = reaper.GetMediaTrackInfo_Value(track, "P_PARTRACK")

        for i, t in ipairs(table) do
            if t == parent_track then
                local parent_track_name = get_parent_track_name(parent_track)
                -- reaper.ShowConsoleMsg(parent_track_name .. "\n")
                -- return parent_track
            end

            -- search_up_family_tree(parent_track, table)
        end
    end
end

function IsChild(track)
    if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1 then
        return false
    else
        return true
    end
end

function is_marked(subject, pattern)
    local start_index, end_index = string.find(subject, pattern)
    if start_index ~= nil and end_index ~= nil then
        return true
    else
        return false
    end
end

function toggle_mark_track(mark)
    for _, track in ipairs(GetAllTracks()) do
        if track.is_selected == true and track.depth < 1 then
            if is_marked(track.name, mark) then
                local new_name = track.name:gsub(mark .. " ", "")
                reaper.GetSetMediaTrackInfo_String(track.media_track, "P_NAME", new_name, true)
            else
                local new_name = mark .. ' ' .. track.name
                reaper.GetSetMediaTrackInfo_String(track.media_track, "P_NAME", new_name, true)
            end
        end
    end
end

function get_all_marked_tracks()
    local all_marked_tracks = {}
    for _, track in ipairs(GetAllTracks()) do
        for key, value in pairs(TrackMarks) do
            if is_marked(track.name, value) then
                table.insert(all_marked_tracks, track)
            end
        end
    end

    return all_marked_tracks
end

-- FIXME
function get_marked_tracks(...)
    local marked_tracks = {}
    for _, track in ipairs(GetAllTracks()) do
        for _, mark in ipairs(arg) do
            if is_marked(track.name, mark) then
                reaper.ShowConsoleMsg(track.name)
                table.insert(marked_tracks, track)
            end
        end
    end

    return marked_tracks
end

function export_marked_tracks(marked_tracks)
    for _, track in ipairs(GetAllTracks()) do
        for _, marked_track in ipairs(marked_tracks) do
            if track.name == marked_track.name then
                reaper.SetTrackSelected(track.media_track, true)
            end
        end
    end

    -- OLD
    -- for i = 0, total_num_tracks - 1 do
    --     local track = reaper.GetTrack(0, i)
    --     local _, track_name = reaper.GetTrackName(track)
    --     for j, marked_track in ipairs(marked_tracks) do
    --         if track_name == marked_track then
    --             reaper.SetTrackSelected(track, true)
    --         end
    --     end
    -- end

    -- File: Export project MIDI...
    reaper.Main_OnCommand(40849, 0)
end

-- FIXME: This function is acting a little weird, not always firing. Just adapting the meat of this
-- function and straight-forwardly calling the SetMediaTrackInfo_Value() function whenever needed.
function toggle_effects_track_mute_state()
    for _, track in ipairs(GetAllTracks()) do
        if track.name == "Effects" and track.depth == 1 then
            local muted = nil
            if track.track_mute_state == 0 then
                muted = reaper.SetMediaTrackInfo_Value(track.media_track, "B_MUTE", 1)
            else
                muted = reaper.SetMediaTrackInfo_Value(track.media_track, "B_MUTE", 0)
            end
            return muted
            -- else
            -- TODO: better error handling.
            -- reaper.ShowConsoleMsg("Could not find a track called Effects. Please try again.")
        end
    end
end

function UnmuteTrack(name)
    for _, track in ipairs(GetAllTracks()) do
        if track.name == name and track.depth == 1 then
            local mute_state = reaper.SetMediaTrackInfo_Value(track.media_track, "B_MUTE", 0)
        end
    end
end

function MuteTrack(name)
    for _, track in ipairs(GetAllTracks()) do
        if track.name == name and track.depth == 1 then
            local mute_state = reaper.SetMediaTrackInfo_Value(track.media_track, "B_MUTE", 1)
        end
    end
end
