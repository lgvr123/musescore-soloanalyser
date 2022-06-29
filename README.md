# Solo Analyser plugin for MuseScore 3.x
*Solo Analyser plugin for MuseScore 3.x* will highlight key notes in a Solo score.

![SoloAnalyser in action](/demo/soloanalyzer-demo.png)

## What's new in 1.4.2 ?
* [New] Look ahead option, useful for anacrusis
* [Correction] Invalid analysis for some transposing instruments
* [Correction] Issue when the selection was too far in the score 
* [Correction] Issue when the first note to analyse is far beyond the first chord symbol

## Plugins

### SoloAnalyser ### 
The *SoloAnalyser* comes in 2 flavours:
- **A plugin without interaction**: it colours and names the selected note automatically without manual intervention,
- **An interactive plugin**: you can select the options for the solo analysing and rendering. It acts also as a default behaviour management for the non-interactive plugin.

Important notes are the one defined in chord played. It uses the *Chord Symbols* to identify those notes.

### ChordAnalyser ### 
*ChordAnalyser* is an extra plugin provided to explain and describe the notes of a *Chord Symbol*. It also gives a (default) scale matching this chord.
The plugin works in 2 ways:
- either **automatically**, based on a selected chord symbol,
- or **manually**, where the user can enter manually a valid chord symbol to analyse.

### Important remark about transposing instruments ###
*Solo Analyser* works well with transposing instruments may MuseScore be in *Concert pitch* or in *Written pitch*.

Nevertheless, when analysing a complete score with transposing and non-transposing instruments, it is recommended to switch MuseScore to *Concert pitch* to allow a correct analyse.

## Download ##
Download the [last stable version](https://github.com/lgvr123/musescore-soloanalyser/releases)

## Installation
* If using MuseScore version 3 then download the plugin and unzip it.
* Install using the instructions in the MuseScore 3.x Handbook, which typically involves copying the QML file to the local MuseScore Plugin directory.
* Open MuseScore and navigate to 'Plugins' -> 'Plugin Manager' to enable both plugins. Tick the box against 'soloanalyser' and ''soloanalyser-interactive' and apply with 'OK'.


## IMPORTANT
NO WARRANTY THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW THE AUTHOR WILL BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
