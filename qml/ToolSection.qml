import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string title: ""
    property int contentPadding: 10
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
        implicitHeight: contentLayout.implicitHeight + root.contentPadding * 2
        implicitWidth: contentLayout.implicitWidth + root.contentPadding * 2
        Layout.fillWidth: true

        ColumnLayout {
            id: contentLayout
            spacing: 10
            anchors.fill: parent
            anchors.margins: root.contentPadding
        }
    }
}
