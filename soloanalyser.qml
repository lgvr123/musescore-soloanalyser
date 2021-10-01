import QtQuick 2.0
import MuseScore 3.0
import QtQuick.Dialogs 1.2
import "zparkingb/selectionhelper.js" as SelHelper
import "zparkingb/notehelper.js" as NoteHelper

MuseScore {
    menuPath: "Plugins.Solo Analayzer"
    description: "Colors the notes part of each measure harmony."
    version: "1.0"

    readonly property var selHelperVersion: "1.2.0"
    readonly property var noteHelperVersion: "1.0.3"

    onRun: {

        if ((typeof(SelHelper.checktVersion) !== 'function') || !SelHelper.checktVersion(selHelperVersion) ||
            (typeof(NoteHelper.checktVersion) !== 'function') || !NoteHelper.checktVersion(noteHelperVersion)) {
            console.log("Invalid zparkingb/selectionhelper.js and zparkingb/notehelper.js versions. Expecting "
                 + selHelperVersion + " and " + noteHelperVersion + ".");
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
                            var c = chordFromText(ann.text);
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

    function chordFromText(text) {

        if (text.slice(0, 1) === "(")
            text = text.substr(1);

        // Root
        var root = text.slice(0, 1).toUpperCase();
        var alt = text.slice(1, 2);
        if ("bb" === text.slice(1, 3)) {
            alt = 'FLAT2';
            text = text.substr(3);
        } else if ("x" === alt) {
            alt = 'SHARP2';
            text = text.substr(2);
        } else if ("b" === alt) {
            alt = 'FLAT';
            text = text.substr(2);
        } else if ("#" === alt) {
            alt = 'SHARP';
            text = text.substr(2);
        } else {
            alt = 'NONE';
            text = text.substr(1);
        }

        var ftpcs = NoteHelper.tpcs.filter(function (e) {
            return ((e.raw === root) && (e.accidental === alt));
        });

        var tpc;
        if (ftpcs.length > 0) {
            tpc = ftpcs[0];
        } else {
            console.log("!! Could not found >>" + root + "-" + alt + "<<");
            return null;
        }

        // Chord type
        var n3 = null,
        n5 = null,
        n7 = null;
        var keys = [0];

        text = new chordTextClass(text);

        // Base
        // M, Ma, Maj, ma, maj
        if (text.startsWith("Maj") || text.startsWith("Ma") || text.startsWith("M") || text.startsWith("maj") || text.startsWith("ma")) {
            n3 = 4;
            n5 = 7;
        }
        // m, mi, min, -
        else if (text.startsWith("min") || text.startsWith("mi") || text.startsWith("m") || text.startsWith("-")) {
            n3 = 3;
            n5 = 7;
        }

        // dim,o
        else if (text.startsWith("dim") || text.startsWith("o")) {
            n3 = 3;
            n5 = 4;
            n7 = 9;
        }

        // Half-dim
        else if (text.startsWith("0")) {
            n3 = 3;
            n5 = 4;
            n7 = 10;
        }

        // Aug
        else if (text.startsWith("aug") || text.startsWith("+")) {
            n3 = 3;
            n5 = 6;
        }

        // Maj7
        else if (text.startsWith("t7")) {
            n3 = 3;
            n5 = 7;
            n7 = 11;
        }

        // sus2
        else if (text.startsWith("sus2")) {
            n3 = 2;
            n5 = 7;
        }

        // sus4
        else if (text.startsWith("sus4")) {
            n3 = 5;
            n5 = 7;
        }

        // No indication => Major
        else {
            n3 = 4;
            n5 = 7;
        }

        // Compléments
        if (text.includes("7")) {
            n7 = 10;
        }

        if (text.includes("b5")) {
            n5 = 6;
        } else if (text.includes("b5")) {
            n5 = 6;
        }

        if (text.includes("b9")) {
            keys.push(1)
        } else if (text.includes("#9")) {
            keys.push(3)
        } else if (text.includes("9")) {
            keys.push(2)
        }

        if (text.includes("b11")) {
            keys.push(4)
        } else if (text.includes("#11")) {
            keys.push(6)
        } else if (text.includes("11")) {
            keys.push(5)
        }

        if (text.includes("b13")) {
            keys.push(8)
        } else if (text.includes("#13")) {
            keys.push(10)
        } else if (text.includes("13")) {
            keys.push(9)
        }

        console.log("After analysis : >>" + text + "<<");

        if (n3 != null)
            keys.push(n3);
        if (n5 != null)
            keys.push(n5);
        if (n7 != null)
            keys.push(n7);

        var chord = new chordClass(tpc, text, n3, n5, n7, keys);

        return chord;
    }

    function chordTextClass(str) {
        var s = str;
        this.replace = function (r1, r2) {
            s = s.replace(r1, r2);
        }
        this.toString = function () {
            return s;
        }

        this.startsWith = function (test) {
            if (s.startsWith(test)) {
                s = s.substr(test.length);
                return true;
            } else {
                return false;
            }
        }

        this.includes = function (test) {
            var pos = s.indexOf(test);

            if (pos >= 0) {
                s = s.substr(0, pos) + s.substr(pos + test.length);
                return true;
            } else {
                return false;
            }
        }
    }

    function chordClass(tpc, name, n3, n5, n7, keys) {
        this.pitch = tpc.pitch;
        this.name = name;
        this.root = tpc.raw;
        this.accidental = tpc.accidental;
        this.n3 = n3;
        this.n5 = n5;
        this.n7 = n7;
        this.keys = (!keys || (keys == null)) ? [] : keys;

        this.toString = function () {
            return this.root + " " + this.accidental + " " + this.name + " " + keys.toString(); ;
        };

    }

    MessageDialog {
        id: invalidLibraryDialog
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
        title: 'Invalid libraries'
        text: "Invalid 'zparkingb/selectionhelper.js' and 'zparkingb/notehelper.js' versions.\nExpecting "
         + selHelperVersion + " and " + noteHelperVersion + ".\nSolo Analyser will stop here."
        onAccepted: {
            Qt.quit()
        }
    }

}
