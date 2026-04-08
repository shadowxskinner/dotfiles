#!/usr/bin/env bash
state=$(nmcli -t -f STATE general 2>/dev/null)
if [ "$state" = "connected" ]; then
  echo "󰖩"
else
  echo "󰖪"
fi
