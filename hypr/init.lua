-- jake.sidebar: the Hyprland side of the sidebar rice.
-- Loaded from ~/.config/hypr/hyprland.lua (after Omarchy's defaults and your own
-- files) by:  require("hypr.jake_sidebar")
-- which install.sh links to this file.
local dir = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/jake.sidebar/hypr/"
for _, name in ipairs({ "look", "binds", "solo", "rules" }) do
  dofile(dir .. name .. ".lua")
end
