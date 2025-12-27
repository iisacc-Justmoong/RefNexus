import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    property bool opened: false
    signal closed()

    modal: true
    title: "Settings"
    width: 620
    height: 460
    visible: opened

    onAccepted: {
        opened = false
        closed()
    }

    onRejected: {
        opened = false
        closed()
    }

    onVisibleChanged: {
        if (!visible && opened) {
            opened = false
            closed()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12
        padding: 16

        TabBar {
            id: tabs
            Layout.fillWidth: true

            TabButton { text: "General" }
            TabButton { text: "Capture" }
            TabButton { text: "Indexing" }
            TabButton { text: "Storage" }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            ColumnLayout {
                spacing: 10

                Switch { text: "Launch on startup" }
                Switch { text: "Auto-save boards"; checked: true }
                Switch { text: "Enable quick overlay mode"; checked: true }

                TextField {
                    placeholderText: "Default workspace folder"
                    text: "~/RefNexus"
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                spacing: 10

                Switch { text: "Enable browser capture"; checked: true }
                Switch { text: "Auto-ingest from watch folders"; checked: true }

                TextField {
                    placeholderText: "Custom protocol handler"
                    text: "refnexus://capture"
                    Layout.fillWidth: true
                }

                Button { text: "Manage watch folders" }
            }

            ColumnLayout {
                spacing: 10

                Switch { text: "Generate visual embeddings"; checked: true }
                Switch { text: "Group near-duplicates"; checked: true }
                Switch { text: "Enable offline text-image search"; checked: true }

                ComboBox {
                    model: ["Balanced", "Fast", "High quality"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                spacing: 10

                ComboBox {
                    model: ["Embedded", "Linked"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }

                Switch { text: "Keep lossless originals"; checked: true }
                Switch { text: "Generate smart previews"; checked: true }

                Button { text: "Open cache directory" }
            }
        }
    }
}
