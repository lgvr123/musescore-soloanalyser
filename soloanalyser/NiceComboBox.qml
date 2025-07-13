import QtQuick 2.9
import QtQuick.Controls 2.2

// v1.1.0: including textRole
// v1.1.1: bugfix on textRole
// v1.1.2: disabled color
// v1.1.3: new Select function
// v1.1.3: bug if text is undefined

ComboBox {
    id: control

    model: []
	
	textRole: "text"

    delegate: ItemDelegate { // requiert QuickControls 2.2
        width: control.width
        contentItem: Text {
            text: modelData[textRole]
            anchors.verticalCenter: parent.verticalCenter
        }
        highlighted: control.highlightedIndex === index
    }

    contentItem: Text {

        text: (control.model[control.currentIndex])?control.model[control.currentIndex][textRole]:"--"
        anchors.verticalCenter: parent.verticalCenter
        color: (control.enabled)?sysActivePalette.text:sysActivePalette.mid
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

    function select(value) {
        try {
            var index = 0;
            if (Array.isArray(control.model)) {
                for (var i = 0; i < control.model.length; i++) {
                    // console.log(")))" + i + ") " + control.model[i].value + " <-> " + value);
                    if (control.model[i].value == value) {
                        index = i;
                        break;
                    }
                }
            } else {
                // Si ce n'est pas une Array, on suppose que c'est un ListModel
                for (var i = 0; i < control.model.size; i++) {
                    // console.log(")))" + i + ") " + control.model.get(i).value + " <-> " + value);
                    if (control.model.get(i).value == value) {
                        index = i;
                        break;
                    }
                }
            }
            control.currentIndex = index;
        } catch (err) {
            console.log("fail to select value " + value + "\n" + err);
        }
    }
    
    function get() {
        try {
            if (Array.isArray(control.model)) {
                return control.model[control.currentIndex].value;
            } else {
                // Si ce n'est pas une Array, on suppose que c'est un ListModel
                return control.model.get(control.currentIndex).value;
            }
        } catch (err) {
            return undefined;
        }
    }

    function computeWidth(mdl) {
        if (mdl == null) {
            return;
        }



        var longest = "";
        for (var i = 0; i < mdl.length; i++) {
            var txt = mdl[i].text;
            if (txt && txt.length > longest.length)
                longest = txt;
        }
        var pwidth = fontMetric.boundingRect(longest).width;
        pwidth += control.contentItem.rightPadding + control.contentItem.leftPadding;
        pwidth += control.indicator.width

        return pwidth;
    }

    SystemPalette { id: sysActivePalette; colorGroup: SystemPalette.Active }
    SystemPalette { id: sysDisabledPalette; colorGroup: SystemPalette.Disabled }

}