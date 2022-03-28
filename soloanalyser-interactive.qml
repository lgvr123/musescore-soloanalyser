import QtQuick 2.9
import QtQuick.Controls 2.2
import MuseScore 3.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import FileIO 3.0

import "zparkingb/selectionhelper.js" as SelHelper
import "zparkingb/notehelper.js" as NoteHelper
import "zparkingb/chordanalyser.js" as ChordHelper
import "soloanalyser/core.js" as Core
import "soloanalyser"

/**********************
/* Parking B - MuseScore - Solo Analyser plugin
/* v1.3.0
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: Using of ChordAnalyzer shared library
/*  - 1.1.0: New coloring approach
/*  - 1.2.0: Colors and names (optionnaly) all the notes
/*  - 1.2.1: Uses the bass note if specified in the chord
/*  - 1.2.1: Minor improvments on the chord recognission
/*  - 1.3.0: Code moved to a library
/**********************************************/

MuseScore {
    menuPath: "Plugins." + pluginName
    description: "Colors the notes part of each measure harmony."
    version: "1.2.1"

    readonly property var pluginName: "Solo Analyser - Interactive"

    pluginType: "dialog"
    //implicitWidth: controls.implictWidth * 1.5
    //implicitHeight: controls.implicitHeight
    implicitWidth: 500
    implicitHeight: 400

    id: mainWindow

    readonly property var selHelperVersion: "1.2.0"
    readonly property var noteHelperVersion: "1.0.3"
    readonly property var chordHelperVersion: "1.2.7"

    onRun: {

        if ((typeof(SelHelper.checktVersion) !== 'function') || !SelHelper.checktVersion(selHelperVersion) ||
            (typeof(NoteHelper.checktVersion) !== 'function') || !NoteHelper.checktVersion(noteHelperVersion) ||
            (typeof(ChordHelper.checkVersion) !== 'function') || !ChordHelper.checkVersion(chordHelperVersion)) {
            console.log("Invalid zparkingb/selectionhelper.js, zparkingb/notehelper.js or zparkingb/chordanalyser.js versions. Expecting "
                 + selHelperVersion + " and " + noteHelperVersion + " and " + chordHelperVersion + ".");
            invalidLibraryDialog.open();
            return;
        }

        //Core.analyse();
    }

    ColumnLayout {
        anchors.fill: parent
        GridLayout {
            id: controls

			Layout.margins: 10
            columnSpacing: 10
            rowSpacing: 10
            columns: 2

            Layout.fillHeight: true

            Label {
                text: "Note coloring"
                //Tooltip.text : "Color all notes or only the ones defined by the chord";
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: false
            }

            ComboBox {
                //Layout.fillWidth : true
                id: lstColorNote
                model: [{
                        'value': "none",
                        'text': "None - Don't color notes"
                    }, {
                        'value': "chord",
                        'text': "Chord - Color the notes present in the chord"
                    }, {
                        'value': "all",
                        'text': "Scale - Color the notes defined by the scale"
                    }
                ]

                delegate: ItemDelegate { // requiert QuickControls 2.2
                    contentItem: Text {
                        id: cnci
                        text: modelData.text
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    highlighted: lstColorNote.highlightedIndex === index
                }

                contentItem: Text {

                    text: lstColorNote.model[lstColorNote.currentIndex].text
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 5
                    verticalAlignment: Text.AlignVCenter

                }

            }

            Label {
                text: "Note name"
                //Tooltip.text : "Name all notes or only the ones defined by the chord";
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: false
            }

            ComboBox {
                //Layout.fillWidth : true
                id: lstNameNote
                model: [{
                        'value': "none",
                        'text': "None - Don't name notes"
                    }, {
                        'value': "chord",
                        'text': "Chord - Name the notes present by the chord"
                    }, {
                        'value': "all",
                        'text': "Scale - Name the notes defined by the scale"
                    }
                ]

                delegate: ItemDelegate { // requiert QuickControls 2.2
                    contentItem: Text {
                        text: modelData.text
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    highlighted: lstNameNote.highlightedIndex === index
                }

                contentItem: Text {

                    text: lstNameNote.model[lstNameNote.currentIndex].text
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 5
                    verticalAlignment: Text.AlignVCenter

                }

            }

            Label {
                text: "Root:"
            }
            Rectangle {
                id: rootColorChosser
                width: 50
                height: 30
                color: Core.rootColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = rootColorChosser.color
                            colorDialog.target = rootColorChosser;
                        colorDialog.open();
                    }
                }
            }

            Label {
                text: "Chord:"
            }
            Rectangle {
                id: chordColorChosser
                width: 50
                height: 30
                color: Core.chordColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = chordColorChosser.color
                            colorDialog.target = chordColorChosser;
                        colorDialog.open();
                    }
                }
            }

            Label {
                text: "Scale:"
            }
            Rectangle {
                id: scaleColorChosser
                width: 50
                height: 30
                color: Core.scaleColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = scaleColorChosser.color
                            colorDialog.target = scaleColorChosser;
                        colorDialog.open();
                    }
                }
            }

            Label {
                text: "Invalid:"
            }
            Rectangle {
                id: errorColorChosser
                width: 50
                height: 30
                color: Core.errorColor
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = errorColorChosser.color
                            colorDialog.target = errorColorChosser;
                        colorDialog.open();
                    }
                }
            }
        }

        Item { // spacer // DEBUG Item/Rectangle
            implicitWidth: 10
            Layout.fillHeight: true
        }
        RowLayout {
			
			
            id: panButtons
            Layout.fillWidth: true
            Layout.fillHeight: false

            Button {
                implicitHeight: buttonBox.contentItem.height

                text: "Reset"
                onClicked: Core.restToDefault()

                ToolTip.text: "Reset to default values"
                hoverEnabled: true
            }


            Item { // spacer // DEBUG Item/Rectangle
                implicitHeight: 10
                Layout.fillWidth: true
            }


            DialogButtonBox {
                standardButtons: DialogButtonBox.Close
                id: buttonBox

                background.opacity: 0 // hide default white background

                Button {
                    text: "Apply"
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                }
                Button {
                    text: "Clear"
                    DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
                }

                onAccepted: {
                    // push values to backend

                    // save values

                    // execute
                    Core.analyse();
                    Qt.quit();

                }
                onRejected: Qt.quit()

            }
        }

    }

    ColorDialog {
        id: colorDialog
        title: "Please choose a color"
        property var target
        onAccepted: {
            console.log("You chose: " + colorDialog.color)
            if (target !== undefined)
                target.color = colorDialog.color;
        }
        onRejected: {
            console.log("Canceled")
        }
        // Component.onCompleted: visible = true
    }
    MessageDialog {
        id: invalidLibraryDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
        title: 'Invalid libraries'
        text: "Invalid zparkingb/selectionhelper.js, zparkingb/notehelper.js or zparkingb/chordanalyser.js versions.\nExpecting "
         + selHelperVersion + " and " + noteHelperVersion + " and " + chordHelperVersion + ".\n" + pluginName + " will stop here."
        onAccepted: {
            Qt.quit()
        }
    }

}