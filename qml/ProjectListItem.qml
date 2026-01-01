import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property int index
    required property string name
    property bool selected: false
    property bool editing: false
    property string editingName: ""

    signal selectRequested(int index)
    signal renameRequested(int index)
    signal deleteRequested(int index)
    signal editingNameUpdated(string name)
    signal renameCommitted()
    signal renameCanceled()

    width: ListView.view ? ListView.view.width : 0
    height: 34

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: root.selected ? "#1b1f26" : "transparent"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 8

        Item {
            id: projectHitArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.name
                color: "#d7dbe0"
                elide: Text.ElideRight
                visible: !root.editing
            }

            TextField {
                id: projectNameEditor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.editing ? root.editingName : ""
                visible: root.editing
                selectByMouse: true
                onVisibleChanged: {
                    if (visible) {
                        forceActiveFocus()
                        selectAll()
                    }
                }
                onTextChanged: {
                    if (activeFocus) {
                        root.editingNameUpdated(text)
                    }
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.renameCommitted()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.renameCanceled()
                        event.accepted = true
                    }
                }
                onEditingFinished: {
                    if (root.editing) {
                        root.renameCommitted()
                    }
                }
            }

            MouseArea {
                id: projectSelectArea
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.editing
                onClicked: {
                    if (ListView.view) {
                        ListView.view.forceActiveFocus()
                    }
                    root.selectRequested(root.index)
                }
                onDoubleClicked: {
                    if (ListView.view) {
                        ListView.view.forceActiveFocus()
                    }
                    root.renameRequested(root.index)
                }
            }

            ToolTip.text: "Load project: " + root.name
            ToolTip.delay: 1000
            ToolTip.visible: projectSelectArea.containsMouse
        }

        ToolButton {
            hoverEnabled: true
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-trash.svg"
            icon.width: 16
            icon.height: 16
            onClicked: root.deleteRequested(root.index)
            ToolTip.text: "Delete project"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
        }
    }
}
