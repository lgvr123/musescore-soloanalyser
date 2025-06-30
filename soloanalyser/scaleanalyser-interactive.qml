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
/*  - 1.0.1: Incorrect use of the color styles
/*  - 1.0.2: degrees 3, 5, 7 are now coloured as Chord note
/**********************************************/

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if a scale."
    version: "1.0.2"

    readonly property var pluginName: qsTr("Scale analyser")

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
        
        // Scale in score
        var last=getFromScore();
        if (last===null) {
            last={root: "C", scale: "ionian"};
        }
        select(lstScales, last.scale);
        var index = 0;
        for (var i = 0; i < lstRoots.model.length; i++) {
            if (lstRoots.model[i].root === last.root) {
                index = i;
                break;
            }
        }
        lstRoots.currentIndex = index;  

        txtCustom.text = last.custom;
        
     

    }

    property var _scales: [
            {value: "ionian",           data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 11, "7"]},
            {value: "dorian",           data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 9, "6", 10, "7"]},
            {value: "phrygian",         data: [0, "1", 1, "2", 3, "3", 5, "4", 7, "5", 8, "6", 10, "7"]},
            {value: "lydian",           data: [0, "1", 2, "2", 4, "3", 6, "4", 7, "5", 9, "6", 11, "7"]},
            {value: "mixolydian",       data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 10, "7"]},
            {value: "aeolian",          data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 10, "7"]},
            {value: "locrian",          data: [0, "1", 1, "2", 3, "3", 5, "4", 6, "5", 8, "6", 10, "7"]},
            {value: "harmMajor",        data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 8, "6", 11, "7"]},
            {value: "harmMinor",        data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 11, "7"]},
            {value: "melodicMinor",     data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 9, "6", 11, "7"]},
            {value: "pentaMajor",       data: [0, "1", 2, "2", 4, "3", 7, "5", 9, "6"]}                 ,
            {value: "pentaMinor",       data: [0, "1", 3, "3", 5, "4", 7, "5", 10, "7"]}                ,
            {value: "altered",          data: [0, "1", 1, "2", 3, "3", 4, "4", 6, "5", 8, "6", 10, "7"]},
            {value: "lydianDim",        data: [0, "1", 2, "2", 3, "3", 6, "4", 7, "5", 9, "6", 11, "7"]},
            {value: "lydianAug",        data: [0, "1", 2, "2", 4, "3", 6, "4", 8, "5", 9, "6", 11, "7"]},
            {value: "lydianDom",        data: [0, "1", 2, "2", 4, "3", 6, "4", 7, "5", 9, "6", 10, "7"]},
            // {value: "dimnishedWhole", data: [0, "1", 2, "9", 3, "3", 5, "4", 6, "#11", 8, "#5", 9, "6", 11, "7"]},
            // {value: "dimnishedHalf",  data: [0, "1", 1, "b9", 3, "#9", 4, "3", 6, "#11", 7, "5", 9, "6", 10, "7"]},
            {value: "Oct(0,1)",         data: [0,1,3,4,6,7,9,10]},
            {value: "Oct(0,2)",         data: [0,1,3,4,6,7,9,10]},
            {value: "Whole tone",       data: [0,2,4,6,8,10]},
            {value: "Hex(0,1)",         data: [0,1,4,5,8,9]},
            {value: "Hex(0,3)",         data: [0,3,4,7,8,11]},
            {value: "custom"},
    ]
    
    property var _roots: [{
            "root": 'C',
            "major": false, // we consider C as a flat scale, sothat a m7 is displayed as B♭ instead of A♯
            "minor": false
        }, {
            "root": 'D♭/C♯',
            "major": false,
            "minor": true
        }, {
            "root": 'D',
            "major": true,
            "minor": false
        }, {
            "root": 'E♭/D♯',
            "major": false,
            "minor": true
        }, {
            "root": 'E',
            "major": true,
            "minor": true
        }, {
            "root": 'F',
            "major": false,
            "minor": false
        }, {
            "root": 'F♯/G♭',
            "major": true,
            "minor": true
        }, {
            "root": 'G',
            "major": true,
            "minor": false
        }, {
            "root": 'A♭/G♯',
            "major": false,
            "minor": true
        }, {
            "root": 'A',
            "major": true,
            "minor": true
        }, {
            "root": 'B♭/A♯',
            "major": false,
            "minor": false
        }, {
            "root": 'B',
            "major": true,
            "minor": true
        }
    ]



    function select(control, value) {
        
        
        
        try {
        var index = 0;
        for (var i = 0; i < control.model.length; i++) {
            console.log(")))"+i+") "+control.model[i].value +" <-> "+value);  
            if (control.model[i].value == value) {
                index = i;
                break;
            }
        }
        control.currentIndex = index;
        } catch (err) {
            console.log("fail to select value "+value+"\n"+err);
        }

    }
    function get(control) {
        return control.model[control.currentIndex].value;

    }
    
    function storeInScore(root,scale) {
        var last={root: root, scale: scale, custom: txtCustom.text};
        curScore.setMetaTag('Plugin-ScaleAnalyser', JSON.stringify(last));
        
    }

    function getFromScore() {
        var json=curScore.metaTag('Plugin-ScaleAnalyser');
        console.log("config from score: "+json);
        if (json===undefined || json==="") return null;
        var value=JSON.parse(json);
        if (value.root!==undefined && value.scale!==undefined) 
            return {root: value.root, scale: value.scale, custom: value.custom};
        else return null;
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
        property var scaleName: "ionian"
    }

    GridLayout {
        id: mainRow
        //anchors.fill: parent
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 10

        columns: 2
        columnSpacing: 5

        GroupBox {
            title: qsTranslate("GenericUI", "Rendering options...")
            //Layout.margins: 5
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            GridLayout {
                columnSpacing: 5

                rowSpacing: 10
                columns: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                NiceLabel {
                    text: qsTranslate("GenericUI", "Note coloring  :")+" "
                    //Tooltip.text : qsTranslate("GenericUI", "Color all notes or only the ones defined by the chord");
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillHeight: false
                }

                NiceComboBox {
                    //Layout.fillWidth : true
                    id: lstColorNote
                    model: [{
                            'value': "none",
                            'text': qsTranslate("GenericUI", "None - Don't color notes")
                        }, {
                            'value': "chord",
                            'text': qsTranslate("GenericUI", "Chord - Color the notes present in the chord")
                        }, {
                            'value': "all",
                            'text': qsTranslate("GenericUI", "Scale - Color the notes defined by the scale")
                        }
                    ]

                }

                NiceLabel {
                    text: qsTranslate("GenericUI", "Note name  :")+" "
                    //Tooltip.text : qsTranslate("GenericUI", "Name all notes or only the ones defined by the chord");
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillHeight: false
                }

                NiceComboBox {
                    //Layout.fillWidth : true
                    id: lstNameNote
                    model: [{
                            'value': "none",
                            'text': qsTranslate("GenericUI", "None - Don't name notes")
                        }, {
                            'value': "chord",
                            'text': qsTranslate("GenericUI", "Chord - Name the notes present by the chord")
                        }, {
                            'value': "all",
                            'text': qsTranslate("GenericUI", "Scale - Name the notes defined by the scale")
                        }
                    ]

                }

                NiceLabel {
                    text: qsTranslate("GenericUI", "Root :")+" "
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
                    text: qsTranslate("GenericUI", "Bass :")+" "
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
                    text: qsTranslate("GenericUI", "Chord :")+" "
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
                    text: qsTranslate("GenericUI", "Altered :")+" "
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
                    text: qsTranslate("GenericUI", "Scale :")+" "
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

                NiceLabel {
                    text: qsTranslate("GenericUI", "Text form  :")+" "
                }

                NiceComboBox {
                    id: lstFormText
                    model: [{
                            value: "fingering",
                            text: qsTranslate("GenericUI", "As fingering")
                        }, {
                            value: "lyrics",
                            text: qsTranslate("GenericUI", "As lyrics")
                        }
                    ]

                }
            }
        }

        GroupBox {
            title: qsTranslate("GenericUI", "Analyze options...")
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            GridLayout {
                columnSpacing: 5

                rowSpacing: 10
                columns: 2

                Layout.fillHeight: true
                Layout.fillWidth: true
                
                Label {
                    text: qsTr("Root note")
                }

                ComboBox {
                    id: lstRoots
                    model: _roots

                    implicitHeight: 10
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false

                    currentIndex: 0

                    displayText: model[currentIndex].root

                    contentItem: Text {
                        text: lstRoots.displayText
                        verticalAlignment: Qt.AlignVCenter
                        padding: 5
                    }

                    delegate: ItemDelegate { // requiert QuickControls 2.2
                        contentItem: Text {
                            text: modelData.root
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: lstScales.highlightedIndex === index

                    }
                }

                Label {
                    text: qsTr("Scale type")
                }
                
                ComboBox {
                    id: lstScales
                    model: _scales

                    implicitHeight: 10
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 30
                    Layout.fillWidth: false

                    currentIndex: 0

                    displayText: qsTr(model[currentIndex].value)

                    contentItem: Text {
                        text: lstScales.displayText
                        verticalAlignment: Qt.AlignVCenter
                        padding: 5
                    }

                    delegate: ItemDelegate { // requiert QuickControls 2.2
                        contentItem: Text {
                            text: qsTr(modelData.value)
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: lstScales.highlightedIndex === index

                    }
                }
                Label {
                    text: qsTr("Custom")
                }
                TextField {
                    id: txtCustom
                    text: ""
                    placeholderText: "Tone row. E.g. 0,5,2,4,8,7"
                    Layout.fillWidth: true
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

                text: qsTranslate("GenericUI", "Reset")
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
                ToolTip.text: qsTranslate("GenericUI", "Reset to default values")

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
                    text: qsTranslate("GenericUI", "Apply")
                    DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                }
                Button {
                    text: qsTranslate("GenericUI", "Clear")
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


                    // save values
                    // AUTOMATIC

                    // execute
                    var root = _roots[lstRoots.currentIndex].root;
                    var scaleData = _scales[lstScales.currentIndex];
                    storeInScore(root,scaleData.value);
                    root=root.replace(/♯/gi, '#').replace(/♭/gi, "b");
                    if (root.includes("/")) {
                        var parts = root.split("/");
                        root=parts[0];
                    }
                    
                    var scale;
                    if (scaleData.value == "custom") {
                        // var data = scaleData.data;
                        var tones;
                        var custom=txtCustom.text;
                        custom=custom.match(/^\s*\[?((\d+\s*,??\s*)+),?\]?\s*$/);
                        if(custom.length>=2) {
                            tones=custom[1].split(/\s*,\s*/);
                            tones=tones
                                .map(function(e) { return parseInt(e); })
                                .filter(function(e) { return !isNaN(e); });
                        } else {
                            console.log("Cannot find a correct tone row in "+ txtCustom.text);
                        }
                        var data=[];
                        var color = rootColorChosser.color;
                        // var color = JSON.parse(JSON.stringify(rootColorChosser.color));
                        for (var i = 0; i < tones.length; i++) {
                            var fgColor = "#" +
                                floatToHex(color.r) +
                                floatToHex(color.g) +
                                floatToHex(color.b);

                            console.log("Colour: " + color.hslLightness + " => " + fgColor);

                            data.push(tones[i]);
                            data.push(String(i+1)); // convertir en string
                            data.push(fgColor);

                            color.hslLightness = color.hslLightness * 0.9;
                        }
                        console.log(data);
                        scale = toScale(qsTr(scaleData.value), data);
                    } else {
                        scale = toScale(qsTr(scaleData.value), scaleData.data);
                    }

                    console.log(root + " " + scale);
                    console.log("--------------------------------");
                    doScaleAnalyse(root, scale);
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

    function floatToHex(f) {
    //    console.log("floatToHex: pour "+f);
        var t = ((f * 255) | 0).toString(16);
        t = t.padStart(2, "0");
        return t;
    }

    ColorDialog {
        id: colorDialog
        title: qsTranslate("GenericUI", "Please choose a color")
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
        var range = getRange();
        if (range === null)
            return;
        
        var byTrack = new Array(range.trackMax + 1);
        var chords = [];
        var _scale = scale;
        var _root = ChordHelper.getRootAccidental(root);

        // console.log("Scale: " + _scale);
        // console.log("Root: " + _root);
        // console.log("Root.tcp: " + _root.tpc);
        // console.log("Root.tcp.pitch: " + _root.tpc.pitch);
        // console.log("Root.tcp.accidental: " + _root.tpc.accidental);
        // console.log("Root.tcp.raw: " + _root.tpc.raw);

        // On simule un seul accord valable depuis le tick 0 jusqu'à la fin ...
        chords.push({ 
            tick: 0,
            chord: new ChordHelper.chordClass(_root.tpc, _scale.label, _scale)
        });

        console.log("Chord: " + chords[0].chord);

        // ... et valable sur tous les tracks
        for (var track = 0; track <= range.trackMax; track++) {
            byTrack[track]=chords;
        }

        var colorNotes = settings.colorNotes; // none|chord|all
        var nameNotes = settings.nameNotes; // none|chord|all

        pushAnalyse(range, colorNotes, nameNotes, byTrack, true);

        }
    function pushAnalyse(range, colorNotes, nameNotes, byTrack, lookAhead) {
        

        // Config
        var rootColor = settings.rootColor;
        var bassColor = settings.bassColor;
        var errorColor = settings.errorColor;
        var scaleColor = settings.scaleColor;
        var chordColor = settings.chordColor;
        var alteredColor = (settings.alteredColor) ? settings.alteredColor : defAlteredColor
        
        var textType = (settings.textType) ? settings.textType : defTextType
        
        // if configured for doing nothing (no colours, no names) we use the default values
        if (colorNotes == "none" && nameNotes == "none") {
            colorNotes = defColorNotes;
            nameNotes = defNameNotes;
        }

        // Processing
        curScore.startCmd();
        var cursor = curScore.newCursor();

        // processing
        var segMin = range.segMin;
        var segMax = range.segMax;
        var trackMin = range.trackMin;
        var trackMax = range.trackMax;
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
            var values = (byTrack[track] !== undefined) ? byTrack[track] : [];
            var step = lookAhead?0:-1; // if we lookAhead, we start from the first chord, even if it is further that start segment.

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
                            
                            var sRole= curChord.getScaleNote(p);
                            
                            console.log("SCALE ROLE found for "+p+": "+(sRole?sRole:"not found!!"));
                            
                            var color = sRole?sRole.color:undefined; // undefined s'il faut utiliser les couleurs par défaut
                            
                            if (p == 0) {
                                if (typeof color === "undefined") color = rootColor;
                                degree = "1";
                            } else {
                                var role = curChord.getChordNote(p);

                                if (role !== undefined) {
                                    console.log("ROLE FOUND : " + role.note + "-" + role.role);
                                    degree = role.role;
                                    if (typeof color === "undefined") color = (curChord.bass != null && p == curChord.bass.key) ? bassColor : ((degree.indexOf("b") == 0) || (degree.indexOf("#") == 0)) ? alteredColor : chordColor;
                                } else if (curChord.outside.indexOf(p) >= 0) {
                                    color = errorColor;
                                } else if (curChord.keys.indexOf(p) >= 0 && (colorNotes === "all")) {
                                    if (typeof color === "undefined")color = scaleColor;
                                } else {
                                    if (typeof color === "undefined") color = "black";
                                }

                                // Option de donner un nom à toutes les notes
                                if (nameNotes === "all" && degree === null) {

                                    if (sRole !== undefined) {
                                        console.log("ROLE FOUND in SCALE: " + sRole.note + "-" + sRole.role);
                                        degree = sRole.role;
                                    } else {
                                        degree = "✗";
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
                            //Core.writeDegree(note, null); // 1.0.1 Si l'utilisateur veut nettoyer, qu'il fasse un Clean d'abord.
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

    function getRange() {
        // Selection
        var chords = Core.getSelection();
        if (!chords || (chords.length == 0))
            return null;

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

        return {
            segMin: segMin,
            segMax: segMax,
            trackMin: trackMin,
            trackMax: trackMax,
        }

    }
    /**
    * Crée un objet <code>scaleClass</code> de manière sommaire:
    * @param shortname une valeur unique représentant cette gamme.
    *   Ce nom sera à la fois utilisé comme clé de traduction et pour sauvegarder au niveau de la partition la dernière gamme utilisée
    * @param notes une tableau des notes appartenant à la gamme, avec en alternance la note ([0,11]) et le rôle.
    *   E.g. [0, 2, 4, 7, ..]
    *   E.g. [0,"1", 2,"2", 4,"3", 7,"5", ..]
    *   E.g. [0,"1", "#aabbcc", 2,"2", "#ccddee", 4,"3", "#001122", 7,"5", "#334455", ..]
    */
    function toScale(shortname, notes) {
        var chord = [];
        var all = [];
        var keys =[];
        
        var wName=(notes.length>=2)?(typeof notes[1]==="string"):false;
        var wColor=(wName && notes.length>=3)?((""+notes[2]).substr(0,1)==="#"):false;
        
        var inc=(wName?(wColor?3:2):1);
        
        ChordHelper.pushToNotes(chord, notes[0], notes[1], (wColor?notes[2]:undefined));
        for (var i = 0; i < notes.length; i = i + inc) {
            var degree=notes[i];
            var label=wName?notes[i+1]:i;
            var color=wColor?notes[i+2]:undefined;
            keys.push(degree);
            ChordHelper.pushToNotes(all, degree, label,color);
            if (label.includes("3") || label.includes("5") || label.includes("7")) {
                ChordHelper.pushToNotes(chord, degree, label,color);
            }
            
        }
        
        // // Looking for all notes
        // for (var n = 1; n < 12; n++) {
            // if ((ChordHelper.getNote(allnotes, n) === undefined)) {
                // var at;
                // var dn = (n3 === null && (at = [3, 4].indexOf(n)) >= 0) ? ["m3", "M3"][at] : ChordHelper.default_names[n];
                // ChordHelper.pushToNotes(allnotes, n, dn);
            // }
        // }
        var c = new ChordHelper.scaleClass(keys, chord, all);
        c.value=shortname;
        c.label=(shortname?qsTr(shortname):c.toString());
        return c;
    }

}
