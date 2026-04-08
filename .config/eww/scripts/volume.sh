#!/usr/bin/env bash
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+(?=%)' | head -1)
mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -oP '(?<=Mute: )\w+')
if [ "$mute" = "yes" ]; then
  echo "󰝟"
elif [ "$vol" -ge 70 ]; then
  echo "󰕾"
elif [ "$vol" -ge 30 ]; then
  echo "󰖀"
else
  echo "󰕿"
fi
