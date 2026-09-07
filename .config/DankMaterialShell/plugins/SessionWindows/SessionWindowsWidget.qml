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
        Proc.runCommand("sessionWindows.switch", ["session-switch", "windows"], (stdout, exitCode) => {
            root.busy = false
        }, 20000)
    }

    ccWidgetIcon: "restart_alt"
    ccWidgetPrimaryText: "Reboot to Windows"
    ccWidgetSecondaryText: busy ? "Rebooting…" : "Windows 11, next boot still Linux"
    ccWidgetIsActive: false
    onCcWidgetToggled: switchNow()
}
