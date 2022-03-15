/**********************
/* Parking B - MuseScore - Chord analyser
/* v1.2.2
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: The 7th degree was sometime erased
/*  - 1.2.0: Exporting now the chord notes instead of n3/n5/n7 erased
/*  - 1.2.1: Ajout de "^7" comme équivalent à "t7"
/*  - 1.2.2: Ajout des 7th dans les accords 9
/**********************************************/
// -----------------------------------------------------------------------
// --- Vesionning-----------------------------------------
// -----------------------------------------------------------------------

function checkVersion(expected) {
    var version = "1.2.1";

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
    var scale = scaleFromText(text);

    // var chord = new chordClass(tpc, text, n3, n5, n7, keys);
    var chord = new chordClass(tpc, text, scale);

    return chord;
}

function scaleFromText(text) {

    var n3 = null,
    n5 = null,
    n7 = null,
    def2 = null,
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
    var outside = [];

    text = new chordTextClass(text.replace("add", ""));

    // Base
    // M, Ma, Maj, ma, maj
    if (text.startsWith("Maj") || text.startsWith("Ma") || text.startsWith("M") || text.startsWith("maj") || text.startsWith("ma")) {
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

    // Maj7
    else if (text.startsWith("t7") || text.startsWith("^7")) {
        console.log("Starts with t7");
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        n7 = 11;
    }

    // sus2
    else if (text.startsWith("sus2")) {
        console.log("Starts with sus2");
        n3 = 2;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // sus4
    else if (text.startsWith("sus4")) {
        console.log("Starts with sus4");
        n3 = 5;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // No indication => Major, with dominant 7
    else {
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 10; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
        outside = outside.concat([1, 3, 6, 8]);
    }

    // Compléments
    // ..7..
    if (n7 == null && text.includes("7")) {
        console.log("Has 7");
        n7 = 10;
    };

    // ..3..
    if (n3 != null) {
        keys.push(n3);
        chordnotes.push({
            "note": n3,
            "role": "3"
        });
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
        keys.push(n5);
        chordnotes.push({
            "note": n5,
            "role": "5"
        });
    } else {
        // pas de défault 5
    }

    // ..2/9..
	var n9=null;
    if (text.includes("b9")) {
        console.log("Has b9");
		n9=1;
        keys.push(n9);
        chordnotes.push({
            "note": n9,
            "role": "b9"
        });
    } else if (text.includes("#9")) {
        console.log("Has #9");
		n9=3;
        keys.push(n9);
        chordnotes.push({
            "note": n9,
            "role": "#9"
        });
    } else if (text.includes("9")) {
		n9=2;
        keys.push(n9);
        chordnotes.push({
            "note": n9,
            "role": "9"
        });
    } else if (def2 != null) {
        keys.push(def2)
    } else {
        keys.push(2)
    }

	// Adding an explicit 7 if a 9 is present
    if ((n9 != null) && (n7 == null) && (def7 != null)) {
		n7=def7;
    }


    // ..4/11..
    if (text.includes("b11")) {
        console.log("Has b11");
        keys.push(4);
        chordnotes.push({
            "note": 4,
            "role": "b11"
        });
    } else if (text.includes("#11")) {
        console.log("Has #11");
        keys.push(6)
        chordnotes.push({
            "note": 6,
            "role": "#11"
        })
    } else if (text.includes("11")) {
        console.log("Has 11");
        keys.push(5);
        chordnotes.push({
            "note": 5,
            "role": "11"
        });
    } else if (def4 != null) {
        keys.push(def4);
    } else {
        keys.push(5);
    }

    // ..6/13..
    if (text.includes("6")) {
        console.log("Has 6");
        keys.push(9); // "So in the case of min6 chords always always always make the 6th a major 6th."
        chordnotes.push({
            "note": 9,
            "role": "6"
        });
		def6=null;
	}
    if (text.includes("b13")) {
        console.log("Has b13");
        keys.push(8);
        chordnotes.push({
            "note": 8,
            "role": "b13"
        });
    } else if (text.includes("#13")) {
        console.log("Has #13");
        keys.push(10);
        chordnotes.push({
            "note": 10,
            "role": "#13"
        });
    } else if (text.includes("13")) {
        console.log("Has 13");
        keys.push(9);
        chordnotes.push({
            "note": 9,
            "role": "13"
        });
    } else if (def6 != null) {
        keys.push(def6)
    } else {
        keys.push(9)
    }

	//..7..
    if (n7 != null) {
        keys.push(n7);
        chordnotes.push({
            "note": n7,
            "role": "7"
        });
    } else if (def7 != null) {
        keys.push(def7);
    } else {
        keys.push(11);
    }

	

    console.log("After analysis : >>" + text + "<<");

    var scale = new scaleClass(keys, chordnotes);
    return scale;
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

function chordClass(tpc, name, scale) {
    this.pitch = tpc.pitch;
    this.name = name;
    this.root = tpc.raw;
    this.accidental = tpc.accidental;
    this.scale = scale;

    /*    Object.defineProperty(this, "n3", {
    get: function () {
    return getDegree(this.scale.chordnotes, 3);
    }
    });

    Object.defineProperty(this, "n5", {
    get: function () {
    return getDegree(this.scale.chordnotes, 5);
    }
    });

    Object.defineProperty(this, "n7", {
    get: function () {
    return getDegree(this.scale.chordnotes, 7);
    }
    });
     */
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

    Object.defineProperty(this, "outside", {
        get: function () {
            return this.scale.outside;
        }
    });

    this.toString = function () {
        return this.root + " " + this.accidental + " " + this.name + " " + scale.toString(); ;
    };

}

function getDegree(notes, role) {
    var res = notes.filter(function (e) {
        return (parseInt(e.role, 10) === role);
    });
    return (res.length == 0) ? undefined : res[0].note;
}

function scaleClass(keys, chordnotes, outside) {
    this.keys = (!keys || (keys == null)) ? [] : keys;
    this.chordnotes = (!chordnotes || (chordnotes == null)) ? [] : chordnotes;
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
        return chordnotes.map(function (e) {
            return e.role + ": " + e.note;
        }).join(', ');
    };

}