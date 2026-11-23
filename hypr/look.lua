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

-- No borders around windows, rounded corners.
hl.config({
  general = { border_size = 0 },
  decoration = { rounding = 10 },
})
