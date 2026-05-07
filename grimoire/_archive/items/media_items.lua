-- FIXME: This is conflicting with Jon's workflow; perhaps ask for user input?
function set_bounds_to_items(args)
    -- `set_bounds_to_items()` takes a table called `args` for easier passing of named arguments.
    -- Calling it with an empty `{}` denotes that all of the default parameter values will be used.
    -- For more, see here: https://www.lua.org/pil/5.3.html 
    -- (If the link above ends up invalid at any point, it's "Programming in Lua" Chapter 5.3: "Named Arguments")

    -- args
    local audio = args.audio or true                                                              -- default: true
    local click = args.click or false                                                             -- default: false
    local empty = args.empty or false                                                             -- default: false
    local midi = args.midi or true                                                                -- default: true
    local video = args.video or false                                                             -- default: false
    local ignore_movie_folder = args.ignore_movie_folder or true                                  -- default: true
    local clear_track_selection_after_running = args.clear_track_selection_after_running or false -- default: false

    -- Transport: Stop
    reaper.Main_OnCommand(1016, 0)

    -- 'Script: Track Visibility - Show all tracks.lua'
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_RSdf5deea70710b2bb6a464cbab98fb628980c0ab1"), 0)

    ----------------------------------------------------------------------------
    -- type selection
    ----------------------------------------------------------------------------

    -- SWS/BR: Select all audio items
    if audio then reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SEL_ALL_ITEMS_AUDIO"), 0) end

    -- SWS/BR: Select all click source items
    if click then reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SEL_ALL_ITEMS_CLICK"), 0) end

    -- SWS/BR: Select all empty items
    if empty then reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SEL_ALL_ITEMS_EMPTY"), 0) end

    -- SWS/BR: Select all MIDI items
    if midi then reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SEL_ALL_ITEMS_MIDI"), 0) end

    -- _BR_SEL_ALL_ITEMS_VIDEO
    if video then reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SEL_ALL_ITEMS_VIDEO"), 0) end

    ----------------------------------------------------------------------------
    -- ignore_movie_folder
    ----------------------------------------------------------------------------
    if ignore_movie_folder then
        local total_num_tracks = reaper.CountTracks(0)

        for i = 0, total_num_tracks - 1 do
            local track = reaper.GetTrack(0, i)
            local _, track_name = reaper.GetTrackName(track)

            -- 0 = normal, 1 = track is a folder parent, -1 = track is the last in the innermost
            -- folder, -2 = track is the last in the innermost and next-innermost folders, etc...
            local depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
            local parent_track = reaper.GetMediaTrackInfo_Value(track, "P_PARTRACK")
            local parent_track_name = get_parent_track_name(parent_track)

            if track_name == "Movie" and depth == 1 then
                reaper.SetTrackSelected(track, false)
                local num_media_items = reaper.CountTrackMediaItems(track)

                for j = 0, num_media_items - 1 do
                    local item = reaper.GetTrackMediaItem(track, j)

                    -- B_UISEL : bool * : selected in arrange view
                    if reaper.GetMediaItemInfo_Value(item, "B_UISEL") then
                        reaper.SetMediaItemInfo_Value(item, "B_UISEL", 0)
                    end
                end
            end

            if parent_track_name == "Movie" then
                reaper.SetTrackSelected(track, false)
                local num_media_items = reaper.CountTrackMediaItems(track)

                for j = 0, num_media_items - 1 do
                    local item = reaper.GetTrackMediaItem(track, j)

                    -- B_UISEL : bool * : selected in arrange view
                    if reaper.GetMediaItemInfo_Value(item, "B_UISEL") then
                        reaper.SetMediaItemInfo_Value(item, "B_UISEL", 0)
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------------
    -- continue
    ----------------------------------------------------------------------------

    -- TODO: give user input for this/make into arg. Jon needs this to not be enabled for now in 
    -- order for export-audio functions to work, so commenting this out is the short-term solution.
    -- reaper.Main_OnCommand(40290, 0) -- 'Time selection: Set time selection to items'

    -- NOTE: not sure which one of these is the move? Choose one of these three.
    -- 'Script: Track Visibility - Show only tracks with items.lua'
    -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS18025988e0ed4e2830abe9a10d91e47698d54b71"), 0)
    -- 'Script: Track Visibility - Show only selected tracks'
    -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS8f15fdf2ab91fdd3ef930734225dd0ebdcdc4fc4"), 0)
    -- 'Script: Track Visibility - Show only tracks with selected items'
    -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS8372596f61228813cb56a5f174ace6a8da5c5167"), 0)

    -- Item: Unselect (clear selection of) all items
    -- reaper.Main_OnCommand(40289, 0)

    if clear_track_selection_after_running then
        -- Track: Unselect (clear selection of) all tracks
        reaper.Main_OnCommand(40297, 0)
    end

    -- Go to start of time selection
    reaper.Main_OnCommand(40630, 0)
end


-- local unmuted_media_items = {}
-- for m = 0, num_media_items - 1 do
--     local media_item = reaper.GetMediaItem(0, m)
--     local mute_state = reaper.GetMediaItemInfo_Value(media_item, "B_MUTE_ACTUAL")
--     if mute_state == false then
--         local unmuted_media_item_obj = {
--             media_item = media_item,
--             index = m
--         }
--         table.insert(unmuted_media_items, unmuted_media_item_obj)
--     end
-- end
--
-- local track_obj = {
--     media_track = media_track,
--     number = i,
--     name = track_name,
--     depth = depth,
--     parent = parent,
--     num_media_items = num_media_items,
--     unmuted_media_items = unmuted_media_items
-- }
--
-- tracks
--      track
--          unmuted media items
--              media_item
--              index
function get_unmuted_regions(all_tracks)
    -- reaper.ShowConsoleMsg("Running get_unmuted_regions()")
    local unmuted_regions = {}

    for i, track in ipairs(all_tracks) do
        -- reaper.ShowConsoleMsg("Running for loop; current track: " .. track.name .. "\n")
        if (track.num_media_items > 0) then
            -- reaper.ShowConsoleMsg(track.name .. " has 1 or more media items.\n")
            -- local media_items = track.unmuted_media_items
            reaper.ShowConsoleMsg(track.unmuted_media_items.index)
            -- for i, media_item in ipairs(media_items) do
            --     reaper.ShowConsoleMsg(media_item.index)
            -- end
        end
    end
end
