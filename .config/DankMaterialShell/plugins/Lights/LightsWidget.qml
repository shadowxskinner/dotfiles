import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "lights"
    popoutWidth: 280
    popoutHeight: 430

    property bool busy: false
    property var modes: [
        { "id": "candlelight", "label": "Candlelight" },
        { "id": "focus", "label": "Focus" },
        { "id": "gaming", "label": "Gaming" },
        { "id": "light", "label": "Light mode" },
        { "id": "movie", "label": "Movie" },
        { "id": "night", "label": "Night light" }
    ]

    function applyMode(modeId, label, popout) {
        if (root.busy)
            return
        root.busy = true
        Proc.runCommand("lights.apply." + modeId, ["ha-lights", modeId], (stdout, exitCode) => {
            root.busy = false
            const text = String(stdout).trim() || label
            if (exitCode === 0)
                ToastService.showInfo(text)
            else
                ToastService.showInfo("Lights failed")
            if (popout)
                popout.closePopout()
        }, 8000)
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: icon.implicitWidth + Theme.spacingM * 2
            height: parent.widgetThickness

            DankIcon {
                id: icon
                anchors.centerIn: parent
                name: "lightbulb"
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
                name: "lightbulb"
                size: Theme.iconSize
                color: Theme.surfaceText
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popoutColumn
            headerText: "Lights"
            detailsText: "Home Assistant lighting modes"
            showCloseButton: true

            Column {
                width: parent.width
                spacing: Theme.spacingS

                Repeater {
                    model: root.modes

                    StyledRect {
                        required property var modelData
                        width: parent.width
                        height: 40
                        radius: Theme.cornerRadius
                        color: modeMouse.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh

                        StyledText {
                            anchors.left: parent.left
                            anchors.leftMargin: Theme.spacingM
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: Theme.surfaceText
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        MouseArea {
                            id: modeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyMode(modelData.id, modelData.label, popoutColumn)
                        }
                    }
                }
            }
        }
    }
}
