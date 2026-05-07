-- dofile(reaper.GetResourcePath() .. "/Scripts/rewgs-reaper-scripts/modules/project.lua")
-- local p = parse_project_name()

rt_master_wav = {
    render_table_name = "master_wav",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items; 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 0,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - mix",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "mix",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- (int) bit depth: 0, 8 Bit PCM; 1, 16 Bit PCM; 2, 24 Bit PCM; 3, 32 Bit FP; 4, 64 Bit FP; 5, 4 Bit IMA ADPCM; 6, 2 Bit cADPCM; 7, 32 Bit PCM; 8, 8 Bit u-Law
    -- (int) large files: 0, Auto WAV/Wave64; 1, Auto Wav/RF64; 2, Force WAV; 3, Force Wave64; 4, Force RF64
    -- (int) bwf_chunk (write 'bext' chunk and include project filename in BWF data - checkboxes): 0, unchecked - unchecked; 1, checked - unchecked; 2, unchecked - checked; 3, checked - checked
    -- (int) the "include markers" dropdown list: 0, Do not include markers and regions; 1, Markers + regions; 2, Markers + regions starting with #; 3, Markers only; 4, Markers starting with # only; 5, Regions only; 6, Regions starting with # only
    -- (bool) embed tempo-checkbox; true, checked; false, unchecked
    render_string = ultraschall.CreateRenderCFG_WAV(24, 2, 1, 0, false),
    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}


rt_master_mp3 = {
    render_table_name = "master_mp3",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items; 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 0,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - mix",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "mix",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    render_string = ultraschall.CreateRenderCFG_MP3MaxQuality(),
    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}


-- FIXME: not yet working, always setting to wav, not video...the problem probably lies in the render string
-- TODO: normalize it to -24 LUFS; also does this for audio demos
rt_video = {
    render_table_name = "video",

    -- from old function; keeping for now
    -- framerate, has_drop_frame = reaper.TimeMap_curFrameRate(0)

    -- 0, Master mix(default); 1, Master mix + stems; 3, Stems (selected tracks); 8, Region render matrix; 32, Selected media items; 256, Embed stretch markers/transient guides-checkbox=on; optional, as parameter EmbedStretchMarkers is meant for that
    source = 0,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = "$project",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version,
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- integer the videocodec used for the video:
    -- 1, MJPEG
    -- 2, H.264(needs FFMPEG 4.1.3 installed)
    -- 3, MPEG-2(needs FFMPEG 4.1.3 installed)
    -- 4, NONE
    --
    -- integer MJPEG_quality:
    -- set here the MJPEG-quality in percent
    --
    -- integer AudioCodec
    -- the audiocodec to use for the video
    -- 1, 16 bit PCM
    -- 2, 24 bit PCM
    -- 3, 32 bit FP
    -- 4, AAC(needs FFMPEG 4.1.3 installed)
    -- 5, MP3(needs FFMPEG 4.1.3 installed)
    -- 6, NONE
    --
    -- integer WIDTH
    -- the width of the video in pixels; 1 to 2147483647; only even values(2,4,6,etc) will be accepted by Reaper, uneven will be rounded up!
    --
    -- integer HEIGHT
    -- the height of the video in pixels; 1 to 2147483647; only even values(2,4,6,etc) will be accepted by Reaper, uneven will be rounded up!
    --
    -- number FPS
    -- the fps of the video; must be a double-precision-float value (e.g. 9.09 or 25.00); 0.01 to 2000.00
    --
    -- boolean AspectRatio
    -- the aspect-ratio; true, keep source aspect ratio; false, don't keep source aspect ratio
    --
    -- optional integer VIDKBPS
    -- the video-bitrate of the video in kbps; 1 to 2147483647(default 2048)
    --
    -- optional integer AUDKBPS
    -- the video-bitrate of the video in kbps; 1 to 2147483647(default 128)
    --
    -- optional string VideoOptions
    -- additional FFMPEG-options for rendering the video; examples:
    -- g=1 ; all keyframes
    -- crf=1  ; h264 high quality
    -- crf=51 ; h264 small size
    --
    -- optional string AudioOptions
    -- additional FFMPEG-options for rendering the video; examples:
    -- q=0 ; mp3 VBR highest
    -- q=9 ; mp3 VBR lowest
    -- render_string = ultraschall.CreateRenderCFG_QTMOVMP4_Video(2, 100, 2, 1920, 1080, frame_rate, true),
    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}


rt_stems = {
    render_table_name = "stems",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items; 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 128,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - $track",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "$track",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- (int) bit depth: 0, 8 Bit PCM; 1, 16 Bit PCM; 2, 24 Bit PCM; 3, 32 Bit FP; 4, 64 Bit FP; 5, 4 Bit IMA ADPCM; 6, 2 Bit cADPCM; 7, 32 Bit PCM; 8, 8 Bit u-Law
    -- (int) large files: 0, Auto WAV/Wave64; 1, Auto Wav/RF64; 2, Force WAV; 3, Force Wave64; 4, Force RF64
    -- (int) bwf_chunk (write 'bext' chunk and include project filename in BWF data - checkboxes): 0, unchecked - unchecked; 1, checked - unchecked; 2, unchecked - checked; 3, checked - checked
    -- (int) the "include markers" dropdown list: 0, Do not include markers and regions; 1, Markers + regions; 2, Markers + regions starting with #; 3, Markers only; 4, Markers starting with # only; 5, Regions only; 6, Regions starting with # only
    -- (bool) embed tempo-checkbox; true, checked; false, unchecked
    render_string = ultraschall.CreateRenderCFG_WAV(24, 2, 1, 0, false),

    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}

-- NOTE: same as rt_stems, except silently_increment_filename is true
rt_multitrack = {
    render_table_name = "multitrack",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items; 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 128,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - $track",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "$track",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- (int) bit depth: 0, 8 Bit PCM; 1, 16 Bit PCM; 2, 24 Bit PCM; 3, 32 Bit FP; 4, 64 Bit FP; 5, 4 Bit IMA ADPCM; 6, 2 Bit cADPCM; 7, 32 Bit PCM; 8, 8 Bit u-Law
    -- (int) large files: 0, Auto WAV/Wave64; 1, Auto Wav/RF64; 2, Force WAV; 3, Force Wave64; 4, Force RF64
    -- (int) bwf_chunk (write 'bext' chunk and include project filename in BWF data - checkboxes): 0, unchecked - unchecked; 1, checked - unchecked; 2, unchecked - checked; 3, checked - checked
    -- (int) the "include markers" dropdown list: 0, Do not include markers and regions; 1, Markers + regions; 2, Markers + regions starting with #; 3, Markers only; 4, Markers starting with # only; 5, Regions only; 6, Regions starting with # only
    -- (bool) embed tempo-checkbox; true, checked; false, unchecked
    render_string = ultraschall.CreateRenderCFG_WAV(24, 2, 1, 0, false),

    silently_increment_filename = true,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}


rt_regions = {
    render_table_name = "all_regions",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items;
    -- 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 64,

    -- 0, Custom time range;
    -- 1, Entire project(default);
    -- 2, Time selection;
    -- 3, Project regions;
    -- 4, Selected Media Items(in combination with Source 32);
    -- 5, Selected regions;
    -- 6, Razor edit areas;
    -- 7, All project markers;
    -- 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - $track" .. " - $item",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "$track" .. names.delimiter .. "$item",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default);
    -- 1, 1x Offline;
    -- 2, Online Render;
    -- 3, Online Render(Idle);
    -- 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation:
    -- 1, Linear Interpolation: (low quality);
    -- 2, Point Sampling (lowest quality, retro);
    -- 3, Sinc Interpolation: 192pt;
    -- 4, Sinc Interpolation: 384pt;
    -- 5, Linear Interpolation + IIR;
    -- 6, Linear Interpolation + IIRx2;
    -- 7, Sinc Interpolation: 16pt;
    -- 8, Sinc Interpolation: 512pt(slow);
    -- 9, Sinc Interpolation:
    -- 768pt(very slow);
    -- 64pt (medium quality);
    -- 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- (int) bit depth: 0, 8 Bit PCM; 1, 16 Bit PCM; 2, 24 Bit PCM; 3, 32 Bit FP; 4, 64 Bit FP; 5, 4 Bit IMA ADPCM; 6, 2 Bit cADPCM; 7, 32 Bit PCM; 8, 8 Bit u-Law
    -- (int) large files: 0, Auto WAV/Wave64; 1, Auto Wav/RF64; 2, Force WAV; 3, Force Wave64; 4, Force RF64
    -- (int) bwf_chunk (write 'bext' chunk and include project filename in BWF data - checkboxes): 0, unchecked - unchecked; 1, checked - unchecked; 2, unchecked - checked; 3, checked - checked
    -- (int) the "include markers" dropdown list: 0, Do not include markers and regions; 1, Markers + regions; 2, Markers + regions starting with #; 3, Markers only; 4, Markers starting with # only; 5, Regions only; 6, Regions starting with # only
    -- (bool) embed tempo-checkbox; true, checked; false, unchecked
    render_string = ultraschall.CreateRenderCFG_WAV(24, 2, 3, 0, true),

    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}

rt_mix_minus = {
    render_table_name = "mix_minus",

    -- 0, Master mix;
    -- 1, Master mix + stems;
    -- 3, Stems (selected tracks);
    -- 8, Region render matrix;
    -- 16, Tracks with only Mono-Media to Mono Files;
    -- 32, Selected media items; 64, selected media items via master;
    -- 128, selected tracks via master
    -- 4096, Razor edit areas
    -- 4224, Razor edit areas via master
    source = 0,

    -- 0, Custom time range; 1, Entire project(default); 2, Time selection; 3, Project regions; 4, Selected Media Items(in combination with Source 32); 5, Selected regions; 6, Razor edit areas; 7, All project markers; 8, Selected markers
    bounds = 2,
    start_pos = 0,
    end_pos = 0,
    tail_flag = 1,
    tail_ms = 0,
    -- file_name = names.convention .. " - mix",
    file_name = p.project_code .. names.delimiter .. p.cue_number .. names.delimiter .. p.cue_name .. names.delimiter .. p.cue_version .. names.delimiter .. "$starttc" .. names.delimiter .. "mix",
    sample_rate = 48000,
    channels = 2,

    -- 0, Full-speed Offline(default); 1, 1x Offline; 2, Online Render; 3, Online Render(Idle); 4, Offline Render(Idle)
    render_type = 0,
    project_sample_rate_fx_processing = true,

    -- 0, Sinc Interpolation: 64pt (medium quality); 1, Linear Interpolation: (low quality); 2, Point Sampling (lowest quality, retro); 3, Sinc Interpolation: 192pt; 4, Sinc Interpolation: 384pt; 5, Linear Interpolation + IIR; 6, Linear Interpolation + IIRx2; 7, Sinc Interpolation: 16pt; 8, Sinc Interpolation: 512pt(slow); 9, Sinc Interpolation: 768pt(very slow); 10, r8brain free (highest quality, fast)
    render_resample = 10,
    keep_mono = true,
    keep_multichannel = true,

    -- 0 = none; &1, dither master mix; &2, noise shaping master mix; &4, dither stems; &8, dither noise shaping stems
    dither = 0,

    -- args:
    -- (int) bit depth: 0, 8 Bit PCM; 1, 16 Bit PCM; 2, 24 Bit PCM; 3, 32 Bit FP; 4, 64 Bit FP; 5, 4 Bit IMA ADPCM; 6, 2 Bit cADPCM; 7, 32 Bit PCM; 8, 8 Bit u-Law
    -- (int) large files: 0, Auto WAV/Wave64; 1, Auto Wav/RF64; 2, Force WAV; 3, Force Wave64; 4, Force RF64
    -- (int) bwf_chunk (write 'bext' chunk and include project filename in BWF data - checkboxes): 0, unchecked - unchecked; 1, checked - unchecked; 2, unchecked - checked; 3, checked - checked
    -- (int) the "include markers" dropdown list: 0, Do not include markers and regions; 1, Markers + regions; 2, Markers + regions starting with #; 3, Markers only; 4, Markers starting with # only; 5, Regions only; 6, Regions starting with # only
    -- (bool) embed tempo-checkbox; true, checked; false, unchecked
    render_string = ultraschall.CreateRenderCFG_WAV(24, 2, 1, 0, false),
    silently_increment_filename = false,
    add_to_proj = false,
    save_copy_of_project = false,
    render_queue_delay = false,
    render_queue_delay_seconds = 0,

    -- refers to closing the dialog, not the Reaper project
    close_after_render = true,
}

render_tables = {
    master_wav = rt_master_wav,
    master_mp3 = rt_master_mp3,
    mix_minus = rt_mix_minus,
    stems = rt_stems,
    video = rt_video
}

return render_tables
