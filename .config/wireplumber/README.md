# Audio setup (Midnight-PC)

Saved from the Arch install on 2026-10-30, before the Fedora 44 rebuild.
The two rule files in `wireplumber.conf.d/` are applied by WirePlumber at login.

## Device labels

| Hardware | WirePlumber node | Label |
| --- | --- | --- |
| GPU HDMI audio (headphones in the monitor jack) | `alsa_output.pci-0000_0d_00.1.hdmi-stereo-extra2` | Heaphones |
| Motherboard optical (S/PDIF) out | `alsa_output.pci-0000_0f_00.4.iec958-stereo` | Soundbar |
| Focusrite Vocaster One | `alsa_*.usb-Focusrite_Vocaster_One_USB_*` | stock name |

- `00-plasma-pa.conf` sets the two labels. It was written by KDE's audio settings;
  the Heaphones rule also carries buffer/latency tweaks (`api.alsa.period-num 32`,
  `period-size 1024`, `headroom 0`, `node.max-latency 16384/48000`).
- `51-vocaster-hide.conf` hides the Vocaster's Loopback, Aux, Show Mix and Video Call channels.

## Defaults and levels (state, not config: reset by hand after a reinstall)

- Default output: Soundbar (optical). Fallbacks in order: Sunshine stereo sink, Heaphones, Vocaster USB2 out.
- Default input: Vocaster One, USB5 input, at about 83%.
- Card profiles: Vocaster `HiFi`; GPU HDMI `output:hdmi-stereo-extra2`; motherboard `output:iec958-stereo+input:analog-stereo`.
- Levels at save time: Heaphones ~83%, Soundbar ~1% (the soundbar's own remote sets loudness),
  Vocaster USB1 out ~12%, USB2 out ~9%, Direct out ~6%.

## After the rebuild

1. `chezmoi apply` puts these files in `~/.config/wireplumber/`, then `systemctl --user restart wireplumber`.
2. Check the node names with `wpctl status`: PCI addresses can change if hardware moves slots.
   If a label does not apply, update the `node.name` match.
3. Set the default output and mic once in Dux Shell; WirePlumber remembers them from then on.
