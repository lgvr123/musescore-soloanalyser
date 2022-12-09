import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import "selectionhelper.js" as SelHelper
import "notehelper.js" as NoteHelper
import "chordanalyser.js" as ChordHelper
import "core.js" as Core

/**********************
/* Parking B - MuseScore - Solo Analyser plugin
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: Using of ChordAnalyzer shared library
/*  - 1.1.0: New coloring approach
/*  - 1.2.0: Colors and names (optionnaly) all the notes
/*  - 1.2.1: Uses the bass note if specified in the chord
/*  - 1.2.1: Minor improvments on the chord recognission
/*  - 1.3.0: Code moved to a library
/*  - 1.3.1: New altered notes color
/*  - 1.4.0: Multi track and voices
/*  - 1.4.0: Settings for the multi track and voices
/*  - 1.4.1: Bug with some transposing instruments + bug when initiating useBelow/AboveSymbols 
/*  - 1.4.2: Don't analyse the right selection if the selection is further than a certain point in the score 
/*  - 1.4.2: Bug when first note is far beyond the first chord symbol
/*  - 1.4.2: LookAhead option
/*  - 1.4.3: (see Core.js log 1.2.3)
/*  - 1.4.4: IgnoreBrackettedChords option
/* 	- 1.4.4: Qt.quit issue
/*  - 1.4.5: Don't analyse drum staves
/* 	- 1.4.6: Port to MuseScore 4.0
/* 	- 1.4.6: New plugin folder strucutre
/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.4.6"

    readonly property var pluginName: "Analyse"
    id: mainWindow
    
    Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            mainWindow.title = "Solo Analyser "+pluginName;
            mainWindow.thumbnailName = "logoSoloAnalyser.png";
            mainWindow.categoryCode = "color-notes";
        }
    }    

    onRun: {

        Core.doAnalyse();

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
		property var ignoreBrackettedChords : Core.defIgnoreBrackettedChords
    }

}