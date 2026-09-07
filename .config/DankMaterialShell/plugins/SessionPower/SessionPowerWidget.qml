import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    pillClickAction: function() {
        Quickshell.execDetached(["session-switch", "menu"])
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: icon.implicitWidth + Theme.spacingM * 2
            height: parent.widgetThickness

            DankIcon {
                id: icon
                anchors.centerIn: parent
                name: "power_settings_new"
                size: Theme.iconSize
                color: Theme.surfaceText
            }
        }
    }

    verticalBarPill: Component {
        Item {
            implicitWidth: parent.widgetThickness
            implicitHeight: icon.implicitHeight + Theme.spacingM * 2

            DankIcon {
                id: icon
                anchors.centerIn: parent
                name: "power_settings_new"
                size: Theme.iconSize
                color: Theme.surfaceText
            }
        }
    }
}
