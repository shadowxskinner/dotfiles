#!/usr/bin/env python3
import json
import subprocess

try:
    data = json.loads(
        subprocess.check_output(
            ["hyprctl", "activeworkspace", "-j"], stderr=subprocess.DEVNULL
        )
    )
    print(data.get("windows", 0))
except Exception:
    print(0)
