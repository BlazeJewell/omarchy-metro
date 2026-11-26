-- One app at a time, for the jake.metro plugin.
--
-- A tiled window that opens takes its workspace to itself: the other tiled
-- windows there are minimized (to special:minimized, where the sidebar lists
-- them). Doing it here, as the window opens, means it is placed full size
-- straight away and pops in like every other window, instead of opening in a
-- tile and then growing.
--
-- Left alone:
--   * floating windows (dialogs, pickers)
--   * a window whose app already has one showing there (Steam's chat or news
--     next to Steam, a second Firefox window): it tiles with it
--   * the next window after Shift+click or drag-and-drop in the sidebar, which
--     leaves a short-lived note in $XDG_RUNTIME_DIR/jake-metro-tile-next

local tile_next_file = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jake-metro-tile-next"

local function take_tile_next()
  local f = io.open(tile_next_file, "r")
  if not f then return false end
  local until_s = tonumber(f:read("*l") or "") or 0
  f:close()
  os.remove(tile_next_file)
  return os.time() <= until_s
end

-- Which windows are fullscreen (and how), and the last one to leave it.
local fullscreen_mode = {}
local last_unfullscreen = nil
hl.on("window.fullscreen", function(window)
  if not window then return end
  if (window.fullscreen or 0) > 0 then
    fullscreen_mode[window.address] = window.fullscreen
  elseif fullscreen_mode[window.address] then
    last_unfullscreen = { address = window.address, mode = fullscreen_mode[window.address], at = os.time() }
    fullscreen_mode[window.address] = nil
  end
end)

hl.on("window.open", function(window)
  if not window or window.floating then return end
  local ws = window.workspace
  if not ws or not ws.id or ws.id < 1 then return end

  local others = {}
  for _, other in ipairs(hl.get_workspace_windows(ws.id) or {}) do
    if other.address ~= window.address and not other.floating then
      if other.class == window.class then return end
      table.insert(others, other)
    end
  end
  if #others == 0 then return end
  if take_tile_next() then return end

  -- Take them out of the layout right away so the new window is placed full size.
  -- A fullscreen one comes back fullscreen when restored from the sidebar
  -- (fsmem.sh). Hyprland has already taken it out of fullscreen by now, just
  -- before this window opened, so go by that.
  if last_unfullscreen and os.time() - last_unfullscreen.at <= 1 then
    for _, other in ipairs(others) do
      if other.address == last_unfullscreen.address then
        local mem = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jake-metro-fullscreen", "a")
        if mem then mem:write(other.address .. " " .. last_unfullscreen.mode .. "\n"); mem:close() end
      end
    end
  end

  -- Hidden at once, as minimize.sh does: no slide. The new window pops in
  -- (Hyprland's windowsIn) over the space they leave, like GNOME.
  -- Moving a focused window away refocuses another; don't let that move the pointer.
  local warps_off = hl.get_config("cursor.no_warps")
  hl.config({ cursor = { no_warps = true } })
  local hidden = {}
  for _, other in ipairs(others) do
    local w = "address:" .. other.address
    -- the same tag Omarchy's minimize uses, so its dock knows where a window came from
    hl.dispatch(hl.dsp.window.tag({ tag = "+omarchy-minimized-from-" .. ws.id, window = w }))
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "1", window = w }))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false, window = w }))
    table.insert(hidden, w)
  end
  hl.config({ cursor = { no_warps = warps_off == true } })
  hl.timer(function()
    for _, w in ipairs(hidden) do
      hl.dispatch(hl.dsp.window.set_prop({ prop = "no_anim", value = "unset", window = w }))
    end
  end, { timeout = 50, type = "oneshot" })
end)
