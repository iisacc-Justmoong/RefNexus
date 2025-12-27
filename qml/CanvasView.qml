import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property bool gridEnabled: true
    property bool snapEnabled: true
    property bool desaturateMode: false
    property bool overlaySelection: false
    property real zoomLevel: 1.0
    property string activeBoard: ""
    signal itemSelected(var item)

    property string selectedCardId: ""
    property string selectedTitle: ""

    ListModel {
        id: cardModel
        ListElement {
            cardId: "img-1"
            title: "Neon Alley"
            subtitle: "seoul_station.jpg"
            kind: "image"
            tags: "night, neon, rain"
            accent: "#38bdf8"
            xPos: 240
            yPos: 160
            cardWidth: 320
            cardHeight: 240
            rotation: -2
            scale: 1.0
            locked: false
            source: "https://example.com/neo"
            capturedAt: "2025-03-14 11:02"
            license: "Client provided"
            notes: "Use as lighting cue"
        }
        ListElement {
            cardId: "img-2"
            title: "Street Umbrella"
            subtitle: "pinterest_4432.png"
            kind: "image"
            tags: "red, umbrella, silhouette"
            accent: "#fb7185"
            xPos: 640
            yPos: 240
            cardWidth: 280
            cardHeight: 200
            rotation: 1
            scale: 1.05
            locked: false
            source: "https://example.com/umbrella"
            capturedAt: "2025-03-14 12:45"
            license: "Research"
            notes: "Check silhouette and scale"
        }
        ListElement {
            cardId: "note-1"
            title: "Art Direction"
            subtitle: "Muted highlights, dense fog"
            kind: "note"
            tags: "brief"
            accent: "#22d3ee"
            xPos: 980
            yPos: 190
            cardWidth: 260
            cardHeight: 160
            rotation: 0
            scale: 1.0
            locked: true
            source: "Meeting notes"
            capturedAt: "2025-03-13 09:10"
            license: "Internal"
            notes: "Keep value range tight"
        }
        ListElement {
            cardId: "img-3"
            title: "Concrete Texture"
            subtitle: "library_scan.tif"
            kind: "image"
            tags: "material, rough"
            accent: "#fbbf24"
            xPos: 320
            yPos: 520
            cardWidth: 260
            cardHeight: 190
            rotation: 0
            scale: 0.95
            locked: false
            source: "Studio library"
            capturedAt: "2025-03-12 18:20"
            license: "Studio archive"
            notes: "Match wall columns"
        }
        ListElement {
            cardId: "img-4"
            title: "Crowd Flow"
            subtitle: "crowd_scene.jpg"
            kind: "image"
            tags: "composition, flow"
            accent: "#a855f7"
            xPos: 680
            yPos: 520
            cardWidth: 340
            cardHeight: 240
            rotation: -1
            scale: 1.0
            locked: false
            source: "https://example.com/crowd"
            capturedAt: "2025-03-10 08:00"
            license: "Research"
            notes: "Use for crowd density"
        }
        ListElement {
            cardId: "group-1"
            title: "Palette Cluster"
            subtitle: "Reds + Teals"
            kind: "group"
            tags: "palette"
            accent: "#2dd4bf"
            xPos: 1120
            yPos: 520
            cardWidth: 240
            cardHeight: 180
            rotation: 0
            scale: 1.0
            locked: true
            source: "Generated"
            capturedAt: "2025-03-15 14:35"
            license: "Internal"
            notes: "Use for lighting accents"
        }
        ListElement {
            cardId: "img-5"
            title: "Fog Pass"
            subtitle: "fog_layer.exr"
            kind: "image"
            tags: "fog, atmosphere"
            accent: "#60a5fa"
            xPos: 480
            yPos: 860
            cardWidth: 300
            cardHeight: 220
            rotation: 2
            scale: 1.0
            locked: false
            source: "Render output"
            capturedAt: "2025-03-16 10:10"
            license: "Project"
            notes: "Layer as overlay"
        }
    }

    Flickable {
        id: viewport
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: canvasRoot.width * root.zoomLevel
        contentHeight: canvasRoot.height * root.zoomLevel
        ScrollBar.vertical: ScrollBar { }
        ScrollBar.horizontal: ScrollBar { }

        Item {
            id: canvasRoot
            width: 4200
            height: 2800
            scale: root.zoomLevel

            Rectangle {
                anchors.fill: parent
                color: "#0b1220"
            }

            Item {
                id: gridLayer
                anchors.fill: parent
                visible: root.gridEnabled

                Repeater {
                    model: Math.ceil(gridLayer.width / 160)
                    Rectangle {
                        x: index * 160
                        width: 1
                        height: gridLayer.height
                        color: "#132033"
                    }
                }

                Repeater {
                    model: Math.ceil(gridLayer.height / 160)
                    Rectangle {
                        y: index * 160
                        width: gridLayer.width
                        height: 1
                        color: "#132033"
                    }
                }
            }

            Repeater {
                model: cardModel

                CanvasCard {
                    x: xPos
                    y: yPos
                    width: cardWidth
                    height: cardHeight
                    title: title
                    subtitle: subtitle
                    kind: kind
                    tags: tags
                    accentColor: accent
                    selected: root.selectedCardId === cardId
                    rotationAngle: rotation
                    scaleFactor: scale
                    locked: locked
                    onClicked: {
                        root.selectedCardId = cardId
                        root.selectedTitle = title
                        root.itemSelected({
                            title: title,
                            type: kind,
                            board: root.activeBoard,
                            source: source,
                            capturedAt: capturedAt,
                            license: license,
                            tags: tags,
                            notes: notes
                        })
                    }
                }
            }

            Rectangle {
                x: 40
                y: 40
                width: 220
                height: 80
                radius: 12
                color: "#111c34"
                border.color: "#1e293b"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Label {
                        text: root.activeBoard !== "" ? root.activeBoard : "Active Board"
                        color: "#e2e8f0"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    Label {
                        text: root.snapEnabled ? "Snap + constraints active" : "Snap disabled"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: root.desaturateMode
        color: "#0b1220"
        opacity: 0.25
    }

    Rectangle {
        width: 240
        height: 140
        radius: 12
        color: "#111c34"
        border.color: "#1e293b"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        visible: root.overlaySelection

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            Label {
                text: "Overlay Selection"
                color: "#e2e8f0"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            Label {
                text: root.selectedTitle !== "" ? root.selectedTitle : "No item selected"
                color: "#94a3b8"
                font.pixelSize: 11
            }

            Label {
                text: "Floating preview mode"
                color: "#64748b"
                font.pixelSize: 10
            }
        }
    }

    Rectangle {
        width: 160
        height: 110
        radius: 10
        color: "#0b1220"
        border.color: "#1e293b"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 18
        anchors.bottomMargin: 18

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Label {
                text: "Mini Map"
                color: "#e2e8f0"
                font.pixelSize: 11
            }

            Rectangle {
                width: 110
                height: 60
                radius: 6
                color: "#111c34"
                border.color: "#1e293b"
            }
        }
    }
}
