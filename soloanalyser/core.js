
/**********************
/* Parking B - MuseScore - Solo Analyser core plugin
/* v1.2.6
/* ChangeLog:
/* 	- 1.0.0: Initial release
/* 	- 1.1.0: New alteredColor
/* 	- 1.2.0: Multi track
/* 	- 1.2.0: Don't modify the note color on "Color none"
/* 	- 1.2.0: Transposing instruments
/* 	- 1.2.1: Bug with some transposing instruments
/*  - 1.2.2: Don't analyse the right selection if the selection is further than a certain point in the score 
/*  - 1.2.2: Bug when first note is far beyond the first chord symbol
/*  - 1.2.2: LookAhead option
/*  - 1.2.3: Limit to standard Harmony types
/*  - 1.2.3: Don't analyze slash notes
/*  - 1.2.3: Reject invalid chord names or "%" chord names
/*  - 1.2.4: Option to reject chord within brackets
/*  - 1.2.5: Don't analyse drum staves
/*  - 1.2.6: New option for not using chords preceeding the selection
/*  - 1.2.7: new "unknown symbol" "✗"
/**********************************************/

var degrees = '1;2;3;4;5;6;7;8;9;11;13';

var degreefinder = /^(((M|m|b|#)?[0-9]{1,2})|✗)?$/gm;

var defColorNotes = "chord"; // none|chord|all
var defNameNotes = "chord"; // none|chord|all

var defRootColor = "#03A60E"; //"darkblue";
var defBassColor = "#aa00ff";
var defAlteredColor = "#da00da";
var defErrorColor = "red";
var defScaleColor = "sandybrown"; //"green"; //slategray dodgerblue
var defChordColor = "dodgerblue";

var defUseAboveSymbols = true;
var defUseBelowSymbols = true;
var defLookAhead = true;
var defLookBack = false;
var defIgnoreBrackettedChords = true;



var defTextType = "fingering"; // fingering|lyrics

function doAnalyse() {

    // Config
    var colorNotes = settings.colorNotes; // none|chord|all
    var nameNotes = settings.nameNotes; // none|chord|all
    var rootColor = settings.rootColor;
    var bassColor = settings.bassColor;
    var errorColor = settings.errorColor;
    var scaleColor = settings.scaleColor;
    var chordColor = settings.chordColor;
    var alteredColor = (settings.alteredColor) ? settings.alteredColor : defAlteredColor
    var textType = (settings.textType) ? settings.textType : defTextType
    var useAboveSymbols = (settings.useAboveSymbols!==undefined) ? settings.useAboveSymbols : true
    var useBelowSymbols = (settings.useBelowSymbols!==undefined) ? settings.useBelowSymbols : true
    var lookAhead = (settings.lookAhead!==undefined) ? settings.lookAhead : true
    var lookBack = (settings.lookBack!==undefined) ? settings.lookBack : true
    var ignoreBrackettedChords = (settings.ignoreBrackettedChords!==undefined) ? settings.ignoreBrackettedChords : true

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
    var segMin = 999999999;
    var segMax = 0;
    var trackMin = 999;
    var trackMax = 0;

    for (var i = 0; i < chords.length; i++) {
        var c = chords[i];
        segMin = Math.min(segMin, c.parent.tick);
        segMax = Math.max(segMax, c.parent.tick);
        trackMin = Math.min(trackMin, c.track);
        trackMax = Math.max(trackMax, c.track);
    }

    var byTrack = new Array(trackMax + 1); ;

    var cursor = curScore.newCursor();
    if(lookBack) {
        // retrieving the chord from the beginning, so that if do the analyse in the middlle of a chord, we know that chord.
        cursor.rewindToTick(0); 
    } else {
        // limit strictly the analyse at the selection
        cursor.rewindToTick(segMin);
    }
    var segment = cursor.segment;
	var count=0;
    while (segment && ((segment.tick<=segMax) || (lookAhead && count===0))) {

        var annotations = segment.annotations;
        console.log(segment.tick+": "+annotations.length + " annotations");
        if (annotations && (annotations.length > 0)) {
            for (var j = 0; j < annotations.length; j++) {
                var ann = annotations[j];
                //console.log("  (" + i + ") " + ann.userName() + " / " + ann.text + " / " + ann.harmonyType);
                if (ann.type !== Element.HARMONY || ann.harmonyType!== HarmonyType.STANDARD ) // Not using the Roman and Nashvill Harmony types 
                    continue;

				if (ignoreBrackettedChords && (ann.text.search(/^\(.+\)$/g)!==-1)) {
					console.log(segment.tick+": rejecting chord name with parentheses: "+ann.text);
					continue;
				}


                if (/*(ann.track < trackMin) ||*/(ann.track > trackMax)) // j'analyse aussi ce qui a en amont
                    continue;
					
				count++;

                if (byTrack[ann.track] === undefined)
                    byTrack[ann.track] = [];

				var chord = ChordHelper.chordFromText(ann.text);
				if (chord !== null) {
				console.log(segment.tick+": adding "+ann.text+" to track "+ann.track);
				    // If the chord is correctly analyzed, add it (to avoid invalid chord names, or "%" chord names)
				    byTrack[ann.track].push({
				        tick: segment.tick,
				        chord: chord
				    });
				} else {
					console.log(segment.tick+": rejecting invalid chord name: "+ann.text);
				}
            }
        }


        segment = segment.next;
    }

    // consolidation de haut en bas
	if (useAboveSymbols) {
	    for (var track = 1; track <= trackMax; track++) { // !! démarre à 1
	        if (((byTrack[track] !== undefined) ? byTrack[track].length : 0) === 0)
	            byTrack[track] = byTrack[track - 1];
	    }
	}

	// consolidation de bas en haut
	if (useBelowSymbols) {
	    for (var track = trackMax - 1; track >= 0; track--) { // !! démarre à 1
	        if (((byTrack[track] !== undefined) ? byTrack[track].length : 0) === 0)
	            byTrack[track] = byTrack[track + 1];
	    }
	}
	// check
    for (var track = 0; track <= trackMax; track++) {
        console.log(track + ": " + ((byTrack[track] !== undefined) ? byTrack[track].length : 0));
        if (byTrack[track] !== undefined) {
            for (var x = 0; x < byTrack[track].length; x++) {
				var name=(byTrack[track][x].chord!==null)?byTrack[track][x].chord.name:"~undefined chord~";
                console.log("   " + byTrack[track][x].tick + ": " + name);
            }
        }
    }

    // Processing
    curScore.startCmd();

    // processing
    for (var track = trackMin; track <= trackMax; track++) {
		console.log("~~~~ processing track "+track+" ~~~~");
        
        // Is this track a pitched staff (opposed to a drumstaff) ?
        var isdrumset=false;
        for (var i = 0; i < curScore.parts.length; i++) {
            var part = curScore.parts[i];
            if (track>=part.startTrack && track<part.endTrack) {
                console.log("The track belongs to part " + i + ": " + part.startTrack + "/" + part.endTrack + ": " + part.hasDrumStaff + "/" + part.hasPitchedStaff);
                isdrumset=part.hasDrumStaff;
                break;
            }
        }
        if (isdrumset) {
            console.log("~ ~  bypassed because is drumset  ~ ~");
            continue;
        }
        // ok, this is not a drumStaff
        cursor.track = track;
        cursor.rewindToTick(segMin);
        var segment = cursor.segment;
        var values = (byTrack[track] !== undefined) ? byTrack[track] : [];
        var curChord = null;
		var check=null;
        var step = lookAhead?0:-1; // if we lookAhead, we start from the first chord, even if it is further that start segment.
		console.log("lookAhead = "+lookAhead+", donc on commence à l'étape "+step);
        while (segment && segment.tick<=segMax) {
            // getting the right chord diagram
			
            while ((step < (values.length - 1)) && (values[step + 1].tick <= segment.tick)) {
                step++;
				console.log("next: going to step "+step+", because current tick ("+segment.tick+") is >= next step's tick ("+values[step].tick+")"); 
                // curChord = ChordHelper.chordFromText(values[step].text);
			}
			
			if(step>=0) {
                curChord = values[step].chord;
                check = values[step].tick;
			}
            console.log(track + "/" + segment.tick + ": step = "+step + " => chord = "+((curChord === null) ? "/" : curChord.name+" ( from "+check+")"));

            // retrieving the element on this track
            var el = cursor.element;
            if ((el !== null) && (el.type === Element.CHORD)) {

                // Looping in the chord notes
                var notes = el.notes;
                var asLyrics = [];
                for (var j = 0; j < notes.length; j++) {
                    var note = notes[j];
					
					if (note.headGroup === NoteHeadGroup.HEAD_SLASH) continue; // Don't analyse slash notes
					
                    var color = null;
                    var degree = null;

                    // color based on role in chord
                    if (curChord != null) {
						// !! The chord name is depending if we are in Instrument Pitch or Concert Pitch (this is automatic in MuseScore)
						// So we have to retrieve the pitch as shown on the score. In instrument pitch this might be different than the pitch
						// given by note.pitch which is corresponding to the *concert pitch*. 
						
						// var tpitch = note.pitch - (note.tpc - note.tpc1); // note displayed as if it has that pitch
						var tpitch = note.pitch + NoteHelper.deltaTpcToPitch(note.tpc,note.tpc1); // note displayed as if it has that pitch
						
						
                        var p = (tpitch - curChord.pitch + 12) % 12;
                        var color = null;
                        if (p == 0) {
                            color = rootColor;
                            degree = "1";
                        } else {
                            var role = curChord.getChordNote(p);

                            if (role !== undefined) {
                                console.log("ROLE FOUND : " + role.note + "-" + role.role);

                                degree = role.role;
                                color = (curChord.bass != null && p == curChord.bass.key) ? bassColor : ((degree.indexOf("b") == 0) || (degree.indexOf("#") == 0)) ? alteredColor : chordColor;
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
                            console.log("note pitch: "+tpitch + ((tpitch!==note.pitch)?(" (transposing!! original: "+note.pitch+")"):"")+ " | Chord pitch:" + curChord.pitch + " ==> position: " + p + " ==> color: " + color);
                        }
                    } else
                        // no current chord, so resetting the color
                    {
                        color = "black";
                    }

                    console.log("colorNotes : " + colorNotes + ", color: " + color);
                    console.log("nameNotes : " + nameNotes + ", text: " + degree);


                    if (colorNotes !== "none") {
						note.color = (color != null) ? color : "black";
					}
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

            // next
            cursor.next();
            segment = cursor.segment;
        }

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
    var lastVerse = -1;
    //debugP(level_DEBUG,"getFingering", note,"type");
    for (var j = 0; j < lyrics.length; ) {
        var lyric = lyrics[j];
        console.log("found lyric: " + lyric.text + " (at verse " + lyric.verse + ")");
        if (lyric.text.match(degreefinder) != null) {
            chord.remove(lyric);
            console.log("==> remove");
        } else {
            if (lyric.verse > lastVerse)
                lastVerse = lyric.verse;
            console.log("==> keep (last verse is now " + lastVerse + ")");
            j++;
        }
    }

    if (Array.isArray(degrees)) {
        for (var d = (degrees.length - 1); d >= 0; d--) {
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
        chords = SelHelper.getChordsRestsFromScore();
        console.log("CHORDS FOUND FROM ENTIRE SCORE");
    }

    if (!chords || (chords.length == 0))
        return null;

    return chords;

}