import QtQuick 2.9
import QtQuick.Controls 2.2
import MuseScore 3.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "zparkingb/selectionhelper.js" as SelHelper
import "zparkingb/notehelper.js" as NoteHelper
import "zparkingb/chordanalyser.js" as ChordHelper
import "soloanalyser/core.js" as Core
import "soloanalyser"

/**********************
/* Parking B - MuseScore - Solo Analyser plugin
/* v1.3.0
/* ChangeLog:
/*  - 1.3.0: Initial version based on SoloAnalyser 1.3.0
/**********************************************/

MuseScore {
    menuPath: "Plugins." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.3.0"

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

        // 1) Read config file
        // AUTOMATIC

        // 2) push to screen

        select(lstColorNote, settings.colorNotes);
        select(lstNameNote, settings.nameNotes);
        select(lstFormText, settings.textType);

        rootColorChosser.color = settings.rootColor;
        bassColorChosser.color = settings.bassColor;
        chordColorChosser.color = settings.chordColor;
        scaleColorChosser.color = settings.scaleColor;
        // errorColorChosser.color = settings.errorColor;

    }

    function select(control, value) {
        var index = 0;
        for (var i = 0; i < control.model.length; i++) {
            if (control.model[i].value == value) {
                index = i;
                break;
            }
        }
        control.currentIndex = index;

    }
    function get(control) {
        return control.model[control.currentIndex].value;

    }

    Settings {
        id: settings
        category: "SoloAnalyser"
        // in options
        property var rootColor: Core.defRootColor
        property var bassColor: Core.defBassColor
        property var chordColor: Core.defChordColor
        property var scaleColor: Core.defScaleColor
        property var errorColor: Core.defErrorColor
        property var colorNotes: Core.defColorNotes
        property var nameNotes: Core.defNameNotes
        property var textType: Core.defTextType
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

            NiceComboBox {
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

            }

            Label {
                text: "Note name"
                //Tooltip.text : "Name all notes or only the ones defined by the chord";
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: false
            }

            NiceComboBox {
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

            }

            Label {
                text: "Root:"
            }
            Rectangle {
                id: rootColorChosser
                width: 50
                height: 30
                color: "gray"
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
                text: "Bass:"
            }
            Rectangle {
                id: bassColorChosser
                width: 50
                height: 30
                color: "gray"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = bassColorChosser.color
                            colorDialog.target = bassColorChosser;
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
                color: "gray"
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
                color: "gray"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        colorDialog.color = scaleColorChosser.color
                            colorDialog.target = scaleColorChosser;
                        colorDialog.open();
                    }
                }
            }

            /*Label {
            text: "Invalid:"
            }
            Rectangle {
            id: errorColorChosser
            width: 50
            height: 30
            color: "gray"
            MouseArea {
            anchors.fill: parent
            onClicked: {
            colorDialog.color = errorColorChosser.color
            colorDialog.target = errorColorChosser;
            colorDialog.open();
            }
            }
            }*/

            Label {
                text: "Text form"
            }

            NiceComboBox {
                id: lstFormText
                model: [{
                        value: "fingering",
                        text: "As fingering"
                    }, {
                        value: "lyrics",
                        text: "As lyrics"
                    }
                ]

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
                onClicked: {
                    settings.rootColor = Core.defRootColor;
                    settings.bassColor = Core.defBassColor;
                    settings.chordColor = Core.defChordColor;
                    settings.scaleColor = Core.defScaleColor;
                    settings.errorColor = Core.defErrorColor;
                    settings.colorNotes = Core.defColorNotes;
                    settings.nameNotes = Core.defNameNotes;
                    settings.textType = Core.defTextType;

                    select(lstColorNote, settings.colorNotes);
                    select(lstNameNote, settings.nameNotes);
                    select(lstFormText, settings.textType);

                    rootColorChosser.color = settings.rootColor;
                    bassColorChosser.color = settings.bassColor;
                    chordColorChosser.color = settings.chordColor;
                    scaleColorChosser.color = settings.scaleColor;
                    // errorColorChosser.color = settings.errorColor;
                }
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
                    id: btnClear
                    DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
                }

                onAccepted: {
                    // push values to backend
                    settings.rootColor = rootColorChosser.color;
                    settings.bassColor = bassColorChosser.color;
                    settings.chordColor = chordColorChosser.color;
                    settings.scaleColor = scaleColorChosser.color;
                    // settings.errorColor = errorColorChosser.color;

                    settings.colorNotes = get(lstColorNote);
                    settings.nameNotes = get(lstNameNote);
                    settings.textType = get(lstFormText);

                    // save values
                    // AUTOMATIC

                    // execute
                    Core.doAnalyse();
                    Qt.quit();

                }

                onClicked: {
                    console.log("~~~~~~~~~~~~" + button.text + "~~~~~~~~~~~~");
                    if (button == btnClear) {
                        Core.clearAnalyse();
                        Qt.quit();
                    }
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