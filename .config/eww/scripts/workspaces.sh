#!/usr/bin/env bash
get_ws() {
  i3-msg -t get_workspaces | python3 -c '
import sys, json
ws = json.loads(sys.stdin.read())
ws.sort(key=lambda w: w["num"])
out = [{"num": w["num"], "focused": w["focused"]} for w in ws]
print(json.dumps(out), flush=True)
'
}
get_ws
i3-msg -t subscribe '["workspace"]' --monitor | while read -r event; do
  get_ws
done
