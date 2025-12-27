import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: root
    property var workspaceModel
    property var boardsModel
    property string activeWorkspace: ""
    signal workspaceSelected(string name)

    background: Rectangle {
        color: "#0b1120"
    }

    ListModel {
        id: folderModel
        ListElement { name: "Moodboards"; count: "8" }
        ListElement { name: "Client Notes"; count: "3" }
        ListElement { name: "Library"; count: "24" }
    }

    ListModel {
        id: tagModel
        ListElement { name: "cyberpunk"; count: "42" }
        ListElement { name: "organic"; count: "18" }
        ListElement { name: "noir"; count: "23" }
        ListElement { name: "fabric"; count: "16" }
    }

    ListModel {
        id: paletteModel
        ListElement { name: "Rainy Neon"; count: "12" }
        ListElement { name: "Warm Skin"; count: "7" }
        ListElement { name: "Industrial"; count: "5" }
    }

    ListModel {
        id: noteModel
        ListElement { name: "Art direction"; count: "5" }
        ListElement { name: "Materials"; count: "9" }
        ListElement { name: "Feedback"; count: "3" }
    }

    ListModel {
        id: watchModel
        ListElement { name: "~/Desktop/Captures" }
        ListElement { name: "~/Studio/Inbox" }
    }

    ListModel {
        id: recentModel
        ListElement { name: "scan_1024.png" }
        ListElement { name: "crowd_scene.jpg" }
        ListElement { name: "palette_night.tif" }
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 16
            padding: 16

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Label {
                    text: "Workspace"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                ComboBox {
                    model: root.workspaceModel
                    textRole: "name"
                    onActivated: root.workspaceSelected(currentText)
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.fillWidth: true

                    Button {
                        text: "Open"
                        Layout.fillWidth: true
                        onClicked: root.workspaceSelected(activeWorkspace)
                    }

                    Button {
                        text: "New"
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 12
                color: "#111c34"
                border.color: "#1e293b"
                height: 90

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    Label {
                        text: "Inbox"
                        color: "#f8fafc"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: "17 new captures ready to sort"
                        color: "#94a3b8"
                        font.pixelSize: 12
                    }

                    Button {
                        text: "Review"
                        Layout.preferredWidth: 100
                    }
                }
            }

            SidebarSection {
                title: "Boards"
                model: root.boardsModel
                actionText: "+"
            }

            SidebarSection {
                title: "Folders"
                model: folderModel
                actionText: "+"
            }

            SidebarSection {
                title: "Tags"
                model: tagModel
                actionText: "+"
            }

            SidebarSection {
                title: "Palettes"
                model: paletteModel
                actionText: "+"
            }

            SidebarSection {
                title: "Notes"
                model: noteModel
                actionText: "+"
            }

            SidebarSection {
                title: "Watch Folders"
                model: watchModel
                countRole: ""
                actionText: "+"
            }

            SidebarSection {
                title: "Recent Imports"
                model: recentModel
                countRole: ""
            }
        }
    }
}
