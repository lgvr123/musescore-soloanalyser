import QtQuick 2.9
import QtQuick.Controls 2.2

ComboBox {
    id: control

    model: []

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

    Binding on implicitWidth {
        value: computeWidth(model)
    }
	
	popup.implicitWidth: computeWidth(model)


    function computeWidth(mdl) {
        if (mdl == null) {
            return;
        }



        var longest = "";
        for (var i = 0; i < mdl.length; i++) {
            var txt = mdl[i].text;
            if (txt.length > longest.length)
                longest = txt;
        }
        var pwidth = fontMetric.boundingRect(longest).width;
        pwidth += control.contentItem.rightPadding + control.contentItem.leftPadding;
        pwidth += control.indicator.width

        return pwidth;
    }

}