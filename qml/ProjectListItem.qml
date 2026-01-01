import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property int projectIndex
    required property string projectName
    property bool selected: false
    property bool editing: false
    property string editingName: ""
    property color surfaceColor: "#121826"
    property color surfaceHover: "#1a2332"
    property color borderColor: "#243145"
    property color accentColor: "#5c7cfa"
    property color textPrimary: "#e6edf5"
    property color textSecondary: "#9aa6b2"

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
        radius: 8
        color: root.selected
            ? "#1b2534"
            : (projectSelectArea.containsMouse ? root.surfaceHover : "transparent")
        border.color: root.selected ? root.accentColor : "transparent"
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
                text: root.projectName
                color: root.textPrimary
                font.pixelSize: 12
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
                color: root.textPrimary
                placeholderTextColor: root.textSecondary
                font.pixelSize: 12
                leftPadding: 8
                rightPadding: 8
                topPadding: 6
                bottomPadding: 6
                background: Rectangle {
                    radius: 6
                    color: projectNameEditor.activeFocus
                        ? "#1b2534"
                        : root.surfaceColor
                    border.color: projectNameEditor.activeFocus
                        ? root.accentColor
                        : root.borderColor
                }
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
                    root.selectRequested(root.projectIndex)
                }
                onDoubleClicked: {
                    if (ListView.view) {
                        ListView.view.forceActiveFocus()
                    }
                    root.renameRequested(root.projectIndex)
                }
            }

            ToolTip.text: "Load project: " + root.projectName
            ToolTip.delay: 1000
            ToolTip.visible: projectSelectArea.containsMouse
        }

        ToolButton {
            id: deleteButton
            hoverEnabled: true
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-trash.svg"
            icon.width: 16
            icon.height: 16
            onClicked: root.deleteRequested(root.projectIndex)
            ToolTip.text: "Delete project"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            implicitWidth: 28
            implicitHeight: 28
            background: Rectangle {
                radius: 8
                color: deleteButton.down
                    ? "#2a3a54"
                    : (deleteButton.hovered ? "#1f2a3a" : root.surfaceColor)
                border.color: root.borderColor
            }
        }
    }
}
