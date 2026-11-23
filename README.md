# jake.sidebar — a left sidebar rice for Omarchy

Replaces Omarchy's top bar with one panel on the left: clock and system stats
(CPU, memory, disk, GPU, network), workspaces, the Super+Space menu built in,
pinned and running apps, settings, the system tray and plugins — plus a GNOME-style
overview on Super, one-app-at-a-time windows that slide in from the left, and an
editor to rearrange all of it.

Requires an Omarchy install with the Lua Hyprland config (Omarchy 4+).

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/OWNER/REPO/main/install.sh | bash
```

or, if you'd rather look first:

```bash
git clone REPO_URL_PLACEHOLDER ~/.config/omarchy/plugins/jake.sidebar
~/.config/omarchy/plugins/jake.sidebar/install.sh
```

The installer:

- puts the plugin in `~/.config/omarchy/plugins/jake.sidebar`
- links `hypr/` in and adds one line to `~/.config/hypr/hyprland.lua`:
  `require("hypr.jake_sidebar")`
- copies the saved layout from `layout/` into `~/.config/omarchy`
  (pass `--keep-layout` to keep the machine's own), backing up what it replaces
- switches the bar to the sidebar (`omarchy bar use jake.sidebar`) and turns off
  Omarchy's dock

Undo with `./uninstall.sh` (add `--purge` to delete the plugin and layout too).

## Keeping machines in sync

```bash
cd ~/.config/omarchy/plugins/jake.sidebar
./sync.sh save     # this machine's layout -> layout/, commit, push
./sync.sh load     # pull, apply layout/ here
./sync.sh update   # pull plugin / Hyprland changes, keep this machine's layout
```

The layout is the `sidebar-*.json` files: sections and their order, pinned apps,
hidden icons, profiles. Display scale and refresh rate stay per machine.

## What's where

| Path | What |
| --- | --- |
| `Sidebar.qml` | the sidebar (Quickshell, loaded by omarchy-shell as a `bar` plugin) |
| `hypr/` | Hyprland side: `binds.lua`, `look.lua` (animations, borders, corners, grouping), `solo.lua` (one app at a time), `rules.lua` |
| `*.sh` | helpers the sidebar runs (minimize, pairing, drag-to-place, refresh rate, GPU stats) |
| `layout/` | the saved sidebar layout synced between machines |
| `MenuModel.js` | link to Omarchy's own menu model, so the built-in menu follows Omarchy updates |

## Keys

| Keys | Does |
| --- | --- |
| Super (tap) | overview of open windows |
| Super+Space | the menu, inside the sidebar |
| Super+Alt+1…9 | pinned apps |
| Super+M | minimize (slides out left) |
| Super+Ctrl+A / B / D / N / P | sound / bluetooth / display / network / power settings |

Widget sections that use other plugins (for example AI Usage) need that plugin
installed on the machine too; otherwise the section says it has no panel.

After editing `Sidebar.qml`, run `omarchy restart shell` — the shell caches bar plugins.
