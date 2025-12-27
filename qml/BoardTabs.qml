import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root
    property var boardsModel
    property string currentBoard: boardsModel && boardsModel.count > 0
        ? boardsModel.get(tabBar.currentIndex).name
        : ""
    signal boardSelected(string name)

    TabBar {
        id: tabBar
        Layout.fillWidth: true

        Repeater {
            model: root.boardsModel
            TabButton {
                text: model.name
                onClicked: root.boardSelected(model.name)
            }
        }
    }

    ToolButton {
        text: "+"
        onClicked: root.boardSelected("New Board")
    }
}
