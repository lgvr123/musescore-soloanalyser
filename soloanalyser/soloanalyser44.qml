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
/* 	- 1.4.8: New option for not using chords preceeding the selection
/*  - 1.4.8: (see Core.js log 1.2.8)
/*  - 1.4.8: (see ChordAnalyser.js log 1.2.22)
/*  - 1.4.9: (see ChordAnalyser.js log 1.2.23+24)
/*  - 1.4.10: Bug: Wrong usage the lookAhead stored setting
/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if chords/harmonies."
    version: "1.4.10"

    readonly property var pluginName: "Analyse"
    id: mainWindow
    
    //4.4 title: "Solo Analyser-Analyse"
    //4.4 thumbnailName: "logoSoloAnalyser.png"
    //4.4 categoryCode: "color-notes"
    
    Component.onCompleted : {
        if (mscoreMajorVersion >= 4 && mscoreMajorVersion<=3) {
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
        property var rootColor
        property var bassColor
        property var chordColor
        property var scaleColor
        property var errorColor
        property var alteredColor
        property var colorNotes
        property var nameNotes
		property var textType
		property var useBelowSymbols
		property var useAboveSymbols
		property var lookAhead
		property var lookBack
		property var ignoreBrackettedChords
    }

}