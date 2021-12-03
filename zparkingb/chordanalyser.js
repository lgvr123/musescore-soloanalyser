/**********************
/* Parking B - MuseScore - Chord analyser
/* v1.0.0
/* ChangeLog:
/**********************************************/
// -----------------------------------------------------------------------
// --- Vesionning-----------------------------------------
// -----------------------------------------------------------------------

function checkVersion(expected) {
    var version = "1.0.0";

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
    var keys = [0,12];
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
        def2=1;
		def4=4;
		n3 = 3;
        n5 = 6;
        n7 = 9;
        def6 = 7; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
    }

    // Half-dim
    else if (text.startsWith("0")) {
        console.log("Starts with 0");
        n3 = 3;
        n5 = 6;
        n7 = 10;
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
    else if (text.startsWith("t7")) {
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

    // No indication => Major
    else {
        n3 = 4;
        n5 = 7;
        def6 = 9; // Je force une 6ème par défaut. Qui sera peut-être écrasée après.
        def7 = 11; // Je force une 7ème par défaut. Qui sera peut-être écrasée après.
        outside = outside.concat([1, 3, 6, 8]);
    }

    // Compléments
	// ..7..
    if (n7 == null && text.includes("7")) {
        console.log("Has 7");
        n7 = 10;
    } else if (n7 == null && def7 != null) {
        n7 = def7;
    } else {
		n7=11;
	}

	// ..5..
    if (text.includes("b5")) {
        console.log("Has b5");
        n5 = 6;
    } else if (text.includes("#5")) {
        console.log("Has #5");
        n5 = 8;
    }

	// ..2/9..
    if (text.includes("b9")) {
        console.log("Has b9");
        keys.push(1)
    } else if (text.includes("#9")) {
        console.log("Has #9");
        keys.push(3)
    } else if (text.includes("9")) {
        console.log("Has 9");
        keys.push(2)
    } else if (def2!=null) {
        keys.push(def2)
	} else {
        keys.push(2)
	}

	// ..4/11..
    if (text.includes("b11")) {
        console.log("Has b11");
        keys.push(4)
    } else if (text.includes("#11")) {
        console.log("Has #11");
        keys.push(6)
    } else if (text.includes("11")) {
        console.log("Has 11");
        keys.push(5)
    } else if (def4!=null) {
        keys.push(def4)
	} else {
        keys.push(5)
	}

	// ..6/13..
    if (text.includes("b13")) {
        console.log("Has b13");
        keys.push(8)
    } else if (text.includes("#13")) {
        console.log("Has #13");
        keys.push(10)
    } else if (text.includes("13")) {
        console.log("Has 13");
        keys.push(9)
    } else if (def6!=null) {
        keys.push(def6)
	} else {
        keys.push(9)
	}

    console.log("After analysis : >>" + text + "<<");

    if (n3 != null)
        keys.push(n3);
    if (n5 != null)
        keys.push(n5);
    if (n7 != null)
        keys.push(n7);

    var scale = new scaleClass(n3, n5, n7, keys);
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

    Object.defineProperty(this, "n3", {
        get: function () {
            return this.scale.n3;
        }
    });

    Object.defineProperty(this, "n5", {
        get: function () {
            return this.scale.n5;
        }
    });

    Object.defineProperty(this, "n7", {
        get: function () {
            return this.scale.n7;
        }
    });

    Object.defineProperty(this, "keys", {
        get: function () {
            return this.scale.keys;
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

function scaleClass(n3, n5, n7, keys, outside) {
    this.n3 = n3;
    this.n5 = n5;
    this.n7 = n7;
    this.keys = (!keys || (keys == null)) ? [] : keys;
    this.outside = (!outside || (outside == null)) ? [] : outside;
	this.mode=((n3!=null) && (n3==3))?"minor":"major";
	
	this.keys.sort(function compareFn(a, b) { if(a<b) return -1; else if (a==b) return 0; else return 1; });;

    this.toString = function () {
        return keys.toString(); ;
    };

}