# jake.sidebar — a left sidebar rice for Omarchy

Replaces Omarchy's top bar with one panel on the left: clock and system stats
(CPU, memory, disk, GPU, network), workspaces, the Super+Space menu built in,
pinned and running apps, settings, the system tray and plugins — plus a GNOME-style
overview on Super, one-app-at-a-time windows that slide in from the left, and an
editor to rearrange all of it.

Requires an Omarchy install with the Lua Hyprland config (Omarchy 4+).

## Install

The repo is private, so clone it with your GitHub login (`gh auth login` once per machine):

```bash
gh repo clone BlazeJewell/omarchy-sidebar ~/.config/omarchy/plugins/jake.sidebar
~/.config/omarchy/plugins/jake.sidebar/install.sh
```

(`git clone https://github.com/BlazeJewell/omarchy-sidebar.git ~/.config/omarchy/plugins/jake.sidebar` works too.)

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

Or use the **Update** button at the bottom of quick settings: it checks GitHub when
quick settings opens, shows how many updates are waiting, and runs `sync.sh update`.

The layout is the `sidebar-*.json` files: sections and their order, pinned apps,
hidden icons, profiles. Display scale and refresh rate stay per machine.

## What's where

| Path | What |
| --- | --- |
| `Sidebar.qml` | the sidebar (Quickshell, loaded by omarchy-shell as a `bar` plugin) |
| `hypr/` | Hyprland side: `binds.lua`, `look.lua` (animations, borders, corners, grouping), `solo.lua` (one app at a time), `rules.lua` |
| `*.sh` | helpers the sidebar runs: `minimize.sh` / `restore.sh` (slide out / back in; layout-aware), `solo.sh` (one app at a time), `fsmem.sh` (fullscreen memory), `drop.sh` / `pair.sh` (drag to place), `refresh.sh` (resolution & refresh rate), `gpu.sh` (finds the GPU), `update.sh` (the quick-settings Update button) |
| `notifications/` | a copy of Omarchy's notification service, changed so popups dock top-left against the sidebar and slide out from it (installed as the `jake.notifications` plugin) |
| `layout/` | the saved sidebar layout synced between machines |
| `MenuModel.js` | link to Omarchy's own menu model, so the built-in menu follows Omarchy updates |

## Works with stock Omarchy

- Panel shortcuts open inside the sidebar: Super+Ctrl+A/B/D/N/P, Super+Ctrl+1…9
  (counted like the stock bar), Super+Ctrl+Alt+D (calendar), Super+Ctrl+Alt+E
  (world clock) and any other `{ panel = ... }` bind.
- `omarchy toggle bar` and the fullscreen-desktop toggle tuck the sidebar away.
- Minimized windows use Omarchy's `special:minimized` workspace and
  `omarchy-minimized-from-N` tag, and Omarchy's floating workspace layout is
  respected (windows stay floating and keep their size).
- Notifications keep all of Omarchy's features (stacks, actions, history, Do not
  disturb); only their place and motion change. If an Omarchy update changes
  notifications, re-clone with `omarchy plugin clone omarchy.notifications` and
  re-apply the few `jake.sidebar:` lines.
- Do not disturb, indicators, update available and keyboard layout come from
  Omarchy's own services and widgets.

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
