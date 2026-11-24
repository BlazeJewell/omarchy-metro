-- Keybindings for the sidebar.

-- Super+Space opens the menu inside the sidebar instead of Omarchy's popup.
o.rebind("SUPER + SPACE", "Sidebar menu", "omarchy-shell jake.sidebar search")

-- Settings shortcuts open the matching section inside the sidebar.
o.rebind("SUPER + CTRL + A", "Sound settings", "omarchy-shell jake.sidebar settings sound")
o.rebind("SUPER + CTRL + B", "Bluetooth settings", "omarchy-shell jake.sidebar settings bluetooth")
o.rebind("SUPER + CTRL + D", "Display settings", "omarchy-shell jake.sidebar settings display")
o.rebind("SUPER + CTRL + N", "Network settings", "omarchy-shell jake.sidebar settings network")
o.rebind("SUPER + CTRL + P", "Power settings", "omarchy-shell jake.sidebar settings power")

-- Let the sidebar know whether Shift is held (it has no keyboard focus of its
-- own), so Shift+click there tiles an app instead of opening it alone. The
-- binds pass Shift through untouched and just write a flag file in-process.
local sidebar_shift_flag = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jake-sidebar-shift"
local function sidebar_shift(value)
  local f = io.open(sidebar_shift_flag, "w")
  if f then f:write(value) f:close() end
end
for _, key in ipairs({ "Shift_L", "Shift_R" }) do
  hl.bind(key, function() sidebar_shift("1") end, { non_consuming = true, ignore_mods = true })
  hl.bind(key, function() sidebar_shift("0") end, { non_consuming = true, ignore_mods = true, release = true, transparent = true })
end

-- Tap Super for the overview of open windows. A release bind on the Super key
-- itself only fires when Super is tapped on its own.
o.bind("SUPER + Super_L", "Overview", "omarchy-shell jake.sidebar overview", { release = true })

-- Super+M minimizes the sidebar's way (slides out to the left, on any workspace).
o.rebind("SUPER + M", "Minimize window", "bash " .. os.getenv("HOME") .. "/.config/omarchy/plugins/jake.sidebar/min-active.sh")

-- Super+Alt+1..9 open (or bring forward) the sidebar's pinned apps, in order.
-- (They replace Omarchy's "switch to group window N"; grouping is off here.)
for n = 1, 9 do
  o.rebind("SUPER + ALT + code:" .. tostring(n + 9), "Pinned app " .. n, "omarchy-shell jake.sidebar launchPinned " .. n)
end
