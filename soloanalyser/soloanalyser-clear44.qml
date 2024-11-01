import QtQuick 2.9
import MuseScore 3.0
// import Qt.labs.settings 1.0
import "selectionhelper.js" as SelHelper
import "notehelper.js" as NoteHelper
import "chordanalyser.js" as ChordHelper
import "core.js" as Core

/**********************
/* Parking B - MuseScore - Solo Analyser plugin	- MuseScore 4.4 version
/* ChangeLog:
/* 	- 1.0.0: Initial release (extract from SoloAnalyser-Interactive)
/* 	- 1.0.1: Qt.quit issue
/* 	- 1.0.2: Port to MuseScore 4.0
/* 	- 1.0.2: New plugin folder strucutre
/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.0.2"

    readonly property var pluginName: "Clear"

    id: mainWindow

    //4.4 title: "Solo Analyser-Clear"
    //4.4 thumbnailName: "logoSoloAnalyserClear.png"
    //4.4 categoryCode: "color-notes"
    

    Component.onCompleted : {
        if (mscoreMajorVersion >= 4 && mscoreMajorVersion<=3) {
            mainWindow.title = "Solo Analyser "+pluginName;
            mainWindow.thumbnailName = "logoSoloAnalyserClear.png";
            mainWindow.categoryCode = "color-notes";
        }
    }    

    onRun: {
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

}