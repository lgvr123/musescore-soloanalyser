
/**********************
/* Parking B - MuseScore - Solo Analyser core plugin
/* v1.1.0
/* ChangeLog:
/* 	- 1.0.0: Initial release
/* 	- 1.1.0: New alteredColor
/**********************************************/

var degrees = '1;2;3;4;5;6;7;8;9;11;13';

var degreefinder=/^((M|m|b|#)?[0-9]{1,2})?$/gm;

var defColorNotes = "chord"; // none|chord|all
var defNameNotes = "chord"; // none|chord|all

var defRootColor = "#03A60E"; //"darkblue";
var defBassColor = "#aa00ff";
var defAlteredColor = "#da00da";
var defErrorColor = "red";
var defScaleColor = "sandybrown"; //"green"; //slategray dodgerblue
var defChordColor = "dodgerblue";

var defTextType = "fingering"; // fingering|lyrics

function doAnalyse() {

    // Config
    var colorNotes = settings.colorNotes; // none|chord|all
    var nameNotes = settings.nameNotes; // none|chord|all
    var rootColor = settings.rootColor;
    var bassColor = settings.bassColor;
    var errorColor = settings.errorColor;
    var scaleColor = settings.scaleColor
    var chordColor = settings.chordColor;
    var alteredColor = (settings.alteredColor) ? settings.alteredColor : defAlteredColor
    var textType = (settings.textType) ? settings.textType : defTextType

    // if configured for doing nothing (no colours, no names) we use the default values
    if (colorNotes == "none" && nameNotes == "none") {
        colorNotes = defColorNotes;
        nameNotes = defNameNotes;
    }

    // Selection
    var chords = getSelection();
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
        var asLyrics = [];
        for (var j = 0; j < notes.length; j++) {
            var note = notes[j];
            var color = null;
            var degree = null;

            // color based on role in chord
            if (curChord != null) {
                var p = (note.pitch - curChord.pitch + 12) % 12;
                var color = null;
                if (p == 0) {
                    color = rootColor;
                    degree = "1";
                } else {
                    var role = curChord.getChordNote(p);

                    if (role !== undefined) {
                        console.log("ROLE FOUND : " + role.note + "-" + role.role);

                        degree = role.role;
                        color = (curChord.bass != null && p == curChord.bass.key) ? bassColor : ((degree.indexOf("b")==0) || (degree.indexOf("#")==0))?alteredColor:chordColor;
                    } else if (curChord.outside.indexOf(p) >= 0) {
                        color = errorColor;
                    } else if (curChord.keys.indexOf(p) >= 0 && (colorNotes === "all")) {
                        color = scaleColor;
                    } else {
                        color = "black";
                    }

                    // Option de donner un nom à toutes les notes
                    if (nameNotes === "all" && degree === null) {
                        var role = curChord.getScaleNote(p);

                        if (role !== undefined) {
                            console.log("ROLE FOUND in SCALE: " + role.note + "-" + role.role);
                            degree = role.role;
                        }
                    }
                    console.log(note.pitch + "|" + curChord.pitch + " ==> " + p + " ==> " + color);
                }
            } else
                // no current chord, so resetting the color
            {
                color = "black";
            }

            console.log("colorNotes : " + colorNotes + ", color: " + color);
            console.log("nameNotes : " + nameNotes + ", text: " + degree);

            note.color = ((colorNotes !== "none") && (color != null)) ? color : "black";
            if (textType == "fingering") {
                writeDegree(note, (nameNotes !== "none") ? degree : null);
            } else {
				// clear Fingering on that note
                writeDegree(note, null);
				// Memorize degree as lyrics
                asLyrics.push((nameNotes !== "none") ? degree : null)
            }

        }

        // Je le fais toujours comme ça on clean, d'anciennes valeurs
        writeDegreeAsLyrics(el, asLyrics);

    }

    curScore.endCmd();

}
function clearAnalyse() {

    // Selection
    var chords = getSelection();
    if (!chords || (chords.length == 0))
        return;

    // Analyse
    curScore.startCmd();
    var prevSeg = null;
    var curChord = null;
    for (var i = 0; i < chords.length; i++) {
        var el = chords[i];
        // Looping in the chord notes
        if (el.type === Element.REST)
            continue;
        writeDegreeAsLyrics(el, null);
        var notes = el.notes;
        for (var j = 0; j < notes.length; j++) {
            var note = notes[j];
            note.color = "black";
            writeDegree(note, null);
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
                if (e.text.match(degreefinder) != null);
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
function writeDegreeAsLyrics(chord, degrees) {

    if (chord.type != Element.CHORD) {
        return;
    }
    var lyrics = chord.lyrics;
	var lastVerse=-1;
    //debugP(level_DEBUG,"getFingering", note,"type");
    for (var j = 0; j < lyrics.length; ) {
        var lyric = lyrics[j];
		console.log("found lyric: "+lyric.text+" (at verse "+lyric.verse+")");
        if (lyric.text.match(degreefinder) != null) {
            chord.remove(lyric);
			console.log("==> remove");
        } else {
		if (lyric.verse>lastVerse) lastVerse=lyric.verse;
			console.log("==> keep (last verse is now "+lastVerse+")");
			j++;
		}
    }


    if (Array.isArray(degrees)) {
        for (var d = (degrees.length-1); d >=0 ; d--) {
            var degree = degrees[d];
            if (degree != null) {
                var lyric = newElement(Element.LYRICS);
                lyric.text = degree;
                // // Turn on note relative placement
                lyric.autoplace = true;
				lyric.verse = ++lastVerse;
                chord.add(lyric);
            }
        }
    }
}

function getSelection() {
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
        return null;

    return chords;

}