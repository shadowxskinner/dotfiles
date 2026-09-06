import QtQuick
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool active: false
    property bool busy: false
    readonly property var gamingMode: ["/home/shadow/.local/bin/gaming-mode"]

    function refresh() {
        Proc.runCommand("gamingMode.status", root.gamingMode.concat(["status"]), (stdout, exitCode) => {
            if (exitCode === 0)
                root.active = stdout.trim() === "on"
        }, 100)
    }

    function setMode(enabled) {
        if (root.busy)
            return
        root.busy = true
        Proc.runCommand("gamingMode.toggle", root.gamingMode.concat([enabled ? "on" : "off"]), (stdout, exitCode) => {
            root.busy = false
            root.refresh()
        }, 15000)
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    ccWidgetIcon: "sports_esports"
    ccWidgetPrimaryText: "Gaming Mode"
    ccWidgetSecondaryText: active ? "Hermes paused — HA gaming lights" : "Ready — automatic detection on"
    ccWidgetIsActive: active
    onCcWidgetToggled: setMode(!active)
}
