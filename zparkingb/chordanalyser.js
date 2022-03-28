/**********************
/* Parking B - MuseScore - Chord analyser
/* v1.2.5
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

/**********************************************/
// -----------------------------------------------------------------------
// --- Vesionning-----------------------------------------
// -----------------------------------------------------------------------
var default_names = ["1", "b9", "2", "#9", "b11", "4", "#11", "(5)", "m6", "M6", "m7", "M7"];

function checkVersion(expected) {
    var version = "1.2.7";

    var aV = version.split('.').map(function (v) {
        return parseInt(v);
    });
    var aE = (expected && (expected != null)) ? expected.split('.').map(function (v) {
        return parseInt(v);
    }) : [99];
    if (aE.length == 0)
        aE = [99];

    for (var i = 0; (i < aV.length) && (i < aE.length); i++) {
        if (!(aV[i] >= aE[i]))
            return false;
    }

    return true;
}

function chordFromText(source) {

    var text = source.replace(/(\(|\))/g, '');

    var rootbass = text.split("/");
    text = rootbass[0];
    var bass = (rootbass.length > 1) ? rootbass[1] : null;

    // Root
    var rootacc = getRootAccidental(text);
    text = rootacc.remaingtext;

    if (rootacc.tpc == null) {
        console.log("!! Could not found >>" + rootacc.root + "-" + rootacc.alt + "<<");
        return null;
    }

    // Chord type
    var scale;

    // Bass and scale
    var bassacc = null;
    if (bass != null) {
        bassacc = getRootAccidental(bass);
        if (bassacc.tpc != null) {
            var relpitch = (bassacc.tpc.pitch - rootacc.tpc.pitch + 12) % 12;
            scale = scaleFromText(text, relpitch);
        }
    }
    if (scale == null)
        scale = scaleFromText(text);

    // var chord = new chordClass(tpc, text, n3, n5, n7, keys);
    var chord = new chordClass(rootacc.tpc, text, scale, (bassacc != null) ? bassacc.tpc : null);

    console.log(">>>" + chord);

    return chord;
}

function getRootAccidental(text) {
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

    var n2 = null,
    n3 = null,
    n4 = null,
    n5 = null,
	n6=null,
    n7 = null,
    def2 = null,
    def3 = null,
    def4 = null,
    def6 = null,
    def7 = null;
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
    if ((bass !== bass) || (bass == 0)) // testing NaN
        bass = null

            var at = null;
    // Base
    // M, Ma, Maj, ma, maj
    if (text.startsWith("Maj7") || text.startsWith("Ma7") || text.startsWith("M7") || text.startsWith("maj7") || text.startsWith("ma7") ||
        text.startsWith("t7") || text.startsWith("^7")) {
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
    }

    // Aug
    else if (text.startsWith("aug") || text.startsWith("+")) {
        console.log("Starts with aug/+");
        n3 = 3;
        n5 = 6;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
    }

    // sus2
    else if (text.startsWith("sus2")) {
        console.log("Starts with sus2");
        n2 = 2;
        def3 = 4; //pourrait être 3 ou 4
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // sus4
    else if (text.startsWith("sus4")) {
        console.log("Starts with sus4");
        n4 = 5;
        def3 = 4; //pourrait être 3 ou 4
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // No indication => Major, with dominant 7
    else {
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
        outside = outside.concat([1, 3, 6, 8]);
    }

    // Compléments
    // ..7..
    if (n7 == null && (text.includes("maj7") || text.includes("ma7") || text.startsWith("t7") || text.startsWith("^7"))) {
        console.log("Has M7");
        n7 = 11;
    } else
        if (n7 == null && text.includes("7")) {
            console.log("Has m7");
            n7 = 10;
        };

    // ..3..
    if (n3 != null) {
        _ptok(keys, n3, "n3");
        pushToNotes(chordnotes, n3, "3");
    } else if (def3 != null) {
        _ptok(keys, def3, "def3");
    }

    // ..5..
    if (text.includes("b5")) {
        console.log("Has b5");
        n5 = 6;
    } else if (text.includes("#5")) {
        console.log("Has #5");
        n5 = 8;
    }

    if (n5 != null) {
        _ptok(keys, n5, "n5");
        pushToNotes(chordnotes, n5, "5");
    } else if (bass == 7) {
        _ptok(keys, bass, "bass as 5");
        pushToNotes(chordnotes, bass, "5");
    } else {
        _ptok(keys, 7, "def5 (=7)");
    }

    // ..2/9..
    var n9 = null;
    if (text.includes("b9")) {
        console.log("Has b9");
        n9 = 1;
        _ptok(keys, n9, "b9");
        pushToNotes(chordnotes, n9, "b9");
    } else if (text.includes("#9")) {
        console.log("Has #9");
        n9 = 3;
        _ptok(keys, n9, "#9");
        pushToNotes(chordnotes, n9, "#9");
    } else if (text.includes("9")) {
        n9 = 2;
        _ptok(keys, n9, "9");
        pushToNotes(chordnotes, n9, "9");

    } else if (((at = [1, 2, 3].indexOf(bass)) >= 0) && (bass!==n2)) {
        n9 = bass;
        _ptok(keys, bass, "bass as 2/9");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "9(B)");
    }

    if (n2 != null) {
        _ptok(keys, n2, "n2");
        pushToNotes(chordnotes, n2, "2");
    } else if (n9 == null) {
        if (def2 == null) { // 15/3: alignement sur Supercollider
            def2 = 2;
        }
        _ptok(keys, def2, "def2");
        if (getNote(chordnotes, def2) === undefined)
            allnotes.push({
                "note": def2,
                "role": "2"
            });
    }

    // Adding an explicit 7 if a 9 is present
    if ((n9 != null) && (n7 == null) && (def7 != null)) {
        // n7 = def7;
        n7 = 10;
    }

    // ..4/11..
    var n11 = null;
    if (text.includes("b11")) {
        console.log("Has b11");
        n11 = 4;
        _ptok(keys, n11, "b11");
        pushToNotes(chordnotes, n11, "b11");
    } else if (text.includes("#11")) {
        console.log("Has #11");
        n11 = 6;
        _ptok(keys, n11, "#11");
        pushToNotes(chordnotes, n11, "#11");
    } else if (text.includes("11")) {
        console.log("Has 11");
        n11 = 5;
        _ptok(keys, n11, "11");
        pushToNotes(chordnotes, n11, "11");
    } else if (((at = [4, 5, 6].indexOf(bass)) >= 0) && (bass!=n4)){
        n11 = bass;
        _ptok(keys, bass, "bass as 4/11");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "11");

    }

    if (n4 != null) {
        _ptok(keys, n4, "n4");
        pushToNotes(chordnotes, n4, "4");
    } else if (n11 == null) {
        if (def4 == null)
            def4 = 5;
        _ptok(keys, def4, "def4");
        if (getNote(chordnotes, def4) === undefined)
            pushToNotes(allnotes, def4, "4");
    }

    // ..6/13..
    if (text.includes("6")) {
        console.log("Has 6");
		n6=9;
        _ptok(keys, n6, "(n)6"); // "So in the case of min6 chords always always always make the 6th a major 6th."
        pushToNotes(chordnotes, n6, "6");
        def6 = null;
    }
    var n13 = null;
    if (text.includes("b13")) {
        console.log("Has b13");
        n13 = 8;
        _ptok(keys, n13, "b13");
        pushToNotes(chordnotes, n13, "b13");
    } else if (text.includes("#13")) {
        console.log("Has #13");
        n13 = 10;
        _ptok(keys, n13, "#13");
        pushToNotes(chordnotes, n13, "#13");
    } else if (text.includes("13")) {
        console.log("Has 13");
        n13 = 9;
        _ptok(keys, n13, "13");
        pushToNotes(chordnotes, n13, "13");
    } else if (((at = [8, 9, 10].indexOf(bass)) >= 0) && (bass!=n6)) {
        n13 = bass;
        _ptok(keys, bass, "bass as 6/13");
        pushToNotes(chordnotes, bass, ["b", "", "#"][at] + "13");
    } else {
        if (def6 == null)
            def6 = 9;
        _ptok(keys, def6, "def6");
        if (getNote(chordnotes, def6) === undefined)
            pushToNotes(allnotes, def6, "6");
    }

    //..7..
    if (n7 != null) {
        _ptok(keys, n7, "n7");
        pushToNotes(chordnotes, n7, "7");
    } else if ((at = [10, 11].indexOf(bass)) >= 0) {
        n7 = bass;
        _ptok(keys, bass, "bass as 7");
        pushToNotes(chordnotes, bass, ["m", "M"][at] + "7");
    } else {
        if (def7 == null)
            def7 = 11;
        _ptok(keys, def7, "def7");
        if (getNote(chordnotes, def7) === undefined)
            pushToNotes(allnotes, def7, "7");
    }

    // Looking for all notes
    allnotes = chordnotes.concat(allnotes);
    for (var n = 1; n < 12; n++) {
        if ((getNote(allnotes, n) === undefined) && (n !== bass)) {
			var at;
		    var dn = (n3 == null && (at=[3,4].indexOf(n))>=0) ? ["m3","M3"][at] : default_names[n];
            pushToNotes(allnotes, n, dn);
        } else if (n === bass) {
            pushToNotes(allnotes, n, "bass");
        }
    }

    console.log("After analysis : >>" + text + "<<");

    var scale = new scaleClass(keys, chordnotes, allnotes);
    return scale;
}

function pushToNotes(collection, note, role) {
    var exist = getNote(collection, note);

    if (exist) {
        console.log("Not adding " + role + "(" + note + ") because it exist as " + exist.role);
        return;
    }
    collection.push({
        "note": note,
        "role": role
    });
}

function _ptok(keys, value, comment) {
    console.log("....pushing >>" + value + "<< (" + comment + ")");
    keys.push(value);
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

function chordClass(tpc, name, scale, basstpc) {
    this.pitch = tpc.pitch;
    this.name = name;
    this.root = tpc.raw;
    this.accidental = tpc.accidental;
    this.scale = scale;
    this.bass_pitch = (basstpc != null) ? basstpc.pitch : null;
    this.bass_accidental = (basstpc != null) ? basstpc.accidental : null;
    this.bass_root = (basstpc != null) ? basstpc.raw : null;

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
    return (res.length == 0) ? undefined : res[0];
}

function getNote(roles, note) {

    if ((typeof(roles) === "undefined") || !Array.isArray(roles))
        return undefined;

    var res = roles.filter(function (e) {
        return (e.note === note);
    });
    return (res.length == 0) ? undefined : res[0];
}

function scaleClass(keys, chordnotes, allnotes, outside) {
    this.keys = (!keys || (keys == null)) ? [] : keys;
    this.chordnotes = (!chordnotes || (chordnotes == null)) ? [] : chordnotes;
    this.allnotes = (!allnotes || (allnotes == null)) ? default_names.map(function (role, idx) { {
            "note": idx,
            "role": role
        }
    }) : allnotes;
    this.outside = (!outside || (outside == null)) ? [] : outside;

    var n3 = this.chordnotes.filter(function (e) {
        return (parseInt(e.role, 10) === 3);
    });

    this.mode = ((n3.length > 0) && (n3[0].note === 3)) ? "minor" : "major";

    this.keys.sort(function compareFn(a, b) {
        if (a < b)
            return -1;
        else if (a == b)
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
            return a - b
        }).join(', '); ;

    };

}