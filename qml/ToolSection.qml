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
        color: "#8b9098"
        font.pixelSize: 12
    }

    ColumnLayout {
        id: contentLayout
        spacing: 10
        Layout.fillWidth: true
    }
}
