import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string title: ""
    default property alias content: contentLayout.data
    spacing: 10
    Layout.fillWidth: true

    Label {
        text: root.title
        color: "#9aa6b2"
        font.pixelSize: 12
    }

    Rectangle {
        radius: 10
        color: "#111826"
        border.color: "#243145"
        Layout.fillWidth: true

        ColumnLayout {
            id: contentLayout
            spacing: 10
            anchors.fill: parent
            anchors.margins: 10
        }
    }
}
