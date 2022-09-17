import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import "zparkingb/selectionhelper.js" as SelHelper
import "zparkingb/notehelper.js" as NoteHelper
import "zparkingb/chordanalyser.js" as ChordHelper
import "soloanalyser/core.js" as Core

/**********************
/* Parking B - MuseScore - Solo Analyser plugin
/* v1.0.1
/* ChangeLog:
/* 	- 1.0.0: Initial release (extract from SoloAnalyser-Interactive)
/* 	- 1.0.1: Qt.quit issue

/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.0.1"

    readonly property var pluginName: "Clear"

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


        Core.clearAnalyse();

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
		property var textType : Core.defTextType
		property var useBelowSymbols : Core.defUseBelowSymbols
		property var useAboveSymbols : Core.defUseAboveSymbols
		property var lookAhead : Core.defLookAhead
    }

    MessageDialog {
        id: invalidLibraryDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
        title: 'Invalid libraries'
        text: "Invalid zparkingb/selectionhelper.js, zparkingb/notehelper.js or zparkingb/chordanalyser.js versions.\nExpecting "
         + selHelperVersion + " and " + noteHelperVersion + " and " + chordHelperVersion + ".\n" + pluginName + " will stop here."
        onAccepted: {
            //Qt.quit()
        }
    }

}