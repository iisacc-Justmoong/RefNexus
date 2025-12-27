import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string title: ""
    property var model
    property string titleRole: "name"
    property string countRole: "count"
    property string actionText: ""
    signal actionRequested()
    signal itemSelected(int index, string name)

    RowLayout {
        Layout.fillWidth: true

        Label {
            text: root.title
            color: "#cbd5f5"
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }

        Item {
            Layout.fillWidth: true
        }

        ToolButton {
            visible: root.actionText !== ""
            text: root.actionText
            onClicked: root.actionRequested()
        }
    }

    ListView {
        Layout.fillWidth: true
        model: root.model
        interactive: false
        clip: true
        spacing: 2
        height: contentHeight

        delegate: ItemDelegate {
            width: ListView.view.width
            padding: 6

            readonly property string labelText: model[root.titleRole] !== undefined
                ? model[root.titleRole]
                : modelData
            readonly property string countText: root.countRole !== "" && model[root.countRole] !== undefined
                ? String(model[root.countRole])
                : ""

            onClicked: root.itemSelected(index, labelText)

            contentItem: RowLayout {
                Label {
                    text: labelText
                    color: "#e2e8f0"
                    font.pixelSize: 12
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    visible: countText !== ""
                    radius: 9
                    color: "#1f2a44"
                    Layout.preferredHeight: 18
                    Layout.minimumWidth: 28

                    Label {
                        anchors.centerIn: parent
                        text: countText
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
