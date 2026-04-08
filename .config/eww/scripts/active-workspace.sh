#!/usr/bin/env bash
i3-msg -t get_workspaces 2>/dev/null | python3 -c '
import sys, json
ws = json.loads(sys.stdin.read())
focused = next((w for w in ws if w["focused"]), None)
print(focused["num"] if focused else 1)
'
