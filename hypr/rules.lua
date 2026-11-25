-- Window rules for the sidebar rice.

-- Tile Steam instead of Omarchy's default floating 1100x700 window.
o.window("steam", { tile = true })

-- Games in "fullscreen windowed" mode are just screen-sized borderless windows,
-- so the sidebar (Top layer) stays over them. Make them real fullscreen.
o.window("^cs2$", { fullscreen = true })
