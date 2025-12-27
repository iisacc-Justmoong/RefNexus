import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: root
    property bool requestedOpen: false
    property string query: ""
    signal dismissed()

    edge: Qt.RightEdge
    width: 360
    modal: false

    onRequestedOpenChanged: requestedOpen ? open() : close()
    onClosed: dismissed()

    background: Rectangle {
        color: "#0b1120"
    }

    ListModel {
        id: resultsModel
        ListElement { title: "Red umbrella alley"; board: "Inspiration"; tags: "neon, rain" }
        ListElement { title: "Fog pass"; board: "Lighting"; tags: "atmosphere" }
        ListElement { title: "Concrete wall"; board: "Materials"; tags: "rough" }
        ListElement { title: "Crowd flow"; board: "Environments"; tags: "composition" }
    }

    ColumnLayout {
        anchors.fill: parent
        padding: 16
        spacing: 12

        Label {
            text: "Search"
            color: "#f8fafc"
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }

        TextField {
            text: root.query
            placeholderText: "Search by text, color, or metadata"
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true

            ComboBox {
                model: ["All boards", "Current board", "Inbox"]
                Layout.fillWidth: true
            }

            ComboBox {
                model: ["Relevance", "Newest", "Color match", "Similarity"]
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Switch {
                text: "Include notes"
                checked: true
            }

            Switch {
                text: "Visual similarity"
                checked: true
            }
        }

        Label {
            text: "Results"
            color: "#cbd5f5"
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: resultsModel
            spacing: 8

            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                radius: 10
                color: "#111c34"
                border.color: "#1e293b"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Label {
                        text: title
                        color: "#f8fafc"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: board + " · " + tags
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
