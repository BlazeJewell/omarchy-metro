# jake.metro — the sidebar, in Metro

A Metro (Windows Phone / Windows 8) take on [jake.sidebar](https://github.com/BlazeJewell/omarchy-sidebar):
the same single left column that replaces Omarchy's top bar, drawn with live tiles, big
light type and one accent colour. It is a fork of jake.sidebar, so everything that makes
the classic sidebar work comes with it unchanged: one app at a time, minimize and restore,
fullscreen memory and games, the overview, Omarchy's panels docked in the column,
notifications inside it, editing and profiles.

Requires an Omarchy install with the Lua Hyprland config (Omarchy 4+).

## What's Metro about it

| Part | Metro look |
| --- | --- |
| Clock | Big Selawik Light time, the day and date in lowercase beside it |
| System | CPU / memory / disk / GPU as live tiles (a tile turns accent above 85%); network in big light numerals with an accent graph |
| Workspaces | Plain light numerals, the current one bright |
| Search | A Windows Phone text box: light grey at rest, white with an accent edge while typing |
| Pinned apps | Tiles in the accent colour, the first ones medium (2×2), the rest small; the app on screen has a white edge, unread counts sit top right |
| Running apps | Rows with the icon on a square tile, names in lowercase light type, an accent bar on the one on screen |
| Super+Space | The Omarchy menu in big lowercase type, windows dimmed behind; `›` drills in, the round `‹` comes back |
| Quick settings | Toggle tiles (wi-fi, bluetooth, quiet, night light, stay awake, power profile, capture, lock), then Metro rows, square toggle switches and block sliders |
| Bottom row | One round **settings** button on the left (quick settings); your plugins' icons on the right |
| Overview (Super) | A panorama: a giant "overview" title, one column per workspace with its caption, the next one peeking in at the edge; ← → move between workspaces |
| Notifications | Square cards with an accent stripe, inside the top of the column |
| Corners | Square everywhere, windows included (Edit sidebar › Corners to change) |
| Edit sidebar | The column's sections become tiles (the rest shrink back, the one you're editing lifts in the accent with a round ✕); beside it a Metro settings page with a pivot (this section · sidebar · profiles), toggle switches, option tiles, round − / + steppers, an accent tile grid, and a round app bar (add · undo · cancel · save) |

Type is [Selawik](https://github.com/microsoft/Selawik), Microsoft's open stand-in for Segoe,
bundled in `fonts/` under the SIL Open Font License (`fonts/LICENSE-Selawik.txt`). Icon
glyphs still come from your theme's Nerd Font.

## Settings

All in **Edit sidebar** (quick settings › edit sidebar), saved in
`~/.config/omarchy/metro-settings.json`, separate from the classic sidebar's files:

- **Width**: 200–560 px (default 360), or drag the column's right edge
- **Accent**: Windows Phone 8's twenty; cobalt blue (`#0050EF`) by default
- **Panel colour**: black (default) or your Omarchy theme's bar colour
- **App list › Pinned apps as tiles** and **› Medium tiles** (how many of the first pins are 2×2)
- Everything the classic sidebar has: sections and their order, auto-hide, profiles, …

## Switching between Metro and classic

Both can be installed at once; only the bar in use loads its Hyprland side.

```bash
omarchy bar use jake.metro      # Metro
omarchy bar use jake.sidebar    # classic
```

Notifications are one shared plugin (`jake.notifications`), linked to this copy while
Metro is installed; the accent stripe only shows while Metro is the bar.

## Install

From this folder:

```bash
./install.sh
```

It loads `hypr/` with one line in `~/.config/hypr/hyprland.lua` (its own line, beside the
classic sidebar's), switches the bar to `jake.metro`, turns off Omarchy's dock and links
notifications. Undo with `./uninstall.sh`, which goes back to the classic sidebar if it is
installed (`--purge` also deletes this folder and the `metro-*.json` files).

## Shortcuts you can bind

`omarchy-shell jake.metro <command>`: `search`, `overview`, `quickSettings`, `edit`,
`editTab section|sidebar|profiles`, `editAdd`, `settings <section>`, `launchPinned <n>`.

## Notes for editing

- Saving `Sidebar.qml` triggers a reload, but the shell can keep the compiled copy:
  run `omarchy restart shell` to be sure you're seeing the new version.
- `notifications/` is reached through the `jake.notifications` link, so the shell does not
  see edits there; run `omarchy restart shell` after changing it.

## What's where

| Path | What |
| --- | --- |
| `Sidebar.qml` | the sidebar (loaded by omarchy-shell as a `bar` plugin) |
| `fonts/` | Selawik Light, Semilight, Regular, Semibold + licence |
| `hypr/` | Hyprland side: `binds.lua` (Super+Space, Super for the overview, …), `look.lua`, `solo.lua` (one app at a time), `rules.lua` |
| `*.sh` | helpers: `minimize.sh` / `restore.sh`, `solo.sh`, `fsmem.sh` (fullscreen memory), `drop.sh` / `pair.sh`, `hbatch.sh`, `refresh.sh`, `gpu.sh`, `update.sh`, `sync.sh` |
| `notifications/` | Omarchy's notification service, docked inside the column (the `jake.notifications` plugin) |
| `MenuModel.js` | copy of Omarchy's menu model |
