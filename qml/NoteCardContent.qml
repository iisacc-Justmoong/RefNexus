import QtQuick
import QtQuick.Controls

Item {
    id: root
    property string noteText: ""
    signal noteEdited(string text)

    TextArea {
        anchors.fill: parent
        anchors.margins: 10
        text: root.noteText
        wrapMode: TextEdit.WordWrap
        color: "#e2e8f0"
        placeholderText: "Note"
        Keys.onPressed: {
            if (event.key === Qt.Key_Return
                || event.key === Qt.Key_Enter
                || event.key === Qt.Key_Escape) {
                focus = false
                event.accepted = true
            }
        }
        background: Item { }
        onTextChanged: {
            if (activeFocus) {
                root.noteEdited(text)
            }
        }
    }
}
