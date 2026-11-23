-- One app at a time, for the jake.sidebar plugin.
--
-- A tiled window that opens takes its workspace to itself: the other tiled
-- windows there slide out to the left and are minimized (to special:minimized,
-- where the sidebar lists them). Doing it here, as the window opens, means it is placed full
-- size straight away and slides in from the left like every other window,
-- instead of opening in a tile and then growing.
--
-- Left alone:
--   * floating windows (dialogs, pickers)
--   * a window whose app already has one showing there (Steam's chat or news
--     next to Steam, a second Firefox window): it tiles with it
--   * the next window after Shift+click or drag-and-drop in the sidebar, which
--     leaves a short-lived note in $XDG_RUNTIME_DIR/jake-sidebar-tile-next

local tile_next_file = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jake-sidebar-tile-next"

local function take_tile_next()
  local f = io.open(tile_next_file, "r")
  if not f then return false end
  local until_s = tonumber(f:read("*l") or "") or 0
  f:close()
  os.remove(tile_next_file)
  return os.time() <= until_s
end

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

  -- Lift them out of the layout right away so the new window is placed full
  -- size, then slide them off to the left and hide them (minimize.sh).
  local addresses = {}
  for _, other in ipairs(others) do
    hl.dispatch(hl.dsp.window.float({ action = "on", window = "address:" .. other.address }))
    table.insert(addresses, other.address)
  end
  hl.exec_cmd("bash " .. os.getenv("HOME") .. "/.config/omarchy/plugins/jake.sidebar/minimize.sh " .. table.concat(addresses, " "))
end)
