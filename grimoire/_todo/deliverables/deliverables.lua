-- Ideally, this should be very easily user-configurable.
-- Need to have a deliverables config dir, and create those with lua?

function package_deliveries(project_dir)
    -- This function copies any renders made by render_assets() and copies them to the appropriate
    -- folder, i.e. we can define who gets what and collect everything they need.
    --
    -- TODO:
    -- Zip folders.
    -- Copy to Dropbox folder.

    local deliveries = {
        client = {
            "master_mp3",
            "master_wav",
            -- "video"
        },
        -- collaborators = {
        --     "",
        -- }
        engineer = {
            -- "click",
            "master_mp3",
            "master_wav",
            -- "midi_tempo_track_only",
            -- "wide_stems"
        },
        mx_edit = {
            "click",
            "master_mp3",
            "master_wav",
            "all_regions",
            -- "midi_tempo_track_only",
            -- "wide_stems"
        },
        orchestration = {
            -- "click",
            "master_mp3",
            "master_wav",
            -- "midi_orch_tracks_only",
            -- "skinny_stems"
        },
        session_musicians = {
            -- "click",
            "master_mp3",
            "master_wav",
            -- "midi_all_tracks",
            -- "skinny_stems"
        }
    }

    -- TODO: check if exists
    local deliveries_dir = project_dir .. "/deliveries/"
    lfs.mkdir(deliveries_dir)

    for recipient, assets in pairs(deliveries) do
        -- TODO: check if exists
        local dst_dir = deliveries_dir .. tostring(recipient)
        lfs.mkdir(dst_dir)
    end

    -- TODO: pick up here!
    -- for i, asset in ipairs(delivery) do
    -- end
end
