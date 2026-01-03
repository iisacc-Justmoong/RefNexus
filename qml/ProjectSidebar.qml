import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#0f141d"
    border.color: "#243145"
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#131a26" }
        GradientStop { position: 1.0; color: "#0f141d" }
    }

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
                color: "#e6edf5"
                font.pixelSize: 16
                Layout.fillWidth: true
            }

            ToolButton {
                id: collapseButton
                display: AbstractButton.IconOnly
                icon.source: "qrc:/qt/qml/RefNexus/resources/icon-chevron-left.svg"
                icon.width: 16
                icon.height: 16
                hoverEnabled: true
                ToolTip.text: "Collapse sidebar"
                ToolTip.delay: 1000
                ToolTip.visible: hovered
                onClicked: root.collapseRequested(true)
                implicitWidth: 30
                implicitHeight: 30
                background: Rectangle {
                    radius: 8
                    color: collapseButton.down
                        ? "#2a3a54"
                        : (collapseButton.hovered ? "#1f2a3a" : "#121826")
                    border.color: "#243145"
                }
            }
        }

        ToolButton {
            id: expandButton
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
            implicitWidth: 30
            implicitHeight: 30
            background: Rectangle {
                radius: 8
                color: expandButton.down
                    ? "#2a3a54"
                    : (expandButton.hovered ? "#1f2a3a" : "#121826")
                border.color: "#243145"
            }
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
            id: newProjectButton
            display: AbstractButton.TextBesideIcon
            icon.source: "qrc:/qt/qml/RefNexus/resources/icon-new-project.svg"
            icon.width: 18
            icon.height: 18
            text: "New Project"
            Layout.fillWidth: true
            hoverEnabled: true
            ToolTip.text: "Create a new Untitled project"
            ToolTip.delay: 1000
            ToolTip.visible: hovered
            onClicked: root.createProjectRequested("Untitled")
            implicitHeight: 36
            background: Rectangle {
                radius: 10
                color: newProjectButton.down
                    ? "#2a3a54"
                    : (newProjectButton.hovered ? "#1f2a3a" : "#121826")
                border.color: "#243145"
            }
            contentItem: RowLayout {
                spacing: 8
                anchors.centerIn: parent
                Image {
                    source: newProjectButton.icon.source
                    width: 16
                    height: 16
                    fillMode: Image.PreserveAspectFit
                }
                Label {
                    text: newProjectButton.text
                    color: "#e6edf5"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }
            }
        }

        Label {
            text: "Saved Sessions"
            color: "#9aa6b2"
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
                projectIndex: index
                projectName: name
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
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    radius: 4
                    color: "#2a364a"
                }
                background: Rectangle {
                    radius: 4
                    color: "#101621"
                }
            }

            Text {
                anchors.centerIn: parent
                visible: projectList.count === 0
                text: "No saved projects yet"
                color: "#9aa6b2"
                font.pixelSize: 12
            }
        }
    }
}
