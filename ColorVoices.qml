//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles 'ozcaveman' Cave (charlesweb@optusnet.com.au)
//  Copyright (C)2014 Jörn 'heuchi' Eichler (joerneichler@gmx.de)
//  Copyright (C)2019 Johan 'jeetee' Temmerman (musescore@jeetee.net)
//  Copyright (C)2012-2024 Joachim 'Jojo' Schmitz (jojo@schmitz-digital.de)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.9
//import QtQuick.Dialogs 1.2
//import Qt.labs.settings 1.0
import MuseScore 3.0

MuseScore {
   version:  "4.4"
   description: "This plugin colors the chords and rests of each voice"
   menuPath: "Plugins.Notes.Color Voices"

   id: colorvoice
   //4.4 title: "Color Voices"
   //4.4 thumbnailName: "color_notes.png"
   //4.4 categoryCode: "color-notes"
   Component.onCompleted : {
      if (mscoreMajorVersion >= 4 && mscoreMinorVersion <= 3) {
         colorvoice.title = "Color Voices";
         colorvoice.thumbnailName = "color_notes.png";
         colorvoice.categoryCode = "color-notes";
      }
   }


   MessageDialog {
      id: versionError
      visible: false
      title: qsTr("Unsupported MuseScore Version")
      text: qsTr("This plugin needs MuseScore 3.0.2 or later")
      onAccepted: {
         (typeof(quit) === 'undefined' ? Qt.quit : quit)()
      }
   }

	Settings {
		id: msSetVoice1
		category: mscoreMajorVersion >= 4 ? "engraving/colors/voice1" : "ui/score/voice1"
		property color color
	}
	Settings {
		id: msSetVoice2
		category: mscoreMajorVersion >= 4 ? "engraving/colors/voice2" : "ui/score/voice2"
		property color color
	}
	Settings {
		id: msSetVoice3
		category: mscoreMajorVersion >= 4 ? "engraving/colors/voice3" : "ui/score/voice3"
		property color color
	}
	Settings {
		id: msSetVoice4
		category: mscoreMajorVersion >= 4 ? "engraving/colors/voice4" : "ui/score/voice4"
		property color color
	}
	Settings {
		id: msSetScore
		category: mscoreMajorVersion >= 4 ? "engraving/colors" : "ui/score"
		property color defaultColor
	}
	
   property variant defaultColors_NEW: [ //as of MuseScore 3.2
      "#2E86AB", // Voice 1 - Blue
      "#306B34", // Voice 2 - Green
      "#C73E1D", // Voice 3 - Orange
      "#8D1E4B", // Voice 4 - Purple
      ]
    property variant defaultColors_OLD: [ //prior to MuseScore 3.2
       "#1259d0", // Voice 1 - Blue    18  89 208
       "#009234", // Voice 2 - Green    0 146  52
       "#c04400", // Voice 3 - Orange 192  68   0
       "#71167a", // Voice 4 - Purple 113  22 122
       ]

   property variant colors: []
   
   property variant prevBeam: -1

   function toggleColor(element, color) {
      if (element.color !== msSetScore.defaultColor)
         element.color = msSetScore.defaultColor
      else
         element.color = color
      }

   function colorVoices(element, voice) {
      if (element.type === Element.REST)
         toggleColor(element, colors[voice % 4])
      else if (element.type === Element.CHORD) {
         if (element.stem)
            toggleColor(element.stem, colors[voice % 4])
         if (element.hook)
            toggleColor(element.hook, colors[voice % 4])
         if (element.beam) 
            // beams would need special treatment as they belong to more than
            // one chord, esp. if they belong to an even number of chords
            if (mscoreMajorVersion == 3 && mscoreMinorVersion < 3) {
               if (element.beam !== prevBeam)
                  toggleColor(element.beam, colors[voice % 4])
               }
            else {
               if (!element.beam.is(prevBeam))
                  toggleColor(element.beam, colors[voice % 4])
               }
            prevBeam = element.beam
         if (element.stemSlash) // Acciaccatura
            toggleColor(element.stemSlash, colors[voice % 4])
         }
      else if (element.type === Element.NOTE) {
         toggleColor(element, colors[voice % 4])
         if (element.accidental)
            toggleColor(element.accidental, colors[voice % 4])
         for (var i = 0; i < element.dots.length; i++) {
            if (element.dots[i])
               toggleColor(element.dots[i], colors[voice % 4])
            }
         }
      else
         console.log("Unknown element type: " + element.type)         
      }

   // Apply the given function to all chords/rests in selection
   // or, if nothing is selected, in the entire score
   function applyToChordsAndRestsInSelection(func) {
      var cursor = curScore.newCursor()
      cursor.rewind(Cursor.SELECTION_START)
      var startStaff
      var endStaff
      var endTick
      var fullScore = false
      if (!cursor.segment) { // no selection
         fullScore = true
         startStaff = 0 // start with 1st staff
         endStaff = curScore.nstaves - 1 // and end with last
         }
      else {
         startStaff = cursor.staffIdx
         cursor.rewind(Cursor.SELECTION_END)
         if (cursor.tick === 0) {
            // this happens when the selection includes
            // the last measure of the score.
            // rewind(Cursor.SELECTION_END)) goes behind the last segment
            // (where there's none) and sets tick=0
            endTick = curScore.lastSegment.tick + 1
            }
         else
            endTick = cursor.tick
         endStaff = cursor.staffIdx
         }
      console.log(startStaff + " - " + endStaff + " - " + endTick)
      curScore.startCmd()
      for (var staff = startStaff; staff <= endStaff; staff++) {
         for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(Cursor.SELECTION_START) // sets voice to 0
            cursor.voice = voice //voice has to be set after goTo
            cursor.staffIdx = staff

            if (fullScore)
               cursor.rewind(Cursor.SCORE_START) // if no selection, beginning of score

            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
               if (cursor.element) {
                  if (cursor.element.type === Element.REST)
                     func(cursor.element, voice)
                  else if (cursor.element.type === Element.CHORD) {
                     func(cursor.element, voice)
                     var graceChords = cursor.element.graceNotes;
                     for (var i = 0; i < graceChords.length; i++) {
                        // iterate through all grace chords
                        func(graceChords[i], voice)
                        var gnotes = graceChords[i].notes
                        for (var j = 0; j < gnotes.length; j++)
                           func(gnotes[j], voice)
                        }
                     var notes = cursor.element.notes
                     for (var k = 0; k < notes.length; k++) {
                        var note = notes[k]
                        func(note, voice)
                        }
                     } // end if CHORD
                  } // end if element
               cursor.next()
               } // end while cursor
            } // end for loop
         } // end for loop
      curScore.endCmd()
      }

   onRun: {
      console.log("Hello, Color Voices - setting colors")
      // check MuseScore version
      if (mscoreMajorVersion == 3 && mscoreMinorVersion == 0 && mscoreUpdateVersion <= 1)
         versionError.open()
      var defaultBlack = "#000000"; //if a color setting isn't read back (because the value is at 'default') then the settings returns the default color, namely black
      if (msSetVoice1.color == defaultBlack) {
         if (mscoreMajorVersion == 3 && mscoreMinorVersion < 2)
            msSetVoice1.color = defaultColors_OLD[0];
         else
            msSetVoice1.color = defaultColors_NEW[0];
         }
      if (msSetVoice2.color == defaultBlack) {
         if (mscoreMajorVersion == 3 && mscoreMinorVersion < 2)
            msSetVoice1.color = defaultColors_OLD[1];
         else
            msSetVoice2.color = defaultColors_NEW[1];
         }
      if (msSetVoice3.color == defaultBlack) {
         if (mscoreMajorVersion == 3 && mscoreMinorVersion < 2)
            msSetVoice1.color = defaultColors_OLD[2];
         else
            msSetVoice3.color = defaultColors_NEW[2];
         }
      if (msSetVoice4.color == defaultBlack) {
         if (mscoreMajorVersion == 3 && mscoreMinorVersion < 2)
            msSetVoice1.color = defaultColors_OLD[3];
         else
            msSetVoice4.color = defaultColors_NEW[3];
         }
      if (!msSetScore.defaultColor.valid) // needed for Mu4?
         msSetScore.defaultColor = defaultBlack;
      colors = [
         msSetVoice1.color,
         msSetVoice2.color,
         msSetVoice3.color,
         msSetVoice4.color
         ];
      console.log('Resulting colors:', colors);
      applyToChordsAndRestsInSelection(colorVoices);
      (typeof(quit) === 'undefined' ? Qt.quit : quit)()
      }
   }
