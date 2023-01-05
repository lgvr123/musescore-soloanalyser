import QtQuick 2.9
import QtQuick.Controls 2.2
import MuseScore 3.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "selectionhelper.js" as SelHelper
import "notehelper.js" as NoteHelper
import "chordanalyser.js" as ChordHelper
import "core.js" as Core

/**********************
/* Parking B - MuseScore - Scale Analyser plugin
/* ChangeLog:
/*  - 1.0.0: Initial version based on SoloAnalyser 1.3.0
/**********************************************/

MuseScore {
    menuPath: "Plugins.Scale Analyser." + pluginName
    description: "Colors and names the notes based on their role if a scale."
    version: "1.0.0"

    readonly property var pluginName: "Interactive"

    pluginType: "dialog"
    width: mainRow.childrenRect.width + mainRow.anchors.leftMargin + mainRow.anchors.rightMargin
    height: mainRow.childrenRect.height + mainRow.anchors.topMargin + mainRow.anchors.bottomMargin

    id: mainWindow

    Component.onCompleted: {
        if (mscoreMajorVersion >= 4) {
            mainWindow.title = "Solo Analyser " + pluginName;
            mainWindow.thumbnailName = "logoScaleAnalyserInteractive.png";
            mainWindow.categoryCode = "color-notes";
        }
    }

    onRun: {
        // 1) Read config file
        // AUTOMATIC

        // 2) push to screen

        select(lstColorNote, settings.colorNotes);
        select(lstNameNote, settings.nameNotes);
        select(lstFormText, settings.textType);

        rootColorChosser.color = settings.rootColor;
        bassColorChosser.color = settings.bassColor;
        chordColorChosser.color = settings.chordColor;
        scaleColorChosser.color = settings.scaleColor;
        alteredColorChosser.color = settings.alteredColor;
        // errorColorChosser.color = settings.errorColor;

        chkUseAboveSymbols.checked = settings.useAboveSymbols;
        chkUseBelowSymbols.checked = settings.useBelowSymbols;
        chkLookAhead.checked = settings.lookAhead;
        chkIgnoreBrackettedChords.checked = settings.ignoreBrackettedChords;

    }

    function select(control, value) {
        var index = 0;
        for (var i = 0; i < control.model.length; i++) {
            if (control.model[i].value == value) {
                index = i;
                break;
            }
        }
        control.currentIndex = index;

    }
    function get(control) {
        return control.model[control.currentIndex].value;

    }

    Settings {
        id: settings
        category: "SoloAnalyser"
        // in options
        property var rootColor: Core.defRootColor
        property var bassColor: Core.defBassColor
        property var chordColor: Core.defChordColor
        property var scaleColor: Core.defScaleColor
        property var errorColor: Core.defErrorColor
        property var alteredColor: Core.defAlteredColor
        property var colorNotes: Core.defColorNotes
        property var nameNotes: Core.defNameNotes
        property var textType: Core.defTextType
        property var useBelowSymbols: Core.defUseBelowSymbols
        property var useAboveSymbols: Core.defUseAboveSymbols
        property var lookAhead: Core.defLookAhead
        property var ignoreBrackettedChords: Core.defIgnoreBrackettedChords
    }

    GridLayout {
        id: mainRow
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 10

        columns: 2
        columnSpacing: 5

        GroupBox {
            title: "Rendering options..."
            //Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            GridLayout {
                columnSpacing: 5

                rowSpacing: 10
                columns: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                NiceLabel {
                    text: "Note coloring  : "
                    //Tooltip.text : "Color all notes or only the ones defined by the chord";
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillHeight: false
                }

                NiceComboBox {
                    //Layout.fillWidth : true
                    id: lstColorNote
                    model: [{
                            'value': "none",
                            'text': "None - Don't color notes"
                        }, {
                            'value': "chord",
                            'text': "Chord - Color the notes present in the chord"
                        }, {
                            'value': "all",
                            'text': "Scale - Color the notes defined by the scale"
                        }
                    ]

                }

                NiceLabel {
                    text: "Note name  : "
                    //Tooltip.text : "Name all notes or only the ones defined by the chord";
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillHeight: false
                }

                NiceComboBox {
                    //Layout.fillWidth : true
                    id: lstNameNote
                    model: [{
                            'value': "none",
                            'text': "None - Don't name notes"
                        }, {
                            'value': "chord",
                            'text': "Chord - Name the notes present by the chord"
                        }, {
                            'value': "all",
                            'text': "Scale - Name the notes defined by the scale"
                        }
                    ]

                }

                NiceLabel {
                    text: "Root : "
                }
                Rectangle {
                    id: rootColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = rootColorChosser.color
                                colorDialog.target = rootColorChosser;
                            colorDialog.open();
                        }
                    }
                }

                NiceLabel {
                    text: "Bass : "
                }
                Rectangle {
                    id: bassColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = bassColorChosser.color
                                colorDialog.target = bassColorChosser;
                            colorDialog.open();
                        }
                    }
                }

                NiceLabel {
                    text: "Chord : "
                }
                Rectangle {
                    id: chordColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = chordColorChosser.color
                                colorDialog.target = chordColorChosser;
                            colorDialog.open();
                        }
                    }
                }

                NiceLabel {
                    text: "Altered : "
                }
                Rectangle {
                    id: alteredColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = alteredColorChosser.color
                                colorDialog.target = alteredColorChosser;
                            colorDialog.open();
                        }
                    }
                }

                NiceLabel {
                    text: "Scale : "
                }
                Rectangle {
                    id: scaleColorChosser
                    width: 50
                    height: 30
                    color: "gray"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            colorDialog.color = scaleColorChosser.color
                                colorDialog.target = scaleColorChosser;
                            colorDialog.open();
                        }
                    }
                }

                /*NiceLabel {
                text: "Invalid : "
                }
                Rectangle {
                id: errorColorChosser
                width: 50
                height: 30
                color: "gray"
                MouseArea {
                anchors.fill: parent
                onClicked: {
                colorDialog.color = errorColorChosser.color
                colorDialog.target = errorColorChosser;
                colorDialog.open();
                }
                }
                }*/

                NiceLabel {
                    text: "Text form  : "
                }

                NiceComboBox {
                    id: lstFormText
                    model: [{
                            value: "fingering",
                            text: "As fingering"
                        }, {
                            value: "lyrics",
                            text: "As lyrics"
                        }
                    ]

                }
            }
        }

        GroupBox {
            title: "Analyze options..."
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            GridLayout {

                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                columns: 1

                Flow {
                    SmallCheckBox {
                        id: chkLookAhead
                        text: "Look ahead"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Use the next chord if no previous chord has been found (e.g. anacrusis)"
                    }
                }

                Flow {
                    SmallCheckBox {
                        id: chkUseAboveSymbols
                        text: "Allow using preceeding staves chord symbols"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "<p>If a staff has no chord symbols, use the chord symbols of the first <br/>preceeding staff having chord symbols.<br/><p><b><u>Remark</u></b>: When these options are used, SoloAnalyzer must be used <br/>preferably in <b>Concert pitch</b></p>"
                    }
                }

                Flow {
                    SmallCheckBox {
                        id: chkUseBelowSymbols
                        text: "Allow using following staves chord symbols"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "<p>If a staff has no chord symbols, use the chord symbols of the first <br/>following staff having chord symbols.<br/><p><b><u>Remark</u></b>: When these options are used, SoloAnalyzer must be used <br/>preferably in <b>Concert pitch</b></p>"
                    }
                }
                Flow {
                    SmallCheckBox {
                        id: chkIgnoreBrackettedChords
                        text: "Ignore chord names in parentheses"
                        hoverEnabled: true
                        ToolTip.visible: hovered
                        ToolTip.text: "Chord names surrounded by parentheses will be ignore for the analyse."
                    }
                }

            }
        }

        // Item { // spacer // DEBUG Item/Rectangle
        // implicitWidth: 10
        // Layout.fillHeight: true
        // }
        RowLayout {

            id: panButtons
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.margins: 0
            Layout.columnSpan: 2
            Button {
                implicitHeight: buttonBox.contentItem.height

                text: "Reset"
                onClicked: {
                    settings.rootColor = Core.defRootColor;
                    settings.bassColor = Core.defBassColor;
                    settings.chordColor = Core.defChordColor;
                    settings.scaleColor = Core.defScaleColor;
                    settings.errorColor = Core.defErrorColor;
                    settings.alteredColor = Core.defAlteredColor;
                    settings.colorNotes = Core.defColorNotes;
                    settings.nameNotes = Core.defNameNotes;
                    settings.textType = Core.defTextType;
                    settings.useAboveSymbols = Core.defUseAboveSymbols;
                    settings.useBelowSymbols = Core.defUseBelowSymbols;
                    settings.lookAhead = Core.defLookAhead;
                    settings.ignoreBrackettedChords = Core.defIgnoreBrackettedChords;

                    select(lstColorNote, settings.colorNotes);
                    select(lstNameNote, settings.nameNotes);
                    select(lstFormText, settings.textType);

                    rootColorChosser.color = settings.rootColor;
                    bassColorChosser.color = settings.bassColor;
                    chordColorChosser.color = settings.chordColor;
                    scaleColorChosser.color = settings.scaleColor;
                    alteredColorChosser.color = settings.alteredColor;
                    // errorColorChosser.color = settings.errorColor;

                    chkUseBelowSymbols.checked = settings.useBelowSymbols;
                    chkUseAboveSymbols.checked = settings.useAboveSymbols;
                    chkLookAhead.checked = settings.lookAhead;
                    chkIgnoreBrackettedChords.checked = settings.ignoreBrackettedChords;
                }
                hoverEnabled: true
                ToolTip.visible: hovered
                ToolTip.text: "Reset to default values"

            }

            Item { // spacer // DEBUG Item/Rectangle
                implicitHeight: 10
                Layout.fillWidth: true
            }

            DialogButtonBox {
                standardButtons: DialogButtonBox.Close
                id: buttonBox

                background.opacity: 0 // hide default white background

                Button {
                    text: "Apply"
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                }
                Button {
                    text: "Clear"
                    id: btnClear
                    DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
                }

                onAccepted: {
                    // push values to backend
                    settings.rootColor = rootColorChosser.color;
                    settings.bassColor = bassColorChosser.color;
                    settings.chordColor = chordColorChosser.color;
                    settings.scaleColor = scaleColorChosser.color;
                    settings.alteredColor = alteredColorChosser.color;
                    // settings.errorColor = errorColorChosser.color;

                    settings.colorNotes = get(lstColorNote);
                    settings.nameNotes = get(lstNameNote);
                    settings.textType = get(lstFormText);

                    settings.useBelowSymbols = chkUseBelowSymbols.checked;
                    settings.useAboveSymbols = chkUseAboveSymbols.checked;
                    settings.lookAhead = chkLookAhead.checked;
                    settings.ignoreBrackettedChords = chkIgnoreBrackettedChords.checked;

                    // save values
                    // AUTOMATIC

                    // execute
                    //Core.doAnalyse();
                    doScaleAnalyse();
                    //Qt.quit();
                    mainWindow.parent.Window.window.close();

                }

                onClicked: {
                    console.log("~~~~~~~~~~~~" + button.text + "~~~~~~~~~~~~");
                    if (button == btnClear) {
                        Core.clearAnalyse();
                        //Qt.quit();
                        mainWindow.parent.Window.window.close();
                    }
                }
                onRejected: {
                    //Qt.quit()
                    mainWindow.parent.Window.window.close();
                }

            }
        }

    }

    ColorDialog {
        id: colorDialog
        title: "Please choose a color"
        property var target
        onAccepted: {
            console.log("You chose: " + colorDialog.color)
            if (target !== undefined)
                target.color = colorDialog.color;
        }
        onRejected: {
            console.log("Canceled")
        }
        // Component.onCompleted: visible = true
    }

    function doScaleAnalyse(root, scale) {

        // Config
        var colorNotes = settings.colorNotes; // none|chord|all
        // var nameNotes = settings.nameNotes; // none|chord|all
        var nameNotes = "all"; // none|chord|all
        var rootColor = settings.rootColor;
        var bassColor = settings.bassColor;
        var errorColor = settings.errorColor;
        var scaleColor = settings.scaleColor;
        var chordColor = settings.chordColor;
        var alteredColor = (settings.alteredColor) ? settings.alteredColor : defAlteredColor
        var textType = (settings.textType) ? settings.textType : defTextType
        var useAboveSymbols = (settings.useAboveSymbols !== undefined) ? settings.useAboveSymbols : true
        var useBelowSymbols = (settings.useBelowSymbols !== undefined) ? settings.useBelowSymbols : true
        var lookAhead = (settings.lookAhead !== undefined) ? settings.lookAhead : true
        var ignoreBrackettedChords = (settings.ignoreBrackettedChords !== undefined) ? settings.ignoreBrackettedChords : true

        // if configured for doing nothing (no colours, no names) we use the default values
        if (colorNotes == "none" && nameNotes == "none") {
            colorNotes = defColorNotes;
            nameNotes = defNameNotes;
        }

        // Selection
        var chords = Core.getSelection();
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

        var cursor = curScore.newCursor();
        /*
        var byTrack = new Array(trackMax + 1); ;

        // cursor.rewindToTick(segMin);
        cursor.rewindToTick(0); // retrieving the chord from the beginning, so that if do the analyse in the middlle of a chord, we know that chord.
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


        //if ((ann.track < trackMin) ||(ann.track > trackMax)) // j'analyse aussi ce qui a en amont
        if ((ann.track > trackMax)) // j'analyse aussi ce qui a en amont
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
         */
        // Processing
        curScore.startCmd();

        // processing
        for (var track = trackMin; track <= trackMax; track++) {
            console.log("~~~~ processing track " + track + " ~~~~");

            // Is this track a pitched staff (opposed to a drumstaff) ?
            var isdrumset = false;
            for (var i = 0; i < curScore.parts.length; i++) {
                var part = curScore.parts[i];
                if (track >= part.startTrack && track < part.endTrack) {
                    console.log("The track belongs to part " + i + ": " + part.startTrack + "/" + part.endTrack + ": " + part.hasDrumStaff + "/" + part.hasPitchedStaff);
                    isdrumset = part.hasDrumStaff;
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
            // var values = (byTrack[track] !== undefined) ? byTrack[track] : [];
            // var step = lookAhead?0:-1; // if we lookAhead, we start from the first chord, even if it is further that start segment.
            var values = [];
            var _scale = pentatonicMinor;
            var _root = ChordHelper.getRootAccidental("F");

            // console.log("Scale: " + _scale);
            // console.log("Root: " + _root);
            // console.log("Root.tcp: " + _root.tpc);
            // console.log("Root.tcp.pitch: " + _root.tpc.pitch);
            // console.log("Root.tcp.accidental: " + _root.tpc.accidental);
            // console.log("Root.tcp.raw: " + _root.tpc.raw);

            values.push({ // Scale analyser
                tick: 0,
                chord: new ChordHelper.chordClass(_root.tpc, _scale.name, _scale)
            });

            console.log("Chord: " + values[0].chord);

            var step = 0; // Scale analyser

            var curChord = null;
            var check = null;
            console.log("lookAhead = " + lookAhead + ", donc on commence à l'étape " + step);
            while (segment && segment.tick <= segMax) {
                // getting the right chord diagram
                while ((step < (values.length - 1)) && (values[step + 1].tick <= segment.tick)) {
                    step++;
                    console.log("next: going to step " + step + ", because current tick (" + segment.tick + ") is >= next step's tick (" + values[step].tick + ")");
                    // curChord = ChordHelper.chordFromText(values[step].text);
                }

                console.log("step: " + step + "/" + values.length);

                if (step >= 0) {
                    curChord = values[step].chord;
                    check = values[step].tick;
                }
                console.log(track + "/" + segment.tick + ": step = " + step + " => chord = " + ((curChord === null) ? "/" : curChord.name + " ( from " + check + ")"));

                // retrieving the element on this track
                var el = cursor.element;
                if ((el !== null) && (el.type === Element.CHORD)) {

                    // Looping in the chord notes
                    var notes = el.notes;
                    var asLyrics = [];
                    for (var j = 0; j < notes.length; j++) {
                        var note = notes[j];

                        if (note.headGroup === NoteHeadGroup.HEAD_SLASH)
                            continue; // Don't analyse slash notes

                        var color = null;
                        var degree = null;

                        // color based on role in chord
                        if (curChord != null) {
                            // !! The chord name is depending if we are in Instrument Pitch or Concert Pitch (this is automatic in MuseScore)
                            // So we have to retrieve the pitch as shown on the score. In instrument pitch this might be different than the pitch
                            // given by note.pitch which is corresponding to the *concert pitch*.


                            // var tpitch = note.pitch - (note.tpc - note.tpc1); // note displayed as if it has that pitch
                            var tpitch = note.pitch + NoteHelper.deltaTpcToPitch(note.tpc, note.tpc1); // note displayed as if it has that pitch


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
                                console.log("note pitch: " + tpitch + ((tpitch !== note.pitch) ? (" (transposing!! original: " + note.pitch + ")") : "") + " | Chord pitch:" + curChord.pitch + " ==> position: " + p + " ==> color: " + color);
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
                            Core.writeDegree(note, (nameNotes !== "none") ? degree : null);
                        } else {
                            // clear Fingering on that note
                            writeDegree(note, null);
                            // Memorize degree as lyrics
                            asLyrics.push((nameNotes !== "none") ? degree : null)
                        }

                    }

                    // Je le fais toujours comme ça on clean, d'anciennes valeurs
                    Core.writeDegreeAsLyrics(el, asLyrics);
                }

                // next
                cursor.next();
                segment = cursor.segment;
            }

        }

        curScore.endCmd();

    }

    property var ionian :           { toScale("ionian",         [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 11, "7"]); }
    property var dorian :           { toScale("dorian",         [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 9, "6", 10, "7"]); }
    property var lydian :           { toScale("lydian",         [0, "1", 2, "2", 4, "3", 6, "4", 7, "5", 9, "6", 11, "7"]); }
    property var mixolydian :       { toScale("mixolydian",     [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 10, "7"]); }
    property var aeolian :          { toScale("aeolian",        [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 10, "7"]); }
    
    property var harmonicMajor :    { toScale("harmonicMajor",  [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 8, "6", 11, "7"]); }
    property var harmonicMinor :    { toScale("harmonicMinor",  [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 11, "7"]); }
    
    property var naturalMinor :    { toScale("naturalMinor",    [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 11, "7"]); } 
    
    property var pentatonicMajor :  { toScale("pentatonicMajor",[0, "1", 2, "2", 4, "3", 7, "5", 9, "6"]); }
    property var pentatonicMinor :  { toScale("pentatonicMinor",[0, "1", 3, "3", 5, "4", 7, "5", 10, "7"]); }

    function toScale(label, notes) {
        var chord = [];
        var all = [];
        ChordHelper.pushToNotes(chord, notes[0], notes[1]);
        for (var i = 0; i < notes.length; i = i + 2) {
            ChordHelper.pushToNotes(all, notes[i], notes[i + 1]);
        }

        var c = new ChordHelper.scaleClass([], chord, all);
        c.name=(label?qsTr(label):c.toString);
        return c;
    }

}
