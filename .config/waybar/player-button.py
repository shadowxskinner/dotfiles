#!/usr/bin/env python3
import json
import subprocess

try:
    status = subprocess.check_output(
        ["playerctl", "status"], stderr=subprocess.DEVNULL, text=True
    ).strip()
except Exception:
    status = "Stopped"

icons = {"Playing": "⏸", "Paused": "▶"}
print(json.dumps({"text": icons.get(status, ""), "class": status.lower()}))
