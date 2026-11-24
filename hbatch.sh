# Sourced by the sidebar's scripts.
# hbatch cmd...: send "dispatch ..." / "eval ..." commands to Hyprland in one
# batch (one round trip instead of one per command), with cursor warps off for
# just that batch: focusing a window from the sidebar shouldn't drag the pointer
# out of it. Whatever cursor.no_warps was before is put back at the end of the
# batch, so keyboard focus changes elsewhere still warp as usual.
NW_ON="eval _G.jake_sidebar_nw = hl.get_config('cursor.no_warps') hl.config({ cursor = { no_warps = true } })"
NW_OFF="eval hl.config({ cursor = { no_warps = _G.jake_sidebar_nw == true } })"
hbatch() {
  (( $# )) || return 0
  local IFS=';'
  hyprctl --batch "$NW_ON;$*;$NW_OFF" >/dev/null
}
