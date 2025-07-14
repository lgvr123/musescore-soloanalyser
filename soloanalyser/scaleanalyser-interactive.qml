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
/*  - 1.1.0: Custom scales and tone rows
/*  - 1.1.0: Color shade coloring mode
/*  - 1.1.0: Merge note analyse function from Core.js and scaleAnalyser
/**********************************************/

// TODO: permettre de choisir une couleur, autre que les couleurs du mode "Accord"

MuseScore {
    menuPath: "Plugins.Solo Analyser." + pluginName
    description: "Colors and names the notes based on their role if a scale."
    version: "1.1.0"

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

        lstColorNote.select(settings.colorNotesScale);
        lstNameNote.select(settings.nameNotes);
        lstFormText.select(settings.textType);

        rootColorChosser.color = settings.rootColor;
        bassColorChosser.color = settings.bassColor;
        chordColorChosser.color = settings.chordColor;
        scaleColorChosser.color = settings.scaleColor;
        alteredColorChosser.color = settings.alteredColor;
        // errorColorChosser.color = settings.errorColor;

        // Scale in score
        lasts = getFromScore();
        var last;
        if (lasts && lasts.length>=1) {
            last=lasts[0];
        } else {
            lasts=[];
            last = {
                root: "C",
                scale: "ionian"
            };
        }
        
        pushToGUI(last);

    }

    property var lasts: [
        /*{"root":"F","scale":"custom","custom":"0,2,4,6,8,t", "color": "#aabbff", "scaleLabel": qsTr("custom")},
        {"root":"G","scale":"lydianDom", "color": "#ffbbaa", "scaleLabel": qsTr("lydianDom")},
        {"root":"A♭/G♯","scale":"mixolydian", "color": "#ffbbaa", "scaleLabel": qsTr("mixolydian")},
    */]

    property var _scales: [{
            value: "ionian",
            data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 11, "7"]
        }, {
            value: "dorian",
            data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 9, "6", 10, "7"]
        }, {
            value: "phrygian",
            data: [0, "1", 1, "2", 3, "3", 5, "4", 7, "5", 8, "6", 10, "7"]
        }, {
            value: "lydian",
            data: [0, "1", 2, "2", 4, "3", 6, "4", 7, "5", 9, "6", 11, "7"]
        }, {
            value: "mixolydian",
            data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 9, "6", 10, "7"]
        }, {
            value: "aeolian",
            data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 10, "7"]
        }, {
            value: "locrian",
            data: [0, "1", 1, "2", 3, "3", 5, "4", 6, "5", 8, "6", 10, "7"]
        }, {
            value: "harmMajor",
            data: [0, "1", 2, "2", 4, "3", 5, "4", 7, "5", 8, "6", 11, "7"]
        }, {
            value: "harmMinor",
            data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 8, "6", 11, "7"]
        }, {
            value: "melodicMinor",
            data: [0, "1", 2, "2", 3, "3", 5, "4", 7, "5", 9, "6", 11, "7"]
        }, {
            value: "pentaMajor",
            data: [0, "1", 2, "2", 4, "3", 7, "5", 9, "6"]
        }, {
            value: "pentaMinor",
            data: [0, "1", 3, "3", 5, "4", 7, "5", 10, "7"]
        }, {
            value: "altered",
            data: [0, "1", 1, "2", 3, "3", 4, "4", 6, "5", 8, "6", 10, "7"]
        }, {
            value: "lydianDim",
            data: [0, "1", 2, "2", 3, "3", 6, "4", 7, "5", 9, "6", 11, "7"]
        }, {
            value: "lydianAug",
            data: [0, "1", 2, "2", 4, "3", 6, "4", 8, "5", 9, "6", 11, "7"]
        }, {
            value: "lydianDom",
            data: [0, "1", 2, "2", 4, "3", 6, "4", 7, "5", 9, "6", 10, "7"]
        },
        // {value: "dimnishedWhole", data: [0, "1", 2, "9", 3, "3", 5, "4", 6, "#11", 8, "#5", 9, "6", 11, "7"]},
        // {value: "dimnishedHalf",  data: [0, "1", 1, "b9", 3, "#9", 4, "3", 6, "#11", 7, "5", 9, "6", 10, "7"]},
        {
            value: "Oct(0,1)",
            data: [0, 1, 3, 4, 6, 7, 9, 10]
        }, {
            value: "Oct(0,2)",
            data: [0, 1, 3, 4, 6, 7, 9, 10]
        }, {
            value: "wholeTone",
            data: [0, 2, 4, 6, 8, 10]
        }, {
            value: "Hex(0,1)",
            data: [0, 1, 4, 5, 8, 9]
        }, {
            value: "Hex(0,3)",
            data: [0, 3, 4, 7, 8, 11]
        }, {
            value: "custom"
        },
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
    
    


    function storeInScore(root, scale) {
        var current = {
            root: root,
            scale: scale,
            custom: txtCustom.text,
            color: rootColorChosser.color.toString(),
        };
        
        console.log(JSON.stringify(current));
        
        var saved=getFromScore();
        
        for(var i=saved.length-1;i>=0;i--) {
            var s=saved[i];
            delete s.scaleLabel; // je ne veux pas sauvegarder le libellé
            if (s.root==current.root 
            && s.scale==current.scale 
            && (current.scale!="custom" || s.custom==current.custom )) {
                saved.splice(i, 1);
            }
            
        }
        
        saved.unshift(current);
        
        saved.length = Math.min(saved.length, 5); // on ne garde que 5 éléments
        
        curScore.setMetaTag('Plugin-ScaleAnalyser', JSON.stringify(saved));
        
        lasts=saved.map(function(l) {
            l.scaleLabel=qsTr(l.scale);
            return l;
        }); // updating the ComboBox
        lstLasts.currentIndex=0;

    }

    function getFromScore() {
        var json = curScore.metaTag('Plugin-ScaleAnalyser');
        console.log("config from score: " + json);
        if (json === undefined || json === "")
            return [];
        var values = JSON.parse(json);
        if (!Array.isArray(values)) {
            values=[values];
        }
        values=values.filter(function(v) {
            console.log("Last :"+JSON.stringify(v));
            return v.root !== undefined && v.scale !== undefined
        }).map(function(v) {
            return {
                root: v.root,
                scale: v.scale,
                custom: v.custom,
                color: v.color,
                scaleLabel: qsTr(v.scale)
            };
        });
        
        return values;
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
        property var colorNotesScale: Core.defColorNotes
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
            Layout.margins: 10
            
            GridLayout {
                columnSpacing: 5

                rowSpacing: 10
                columns: 2

                Layout.fillHeight: true
                Layout.fillWidth: true

                NiceLabel {
                    text: qsTranslate("GenericUI", "Note coloring  :") + " "
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
                        }, {
                            'value': "shade",
                            'text': qsTranslate("GenericUI", "Shade - Color shade from the root note")
                        }
                    ]

                }

                NiceLabel {
                    text: qsTranslate("GenericUI", "Note name  :") + " "
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
                    text: qsTranslate("GenericUI", "Root :") + " "
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
                    text: qsTranslate("GenericUI", "Bass :") + " "
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
                    text: qsTranslate("GenericUI", "Chord :") + " "
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
                    text: qsTranslate("GenericUI", "Altered :") + " "
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
                    text: qsTranslate("GenericUI", "Scale :") + " "
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
                    text: qsTranslate("GenericUI", "Text form  :") + " "
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

        ColumnLayout {
            // Layout.column: 2
            
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.margins: 10
            
        
            GroupBox {
                title: qsTranslate("GenericUI", "Analyze options...")
                Layout.alignment: Qt.AlignTop | Qt.AlignRight
                Layout.fillWidth: true
                
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

                    NiceComboBox {
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
                            elide: Text.ElideRight
                        }

                        delegate: ItemDelegate { // requiert QuickControls 2.2
                            contentItem: Text {
                                text: qsTr(modelData.value)
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
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
                        enabled: lstScales.get() == "custom"
                    }

                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft    
                
                Label {
                    text: qsTr("Last used")
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft    
                }

                ComboBox {

                    id: lstLasts
                    model: lasts
                    
                    Layout.minimumWidth: 300
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft    
                    

                    delegate: ItemDelegate { // requiert QuickControls 2.2
                        highlighted: lstLasts.highlightedIndex === index
                        width: lstLasts.width
                        contentItem: LastDelegateComponent {
                            id: ldc
                            currentValue: modelData
                        }

                    }
                    contentItem: LastDelegateComponent {
                            height: lstLasts.height
                            currentValue: lstLasts.model[lstLasts.currentIndex]
                        }
                        
                    onActivated: {
                        pushToGUI(lstLasts.model[lstLasts.currentIndex]);
                    }
                }
            }
            
            /*Rectangle { // spacer // DEBUG Item/Rectangle
                color: "yellow"
                Layout.column: 2
                implicitWidth: 10
                Layout.fillHeight: true
            }*/
        }
        
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
                    settings.colorNotesScale = Core.defColorNotes;
                    settings.nameNotes = Core.defNameNotes;
                    settings.textType = Core.defTextType;

                    lstColorNote.select(settings.colorNotesScale);
                    lstNameNote.select(settings.nameNotes);
                    lstFormText.select(settings.textType);

                    rootColorChosser.color = settings.rootColor;
                    bassColorChosser.color = settings.bassColor;
                    chordColorChosser.color = settings.chordColor;
                    scaleColorChosser.color = settings.scaleColor;
                    alteredColorChosser.color = settings.alteredColor;
                    // errorColorChosser.color = settings.errorColor;

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

                    settings.colorNotesScale = lstColorNote.get();
                    settings.nameNotes = lstNameNote.get();
                    settings.textType = lstFormText.get();

                    // save values
                    // AUTOMATIC

                    // execute
                    var root = _roots[lstRoots.currentIndex].root;
                    var scaleData = _scales[lstScales.currentIndex];
                    storeInScore(root, scaleData.value);
                    root = root.replace(/♯/gi, '#').replace(/♭/gi, "b");
                    if (root.includes("/")) {
                        var parts = root.split("/");
                        root = parts[0];
                    }

                    var scale, data;
                    if (scaleData.value == "custom") {
                        // TODO : on duplique trop de code de Core.chordForPitchSet
                        // uniquement pcq on veut ajouter des couleurs
                        var custom = txtCustom.text;
                        custom=custom.replace(/t/g,'10').replace(/e/g,'11');
                        custom = custom.match(/^\s*(\[{)?((\d+\s*,??\s*)+),?(\]})?\s*$/);
                        if (custom && custom.length >= 4) {
                            console.log(custom);
                            data = custom[2].split(/\s*,\s*/);
                            data = data
                                .map(function (e) {
                                return parseInt(e);
                            })
                                .filter(function (e) {
                                return !isNaN(e);
                            });
                        } else {
                            // TODO Meilleur message
                            console.log("Cannot find a correct tone row in " + txtCustom.text);
                        }
                    } else {
                        data=scaleData.data;
                    }
                    scale = toScale(qsTr(scaleData.value), data);

                    console.log(root + " " + scale);
                    console.log("--------------------------------");
                    doScaleAnalyse(root, scale);
                    //Qt.quit();
                    //mainWindow.parent.Window.window.close();
                }
                onClicked: {
                    console.log("~~~~~~~~~~~~" + button.text + "~~~~~~~~~~~~");
                    if (button == btnClear) {
                        Core.clearAnalyse();
                        //Qt.quit();
                        //mainWindow.parent.Window.window.close();
                    }
                }
                onRejected: {
                    //Qt.quit()
                    mainWindow.parent.Window.window.close();
                }

            }
        }
        

    }
    
    function pushToGUI(last) {

        lstScales.select(last.scale);

        var index = 0;
        for (var i = 0; i < lstRoots.model.length; i++) {
            if (lstRoots.model[i].root === last.root) {
                index = i;
                break;
            }
        }
        lstRoots.currentIndex = index;

        txtCustom.text = last.custom ? last.custom : "";

        if( last.color) rootColorChosser.color = last.color;

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

        var _scale = scale;
        var _root = ChordHelper.getRootAccidental(root);

        var chord1=new ChordHelper.chordClass(_root.tpc, _scale.label, _scale)

        console.log("Chord: " + chord1);

        var colorNotes = settings.colorNotesScale; // none|chord|all|shade
        var nameNotes = settings.nameNotes; // none|chord|all

        // analyse du type de sélection à la quelle on a à faire
        // RANGE ou SÉLECTION
        var score = curScore;
        var chords = SelHelper.getChordsRestsFromCursor();
        var notes;
    
        if (chords && (chords.length > 0)) {
            console.log("CHORDRESTS FOUND FROM CURSOR");
        } else {
            notes=SelHelper.getNotesFromSelection();
            if (notes && (notes.length > 0)) {
                console.log("NOTES FOUND FROM SELECTION");
                pushSelectionAnalyse(notes, colorNotes, nameNotes, chord1);
                return;
            } else {
            chords = SelHelper.getChordsRestsFromScore();
            console.log("CHORDRESTS FOUND FROM ENTIRE SCORE");
            }
        }

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

        var range = {
            segMin: segMin,
            segMax: segMax,
            trackMin: trackMin,
            trackMax: trackMax,
        };


        pushRangeAnalyse(range, colorNotes, nameNotes, chord1);

    }
    
    function pushSelectionAnalyse(notes, colorNotes, nameNotes, chord1) {
        curScore.startCmd();
        for(var i=0;i<notes.length;i++) {
            var note=notes[i];
            var asLyrics=[];
            Core.analyseNote(note,colorNotes, nameNotes, chord1, asLyrics);
            // TODO faire qqch si on a demandé l'analyse sous forme de Lyrics
        }
        curScore.endCmd();
    }
    
    function pushRangeAnalyse(range, colorNotes, nameNotes, chord1) {


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
            while (segment && segment.tick <= segMax) {
                // getting the right chord diagram
                var curChord = chord1;
                console.log(track + "/" + segment.tick + " => chord = " + ((curChord === null) ? "/" : curChord.name ));

                // retrieving the element on this track
                var el = cursor.element;
                if ((el !== null) && (el.type === Element.CHORD)) {

                    // Looping in the chord notes
                    var notes = el.notes;
                    var asLyrics = [];
                    for (var j = 0; j < notes.length; j++) {
                        var note = notes[j];
                        Core.analyseNote(note,colorNotes, nameNotes, curChord, asLyrics);
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
    
    /**
     * Crée un objet <code>scaleClass</code> de manière sommaire:
     * @param shortname une valeur unique représentant cette gamme.
     *   Ce nom sera à la fois utilisé comme clé de traduction et pour sauvegarder au niveau de la partition la dernière gamme utilisée
     * @param notes une tableau des notes appartenant à la gamme, avec en alternance la note ([0,11]) et le rôle.
     *   E.g. [0, 2, 4, 7, ..]
     *   E.g. [0,"1", 2,"2", 4,"3", 7,"5", ..]
     *   E.g. [0,"1", "#aabbcc", 2,"2", "#ccddee", 4,"3", "#001122", 7,"5", "#334455", ..]
     */
    // TODO : on duplique trop de code de Core.chordForPitchSet
    // uniquement pcq on veut ajouter des couleurs
    function toScale(shortname, notes) {
        var chord = [];
        var all = [];
        var keys = [];
        
        var shade=(lstColorNote.get()==="shade");
        var rcColor=rootColorChosser.color;
        var sColor=Qt.rgba(rcColor.r,rcColor.g,rcColor.b,rcColor.a); // Clone the color to not affect the color picker
        sColor.hslLightness = sColor.hslLightness * 1,2345; // on part de plus clair (telle que la 3ème note soit à la couleur demandée)

        var wName = (notes.length >= 2) ? (typeof notes[1] === "string") : false;
        var wColor = (wName && notes.length >= 3) ? (("" + notes[2]).substr(0, 1) === "#") : false;

        var inc = (wName ? (wColor ? 3 : 2) : 1);

        ChordHelper.pushToNotes(chord, notes[0], notes[1], (wColor ? notes[2] : undefined));
        for (var i = 0; i < notes.length; i = i + inc) {
            var degree = notes[i];
            var label = wName ? notes[i + 1] : "" + i;
            var color = wColor ? notes[i + 2] : undefined;
            if (shade) {
                color="#" +
                    floatToHex(sColor.r) +
                    floatToHex(sColor.g) +
                    floatToHex(sColor.b);
                sColor.hslLightness = sColor.hslLightness * 0.9;
            }
            keys.push(degree);
            ChordHelper.pushToNotes(all, degree, label, color);
            if (label.includes("3") || label.includes("5") || label.includes("7")) {
                ChordHelper.pushToNotes(chord, degree, label, color);
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
        c.value = shortname;
        c.label = (shortname ? qsTr(shortname) : c.toString());
        return c;
    }

    SystemPalette { id: sysActivePalette; colorGroup: SystemPalette.Active }

}