--[[
    thumbz.lua - seekbar thumbnails for ModernGlass

    How it works
      A background mpv (the "renderer") decodes frames and writes them as small raw
      BGRA images; they are shown with overlay-add. A short Lua scheduler runs inside
      the renderer, so requests are handled there without round trips.

      * Storyboard: from the first seekbar hover on, the renderer pre-renders keyframe
        thumbnails across the whole file in idle moments, coarse to fine, so the bar
        fills in evenly. Any hover then shows the nearest one immediately.
      * Cache: every rendered thumbnail stays on disk for the current file, so
        revisiting a position costs nothing. Every keyframe render also teaches which
        stretch of the file starts at that keyframe, so a hover anywhere in that
        stretch reuses the image instead of decoding the same keyframe again.
      * Scheduling: only the newest request is ever rendered (no backlog while
        scrubbing). Keyframe frames while the pointer moves; the exact frame once it
        rests. Exact decodes and storyboard work are abandoned the moment a newer
        hover comes in.
      * HDR is tone-mapped at thumbnail size, not at full video resolution.
      * No helper programs: requests go through a small file, with a named-pipe
        wake-up on Windows.

    Messages (sent by ModernZ)
      script-message-to thumbz hover <time> <x> <y>   show the thumbnail for <time> at x, y
      script-message-to thumbz hide                    remove it
      script-message-to thumbz prepare                 the OSC appeared: start the renderer early
    Broadcast
      script-message thumbz-info <json: width, height, disabled>

    Options: script-opts/thumbz.conf
    Inspired by thumbfast (https://github.com/po5/thumbfast); written from scratch.
--]]

local utils = require "mp.utils"
local msg = require "mp.msg"

local o = {
    max_width = 200,          -- largest thumbnail size in pixels (before hidpi scaling)
    max_height = 200,
    hidpi = true,             -- scale the thumbnail size with display-hidpi-scale
    display_scale = 1,        -- draw thumbnails this much larger than rendered (mpv 0.38+)
    precise = "yes",          -- exact frame once the pointer rests: yes, auto (only if the keyframe is far off), no
    rest_delay = 0.05,        -- seconds the pointer must rest before the exact frame is rendered
    exact_below = 30,         -- files shorter than this many seconds always use exact frames
    storyboard = 120,         -- thumbnails pre-rendered across the file once the seekbar is hovered (0 = off)
    storyboard_gap = 5,       -- at least this many seconds between storyboard thumbnails
    cache_size = 200,         -- thumbnails kept on disk for the current file (minimum 2)
    hwdec = "auto",           -- renderer decoding: auto (same hardware decoder as the player), no, or an mpv --hwdec value
    threads = 2,              -- decoder threads in the renderer for software decoding (0 = automatic)
    scaler = "bilinear",      -- downscaling: fast_bilinear, bilinear, bicubic, area
    tone_mapping = "auto",    -- HDR to SDR: auto, no, clip, linear, gamma, reinhard, hable, mobius
    priority = "belownormal", -- renderer process priority: idle, belownormal, normal (Windows, Linux, macOS)
    network = false,          -- also create thumbnails for network streams
    audio = false,            -- also create thumbnails for audio files with cover art
    idle_quit = 300,          -- seconds without requests before the renderer quits (0 = never)
    overlay_id = 42,          -- overlay-add id (0-63)
    mpv_path = "mpv",         -- mpv executable for the renderer
    tmp_dir = "",             -- folder for temporary files (empty = system temp folder)
}
require("mp.options").read_options(o, "thumbz")

o.cache_size = math.max(2, math.floor(o.cache_size))
o.storyboard = math.max(0, math.min(o.cache_size, math.floor(o.storyboard)))
o.overlay_id = math.max(0, math.min(63, math.floor(o.overlay_id)))

local platform = mp.get_property("platform") or (package.config:sub(1, 1) == "\\" and "windows" or "linux")
local is_windows = platform == "windows"
local pid = utils.getpid()

------------------------------------------------------------------------------
-- File locations (unique per player instance)
------------------------------------------------------------------------------

local function temp_folder()
    local dir = o.tmp_dir
    if dir == "" then
        dir = is_windows and (os.getenv("TEMP") or os.getenv("TMP") or ".")
            or (os.getenv("TMPDIR") or "/tmp")
    end
    return (dir:gsub("[/\\]+$", ""))
end

local sep = is_windows and "\\" or "/"
local folder = temp_folder()
local prefix = "thumbz_" .. pid
local base = folder .. sep .. prefix

-- rendered thumbnails: <base>_<id>.bgra
local function job_path(id) return base .. "_" .. id .. ".bgra" end

-- files of one renderer run; every run gets its own set, so a renderer that is
-- still shutting down can never see the next run's requests
local function run_files(n)
    local run = base .. "_r" .. n
    return {
        name = prefix .. "_r" .. n,  -- the scheduler's script name and the IPC pipe name
        helper = run .. ".lua",      -- scheduler script loaded by the renderer
        cmd = run .. ".cmd",         -- requests: main player -> renderer
        res = run .. ".res",         -- results:  renderer -> main player
        out_prefix = run .. "_",     -- encoder output: <out_prefix><n>.out, one file per frame
    }
end

------------------------------------------------------------------------------
-- Scheduler that runs inside the renderer
------------------------------------------------------------------------------

local scheduler_source = [=[
-- thumbz scheduler: runs inside the renderer and renders requested frames.
-- While paused, mpv encodes exactly one frame per completed seek, and every frame
-- gets its own numbered file, so completed seeks and frame files line up one-to-one
-- and in order. That makes it safe to abandon a slow seek for a newer request.
local CMD, RES, OUT_PREFIX, JOB, IDLE_QUIT = %q, %q, %q, %q, %d
local utils = require "mp.utils"

local function report(line)
    -- opened per write so the main player can always delete the file, and never
    -- recreated once it has (the main player stopped this renderer)
    if not utils.file_info(RES) then return end
    local f = io.open(RES, "ab")
    if f then
        f:write(line, "\n")
        f:close()
    end
end

local frame_bytes = 0        -- expected size of one frame
local next_frame = 1         -- number of the next frame file the encoder writes
local issued = nil           -- seek sent, mpv hasn't started it yet
local executing = nil        -- seek in progress
local pending = nil          -- newest request, waiting to be sent
local waiting = {}           -- seeks that completed, waiting for their frame file
local cmd_pos, cmd_rest = 0, ""
local last_activity = mp.get_time()

-- watchdog: a seek that never completes (broken filter, unreadable spot in the file)
-- must not block every request after it
local resync = false         -- frame numbering may be off after a stalled seek
local watchdog
local function arm(seconds)
    watchdog:kill()
    watchdog.timeout = seconds
    watchdog:resume()
end

local function issue(job)
    issued = job
    arm(6)
    mp.commandv("seek", job.time, job.exact and "absolute+exact" or "absolute+keyframes")
end

-- may this request replace the seek that is running? Only interruptible work (exact
-- frames on rest, storyboard). mpv lets a seek younger than 0.3 s finish before it
-- starts the next one, so replacing a quick keyframe seek would gain nothing.
local function replaces(running, job)
    return running.interruptible
end

-- move finished frames to their job's file, oldest first
local collecting = false
local function collect()
    if collecting then return end
    collecting = true
    local function check()
        local job = waiting[1]
        if not job then collecting = false return end
        if resync and utils.file_info(OUT_PREFIX .. next_frame .. ".out") then
            -- a stalled seek may have delivered its frame late: the newest file is ours
            while utils.file_info(OUT_PREFIX .. (next_frame + 1) .. ".out") do
                os.remove(OUT_PREFIX .. next_frame .. ".out")
                next_frame = next_frame + 1
            end
            resync = false
        end
        local path = OUT_PREFIX .. next_frame .. ".out"
        local info = utils.file_info(path)
        if info and info.size >= frame_bytes then
            table.remove(waiting, 1)
            next_frame = next_frame + 1
            local dest = JOB .. job.id .. ".bgra"
            os.remove(dest)
            if job.discard then
                os.remove(path)
                report("skip " .. job.id)
            elseif info.size == frame_bytes and os.rename(path, dest) then
                report(string.format("done %%d %%.3f", job.id, job.actual or job.time))
            else
                os.remove(path)
                report(info.size == frame_bytes and ("fail " .. job.id) or ("badsize " .. info.size .. " " .. job.id))
            end
            check()
        elseif mp.get_time() > job.deadline then
            -- no frame came for this seek; keep the frame numbering where it is
            table.remove(waiting, 1)
            report("fail " .. job.id)
            check()
        else
            mp.add_timeout(0.002, check)
        end
    end
    check()
end

mp.register_event("seek", function()
    if not issued then return end  -- e.g. the initial --start seek
    if executing then report("skip " .. executing.id) end  -- abandoned by mpv
    executing, issued = issued, nil
    -- the seek mpv just started may be replaced again right away
    if pending and replaces(executing, pending) then
        local job = pending
        pending = nil
        issue(job)
    end
end)

local told_decoder = false
mp.register_event("playback-restart", function()
    if not told_decoder then
        told_decoder = true
        report("dec " .. (mp.get_property("hwdec-current") or "no"))
    end
    local job = executing
    if not job then return end
    executing = nil
    if issued then
        -- mpv let this seek finish but has already started the newer one, so time-pos
        -- belongs to that one: exact frames are at their target anyway, but which
        -- keyframe this was is unknown, so that frame is dropped
        if job.exact then job.actual = job.time else job.discard = true end
    else
        watchdog:kill()
        job.actual = mp.get_property_number("time-pos", job.time)
    end
    job.deadline = mp.get_time() + 3
    waiting[#waiting + 1] = job
    collect()
    if pending and not issued then
        local next_job = pending
        pending = nil
        issue(next_job)
    end
end)

local function request(job)
    if issued or (executing and not replaces(executing, job)) then
        if pending then report("skip " .. pending.id) end
        pending = job  -- sent as soon as mpv is ready for it
    else
        issue(job)     -- idle, or abandoning interruptible work
    end
end

watchdog = mp.add_timeout(6, function()
    if not (executing or issued) then return end
    if executing then report("fail " .. executing.id) end
    if issued then report("fail " .. issued.id) end
    executing, issued = nil, nil
    resync = true
    if pending then
        local next_job = pending
        pending = nil
        issue(next_job)
    end
end)
watchdog:kill()

-- kinds: fast = keyframe, exact = exact, refine = exact but interruptible,
--        bg = keyframe storyboard work, interruptible
local function handle_lines(data)
    local newest
    for line in data:gmatch("([^\n]*)\n") do
        local cmd, a, b, c = line:match("^(%%S+)%%s*(%%S*)%%s*(%%S*)%%s*(%%S*)")
        if cmd == "req" then
            if newest then report("skip " .. newest.id) end
            newest = {id = tonumber(a), time = tonumber(b), exact = c == "exact" or c == "refine",
                      interruptible = c == "refine" or c == "bg"}
        elseif cmd == "init" then
            -- the first frame comes from --start, without a seek of ours
            executing = {id = tonumber(a), time = tonumber(b)}
            frame_bytes = tonumber(c) or 0
            arm(15)  -- opening the file can take a while (network, slow disks)
        elseif cmd == "quit" then
            mp.command("quit")
        end
    end
    -- only the newest request matters; anything older is already out of date
    if newest then request(newest) end
end

local function read_commands()
    local info = utils.file_info(CMD)
    if not info then
        mp.command("quit")  -- the main player is gone
        return false
    end
    if info.size <= cmd_pos then return false end
    local f = io.open(CMD, "rb")
    if not f then return false end
    f:seek("set", cmd_pos)
    local data = f:read("*a") or ""
    f:close()
    cmd_pos = cmd_pos + #data
    data = cmd_rest .. data
    cmd_rest = data:match("[^\n]*$")
    handle_lines(data)
    last_activity = mp.get_time()
    return true
end

-- poll quickly while requests are coming in, back off when idle
local timer
timer = mp.add_periodic_timer(0.008, function()
    read_commands()
    local idle = mp.get_time() - last_activity
    if IDLE_QUIT > 0 and idle > IDLE_QUIT and not (issued or executing or waiting[1]) then
        mp.command("quit")
        return
    end
    local interval = idle < 3 and 0.008 or (idle < 30 and 0.1 or 0.5)
    if timer.timeout ~= interval then
        timer.timeout = interval
        timer:kill()
        timer:resume()
    end
end)

-- on Windows the main player pokes us through the IPC pipe for instant pickup
mp.register_script_message("poke", read_commands)

read_commands()
report("hello")
]=]

------------------------------------------------------------------------------
-- State
------------------------------------------------------------------------------

local props = {}
local size = nil              -- {w, h, rot, bytes} of rendered thumbnails
local disabled = true
local broken = false          -- no renderer could be started this session
local no_tonemap = false      -- HDR filters unavailable in this mpv's FFmpeg
local announced = nil

local gen = 0                 -- bumps on every file/config change
local step = 1                -- seconds per cache slot (fixed per generation)
local signature = nil         -- render configuration the cache belongs to

local run = nil               -- files of the current renderer run
local run_count = 0
local spawned = false
local ready = false           -- the scheduler is running (Windows pokes can go out)
local alive = false           -- the renderer has decoded the file
local failures = 0            -- renderer runs that never got going
local cmd_fh, pipe_fh = nil, nil
local res_pos, res_rest = 0, ""

local next_id = 1
local jobs = {}               -- id -> {slot, time, exact, gen, init, bg}
-- rendered thumbnails, by id: "e<slot>" = exact frame for a cache slot,
-- "k<ms>" = a keyframe; entries are {path, exact, actual, used}
local cache = {}
local cache_count = 0
-- what keyframe seeks have taught: {k, upto} = every time in [k, upto] starts at keyframe k
local spans = {}
local storyboard = {order = nil, pos = 1, active = false}

local visible = false
local interest = -math.huge   -- last time the user showed the OSC or hovered the seekbar
local want = nil              -- {time, slot, x, y, refined}
local last_slot = nil
local resting = false         -- the pointer has rested on the current position
local shown = nil             -- {path, x, y} currently drawn

local poll_timer, rest_timer, config_timer
local reconfigure

------------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------------

local function round(v) return math.floor(v + 0.5) end

local doomed = {}              -- files waiting for remove_later
local function remove_later(path)
    -- an overlay-add for this file may still be queued, so delete it a moment later
    doomed[path] = true
    mp.add_timeout(1, function()
        doomed[path] = nil
        os.remove(path)
    end)
end

local function has_option(name)
    return mp.get_property("options/" .. name) ~= nil
end

local function exact_mode()
    return (props.duration or 0) < o.exact_below
end

local function slot_for(time)
    return math.floor(time / step + 0.5)
end

local function keyframe_id(actual)
    return "k" .. math.floor(actual * 1000 + 0.5)
end

------------------------------------------------------------------------------
-- Size, filters and what the thumbnails should look like
------------------------------------------------------------------------------

local function compute_size()
    local p = props["video-out-params"]
    if not p or not p.dw or not p.dh or p.dw <= 0 or p.dh <= 0 then return nil end
    local dw, dh = p.dw, p.dh
    -- final (displayed) orientation: video-out-params is still unrotated when the
    -- player's video output does the rotation itself (vo=gpu, gpu-next)
    if ((p.rotate or 0) % 180) == 90 then dw, dh = dh, dw end
    -- the renderer always rotates its frames after our filters (video-params.rotate
    -- includes --video-rotate), so those have to scale in the unrotated orientation
    local vp = props["video-params"]
    local rot = ((vp and vp.rotate or 0) % 180) == 90
    local scale = (o.hidpi and props["display-hidpi-scale"]) or 1
    local mw, mh = o.max_width * scale, o.max_height * scale
    local w, h
    if dw * mh > dh * mw then
        w, h = mw, mw * dh / dw
    else
        w, h = mh * dw / dh, mh
    end
    w, h = math.max(2, round(w)), math.max(2, round(h))
    return {w = w, h = h, rot = rot, bytes = w * h * 4}
end

local function tone_map_active()
    if o.tone_mapping == "no" or no_tonemap then return false end
    local vp = props["video-params"]
    local gamma = vp and vp.gamma
    return gamma == "pq" or gamma == "hlg"
end

local tone_curves = {clip = true, linear = true, gamma = true, reinhard = true, hable = true, mobius = true}

local function build_vf(sz)
    local chain = {}

    -- mirror the main player's flips
    for _, f in ipairs(props.vf or {}) do
        if f.enabled ~= false and (f.name == "hflip" or f.name == "vflip") then
            chain[#chain + 1] = f.name
        end
    end

    -- then crop to the area the player shows (--video-crop, or the file's own crop):
    -- mpv crops after the filters, in pixels of the filtered frame, and the renderer's
    -- encoder output ignores crop, so it has to be a filter here
    local p = props["video-out-params"]
    local cw, ch = p and p["crop-w"], p and p["crop-h"]
    if cw and ch and cw > 0 and ch > 0 and (cw < (p.w or cw) or ch < (p.h or ch)) then
        chain[#chain + 1] = string.format("crop=w=%d:h=%d:x=%d:y=%d", cw, ch, p["crop-x"] or 0, p["crop-y"] or 0)
    end

    -- downscale first; mpv rotates after user filters, so scale in source orientation
    local sw, sh = sz.w, sz.h
    if sz.rot then sw, sh = sh, sw end
    chain[#chain + 1] = string.format("scale=w=%d:h=%d:flags=%s", sw, sh, o.scaler)

    -- tone-map at thumbnail size, which is far cheaper than at full resolution
    if tone_map_active() then
        local curve = tone_curves[o.tone_mapping] and o.tone_mapping or "hable"
        -- 4:4:4 first: zscale rejects odd sizes (e.g. 200x113) in subsampled formats
        chain[#chain + 1] = "format=yuv444p10le,zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709," ..
            "tonemap=tonemap=" .. curve .. ":desat=0,zscale=t=bt709:m=bt709:r=pc,format=bgra"
        -- all in one FFmpeg graph: in --vf, "format" is mpv's own converter, and splitting
        -- the chain there would carry linear light through 10-bit YUV (wrong colors, banding)
        return "lavfi=[" .. table.concat(chain, ",") .. "]"
    end

    chain[#chain + 1] = "format=bgra"
    return table.concat(chain, ",")
end

local function media_path()
    local path = props.path
    local open_name = props["stream-open-filename"]
    -- for ytdl and similar, open the resolved stream rather than the page URL
    if props["demuxer-via-network"] and open_name and open_name ~= path then
        return open_name
    end
    return path
end

local function compute_disabled()
    if broken or not size or not props.path then return true end
    local track = props["current-tracks/video"]
    if not track or not props.vid then return true end
    if track.albumart then
        if not o.audio then return true end
    elseif track.image then
        return true  -- still image
    end
    if props["demuxer-via-network"] and not o.network then return true end
    if (props.duration or 0) <= 0 then return true end
    return false
end

local function announce()
    local w = size and round(size.w * o.display_scale) or 0
    local h = size and round(size.h * o.display_scale) or 0
    local state_key = w .. "x" .. h .. (disabled and "d" or "e")
    if state_key == announced then return end
    announced = state_key
    mp.commandv("script-message", "thumbz-info",
        utils.format_json({width = w, height = h, disabled = disabled}))
end

------------------------------------------------------------------------------
-- Drawing
------------------------------------------------------------------------------

local function draw(path, x, y)
    if shown and shown.path == path and shown.x == x and shown.y == y then return end
    shown = {path = path, x = x, y = y}
    local w, h = size.w, size.h
    local args = {"overlay-add", o.overlay_id, x, y, path, 0, "bgra", w, h, 4 * w}
    if o.display_scale ~= 1 then
        args[#args + 1] = round(w * o.display_scale)
        args[#args + 1] = round(h * o.display_scale)
    end
    mp.command_native_async(args, function() end)
end

local function remove_overlay()
    if shown then
        shown = nil
        mp.command_native_async({"overlay-remove", o.overlay_id}, function() end)
    end
end

------------------------------------------------------------------------------
-- Cache: rendered thumbnails stay on disk, least recently used ones are dropped
------------------------------------------------------------------------------

local function flush_cache()
    for _, entry in pairs(cache) do remove_later(entry.path) end
    cache, cache_count, spans = {}, 0, {}
end

local function evict_one()
    local oldest_id, oldest
    for id, entry in pairs(cache) do
        if not (shown and shown.path == entry.path) and (not oldest or entry.used < oldest.used) then
            oldest_id, oldest = id, entry
        end
    end
    if oldest then
        cache[oldest_id] = nil
        cache_count = cache_count - 1
        remove_later(oldest.path)
    end
end

local function store(id, entry)
    local old = cache[id]
    if old then
        remove_later(old.path)
    else
        cache_count = cache_count + 1
        if cache_count > o.cache_size then evict_one() end
    end
    cache[id] = entry
end

-- a keyframe seek to `target` landed on `actual`: nothing in between is a keyframe,
-- so every time in [actual, target] starts from that same keyframe
local function learn_keyframe(target, actual)
    local upto = math.max(target, actual)
    for _, span in ipairs(spans) do
        if math.abs(span.k - actual) < 0.0005 then
            if upto > span.upto then span.upto = upto end
            return
        end
    end
    spans[#spans + 1] = {k = actual, upto = upto}
end

local function keyframe_for(time)
    for _, span in ipairs(spans) do
        if time >= span.k - 0.0005 and time <= span.upto + 0.0005 then return span.k end
    end
    return nil
end

local function half_frame()
    return 0.5 / (props["container-fps"] or 24)
end

-- how far away (s) a cached frame may be and still stand in for the hovered time
local function stand_in_limit()
    return math.max(15, (props.duration or 0) / 40)
end

-- the cached thumbnail closest in time (ties go to the earlier frame)
local function closest(time)
    local best, best_d
    for _, entry in pairs(cache) do
        local d = math.abs(entry.actual - time)
        if not best_d or d < best_d or (d == best_d and entry.actual < best.actual) then
            best, best_d = entry, d
        end
    end
    return best, best_d or math.huge
end

-- what to show for a time: the slot's exact frame if there is one (final), otherwise
-- whatever on disk is closest in time. Returns entry, distance (s), final.
local function best_for(time, slot)
    local exact = cache["e" .. slot]
    if exact then return exact, 0, true end
    local best, d = closest(time)
    return best, d, d <= half_frame()
end

-- would a keyframe render of this time show something closer than what's on disk?
local function fast_render_helps(time, d)
    if d <= step / 2 then return false end
    local k = keyframe_for(time)
    -- known keyframe: its image is already a candidate, unless it was dropped from the cache
    if k then return not cache[keyframe_id(k)] and time - k < d end
    return true
end

------------------------------------------------------------------------------
-- Talking to the renderer
------------------------------------------------------------------------------

local function poke()
    -- Windows: wake the scheduler through mpv's IPC pipe instead of waiting for its next poll
    if not pipe_fh then
        pipe_fh = io.open("\\\\.\\pipe\\" .. run.name, "r+b")
        if not pipe_fh then return end
        -- no events on this connection, so unread data can never fill the pipe
        pipe_fh:write('{"command":["disable_event","all"]}\n')
    end
    if not (pipe_fh:write("script-message-to " .. run.name .. " poke\n") and pipe_fh:flush()) then
        pipe_fh:close()
        pipe_fh = nil
    end
end

local function send(line)
    if not cmd_fh then return end
    cmd_fh:write(line, "\n")
    cmd_fh:flush()
    if is_windows and ready then poke() end
end

local function remove_run_files(files)
    if not files then return end
    for _, key in ipairs({"cmd", "res", "helper"}) do os.remove(files[key]) end
end

-- stop the current renderer (it also quits by itself once its command file is gone)
local function stop_renderer()
    if spawned then send("quit") end
    if cmd_fh then cmd_fh:close() cmd_fh = nil end
    if pipe_fh then pipe_fh:close() pipe_fh = nil end
    if run then
        run.stopped = true  -- its exit is expected, not a failure
        remove_run_files(run)
        -- frames it may still write while quitting
        local out = run.name .. "_"
        mp.add_timeout(2, function()
            for _, name in ipairs(utils.readdir(folder, "files") or {}) do
                if name:sub(1, #out) == out and name:sub(-4) == ".out" then os.remove(folder .. sep .. name) end
            end
        end)
    end
    for id in pairs(jobs) do remove_later(job_path(id)) end
    run, spawned, ready, alive = nil, false, false, false
    jobs = {}
    if poll_timer then poll_timer:kill() end
end

------------------------------------------------------------------------------
-- Starting the renderer
------------------------------------------------------------------------------

local mpv_candidates = nil

local function find_mpv_candidates()
    if o.mpv_path ~= "mpv" then return {o.mpv_path} end
    local list = {}
    local frontend = mp.get_property_native("user-data/frontend/process-path")
    if frontend and frontend ~= "" then list[#list + 1] = frontend end
    if platform == "linux" then
        -- the exact binary that's running (skips wrappers that inject scripts, e.g. on NixOS)
        local exe = "/proc/" .. pid .. "/exe"
        if utils.file_info(exe) then list[#list + 1] = exe end
    elseif platform == "darwin" then
        local r = mp.command_native({name = "subprocess", playback_only = false, capture_stdout = true,
            args = {"ps", "-o", "comm=", "-p", tostring(pid)}})
        local exe = r and r.stdout and r.stdout:gsub("%s+$", "")
        if exe and exe:find("/") then list[#list + 1] = exe end
    end
    -- on Windows this also finds the mpv.exe next to the running one
    list[#list + 1] = "mpv"
    return list
end

-- remove files left behind by crashed players (older than a day), once per session
local cleaned_stale = false
local function clean_stale_files()
    if cleaned_stale then return end
    cleaned_stale = true
    local names = utils.readdir(folder, "files")
    if not names then return end
    local cutoff = os.time() - 86400
    for _, name in ipairs(names) do
        if name:match("^thumbz_%d+_") and not name:find(prefix .. "_", 1, true) then
            local path = folder .. sep .. name
            local info = utils.file_info(path)
            if info and info.mtime < cutoff then os.remove(path) end
        end
    end
end

local function add_if(args, name, value)
    if has_option(name) then args[#args + 1] = "--" .. name .. "=" .. value end
end

-- Hardware decoding in the renderer. "auto" uses the copy-back variant of the decoder
-- the player itself is using (so e.g. a laptop never wakes a second GPU just for
-- thumbnails), then mpv's own safe choice, then software decoding.
local copy_variants = {
    nvdec = "nvdec-copy", cuda = "nvdec-copy", d3d11va = "d3d11va-copy", dxva2 = "dxva2-copy",
    vaapi = "vaapi-copy", videotoolbox = "videotoolbox-copy",
}

local function renderer_hwdec()
    if o.hwdec ~= "auto" then return o.hwdec end
    local api = (mp.get_property("hwdec-current") or ""):gsub("%-copy$", "")
    local copy = copy_variants[api]
    -- a list of decoders to try in order needs mpv 0.36+ (where the option is a list)
    if copy and type(mp.get_property_native("options/hwdec")) == "table" then
        return copy .. ",auto-safe"
    end
    return "auto-safe"
end

-- Linux/macOS: lower the renderer's priority with nice (Windows uses mpv's --priority)
local nice_levels = {idle = 19, belownormal = 10}
local use_nice = not is_windows and nice_levels[o.priority] ~= nil

local function spawn(time)
    if spawned or broken or disabled or not size then return false end
    clean_stale_files()
    mpv_candidates = mpv_candidates or find_mpv_candidates()
    local exe = mpv_candidates[1]

    run_count = run_count + 1
    local files = run_files(run_count)
    local f = io.open(files.helper, "wb")
    if not f then
        msg.error("can't write to " .. folder .. " (set tmp_dir in thumbz.conf)")
        broken = true
        return false
    end
    f:write(string.format(scheduler_source, files.cmd, files.res, files.out_prefix, base .. "_", math.floor(o.idle_quit)))
    f:close()
    f = io.open(files.res, "wb")
    if f then f:close() end
    cmd_fh = io.open(files.cmd, "wb")
    if not cmd_fh then broken = true return false end
    run, res_pos, res_rest = files, 0, ""

    -- the first frame comes straight from --start, without a seek
    local id = next_id
    next_id = next_id + 1
    local exact = exact_mode()
    jobs[id] = {slot = slot_for(time), time = time, exact = exact, gen = gen, init = true}
    send(string.format("init %d %.3f %d", id, time, size.bytes))

    local niced = use_nice
    local args = niced and {"nice", "-n", tostring(nice_levels[o.priority])} or {}
    for _, arg in ipairs({
        exe, "--no-config", "--quiet", "--msg-level=all=error", "--input-terminal=no",
        "--load-scripts=no", "--osc=no", "--ytdl=no", "--input-default-bindings=no",
        "--pause", "--keep-open=always", "--start=" .. string.format("%.3f", time),
        "--hr-seek=" .. (exact and "yes" or "no"),
        "--aid=no", "--sid=no", "--demuxer-readahead-secs=0", "--demuxer-max-bytes=128KiB",
        "--vd-lavc-skiploopfilter=all", "--vd-lavc-fast",
        "--vd-lavc-threads=" .. math.floor(o.threads), "--hwdec=" .. renderer_hwdec(),
        "--vf=" .. build_vf(size), "--video-rotate=" .. (props["video-rotate"] or 0),
        "--ovc=rawvideo", "--of=image2", "--ofopts=atomic_writing=1", "--o=" .. files.out_prefix .. "%d.out",
        "--scripts=" .. files.helper,
    }) do args[#args + 1] = arg end
    -- fall back to software decoding on the first hardware decoding error
    if has_option("hwdec-software-fallback") then
        args[#args + 1] = "--hwdec-software-fallback=1"
    else
        args[#args + 1] = "--vd-lavc-software-fallback=1"
    end
    if type(props.vid) == "number" then args[#args + 1] = "--vid=" .. props.vid end
    if type(props.edition) == "number" then args[#args + 1] = "--edition=" .. props.edition end
    for _, name in ipairs({"load-stats-overlay", "load-auto-profiles", "load-select",
                           "load-commands", "load-positioning", "load-context-menu"}) do
        add_if(args, name, "no")
    end
    add_if(args, has_option("load-console") and "load-console" or "load-osd-console", "no")
    add_if(args, "sub-auto", "no")
    add_if(args, "audio-file-auto", "no")
    add_if(args, "cover-art-auto", "no")
    add_if(args, "media-controls", "no")
    if is_windows then
        args[#args + 1] = "--input-ipc-server=" .. files.name
        if o.priority ~= "" and o.priority ~= "normal" then add_if(args, "priority", o.priority) end
    end
    if platform == "darwin" then add_if(args, "macos-app-activation-policy", "accessory") end
    args[#args + 1] = "--"
    args[#args + 1] = media_path()

    spawned, ready, alive = true, false, false
    local started = mp.get_time()
    poll_timer:resume()

    mp.command_native_async({name = "subprocess", args = args, playback_only = true,
                             capture_stdout = true, capture_stderr = true},
        function(_, result)
            if run == files then stop_renderer() end  -- it quit by itself (idle) or crashed
            if files.alive then failures = 0 end
            if files.alive or files.stopped or (result and result.killed_by_us) then return end
            if run ~= nil then return end  -- a newer run already took over
            -- this run never got going: try the next mpv candidate, then give up
            local out = result and ((result.stderr or "") .. (result.stdout or "")) or ""
            local err = out:match("[^\r\n]+") or (result and result.error_string) or "unknown error"
            msg.warn(string.format("renderer '%s' failed after %.2fs: %s", exe, mp.get_time() - started, err))
            failures = failures + 1
            if niced then
                use_nice = false  -- try the same mpv again without nice
            elseif #mpv_candidates > 1 then
                table.remove(mpv_candidates, 1)
            end
            if failures >= 3 then
                broken = true
                msg.error("thumbnails disabled: could not start the renderer (see mpv_path in thumbz.conf)")
                reconfigure()
            elseif want and visible then
                spawn(want.time)
            end
        end)
    return true
end

------------------------------------------------------------------------------
-- Requests, storyboard and results
------------------------------------------------------------------------------

local function job_pending_for(slot, exact)
    for _, job in pairs(jobs) do
        if job.slot == slot and (job.exact or not exact) then return true end
    end
    return false
end

-- kind: "fast" (keyframe), "exact" (short files), "refine" (exact frame on rest,
-- abandoned as soon as a newer request comes in) or "bg" (storyboard keyframe)
local function request(time, slot, kind)
    local exact = kind == "exact" or kind == "refine"
    if job_pending_for(slot, exact) then return end
    if not spawned then
        if not spawn(time) then return end
        -- starting up renders this position already (as an exact frame in exact mode)
        if not exact or exact_mode() then return end
    end
    local id = next_id
    next_id = next_id + 1
    jobs[id] = {slot = slot, time = time, exact = exact, gen = gen, bg = kind == "bg"}
    send(string.format("req %d %.3f %s", id, time, kind))
    poll_timer:resume()
end

-- does the pointer resting here deserve an exact render? (entry/distance from best_for)
local function needs_exact(d, final)
    if final or o.precise == "no" then return false end
    if o.precise == "yes" then return true end
    return d > step  -- auto: only when nothing on disk is close to the hovered time
end

local function refine(target)
    target.refined = true
    request(target.time, target.slot, "refine")
end

-- storyboard: keyframe thumbnails spread over the whole file, rendered when nothing
-- else is going on, in bit-reversed order so coverage grows evenly (1/2, 1/4, 3/4, ...)
local function storyboard_start()
    if o.storyboard < 2 or storyboard.order or disabled then return end
    local duration = props.duration or 0
    local n = math.min(o.storyboard, math.floor(duration / math.max(step, o.storyboard_gap)))
    if n < 2 then return end
    local bits = 0
    while 2 ^ bits < n do bits = bits + 1 end
    local order, seen = {}, {}
    for i = 0, 2 ^ bits - 1 do
        local r, v = 0, i
        for _ = 1, bits do
            r = r * 2 + v % 2
            v = math.floor(v / 2)
        end
        if r < n then
            local slot = slot_for((r + 0.5) * duration / n)
            if not seen[slot] then
                seen[slot] = true
                order[#order + 1] = slot
            end
        end
    end
    storyboard.order, storyboard.pos, storyboard.active = order, 1, true
end

local function pump()
    if not storyboard.active or not spawned or not alive or next(jobs) ~= nil then return end
    if visible and want and not resting then return end  -- the moving pointer comes first
    -- background work only while the user is navigating, never during plain playback
    if not props.pause and mp.get_time() - interest > 10 then return end
    local order = storyboard.order
    while storyboard.pos <= #order do
        local slot = order[storyboard.pos]
        storyboard.pos = storyboard.pos + 1
        -- skip spots an earlier render already covers
        local _, d = best_for(slot * step, slot)
        if fast_render_helps(slot * step, d) then
            request(slot * step, slot, "bg")
            return
        end
    end
    storyboard.active = false  -- complete
end

local function on_done(id, actual)
    local job = jobs[id]
    jobs[id] = nil
    local path = job_path(id)
    if not job or job.gen ~= gen then
        os.remove(path)
        return
    end
    local entry = {path = path, exact = job.exact, slot = job.slot, actual = actual or job.time, used = mp.get_time()}
    msg.debug(string.format("rendered %s %.3f -> %.3f", job.exact and "exact" or "keyframe", job.time, entry.actual))
    if job.exact then
        store("e" .. job.slot, entry)
    else
        learn_keyframe(job.time, entry.actual)
        store(keyframe_id(entry.actual), entry)
    end
    if visible and want then
        -- show whatever is now closest to the pointer: the image only ever gets closer
        local best, d, final = best_for(want.time, want.slot)
        if final or d <= stand_in_limit() then
            draw(best.path, want.x, want.y)
        elseif not job.bg then
            draw(path, want.x, want.y)  -- newest hover frame as feedback while scrubbing
        end
        -- the pointer rests here and only a keyframe arrived ("auto" mode)
        if resting and not want.refined and not exact_mode() and needs_exact(d, final) then refine(want) end
    end
end

local function on_fail(id)
    local job = jobs[id]
    jobs[id] = nil
    -- a failing first frame on HDR video usually means FFmpeg lacks zscale: retry without
    if job and job.init and tone_map_active() then
        msg.warn("HDR tone-mapping failed in the renderer; continuing without it")
        no_tonemap = true
        reconfigure()
    end
end

local function poll_results()
    if not run then
        poll_timer:kill()
        return
    end
    local info = utils.file_info(run.res)
    if info and info.size > res_pos then
        local f = io.open(run.res, "rb")
        if f then
            f:seek("set", res_pos)
            local data = f:read("*a") or ""
            f:close()
            res_pos = res_pos + #data
            data = res_rest .. data
            res_rest = data:match("[^\n]*$")
            for line in data:gmatch("([^\n]*)\n") do
                local what, a, b = line:match("^(%S+)%s*(%S*)%s*(%S*)")
                if what == "done" or what == "dec" then
                    alive, run.alive = true, true  -- it opened and decoded the file
                end
                if what == "done" then
                    on_done(tonumber(a), tonumber(b))
                elseif what == "fail" then
                    on_fail(tonumber(a))
                elseif what == "skip" then
                    jobs[tonumber(a)] = nil  -- replaced by a newer request
                elseif what == "badsize" then
                    msg.warn("unexpected thumbnail size from the renderer: " .. a .. " bytes")
                    on_fail(tonumber(b))
                elseif what == "dec" then
                    msg.verbose("renderer decoding: " .. ((a == "no" or a == "") and "software" or a))
                elseif what == "hello" then
                    ready = true
                    if is_windows then poke() end
                end
                if not run then return end
            end
        end
    end
    if next(jobs) == nil then pump() end
    if (alive or ready) and next(jobs) == nil then poll_timer:kill() end
end

------------------------------------------------------------------------------
-- Messages from ModernZ
------------------------------------------------------------------------------

local function hover(time, x, y)
    time, x, y = tonumber(time), tonumber(x), tonumber(y)
    if disabled or not time or not x or not y then return end
    time = math.max(0, math.min(props.duration or time, time))
    x, y = round(x), round(y)
    visible = true
    interest = mp.get_time()
    storyboard_start()  -- the seekbar is in use: fill in the rest of the bar in idle moments
    local slot = slot_for(time)
    local moved = not want or want.time ~= time
    local refined = want and want.slot == slot and want.refined
    want = {time = time, slot = slot, x = x, y = y, refined = refined}

    -- this spot's exact frame, or else the closest thing on disk (a storyboard frame,
    -- or the keyframe this spot starts from when an earlier render already found it)
    local entry, d, final = best_for(time, slot)
    if entry and (final or d <= stand_in_limit()) then
        entry.used = mp.get_time()
        draw(entry.path, x, y)
    elseif shown then
        draw(shown.path, x, y)
    end

    -- "resting" means the pointer stopped moving, not just that it stayed within one slot
    if moved then
        resting = false
        rest_timer:kill()
        rest_timer:resume()
    end
    if slot ~= last_slot then
        last_slot = slot
        if not final then
            if exact_mode() then
                request(time, slot, "exact")
            elseif fast_render_helps(time, d) then
                request(time, slot, "fast")
            end
        end
    end
end

local function on_rest()
    if not visible or not want then return end
    resting = true
    local _, d, final = best_for(want.time, want.slot)
    if final then return end
    if exact_mode() then
        request(want.time, want.slot, "exact")
    elseif o.precise == "yes" then
        refine(want)  -- queued right behind a keyframe render that may still be on its way
    elseif not job_pending_for(want.slot, false) and needs_exact(d, final) then
        refine(want)  -- otherwise on_done decides once the keyframe is in
    end
end

local function hide()
    visible = false
    want, last_slot, resting = nil, nil, false
    rest_timer:kill()
    remove_overlay()
    if spawned and alive and next(jobs) == nil then
        pump()
        if next(jobs) ~= nil then poll_timer:resume() end
    end
end

local function prepare()
    if disabled or spawned then return end
    interest = mp.get_time()
    spawn(mp.get_property_number("time-pos", 0) or 0)
end

------------------------------------------------------------------------------
-- Following the main player
------------------------------------------------------------------------------

reconfigure = function()
    size = compute_size()
    disabled = compute_disabled()
    local sig = (not disabled) and table.concat({
        media_path() or "", size.w, size.h, tostring(size.rot), build_vf(size),
        tostring(props.vid), tostring(props.edition), tostring(props["video-rotate"]),
    }, "|") or nil
    if sig ~= signature then
        -- anything that changes how frames look invalidates the cache and the renderer
        signature = sig
        gen = gen + 1
        stop_renderer()
        flush_cache()
        remove_overlay()
        last_slot = nil
        storyboard = {order = nil, pos = 1, active = false}
        step = math.max(0.1, math.min(30, (props.duration or 0) / 500))
    end
    announce()
end

-- the parts of video(-out)-params that matter here; HDR peak detection changes the
-- rest every frame, which would keep postponing the update
local function params_key(p)
    if not p then return "" end
    local parts = {}
    for _, k in ipairs({"w", "h", "dw", "dh", "rotate", "gamma", "crop-x", "crop-y", "crop-w", "crop-h"}) do
        parts[#parts + 1] = tostring(p[k])
    end
    return table.concat(parts, ",")
end

local keys = {}
local function observe(name, key_of)
    mp.observe_property(name, "native", function(_, value)
        props[name] = value
        if key_of then
            local key = key_of(value)
            if key == keys[name] then return end
            keys[name] = key
        end
        config_timer:kill()
        config_timer:resume()
    end)
end

poll_timer = mp.add_periodic_timer(0.005, poll_results)
poll_timer:kill()
rest_timer = mp.add_timeout(o.rest_delay, on_rest)
rest_timer:kill()
config_timer = mp.add_timeout(0.05, reconfigure)
config_timer:kill()

for _, name in ipairs({"path", "stream-open-filename", "demuxer-via-network", "duration", "vid", "edition",
                       "current-tracks/video", "display-hidpi-scale", "video-rotate", "vf"}) do
    observe(name)
end
observe("video-out-params", params_key)
observe("video-params", params_key)
mp.observe_property("container-fps", "number", function(_, fps) props["container-fps"] = fps end)
mp.observe_property("pause", "bool", function(_, paused)
    props.pause = paused
    -- pausing is a good moment to continue the storyboard
    if paused and spawned and alive and next(jobs) == nil then
        pump()
        if next(jobs) ~= nil then poll_timer:resume() end
    end
end)

mp.register_script_message("hover", hover)
mp.register_script_message("hide", hide)
mp.register_script_message("prepare", prepare)
mp.register_event("shutdown", function()
    stop_renderer()
    for _, entry in pairs(cache) do os.remove(entry.path) end
    for path in pairs(doomed) do os.remove(path) end
    -- anything else of this player's (e.g. a frame the renderer wrote while quitting)
    for _, name in ipairs(utils.readdir(folder, "files") or {}) do
        if name:sub(1, #prefix + 1) == prefix .. "_" then os.remove(folder .. sep .. name) end
    end
end)
