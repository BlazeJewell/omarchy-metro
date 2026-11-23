#!/bin/sh
# Prints "gpu <busy%> <vram used MiB> <vram total MiB> <temp °C>" for the GPU with the most VRAM
# (amdgpu sysfs; prints nothing if there's no such GPU). Used by the sidebar's System section.
best=""; bestTotal=0
for d in /sys/class/drm/card[0-9]*/device; do
  [ -r "$d/gpu_busy_percent" ] || continue
  t=$(cat "$d/mem_info_vram_total" 2>/dev/null || echo 0)
  [ "$t" -gt "$bestTotal" ] && { bestTotal=$t; best=$d; }
done
[ -n "$best" ] || exit 0
busy=$(cat "$best/gpu_busy_percent" 2>/dev/null || echo 0)
used=$(cat "$best/mem_info_vram_used" 2>/dev/null || echo 0)
temp=$(cat "$best"/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
echo "gpu $busy $((used / 1048576)) $((bestTotal / 1048576)) $(( ${temp:-0} / 1000 ))"
