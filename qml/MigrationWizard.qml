import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    property bool opened: false
    property int step: 0
    signal closed()

    modal: true
    title: "PureRef Migration"
    width: 620
    height: 420
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
        if (visible) {
            step = 0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        padding: 16
        spacing: 12

        TabBar {
            id: steps
            Layout.fillWidth: true
            currentIndex: root.step

            TabButton { text: "Source" }
            TabButton { text: "Mapping" }
            TabButton { text: "Import" }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.step

            ColumnLayout {
                spacing: 10

                Label {
                    text: "Choose a PureRef file or export"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                ComboBox {
                    model: [".pur direct import", "Canvas image export", "Selection export"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }

                Button { text: "Select file" }
            }

            ColumnLayout {
                spacing: 10

                Label {
                    text: "Map metadata to RefNexus"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                Switch { text: "Preserve layout when possible"; checked: true }
                Switch { text: "Rebuild tags from filenames"; checked: true }
                Switch { text: "Generate palettes"; checked: false }

                ComboBox {
                    model: ["Tidy grid", "Preserve clustering", "Auto layout"]
                    currentIndex: 1
                    Layout.fillWidth: true
                }
            }

            ColumnLayout {
                spacing: 10

                Label {
                    text: "Ready to import"
                    color: "#94a3b8"
                    font.pixelSize: 12
                }

                ProgressBar {
                    value: 0.4
                    Layout.fillWidth: true
                }

                Label {
                    text: "18 items prepared, 4 duplicates detected"
                    color: "#94a3b8"
                    font.pixelSize: 11
                }

                Button { text: "Start import" }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                text: "Back"
                enabled: root.step > 0
                onClicked: root.step = Math.max(0, root.step - 1)
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                text: root.step < 2 ? "Next" : "Finish"
                onClicked: {
                    if (root.step < 2) {
                        root.step += 1
                    } else {
                        root.opened = false
                        root.closed()
                    }
                }
            }
        }
    }
}
