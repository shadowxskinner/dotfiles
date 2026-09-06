import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property bool active: false
    property var popoutService: null

    function refresh() {
        Proc.runCommand("gamingMode.status", ["gaming-mode", "status"], (stdout, exitCode) => {
            if (exitCode === 0)
                root.active = stdout.trim() === "on"
        }, 100)
    }

    function toggle() {
        Quickshell.execDetached(["gaming-mode", "toggle"])
        refreshDelay.restart()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: refreshDelay
        interval: 700
        repeat: false
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    ccWidgetIcon: "sports_esports"
    ccWidgetPrimaryText: "Gaming Mode"
    ccWidgetSecondaryText: active ? "Hermes and local AI paused" : "Ready"
    ccWidgetIsActive: active
    onCcWidgetToggled: toggle()

    horizontalBarPill: Component {
        StyledRect {
            width: root.active ? 78 : 38
            height: parent.widgetThickness
            radius: Theme.cornerRadius
            color: root.active ? Theme.primary : Theme.surfaceContainerHigh

            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacingXS

                DankIcon {
                    name: "sports_esports"
                    color: root.active ? Theme.onPrimary : Theme.surfaceVariantText
                    size: Theme.iconSize - 4
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    visible: root.active
                    text: "GAME"
                    color: Theme.onPrimary
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggle()
            }
        }
    }

    verticalBarPill: Component {
        StyledRect {
            width: parent.widgetThickness
            height: parent.widgetThickness
            radius: Theme.cornerRadius
            color: root.active ? Theme.primary : Theme.surfaceContainerHigh

            DankIcon {
                anchors.centerIn: parent
                name: "sports_esports"
                color: root.active ? Theme.onPrimary : Theme.surfaceVariantText
                size: Theme.iconSize - 4
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggle()
            }
        }
    }
}
