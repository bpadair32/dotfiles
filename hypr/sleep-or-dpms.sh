#!/bin/bash
# When on AC power, turn off displays instead of suspending
if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
  hyprctl dispatch dpms off
else
  systemctl suspend
fi
