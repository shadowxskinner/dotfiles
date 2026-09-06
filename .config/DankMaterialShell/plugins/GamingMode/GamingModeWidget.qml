import QtQuick
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool active: false
    property bool busy: false

    function refresh() {
        Proc.runCommand("gamingMode.status", ["gaming-mode", "status"], (stdout, exitCode) => {
            if (exitCode === 0)
                root.active = stdout.trim() === "on"
        }, 100)
    }

    function setMode(enabled) {
        if (root.busy)
            return
        root.busy = true
        Proc.runCommand("gamingMode.toggle", ["gaming-mode", enabled ? "on" : "off"], (stdout, exitCode) => {
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
    ccWidgetSecondaryText: active ? "Hermes and local AI paused" : "Ready — automatic detection on"
    ccWidgetIsActive: active
    onCcWidgetToggled: setMode(!active)
}
