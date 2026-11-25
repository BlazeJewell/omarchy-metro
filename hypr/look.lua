-- Look and feel for the sidebar rice.

-- No tab strip above grouped windows; apps are switched from the sidebar.
-- New windows get their own tile instead of joining the focused window's group.
hl.config({
  group = {
    auto_group = false,
    groupbar = {
      enabled = false,
    },
  },
})

-- Windows slide in from the left (out of the sidebar) and slide back out to it.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "slide left" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "easeInOutCubic", style = "slide left" })

-- Window corners and borders: set in the sidebar's editor (Whole sidebar ›
-- Windows), saved in ~/.config/omarchy/metro-settings.json; rounded corners
-- and no borders unless changed there. (The sidebar also applies them live.)
local settings_text = (function()
  local f = io.open((os.getenv("HOME") or "") .. "/.config/omarchy/metro-settings.json", "r")
  if not f then return "" end
  local t = f:read("*a") or ""
  f:close()
  return t
end)()
local function sidebar_number(key, default)
  local v = settings_text:match('"' .. key .. '"%s*:%s*(%d+)')
  return v and tonumber(v) or default
end
local function sidebar_string(key, default)
  return settings_text:match('"' .. key .. '"%s*:%s*"(%a+)"') or default
end
-- What Omarchy and your own files set (this loads after them), so the sidebar
-- can hand windows back to it when the look is for the sidebar only.
do
  local f = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/jake-metro-window-base", "w")
  if f then
    f:write(tostring(hl.get_config("general.border_size") or 0) .. " " .. tostring(hl.get_config("decoration.rounding") or 0) .. "\n")
    f:close()
  end
end
-- "Apply to": windows (default), sidebar (the panel only; windows keep your
-- config's look), or both.
if sidebar_string("lookScope", "windows") ~= "sidebar" then
  hl.config({
    general = { border_size = sidebar_number("windowBorder", 0) },
    decoration = { rounding = sidebar_number("windowRounding", 0) },
  })
end

-- Opening or switching to another app while one is fullscreen takes it out of
-- fullscreen instead of handing fullscreen to the new app (Omarchy's default),
-- so apps opened from the sidebar always come up at normal size.
hl.config({
  misc = { on_focus_under_fullscreen = 2 },
})
