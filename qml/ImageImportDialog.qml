import QtQuick
import QtQuick.Dialogs

FileDialog {
    id: root
    title: "Add Images"
    fileMode: FileDialog.OpenFiles
    nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.bmp *.gif *.tif *.tiff)"]

    signal imagesSelected(var urls)

    onAccepted: root.imagesSelected(selectedFiles)
}
