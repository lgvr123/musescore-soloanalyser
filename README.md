# Solo Analyser plugin for MuseScore 3.x and 4.x
The *Solo Analyser plugin* will highlight key notes in a Solo score.
<p align="center"><img src="/soloanalyser/logoSoloAnalyser.png" Alt="logo" width="300" />&nbsp;<img src="/soloanalyser/logoChordAnalyser.png" Alt="logo" width="300" /></p>

![SoloAnalyser in action](/demo/soloanalyzer-demo.png)

## What's new in 1.5.0 ?
* CR: New color mode "outside" (draft)
* CR: New ToneSet support (e.g. "T4[0,1,3,4]" ≡ E,F,G,Ab -- Additional notation E[0,1,3,4] = Set [0,1,3,4] starting from E, ≡ E,F,G,Ab)
* CR: New option for not using chords preceeding the selection
* CR: Better treatment of lack of chord symbols and uparsable chord symbols (e.g. chord symbols for files just imported from MusicXML does not work unless the chords are manually edited).
* CR: Allow for both b9 and #9 together (same for 11 and 13)
* CR: New 10th chords (e.g. Cm7(10))
* Bug: Chord Symbol attached to Fret Diagrams were not used
* Bug: Wrong usage the lookAhead stored setting
* Bug: b5 and #5 chords wrongly analysed
* Bug: Addition of 7th, 9th, 11th in 11th and 13th chords
* Bug: Wrong analyse of ## chords
* Bug: Wrong analyse when not all chords are on the same voice
* Bug: A Chord Symbol is not used in the analyse when the track 0 has nothing defined at that segment's tick.

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

## Download and Install ##
Download the [last stable version](https://github.com/lgvr123/musescore-soloanalyser/releases)
For installation see [Plugins](https://musescore.org/en/handbook/3/plugins).
### Remark
The whole zip content (so the `soloanalyser\ ` folder) must be unzipped **as such** in your plugin folder. <br/>
If you had a previous version installed, please delete the previous `soloanalyser*.qml` and `chordnalyser.qml`files to avoid conflicts.

## Support of MS4.0
**SUPPORTED**

## Sponsorship ##
If you appreciate my plugins, you can support and sponsor their development on the following platforms:
[<img src="/support/Button-Tipeee.png" alt="Support me on Tipee" height="50"/>](https://www.tipeee.com/parkingb) 
[<img src="/support/paypal.jpg" alt="Support me on Paypal" height="55"/>](https://www.paypal.me/LaurentvanRoy) 
[<img src="/support/patreon.png" alt="Support me on Patreon" height="25"/>](https://patreon.com/parkingb)

And also check my **[Zploger application](https://www.parkingb.be/zploger)**, a tool for managing a library of scores, with extended MuseScore support.

## IMPORTANT
NO WARRANTY THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW THE AUTHOR WILL BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF THE AUTHOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
