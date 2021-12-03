import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.2
import "zparkingb/selectionhelper.js" as SelHelper
import "zparkingb/notehelper.js" as NoteHelper
import "zparkingb/chordanalyser.js" as ChordHelper

/**********************
/* Parking B - MuseScore - Solo Analyser² plugin
/* v1.0.1
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: Using of ChordAnalyzer shared library
/**********************************************/

MuseScore {
    menuPath: "Plugins." + pluginName
    description: "Colors the notes part of each measure harmony."
    version: "1.0.2"

    readonly property var pluginName: "Solo Analyser"

    readonly property var selHelperVersion: "1.2.0"
    readonly property var noteHelperVersion: "1.0.3"
    readonly property var chordHelperVersion: "1.0"

    onRun: {

        if ((typeof(SelHelper.checktVersion) !== 'function') || !SelHelper.checktVersion(selHelperVersion) ||
            (typeof(NoteHelper.checktVersion) !== 'function') || !NoteHelper.checktVersion(noteHelperVersion) ||
            (typeof(ChordHelper.checkVersion) !== 'function') || !ChordHelper.checkVersion(chordHelperVersion)) {
            console.log("Invalid zparkingb/selectionhelper.js, zparkingb/notehelper.js or zparkingb/chordanalyser.js versions. Expecting "
                 + selHelperVersion + " and " + noteHelperVersion + " and " + chordHelperVersion + ".");
            invalidLibraryDialog.open();
            return;
        }

        var score = curScore;
        //var cursor = score.newCursor();

        var chords = SelHelper.getChordsRestsFromCursor();

        if (chords && (chords.length > 0)) {
            console.log("CHORDS FOUND FROM CURSOR");
        } else {
            chords = SelHelper.getChordsRestsFromSelection();
            if (chords && (chords.length > 0)) {
                console.log("CHORDS FOUND FROM SELECTION");
            } else {
                chords = SelHelper.getChordsRestsFromScore();
                console.log("CHORDS FOUND FROM ENTIRE SCORE");
            }
        }

        if (!chords || (chords.length == 0))
            return;

        // Notes and Rests
        var prevSeg = null;
        var curChord = null;
        for (var i = 0; i < chords.length; i++) {
            var el = chords[i];
            var seg = el.parent;
            //console.log(i + ")" + el.userName() + " / " + seg.segmentType);

            // Looking for new Chord symbol
            if (!prevSeg || (seg !== prevSeg)) {
                // nouveau segment, on y cherche un accord
                prevSeg = seg;

                var annotations = seg.annotations;
                //console.log(annotations.length + " annotations");
                if (annotations && (annotations.length > 0)) {
                    for (var j = 0; j < annotations.length; j++) {
                        var ann = annotations[j];
                        //console.log("  (" + i + ") " + ann.userName() + " / " + ann.text + " / " + ann.harmonyType);
                        if (ann.type === Element.HARMONY) {
                            // keeping 1st Chord
                            var c = ChordHelper.chordFromText(ann.text);
                            if (c != null) {
                                curChord = c;
                                break;
                            }
                        }
                    }
                }
            }

            console.log("Using chord : > " + curChord + " < ");

            // Looping in the chord notes
            if (el.type === Element.REST)
                continue;
            var notes = el.notes;
            for (var j = 0; j < notes.length; j++) {
                var note = notes[j];
                var color = null;
                var degree = null;

                // color based on role in chord
                if (curChord != null) {
                    var p = (note.pitch - curChord.pitch) % 12;
                    if (p < 0)
                        p += 12;
                    var color = null;
                    if (p == 0) {
                        color = "darkblue"; //"crimson";
                        degree = "1";
                    } else if ((curChord.n3 != null) && (p == curChord.n3)) {
                        color = "slateblue"; //"magenta";
                        degree = "3";
                    } else if ((curChord.n5 != null) && (p == curChord.n5)) {
                        color = "blue"; //tomato
                        degree = "5";
                    } else if ((curChord.n7 != null) && (p == curChord.n7)) {
                        color = "teal"; //"purple";
                        degree = "7";
                    } else if (curChord.keys.indexOf(p) >= 0) {
                        color = "purple"; //"green"; //slategray dodgerblue
                    } else if (curChord.outside.indexOf(p) >= 0) {
                        color = "red";
                    } else {
                        color = "black";
                    }
                    console.log(note.pitch + "/" + curChord.pitch + " ==> " + p + " ==> " + color);
                } else
                    // no current chord, so resetting the color
                {
                    color = "black";
                }

                note.color = color;
                writeDegree(note, degree);

            }

        }

    }

    function writeDegree(note, degree) {

        const degrees = '1;2;3;4;5;6;7;8;9;11;13';

        var eltext = null;

        if (note.type != Element.NOTE) {
            return;
        } else {
            var el = note.elements;
            //debugP(level_DEBUG,"getFingering", note,"type");
            for (var j = 0; j < el.length; j++) {
                var e = el[j];
                if (e.type == Element.FINGERING) {
                    if (degrees.indexOf(e.text) >= 0) {
                        eltext = e;
                        break;
                    }
                }
            }
        }

        if (degree != null) {
            if (eltext != null) {
                eltext.text = degree;
            } else {
                var f = newElement(Element.FINGERING);
                f.text = degree;
                // Turn on note relative placement
                f.autoplace = true;
                note.add(f);
            }
        } else {
            if (eltext != null) {
                note.remove(eltext);
            }
        }

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