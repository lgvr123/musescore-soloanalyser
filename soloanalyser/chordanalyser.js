/**********************
/* Parking B - MuseScore - Chord analyser
/* v1.2.25
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: The 7th degree was sometime erased
/*  - 1.2.0: Exporting now the chord notes instead of n3/n5/n7 erased
/*  - 1.2.1: Ajout de "^7" comme équivalent à "t7"
/*  - 1.2.2: Ajout des 7th dans les accords 9
/*  - 1.2.3: Ajout des maj7
/*  - 1.2.4: Exporting all scale roles
/*  - 1.2.5: Ajout des maj7 (2)
/*  - 1.2.6: Bug dans Workoutbuilder avec 1.2.4 (Accords 9, 11 et 13)
/*  - 1.2.7: Ajout de la gestion de la basse
/*  - 1.2.7: Correction sur les accords majeurs non 7 (ex "C")
/*  - 1.2.8: Export de la position relative de la basse
/*  - 1.2.9: Better name for altered 5
/*  - 1.2.10(1.3.0): Better handling of Aug, Sus2, Sus4
/*  - 1.2.11(1.3.1): Better handling of (b5) chords
/*  - 1.2.12(1.3.2): Better handling of some Maj7 chords
/* 	- 1.2.13(1.3.3): key was doubled in case of bass
/*  - 1.2.14: Better handling of Aug, Sus2, Sus4
/*  - 1.2.15: Invalid definition of Aug
/*  - 1.2.16: Invalid definition of Aug
/*  - 1.2.17: Invalid definition of Dim7
/*  - 1.2.18: 7 as bass was labelled #13
/*  - 1.2.19: Syntax corrections for Netbeans
/*  - 1.2.20: Case-insensitive search for "Aug", "Sus2", ...
/*  - 1.2.21: Accords "Alt"
/*  - 1.2.22: b5 and #5 chords wrongly analysed
/*  - 1.2.23: Ajout des 7th, 9th, 11th dans les accords 11th et 13th
/*  - 1.2.23: Ajout des accords 10th
/*  - 1.2.24: bug: mauvaise reconnaissance des accords ##
/*  - 1.2.25: CR: Allow for both b9 and #9 together (same for 11 and 13)
/*  - 1.3.0: CR: Support for Tone sets
/**********************************************/
// -----------------------------------------------------------------------
// --- Vesionning-----------------------------------------
// -----------------------------------------------------------------------
var default_names = ["1", "b9", "2", "#9", "b11", "4", "#11", "(5)", "m6", "M6", "m7", "M7"];

function checkVersion(expected) {
    var version = "1.3.00";

    var aV = version.split('.').map(function (v) {
        return parseInt(v);
    });
    var aE = (expected && (expected !== null)) ? expected.split('.').map(function (v) {
        return parseInt(v);
    }) : [99];
    if (aE.length === 0)
        aE = [99];

    for (var i = 0; (i < aV.length) && (i < aE.length); i++) {
        if (!(aV[i] >= aE[i]))
            return false;
    }

    return true;
}

function chordFromText(source) {

    var pitchSet=source.match(/^(T[0-9]{1,2}|[A-G][#b]{0,2})?\[(([0-9te]+[,]*)+)\]$/);
    if (pitchSet!=null) return chordForPitchSet(pitchSet[1]?pitchSet[1]:"T0",pitchSet[2]);

    //var text = source.replace(/(\(|\))/g, '');
    var text = source.replace(/(^\s*\(\s*|\s*\)\s*$)/g, ''); // on vire les "(" et ")" de début et fin
    var name = text;

    console.log("chordFromText: source: "+source);
    console.log("chordFromText: cleaned: "+text);

    var rootbass = text.split("/");
    text = rootbass[0];
    var bass = (rootbass.length > 1) ? rootbass[1] : null;

    console.log("chordFromText: /w bass : "+text);
    console.log("chordFromText: bass : "+text);


    // Root
    var rootacc = getRootAccidental(text);
    text = rootacc.remaingtext;

    if (rootacc.tpc === null) {
        console.log("!! Could not found >>" + rootacc.root + "-" + rootacc.alt + "<<");
        return null;
    }

    // Chord type
    var scale=null;

    // Bass and scale
    var bassacc = null;
    if (bass !== null) {
        bassacc = getRootAccidental(bass);
        if (bassacc.tpc !== null) {
            var relpitch = (bassacc.tpc.pitch - rootacc.tpc.pitch + 12) % 12;
            scale = scaleFromText(text, relpitch);
        }
    }
    if (scale === null)
        scale = scaleFromText(text);

    // var chord = new chordClass(tpc, text, n3, n5, n7, keys);
    var chord = new chordClass(rootacc.tpc, name, scale, (bassacc !== null) ? bassacc.tpc : null);

    console.log(">>>" + chord);

    return chord;
}

function getRootAccidental(text) {
    var root = text.slice(0, 1).toUpperCase();
    var alt = text.slice(1, 2);
    console.log("Searching root and accidental in : "+text);
    console.log("Root: "+root);
    console.log("Alteration text: "+alt);
    if ("bb" === text.slice(1, 3)) {
        alt = 'FLAT2';
        text = text.substr(3);
    } else if ("##" === text.slice(1, 3)) {
        alt = 'SHARP2';
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

    console.log("Searching for tp for root="+root+", accidental="+alt);

    var ftpcs = NoteHelper.tpcs.filter(function (e) {
        return ((e.raw === root) && (e.accidental === alt));
    });

    var tpc = null;
    if (ftpcs.length > 0) {
        tpc = ftpcs[0];
    }

    return {
        'root': root,
        'alt': alt,
        'tpc': tpc,
        'remaingtext': text
    };
}

function scaleFromText(text, bass) {

    text = text.replace(/(\(|\))/g, ''); // on vire les parenthèses


    var n2 = null,
    n3 = null,
    n4 = null,
    n5 = null,
    n6 = null,
    n7 = null,
    def2 = null,
    def3 = null,
    def4 = null,
    def6 = null,
    def7 = null,
    n5role = "5";

    var keys = [0, 12];
    var chordnotes = [{
            "note": 0,
            "role": "1"
        }, {
            "note": 12,
            "role": "1"
        }
    ];
    var allnotes = [];

    var outside = [];

    text = new chordTextClass(text.replace("add", ""));

    bass = parseInt(bass);
    if ((bass !== bass) || (bass === 0)) // testing NaN
        bass = null;

            var at = null;
    // Base
    // M, Ma, Maj, ma, maj
    if (text.startsWith("Maj7") || text.startsWith("Ma7") || text.startsWith("M7") || text.startsWith("maj7") || text.startsWith("ma7") ||
        text.startsWith("t7") || text.startsWith("t") || text.startsWith("^7")|| text.startsWith("^")) {
        console.log("Starts with Maj7, t7, ...");
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        n7 = 11;
        outside = outside.concat([1, 3, 6, 8]);
    }
    // M, Ma, Maj, ma, maj
    else if (text.startsWith("Maj") || text.startsWith("Ma") || text.startsWith("M") || text.startsWith("maj") || text.startsWith("ma")) {
        console.log("Starts with Maj/Ma/M/maj/ma");
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
        outside = outside.concat([1, 3, 6, 8]);

    }
    // m, mi, min, -
    else if (text.startsWith("min") || text.startsWith("mi") || text.startsWith("m") || text.startsWith("-")) {
        console.log("Starts with min/mi/m/-");
        n3 = 3;
        n5 = 7;
        def6 = 8; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 10; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
        outside = outside.concat([1, 4, 6]);
    }

    // dim,o
    else if (text.startsWith("dim") || text.startsWith("o")) {
        console.log("Starts with dim/o");
        // [0, 1, 3, 4, 6, 7, 9, 12]
        def2 = 1;
        def4 = 4;
        n3 = 3;
        n5 = 6;
        def7 = 9; // changed 12/3/22. Was "n7="
        def6 = 7; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        n5role = "b5";
    }

    // Half-dim
    else if (text.startsWith("0")) {
        console.log("Starts with 0");
        def2 = 1; // added 12/3/22
        def4 = 4; // added 12/3/22
        n3 = 3;
        n5 = 6;
        def7 = 10; // changed 12/3/22. Was "n7="
        def6 = 8; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        n5role = "b5";
    }

    // No indication => Major
    else {
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        //def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après. 3/9/22: pas d'interprétation ici. Fait plus loin
        //outside = outside.concat([1, 3, 6, 8]);
    }

    // Posibles additions
    // ..Aug|+|#5..
    if (text.includes("aug",true) || text.includes("+") || text.includes("#5")) {
        console.log("Contains  aug/+/b5");
        // n3 = 3; // 1.2.16: un accord augmenté n'a pas nécessairement une tierce mineure
        n5 = 8;
        n5role = "#5";
        //def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        //def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
    }

    // ..b5..
    else if (text.includes("b5",true)) {
        console.log("Contains b5");
        n5 = 6;
        n5role = "b5";
    }

    // ..sus2..
    else if (text.includes("sus2",true)) {
        console.log("Contains sus2");
        n2 = 2;
        n3 = null; // pas de tierce explicite
        def3 = 4; //pourrait être 3 ou 4
        //n5 = 7;
        //def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // ..sus4..
    else if (text.includes("sus4",true) || text.includes("sus")) {
        console.log("Contains sus4 or sus");
        n4 = 5;
        n3 = null; // pas de tierce explicite
        def3 = 4; //pourrait être 3 ou 4
        //n5 = 7;
        //def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // ..alt..
    else if (text.includes("alt",true)) {
        console.log("Contains alt or sus");
        // 1/2, 1, 1/2, 1, 1, 1
        n2 = 1; // b9
        n3 = 3; // b3 i.e. #9
        n4 = 4; // 3 i.e. b11
        n5 = 6; // b5
        n5role = "b5";
        n6 = 8; // b13
        n7 = 10; // b7
    }

    // Compléments
    // ..7..
    if (n7 === null && (text.includes("maj7",true) || text.includes("ma7",true) || text.startsWith("t7") || text.startsWith("t") || text.startsWith("^7") || text.startsWith("^"))) {
        console.log("Has M7");
        n7 = 11;
    } else 
        if (n7 === null && text.includes("7")) {
           if (def7 == null) {
                def7 = 10;
                console.log("Has m7");
           } else {
                console.log("Has specific 7");
           }
            n7 = def7;
        };

    // ..3..
    if (n3 !== null) {
        pushToKeys(keys, n3, "n3");
        pushToNotes(chordnotes, n3, "3");
    } else if (text.includes("10")) {
        pushToKeys(keys, 4, "10");
        pushToNotes(chordnotes, 4, "10");
    } else if (def3 !== null) {
        pushToKeys(keys, def3, "def3");
    }

    // ..5..
    if (n5 === null) {
        if (text.includes("b5")) {
            console.log("Has b5");
            n5 = 6;
            n5role = "b5";
        } else if (text.includes("#5")) {
            console.log("Has #5");
            n5 = 8;
            n5role = "#5";
        }
    }

    if (n5 !== null) {
        pushToKeys(keys, n5, "n5");
        pushToNotes(chordnotes, n5, n5role);
    } else if (bass === 7) {
        pushToKeys(keys, bass, "bass as 5");
        pushToNotes(chordnotes, bass, "5");
    } else {
        pushToKeys(keys, 7, "def5 (=7)");
    }

    // ..2/9..
    var n9 = null;
    if (text.includes("b9")) {
        console.log("Has b9");
        n9 = 1;
        pushToKeys(keys, n9, "b9");
        pushToNotes(chordnotes, n9, "b9");
    } 
    if (text.includes("#9")) {
        console.log("Has #9");
        n9 = 3;
        pushToKeys(keys, n9, "#9");
        pushToNotes(chordnotes, n9, "#9");
    } 
    if (text.includes("9")) {
        n9 = 2;
        pushToKeys(keys, n9, "9");
        pushToNotes(chordnotes, n9, "9");
    } 
    
    if ((n9===null) && ((at = [1, 2, 3].indexOf(bass)) >= 0) && (bass !== n2)) {
        n9 = bass;
        pushToKeys(keys, bass, "bass as 2/9");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "9(B)");
    }

    if (n2 !== null) {
        pushToKeys(keys, n2, "n2");
        pushToNotes(chordnotes, n2, "2");
    } else if (n9 === null) {
        if (def2 === null) { // 15/3: alignement sur Supercollider
            def2 = 2;
        }
        pushToKeys(keys, def2, "def2");
        if (getNote(chordnotes, def2) === undefined)
            allnotes.push({
                "note": def2,
                "role": "2"
            });
    }

    // Adding an explicit 7 if a 9 is present
    //if ((n9 !== null) && (n7 === null) && (def7 !== null)) {
        // n7 = def7;
    if ((n9 !== null) && (n7 === null)) {
        n7 = 10;
    }

    // ..4/11..
    var n11 = null;
    if (text.includes("b11")) {
        console.log("Has b11");
        n11 = 4;
        pushToKeys(keys, n11, "b11");
        pushToNotes(chordnotes, n11, "b11");
    } 
    
    if (text.includes("#11")) {
        console.log("Has #11");
        n11 = 6;
        pushToKeys(keys, n11, "#11");
        pushToNotes(chordnotes, n11, "#11");
    } 
    
    if (text.includes("11")) {
        console.log("Has 11");
        n11 = 5;
        pushToKeys(keys, n11, "11");
        pushToNotes(chordnotes, n11, "11");
    } 
    
     if ((n11===null) && ((at = [4, 5, 6].indexOf(bass)) >= 0) && (bass!==n4)){
        n11 = bass;
        pushToKeys(keys, bass, "bass as 4/11");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "11");
    }

    if (n4 !== null) {
        pushToKeys(keys, n4, "n4");
        pushToNotes(chordnotes, n4, "4");
    } else if (n11 === null) {
        if (def4 === null)
            def4 = 5;
        pushToKeys(keys, def4, "def4");
        if (getNote(chordnotes, def4) === undefined)
            pushToNotes(allnotes, def4, "4");
    }
    
    // Adding an explicit 7 and 9 if a 11 is present
    console.log("---Adding 7 in 11 chord :"+n11+"/"+n7+"/"+def7);
    if ((n11 !== null) && (n7 === null)) {
        console.log("...Ajouté");
        n7 = 10;
    }

    if ((n11 !== null) && (n9 === null)) {
        n9 = 2;
        pushToKeys(keys, n9, "9");
        pushToNotes(chordnotes, n9, "9");
    }



    // ..6/13..
    if (n6===null) {
        if (text.includes("6")) {
            console.log("Has 6");
            n6 = 9;
        }
    }
    if (n6!==null) {
        pushToKeys(keys, n6, "(n)6"); // "So in the case of min6 chords always always always make the 6th a major 6th."
        pushToNotes(chordnotes, n6, "6");
        def6 = null;
    }

    var n13 = null;
    if (text.includes("b13")) {
        console.log("Has b13");
        n13 = 8;
        pushToKeys(keys, n13, "b13");
        pushToNotes(chordnotes, n13, "b13");
    } 
    
    if (text.includes("#13")) {
        console.log("Has #13");
        n13 = 10;
        pushToKeys(keys, n13, "#13");
        pushToNotes(chordnotes, n13, "#13");
    } 
    
    if (text.includes("13")) {
        console.log("Has 13");
        n13 = 9;
        pushToKeys(keys, n13, "13");
        pushToNotes(chordnotes, n13, "13");
    } 
    
    if ((n13===null) && ((at = [8, 9, 10].indexOf(bass)) >= 0) && ([n5, n6, n7].indexOf(bass) < 0)) { // The bass is b13,13,#13 but is not already defined as the 5,6 or 7.
        n13 = bass;
        pushToKeys(keys, bass, "bass as 6/13");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "13");
    } else if (n6===null) {
        if (def6 === null)
            def6 = 9;
        pushToKeys(keys, def6, "def6");
        if (getNote(chordnotes, def6) === undefined)
            pushToNotes(allnotes, def6, "6");
    }
    
    // Adding an explicit 7, 9, 11 if a 13 is present
    if ((n13 !== null) && (n7 === null)) {
        n7 = 10;
    }

    if ((n13 !== null) && (n9 === null)) {
        n9 = 2;
        pushToKeys(keys, n9, "9");
        pushToNotes(chordnotes, n9, "9");
    }

    if ((n13 !== null) && (n11 === null)) {
        n11 = 5;
        pushToKeys(keys, n11, "(11)");
        pushToNotes(chordnotes, n11, "11");
    }

    

    //..7..
    if (n7 !== null) {
        console.log("found 7 as explicit ("+n7+")");
        pushToKeys(keys, n7, "n7");
        pushToNotes(chordnotes, n7, "7");
    } else if ((at = [10, 11].indexOf(bass)) >= 0) {
        console.log("found 7 as bass ("+bass+")");
        n7 = bass;
        pushToKeys(keys, bass, "bass as 7");
        pushToNotes(chordnotes, bass, ["m", "M"][at] + "7");
    } else {
        if (def7 === null)
            def7 = 11;
        pushToKeys(keys, def7, "def7");
        if (getNote(chordnotes, def7) === undefined)
            pushToNotes(allnotes, def7, "7");
    }

    // Looking for all notes
    allnotes = chordnotes.concat(allnotes);
    for (var n = 1; n < 12; n++) {
        if ((getNote(allnotes, n) === undefined) && (n !== bass)) {
            var at;
		    var dn = (n3 === null && (at=[3,4].indexOf(n))>=0) ? ["m3","M3"][at] : default_names[n];
            pushToNotes(allnotes, n, dn);
        } else if (n === bass) {
            pushToNotes(allnotes, n, "bass");
        }
    }

    // console.log("After analysis : >>" + text + "<<");

    var scale = new scaleClass(keys, chordnotes, allnotes);
    return scale;
}

function pushToNotes(collection, note, role) {
    var exist = getNote(collection, note);

    if (exist) {
        console.log("Not adding " + role + " (" + note + ") because it exist as " + exist.role);
        return;
    }
    console.log("....pushing note >>" + note + " as " + role + "<<");
    collection.push({
        "note": note,
        "role": role
    });
}

function pushToKeys(keys, value, comment) {
    console.log("....pushing key >>" + value + "<< (" + comment + ")");
	
	if(keys.indexOf(value)>=0) {
        console.log("Not adding " +  value + " to keys because it is already present");
        return;
	}
	
    keys.push(value);
}

function chordForPitchSet(transposition,pitches) {
    if (!Array.isArray(pitches)) {
        pitches=pitches.replace(/t/g,'10').replace(/e/g,'11');
        pitches=pitches.split(",");
    }
    pitches=pitches.map(function(e) { return parseInt(e)});
    
    var chordnotes=pitches.map(function (p) { return {note: p, role: ''+p}; });
    
    var rootText;
    if(transposition.substring(0,1)==="T") {
        rootText=["C","C#","D","D#","E","F","F#","G","G#","A","Bb","B"][transposition.substring(1)];
    } else {
        rootText=transposition;
    }
    
    console.log("Transposition: "+transposition+" => "+rootText);
    console.log(JSON.stringify(chordnotes));
    
    var rootacc=getRootAccidental(rootText);
    
    var scale=new scaleClass(pitches,chordnotes,chordnotes)
    var chord = new chordClass(rootacc.tpc, "T"+transposition+"["+pitches+"]", scale, null);

    console.log(">>>" + chord);
    
    return chord;

}

function chordTextClass(str) {
    var s = str;
    this.replace = function (r1, r2) {
        s = s.replace(r1, r2);
    };
    this.toString = function () {
        return s;
    };

    this.startsWith = function (test) {
        if (s.startsWith(test)) {
            s = s.substr(test.length);
            return true;
        } else {
            return false;
        }
    };

    this.includes = function (test, insesitive) {
        if (typeof insesitive === "undefined") insesitive=false;
        var pos ;
        if (insesitive) {
            pos = s.toUpperCase().indexOf(test.toUpperCase());
        } else {
            pos = s.indexOf(test);
        }

        if (pos >= 0) {
            s = s.substr(0, pos) + s.substr(pos + test.length);
            return true;
        } else {
            return false;
        }
    };
}

function chordClass(tpc, name, scale, basstpc) {
    this.pitch = tpc.pitch;
    this.name = name;
    this.root = tpc.raw;
    this.accidental = tpc.accidental;
    this.scale = scale;
	if (basstpc == null) { // keeping "==" on purpose
        this.bass = null;
    } else {
        this.bass = {
            "key": ((basstpc.pitch - tpc.pitch + 12) % 12),
            "pitch": basstpc.pitch,
            "accidental": basstpc.accidental,
            "root": basstpc.raw
	    };
    }
    Object.defineProperty(this, "keys", {
        get: function () {
            return this.scale.keys;
        }
    });

    Object.defineProperty(this, "chordnotes", {
        get: function () {
            return this.scale.chordnotes;
        }
    });

    Object.defineProperty(this, "allnotes", {
        get: function () {
            return this.scale.allnotes;
        }
    });

    Object.defineProperty(this, "outside", {
        get: function () {
            return this.scale.outside;
        }
    });

    this.toString = function () {
        return this.root + " " + this.accidental + " " + this.name + " " + scale.toString(); ;
    };

    this.getChordNote = function (note) {
        return getNote(scale.chordnotes, note);
    };

    this.getScaleNote = function (note) {
        return getNote(scale.allnotes, note);
    };

}

function getRole(roles, role) {
    if ((typeof(roles) === "undefined") || !Array.isArray(roles))
        return undefined;

    var res = roles.filter(function (e) {
        return (e.role === ('' + role));
    });
    return (res.length === 0) ? undefined : res[0];
}

function getNote(roles, note) {

    if ((typeof(roles) === "undefined") || !Array.isArray(roles))
        return undefined;

    var res = roles.filter(function (e) {
        return (e.note === note);
    });
    return (res.length === 0) ? undefined : res[0];
}
/**
* @param keys           an array of all the notes belonging to the scale, represented as an integer ranging from [0,11]
* @param chordnotes     an array of all the notes belonging explicitly to the chord from which this scale is deduced. 
*   Each note is represented on the form <code>{note: [0,11], role: string}</code>
* @param allnotes       an array of all the chromatic notes (ranging from 0 to 11) with their role on the form <code>{note: [0,11], role: string}</code>
* @param outside        an array of all the notes that must be considered as "incongruity" in that the scale,  represented as an integer ranging from [0,11]
*
*/
function scaleClass(keys, chordnotes, allnotes, outside) {
    this.keys = (!keys || (keys == null)) ? [] : keys; // keeping "==" on purpose
    this.chordnotes = (!chordnotes || (chordnotes == null)) ? [] : chordnotes; // keeping "==" on purpose
    this.allnotes = (!allnotes || (allnotes == null)) ? default_names.map(function (role, idx) { // keeping "==" on purpose
        var nr={
            "note": idx,
            "role": role
        };
        
        return nr;
        }
    ) : allnotes;
    this.outside = (!outside || (outside == null)) ? [] : outside; // keeping "==" on purpose

    var n3 = this.chordnotes.filter(function (e) {
        return (parseInt(e.role, 10) === 3);
    });

    this.mode = ((n3.length > 0) && (n3[0].note === 3)) ? "minor" : "major";

    this.keys.sort(function compareFn(a, b) {
        if (a < b)
            return -1;
        else if (a === b)
            return 0;
        else
            return 1;
    });

    this.toString = function () {
        return chordnotes
        .sort(function (a, b) {
            return a.note - b.note;
        })
        .map(function (e) {
            return e.role + ": " + e.note;
        }).join(', ') + "  === " +
        allnotes
        .sort(function (a, b) {
            return a.note - b.note;
        })
        .map(function (e) {
            return e.role + ": " + e.note;
        }).join(', ') + "  === " +
        keys.sort(function (a, b) {
            return a - b;
        }).join(', '); ;

    };

}