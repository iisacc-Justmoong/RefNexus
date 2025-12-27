import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root
    property bool requestedOpen: false
    signal dismissed()

    edge: Qt.LeftEdge
    width: 320
    modal: false

    onRequestedOpenChanged: requestedOpen ? open() : close()
    onClosed: dismissed()

    background: Rectangle {
        color: "#0b1120"
    }

    ListModel {
        id: captureModel
        ListElement { name: "Browser send"; detail: "Capture tab or selection" }
        ListElement { name: "Clipboard"; detail: "Paste image or SVG" }
        ListElement { name: "Watch folder"; detail: "Auto-ingest new files" }
        ListElement { name: "Custom protocol"; detail: "refnexus://capture" }
    }

    ColumnLayout {
        anchors.fill: parent
        padding: 16
        spacing: 12

        Label {
            text: "Quick Capture"
            color: "#f8fafc"
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }

        Label {
            text: "Send references directly from local tools"
            color: "#94a3b8"
            font.pixelSize: 12
        }

        Repeater {
            model: captureModel

            Rectangle {
                width: parent.width
                height: 70
                radius: 10
                color: "#111c34"
                border.color: "#1e293b"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Label {
                        text: name
                        color: "#f8fafc"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: detail
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            background: Rectangle {
                color: "#111c34"
                radius: 12
                border.color: "#1e293b"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                Label {
                    text: "Watch Folders"
                    color: "#e2e8f0"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                Label {
                    text: "~/Desktop/Captures"
                    color: "#94a3b8"
                    font.pixelSize: 11
                }

                Label {
                    text: "~/Studio/Inbox"
                    color: "#94a3b8"
                    font.pixelSize: 11
                }

                Button {
                    text: "Add watch folder"
                }
            }
        }
    }
}
