import QtQuick 2.9
import QtQuick.Controls 2.2

ComboBox {
    //Layout.fillWidth : true
    id: control

    delegate: ItemDelegate { // requiert QuickControls 2.2
		width: control.width
        contentItem: Text {
            text: modelData.text
            anchors.verticalCenter: parent.verticalCenter
        }
        highlighted: control.highlightedIndex === index
    }

    contentItem: Text {

        text: control.model[control.currentIndex].text
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: 10
        rightPadding: 10
        topPadding: 5
        bottomPadding: 5
        verticalAlignment: Text.AlignVCenter

    }

    FontMetrics {
        id: fontMetric
        font.family: control.contentItem.font.family

    }
    Component.onCompleted: {
        control.activated(-1);
    }
    onActivated: { // arg: index
        var longest = "";
        for (var i = 0; i < control.model.length; i++) {
            var txt = control.model[i].text;
            if (txt.length > longest.length)
                longest = txt;
        }
        var pwidth = fontMetric.boundingRect(longest).width;
        pwidth += control.contentItem.rightPadding + control.contentItem.leftPadding;
        pwidth += control.indicator.width
        control.width = pwidth;
    }

}