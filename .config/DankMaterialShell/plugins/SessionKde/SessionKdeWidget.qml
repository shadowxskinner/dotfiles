import QtQuick
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool busy: false

    function switchNow() {
        if (root.busy)
            return
        root.busy = true
        Proc.runCommand("sessionKde.switch", ["session-switch", "kde"], (stdout, exitCode) => {
            root.busy = false
        }, 20000)
    }

    ccWidgetIcon: "desktop_windows"
    ccWidgetPrimaryText: "Switch to KDE"
    ccWidgetSecondaryText: busy ? "Starting Plasma…" : "Moonlight / Sunshine session"
    ccWidgetIsActive: false
    onCcWidgetToggled: switchNow()
}
