
/**********************
/* Parking B - MuseScore - Solo Analyser core plugin
/* v1.0.0
/* ChangeLog:
/* 	- 1.0.0: Initial release
/**********************************************/

var degrees = '1;2;3;4;5;6;7;8;9;11;13';


var defColorNotes = "chord"; // "none"/"chord"/"all"
var defNameNotes = "chord"; // "none"/"chord"/"all"


// var colorNotes = defColorNotes; // "none"/"chord"/"all"
// var nameNotes = defNameNotes; // "none"/"chord"/"all"

var defRootColor = "#03A60E"; //"darkblue";
var defBassColor = "#aa00ff";
var defErrorColor ="red";
var defScaleColor = "sandybrown"; //"green"; //slategray dodgerblue
var defChordColor = "dodgerblue";

// var rootColor = defRootColor;
// var bassColor = defBassColor;
// var errorColor = defErrorColor;
// var scaleColor = defScaleColor
// var chordColor = defChordColor;

function analyse() {

	// Config
var colorNotes = settings.colorNotes; // "none"/"chord"/"all"
var nameNotes = settings.nameNotes; // "none"/"chord"/"all"
var rootColor = settings.rootColor;
var bassColor = settings.bassColor;
var errorColor = settings.errorColor;
var scaleColor = settings.scaleColor
var chordColor = settings.chordColor;
	
	
	// Selection
    var score = curScore;
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

    // Analyse
	curScore.startCmd();
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
                var p = (note.pitch - curChord.pitch +12) % 12;
                var color = null;
                if (p == 0) {
                    color = rootColor;
                    degree = "1";
                } else {
                    var role = curChord.getChordNote(p);

                    if (role !== undefined) {
                        console.log("ROLE FOUND : " + role.note + "-" + role.role);
                  
				  color = (curChord.bass!=null && p==curChord.bass.key)?bassColor:chordColor;
                        degree = role.role;
                    } else if (curChord.outside.indexOf(p) >= 0) {
                        color = errorColor;
                    } else if (curChord.keys.indexOf(p) >= 0 && (colorNotes==="all")) {
                        color = scaleColor;
                    } else {
                        color = "black";
                    }

                    // Option de donner un nom à toutes les notes
                    if (nameNotes==="all" && degree === null) {
                        var role = curChord.getScaleNote(p);

                        if (role !== undefined) {
                            console.log("ROLE FOUND in SCALE: " + role.note + "-" + role.role);
                            degree = role.role;
                        }
                    }
                    console.log(note.pitch + "/" + curChord.pitch + " ==> " + p + " ==> " + color);
                }
            } else
                // no current chord, so resetting the color
            {
                color = "black";
            }

			console.log("colorNotes : "+colorNotes+", color: "+color);
			console.log("nameNotes : "+nameNotes+", text: "+degree);

            note.color = ((colorNotes!=="none") && (color!=null))?color:"black";
            writeDegree(note, (nameNotes!=="none")?degree:null);

        }

    }

	curScore.endCmd();

}
function writeDegree(note, degree) {

    var eltext = null;

    if (note.type != Element.NOTE) {
        return;
    } else {
        var el = note.elements;
        //debugP(level_DEBUG,"getFingering", note,"type");
        for (var j = 0; j < el.length; j++) {
            var e = el[j];
            if (e.type == Element.FINGERING) {
                // if (degrees.indexOf(e.text) >= 0) {
                if (e.text.match(/^((b|#)?[0-9]{1,2})?$/gm) != null);
                eltext = e;
                break;
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