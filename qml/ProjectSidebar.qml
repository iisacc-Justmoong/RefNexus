import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0f1115"
    border.color: "#1b1f26"

    property bool collapsed: false
    property var projectModel
    property int selectedProjectIndex: -1
    property int editingProjectIndex: -1
    property string editingProjectName: ""

    signal collapseRequested(bool collapsedState)
    signal createProjectRequested(string name)
    signal projectSelected(int index)
    signal deleteProjectRequested(int index)
    signal renameProjectRequested(int index)
    signal renameCommitted()
    signal renameCanceled()
    signal editingProjectNameUpdated(string name)

    Item {
        id: leftSidebarHeader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 44

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            visible: !root.collapsed

            Label {
                text: "Projects"
                color: "#d7dbe0"
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            ToolButton {
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-left.svg"
                icon.width: 16
                icon.height: 16
                hoverEnabled: true
                ToolTip.text: "Collapse sidebar"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.collapseRequested(true)
            }
        }

        ToolButton {
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-right.svg"
            icon.width: 16
            icon.height: 16
            hoverEnabled: true
            ToolTip.text: "Expand sidebar"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            anchors.centerIn: parent
            visible: root.collapsed
            onClicked: root.collapseRequested(false)
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: leftSidebarHeader.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 16
        spacing: 12
        visible: !root.collapsed

        Button {
            display: AbstractButton.IconOnly
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-new-project.svg"
            icon.width: 18
            icon.height: 18
            Layout.fillWidth: true
            hoverEnabled: true
            ToolTip.text: "Create a new Untitled project"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            onClicked: root.createProjectRequested("Untitled")
        }

        Label {
            text: "Saved Sessions"
            color: "#8b9098"
            font.pixelSize: 12
        }

        ListView {
            id: projectList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.projectModel
            focus: true
            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (root.editingProjectIndex >= 0) {
                        root.renameCommitted()
                    } else if (root.selectedProjectIndex >= 0) {
                        root.renameProjectRequested(root.selectedProjectIndex)
                    }
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    root.renameCanceled()
                    event.accepted = true
                }
            }
            delegate: ProjectListItem {
                index: index
                name: name
                selected: index === root.selectedProjectIndex
                editing: index === root.editingProjectIndex
                editingName: root.editingProjectName
                onSelectRequested: root.projectSelected(index)
                onRenameRequested: root.renameProjectRequested(index)
                onDeleteRequested: root.deleteProjectRequested(index)
                onEditingNameUpdated: function(updatedName) {
                    root.editingProjectNameUpdated(updatedName)
                }
                onRenameCommitted: root.renameCommitted()
                onRenameCanceled: root.renameCanceled()
            }
            ScrollBar.vertical: ScrollBar { }

            Text {
                anchors.centerIn: parent
                visible: root.projectModel ? root.projectModel.count === 0 : true
                text: "No saved projects yet"
                color: "#8b9098"
                font.pixelSize: 12
            }
        }
    }
}
