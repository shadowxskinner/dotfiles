#!/usr/bin/env python3
import subprocess, json

icons = {
    "Google-chrome": "\uf268",
    "firefox": "\ue745",
    "kitty": "\ue795",
    "discord": "\uf392",
    "Steam": "\uf1b6",
    "Thunar": "\uf07b",
    "thunar": "\uf07b",
    "dolphin-emu": "\uf11b",
    "dolphin": "\uf07b",
    "rpcs3": "\uf11b",
    "RPCS3": "\uf11b",
    "pcsx2-qt": "\uf11b",
    "cemu": "\uf11b",
    "Rustdesk": "\uf108",
    "Code": "\ue70c",
    "Spotify": "\uf1bc",
}

try:
    tree = json.loads(subprocess.getoutput("i3-msg -t get_tree"))
    def find_focused(node):
        if node.get("focused"):
            return node
        for n in node.get("nodes", []) + node.get("floating_nodes", []):
            r = find_focused(n)
            if r:
                return r
        return None
    focused = find_focused(tree)
    if focused:
        wclass = focused.get("window_properties", {}).get("class", "")
        print(icons.get(wclass, "?"))
    else:
        print("?")
except:
    print("?")
