import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Rectangle {
    id: control
    property var currentValue // {"root":"C","scale":"wholeTone", "color": "#ffbbaa", "scaleLabel": "Whole Tone"}
        
    color: "transparent"
    
    // anchors.fill: parent

    width: 200
    height: ldr.childrenRect.height+10

    RowLayout {
        id: ldr
        anchors.verticalCenter: parent.verticalCenter
        // anchors.left: parent.left
        anchors.fill: parent
        anchors.margins: 5

        Text {
            text: (control.currentValue) ? (
                control.currentValue["root"] + " - " +
                ((control.currentValue["scale"] == "custom") ? control.currentValue["custom"] :control.currentValue["scaleLabel"])) 
                : "--"
            // Layout.preferredWidth: 200
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Rectangle {
            width: 20
            height: 20
            Layout.alignment: Qt.AlignVCenter
            color: (control.currentValue && control.currentValue["color"]) ? control.currentValue["color"] : "Gray"
            border.color: sysActivePalette.button
        }
    }
}


