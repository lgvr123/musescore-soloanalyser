import QtQuick 2.9
import QtQuick.Controls 2.2
import MuseScore 3.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "chordanalyser.js" as ChordHelper
import "notehelper.js" as NoteHelper // required by chordanalyser.js

/**********************
/* Parking B - MuseScore - ChordAnalyser plugin
/* ChangeLog:
/* 	- 1.0.0: Initial release
/*  - 1.0.1: Limit to standard Harmony types
/*  - 1.0.1: Qt.quit issue
/*  - 1.0.2: New plugin folder structure
/*  - 1.0.2: MS4 port
/**********************************************/

MuseScore {
    menuPath: "Plugins." + pluginName
    description: "Uses the latest 'chordanalyzer.js' library to describe the selected chords."
    version: "1.0.2"
    readonly property var pluginName: "Chord analyzer"

    pluginType: "dialog"
    requiresScore: false
    width: 600
    height: 620
	
	id: mainWindow

    Component.onCompleted : {
        if (mscoreMajorVersion >= 4) {
            mainWindow.title = pluginName;
            mainWindow.thumbnailName = "logoChordAnalyser.png";
            mainWindow.categoryCode= "analysis";
        }
    }

    onRun: {
        // === TEMPLATE (begin) ===
        // === TEMPLATE (end) ===

        var harmonies = getHarmoniesFromSelection();

		cleanTexts();
		
        for (var i = 0; i < harmonies.length; i++) {
            logHarmony(harmonies[i]);
        }

        txtChordSymbol.text = (harmonies.length > 0) ? harmonies[0] : "";

    }

    // === PLUGIN (start) =========================================================

    function getHarmoniesFromSelection() {
        if (curScore == null)
            return [];
        var selection = curScore.selection;
        var el = selection.elements;
        var harmonies = [];
        console.log("Analyzing " + el.length + " elements in search of harmonies");
		
        for (var i = 0; i < el.length; i++) {
            var element = el[i];
            console.log("\t" + i + ") " + element.type + " (" + element.userName() + ")");
            if (element.type === Element.HARMONY && element.harmonyType === HarmonyType.STANDARD ) {
                harmonies.push(element.text);
            }
        }

        return harmonies;
    }

	function cleanTexts() {
		txtLog.text = "";
        txtSimple.text = "";
	}
		

    function logHarmony(chord_symbol) {
        if (typeof chord_symbol !== 'string') {
            console.log("Invalid chord type. Received " + (typeof chord_symbol));
            return;
        }

        addlog("===== " + chord_symbol + " =====");

        addSimple("===== " + chord_symbol + " =====");

        var chord = ChordHelper.chordFromText(chord_symbol);

        if (chord) {

            var context = {
                "root": chord.pitch,
                "sharp_mode": (['NONE', 'FLAT', 'FLAT2'].indexOf(chord.accidental) < 0)
            };

            logObject("Chord", chord, context);

            // Simple
            addSimple("----- chord -----");
            if (chord.bass !== null) {
                addSimple("Bass", chord.bass.root);
            }
            for (var i = 0; i < chord.scale.chordnotes.length; i++) {
                var cn = chord.scale.chordnotes[i];
                if (cn.note !== 12 || i < chord.scale.chordnotes.length - 1) {
                    addSimple(cn.role, cn.name);
                }
            }

            var all = chord.scale.allnotes;
            addSimple("----- scale -----");
            for (var i = 0; i < chord.keys.length; i++) {
                var note = chord.keys[i];
                if (note !== 12 || i < chord.keys.length - 1) {
                    var cn = all[note];
                    addSimple(cn.role, cn.name);
                }
            }
        } else {
            addlog("Invalid chord symbol");
            addSimple("Invalid chord symbol");
        }

    }

    function addSimple(label, text) {
        var towrite = label;
        if (typeof text !== 'undefined') {
            towrite += ": " + text;
        }
        txtSimple.text = ((txtSimple.text !== "") ? (txtSimple.text + "\n") : "") + towrite;
    }

    function addlog(label, text) {
        var towrite = label;
        if (typeof text !== 'undefined') {
            towrite += ": " + text;
        }
        //console.log(towrite);
        txtLog.text = ((txtLog.text !== "") ? (txtLog.text + "\n") : "") + towrite;
    }

    function logObject(label, element, context, excludes) {

        if (typeof element === 'undefined') {
            addlog(label + "undefined");
        } else if (element === null) {
            addlog(label + ": null");

        } else if (Array.isArray(element)) {
            for (var i = 0; i < element.length; i++) {
                logObject(label + "-" + i, element[i], context, excludes);
            }

        } else if (typeof element === 'object') {

            var kys = Object.keys(element);

            if ((kys.length == 2) && (kys.indexOf('note') >= 0) && (kys.indexOf('role') >= 0)) {
                var p = 60 + context.root + parseInt(element.note);
                var tp = p % 12;
                var tpcs = (context.sharp_mode) ? NoteHelper.sharpTpcs : NoteHelper.flatTpcs;
                var tpc = tpcs.filter(function (e) {
                    return e.pitch == tp;
                });
                if (tpc.length == 0) {
                    console.log("!!No such pitch : " + tp);
                    tpc = undefined;
                } else {
                    tpc = tpc[0];
                }

                element.name = tpc.name;
                addlog(label, JSON.stringify(element));
            } else {

                for (var i = 0; i < kys.length; i++) {
                    if (!excludes || excludes.indexOf(kys[i]) == -1) {
                        logObject(label + ": " + kys[i], element[kys[i]], context, excludes);
                    }
                }
            }
        } else if (typeof element !== 'function') {
            addlog(label + ": " + element);
        }
    }

    // -----------------------------------------------------------------------
    // --- Screen design -----------------------------------------------------
    // -----------------------------------------------------------------------
    ColumnLayout {
        id: panMain

        anchors.fill: parent
        spacing: 5
        anchors.topMargin: 10
        anchors.rightMargin: 10
        anchors.leftMargin: 10
        anchors.bottomMargin: 15

        RowLayout {
            Layout.fillWidth: false
            Label {
                text: "Chord symbol:"
            }

            TextField {
                id: txtChordSymbol
                text: ""
                placeholderText: "E.g. Bb-7, Ct7, B07, Dbadd9, ..."
            }
        }

        StackLayout {

            currentIndex: rdbViewSimple.checked ? 0 : 1

            ScrollView {
                id: viewSimple
                Layout.fillWidth: true
                Layout.fillHeight: true
                TextArea {
                    id: txtSimple
                    text: ""
                    placeholderText: "here will come the selected chord symbol details..."
                    background: Rectangle {
                        color: "white"
                        border.color: "#C0C0C0"
                    }
                }
            }

            ScrollView {
                id: view
                Layout.fillWidth: true
                Layout.fillHeight: true
                TextArea {
                    id: txtLog
                    text: ""
                    placeholderText: "here will come the selected chord symbol raw details..."
                    background: Rectangle {
                        color: "white"
                        border.color: "#C0C0C0"
                    }
                }
            }

        }
        RowLayout {
            Label {
                text: "View:"
            }
            NiceRadioButton {
                id: rdbViewSimple
                text: qsTr("Simple")
                checked: true
                //ButtonGroup.group: bar
            }
            NiceRadioButton {
                id: rdbViewRaw
                text: qsTr("Raw")
                //ButtonGroup.group: bar
            }
        }

        Item { // buttons row // DEBUG was Item
            Layout.fillWidth: true
            Layout.preferredHeight: buttonBox.implicitHeight

            RowLayout {
                id: panButtons
                anchors.fill: parent
                Item { // spacer // DEBUG Item/Rectangle
                    id: spacer
                    implicitHeight: 10
                    Layout.fillWidth: true
                }

                Button {
                    id: btnAnalyse
                    text: "Analyse"
                    enabled: txtChordSymbol.text !== ""
                    onClicked: {
						cleanTexts();
                        console.log("launching analyse with '" + txtChordSymbol.text + "'");
                        logHarmony(txtChordSymbol.text)
                    }
                }
                Button {
                    id: buttonBox
                    text: "Close"

                    onClicked: mainWindow.parent.Window.window.close(); //Qt.quit()
                    // onClicked: Qt.exit(0) // ne fonctionne pas
                }
            }
        } // button rows

    }

    // === PLUGIN (end) =========================================================

    // === TEMPLATE =========================================================


    function debugO(label, element, excludes) {

        if (typeof element === 'undefined') {
            console.log(label + ": undefined");
        } else if (element === null) {
            console.log(label + ": null");

        } else if (Array.isArray(element)) {
            for (var i = 0; i < element.length; i++) {
                debugO(label + "-" + i, element[i], excludes);
            }

        } else if (typeof element === 'object') {

            var kys = Object.keys(element);
            for (var i = 0; i < kys.length; i++) {
                if (!excludes || excludes.indexOf(kys[i]) == -1) {
                    debugO(label + ": " + kys[i], element[kys[i]], excludes);
                }
            }
        } else {
            console.log(label + ": " + element);
        }
    }
}