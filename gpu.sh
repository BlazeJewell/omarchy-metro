#!/bin/sh
# Finds the GPU for the sidebar's System section (run once at startup):
#   amd <sysfs device dir> <temperature file>   the amdgpu card with the most VRAM
#   nvidia                                      nvidia-smi is available
# Prints nothing when neither is found (the GPU stats are then left out).
best=""; bestTotal=0
for d in /sys/class/drm/card[0-9]*/device; do
  [ -r "$d/gpu_busy_percent" ] || continue
  t=$(cat "$d/mem_info_vram_total" 2>/dev/null || echo 0)
  [ "$t" -gt "$bestTotal" ] && { bestTotal=$t; best=$d; }
done
if [ -n "$best" ]; then
  temp=$(ls "$best"/hwmon/hwmon*/temp1_input 2>/dev/null | head -1)
  echo "amd $(readlink -f "$best") $temp"
elif command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; then
  echo nvidia
fi
