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
/* v1.4.3
/* ChangeLog:
/*  - 1.3.0: Initial version based on SoloAnalyser 1.3.0
/*  - 1.3.1: New altered notes color
/*  - 1.4.0: Multi track and voices
/*  - 1.4.0: Settings for the multi track and voices
/*  - 1.4.1: Bug with some transposing instruments
/*  - 1.4.2: Don't analyse the right selection if the selection is further than a certain point in the score
/*  - 1.4.2: Bug when first note is far beyond the first chord symbol
/*  - 1.4.2: LookAhead option + new UI layout
/*  - 1.4.3: New plugin menu's structure
/*  - 1.4.3: Qt.quit issue
/*  - 1.4.3: IgnoreBrackettedChords option
/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.4.3"

    readonly property var pluginName: "Interactive"

    pluginType: "dialog"
    //implicitWidth: controls.implictWidth * 1.5
    //implicitHeight: controls.implicitHeight
    implicitWidth: 900
    implicitHeight: 500

    id: mainWindow

    readonly property var selHelperVersion: "1.3.0"
    readonly property var noteHelperVersion: "1.0.3"
    readonly property var chordHelperVersion: "1.2.13"

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
        alteredColorChosser.color = settings.alteredColor;
        // errorColorChosser.color = settings.errorColor;

        chkUseAboveSymbols.checked = settings.useAboveSymbols;
        chkUseBelowSymbols.checked = settings.useBelowSymbols;
        chkLookAhead.checked = settings.lookAhead;
        chkIgnoreBrackettedChords.checked = settings.ignoreBrackettedChords;

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
        property var alteredColor: Core.defAlteredColor
        property var colorNotes: Core.defColorNotes
        property var nameNotes: Core.defNameNotes
        property var textType: Core.defTextType
        property var useBelowSymbols: Core.defUseBelowSymbols
        property var useAboveSymbols: Core.defUseAboveSymbols
        property var lookAhead: Core.defLookAhead
        property var ignoreBrackettedChords: Core.defIgnoreBrackettedChords
    }

    GridLayout {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 10
        
		columns: 2
                columnSpacing: 5


        GroupBox {
            title: "Rendering options..."
                //Layout.margins: 5
				Layout.alignment: Qt.AlignTop | Qt.AlignLeft
				GridLayout {
                columnSpacing: 5

                rowSpacing: 10
                columns: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

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
                    text: "Altered:"
                }
                Rectangle {
                    id: alteredColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = alteredColorChosser.color
                                colorDialog.target = alteredColorChosser;
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
        }

        GroupBox {
            title: "Analyze options..."
				Layout.alignment: Qt.AlignTop | Qt.AlignRight
            GridLayout {

                columnSpacing: 10
                rowSpacing: 10
	                Layout.fillWidth: true
			
				columns: 1

                Flow {
                    SmallCheckBox {
                        id: chkLookAhead
                        text: "Look ahead"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Use the next chord if no previous chord has been found (e.g. anacrusis)"
                    }
                }

                Flow {
                    SmallCheckBox {
                        id: chkUseAboveSymbols
                        text: "Allow using preceeding staves chord symbols"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "<p>If a staff has no chord symbols, use the chord symbols of the first <br/>preceeding staff having chord symbols.<br/><p><b><u>Remark</u></b>: When these options are used, SoloAnalyzer must be used <br/>preferably in <b>Concert pitch</b></p>"
                    }
                }

                Flow {
                    SmallCheckBox {
                        id: chkUseBelowSymbols
                        text: "Allow using following staves chord symbols"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "<p>If a staff has no chord symbols, use the chord symbols of the first <br/>following staff having chord symbols.<br/><p><b><u>Remark</u></b>: When these options are used, SoloAnalyzer must be used <br/>preferably in <b>Concert pitch</b></p>"
                    }
                }
                Flow {
                    SmallCheckBox {
                        id: chkIgnoreBrackettedChords
                        text: "Ignore chord names in parentheses"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Chord names surrounded by parentheses will be ignore for the analyse."
                    }
                }

            }
        }

        // Item { // spacer // DEBUG Item/Rectangle
            // implicitWidth: 10
            // Layout.fillHeight: true
        // }
        RowLayout {
			
			

            id: panButtons
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.margins: 0
			Layout.columnSpan: 2
            Button {
                implicitHeight: buttonBox.contentItem.height

                text: "Reset"
                onClicked: {
                    settings.rootColor = Core.defRootColor;
                    settings.bassColor = Core.defBassColor;
                    settings.chordColor = Core.defChordColor;
                    settings.scaleColor = Core.defScaleColor;
                    settings.errorColor = Core.defErrorColor;
                    settings.alteredColor = Core.defAlteredColor;
                    settings.colorNotes = Core.defColorNotes;
                    settings.nameNotes = Core.defNameNotes;
                    settings.textType = Core.defTextType;
                    settings.useAboveSymbols = Core.defUseAboveSymbols;
                    settings.useBelowSymbols = Core.defUseBelowSymbols;
                    settings.lookAhead = Core.defLookAhead;
                    settings.ignoreBrackettedChords = Core.defIgnoreBrackettedChords;

                    select(lstColorNote, settings.colorNotes);
                    select(lstNameNote, settings.nameNotes);
                    select(lstFormText, settings.textType);

                    rootColorChosser.color = settings.rootColor;
                    bassColorChosser.color = settings.bassColor;
                    chordColorChosser.color = settings.chordColor;
                    scaleColorChosser.color = settings.scaleColor;
                    alteredColorChosser.color = settings.alteredColor;
                    // errorColorChosser.color = settings.errorColor;

                    chkUseBelowSymbols.checked = settings.useBelowSymbols;
                    chkUseAboveSymbols.checked = settings.useAboveSymbols;
                    chkLookAhead.checked = settings.lookAhead;
                    chkIgnoreBrackettedChords.checked = settings.ignoreBrackettedChords;
                }
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Reset to default values"

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
                    settings.alteredColor = alteredColorChosser.color;
                    // settings.errorColor = errorColorChosser.color;

                    settings.colorNotes = get(lstColorNote);
                    settings.nameNotes = get(lstNameNote);
                    settings.textType = get(lstFormText);

                    settings.useBelowSymbols = chkUseBelowSymbols.checked;
                    settings.useAboveSymbols = chkUseAboveSymbols.checked;
                    settings.lookAhead = chkLookAhead.checked;
                    settings.ignoreBrackettedChords = chkIgnoreBrackettedChords.checked;

                    // save values
                    // AUTOMATIC

                    // execute
                    Core.doAnalyse();
                    //Qt.quit();
                    mainWindow.parent.Window.window.close();
                  
                }

                onClicked: {
                    console.log("~~~~~~~~~~~~" + button.text + "~~~~~~~~~~~~");
                    if (button == btnClear) {
                        Core.clearAnalyse();
                        //Qt.quit();
                        mainWindow.parent.Window.window.close();
                    }
                }
                onRejected: {
                  //Qt.quit()
                  mainWindow.parent.Window.window.close();
                  }

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
            mainWindow.parent.Window.window.close(); //Qt.quit()
        }
    }

}