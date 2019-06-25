//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles Cave (charlesweb@optusnet.com.au)
//  Copyright (C)2014 Jörn Eichler (joerneichler@gmx.de)
//  Copyright (C)2012-2018 Joachim Schmitz (jojo@schmitz-digital.de)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.9
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import MuseScore 3.0

MuseScore {
   version:  "3.0"
   description: "This plugin colors the chords and rests of each voice"
   menuPath: "Plugins.Notes.Color Voices"

  MessageDialog {
    id: versionError
    visible: false
    title: qsTr("Unsupported MuseScore Version")
    text: qsTr("This plugin needs MuseScore 3.0.2 or later")
    onAccepted: {
      Qt.quit()
      }
    }

	Settings {
		id: msSetVoice1
		category: "ui/score/voice1"
		property color color
	}
	Settings {
		id: msSetVoice2
		category: "ui/score/voice2"
		property color color
	}
	Settings {
		id: msSetVoice3
		category: "ui/score/voice3"
		property color color
	}
	Settings {
		id: msSetVoice4
		category: "ui/score/voice4"
		property color color
	}
	Settings {
		id: msSetScore
		category: "ui/score"
		property color defaultColor
	}
	
   property variant defaultColors: [ //as in MuseScore 3.2
      "#2E86AB", // Voice 1 - Blue
      "#306B34", // Voice 2 - Green
      "#C73E1D", // Voice 3 - Orange
      "#8D1E4B", // Voice 4 - Purple
      ]

   property variant colors: []

   function toggleColor(element, color) {
      if (element.color != msSetScore.defaultColor)
         element.color = msSetScore.defaultColor
      else
         element.color = color
      }

   function colorVoices(element, voice) {
      if (element.type == Element.REST)
         toggleColor(element, colors[voice % 4])
      else if (element.type == Element.CHORD) {
         if (element.stem)
            toggleColor(element.stem, colors[voice % 4])
         if (element.hook)
            toggleColor(element.hook, colors[voice % 4])
         if (element.beam) 
            // beams would need special treatment as they belong to more than
            // one chord, esp. if they belong to an even number of chords,
            // so for now leave (or make) them defaultColor
            toggleColor(element.beam, msSetScore.defaultColor)
         if (element.stemSlash) // Acciaccatura
            toggleColor(element.stemSlash, colors[voice % 4])
         }
      else if (element.type == Element.NOTE) {
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
      cursor.rewind(1)
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
         cursor.rewind(2)
         if (cursor.tick == 0) {
            // this happens when the selection includes
            // the last measure of the score.
            // rewind(2) goes behind the last segment (where
            // there's none) and sets tick=0
            endTick = curScore.lastSegment.tick + 1
            }
         else
            endTick = cursor.tick
         endStaff = cursor.staffIdx
         }
      console.log(startStaff + " - " + endStaff + " - " + endTick)
      for (var staff = startStaff; staff <= endStaff; staff++) {
         for (var voice = 0; voice < 4; voice++) {
            cursor.rewind(1) // sets voice to 0
            cursor.voice = voice //voice has to be set after goTo
            cursor.staffIdx = staff

            if (fullScore)
               cursor.rewind(0) // if no selection, beginning of score

            while (cursor.segment && (fullScore || cursor.tick < endTick)) {
               if (cursor.element) {
                  if (cursor.element.type == Element.REST)
                     func(cursor.element, voice)
                  else if (cursor.element.type == Element.CHORD) {
                     func(cursor.element, voice)
                     var graceChords = cursor.element.graceNotes;
                     for (var i = 0; i < graceChords.length; i++) {
                        // iterate through all grace chords
                        func(graceChords[i], voice)
                        var notes = graceChords[i].notes
                        for (var j = 0; j < notes.length; j++)
                           func(notes[j], voice)
                        }
                     var notes = cursor.element.notes
                     for (var i = 0; i < notes.length; i++) {
                        var note = notes[i]
                        func(note, voice)
                        }
                     } // end if CHORD
                  } // end if element
               cursor.next()
               } // end while cursor
            } // end for loop
         } // end for loop
      }

   onRun: {
      console.log("Hello, Color Voices - setting colors")
      var defaultBlack = '#000000'; //if a color setting isn't read back (because the value is at 'default') then the settings returns the default color, namely black
      if (msSetVoice1.color == defaultBlack) {
          msSetVoice1.color = defaultColors[0];
      }
      if (msSetVoice2.color == defaultBlack) {
          msSetVoice2.color = defaultColors[1];
      }
      if (msSetVoice3.color == defaultBlack) {
          msSetVoice3.color = defaultColors[2];
      }
      if (msSetVoice4.color == defaultBlack) {
          msSetVoice4.color = defaultColors[3];
      }
      colors = [
          msSetVoice1.color,
          msSetVoice2.color,
          msSetVoice3.color,
          msSetVoice4.color
      ];
      console.log('Resulting colors:', colors);
      // check MuseScore version
      if (mscoreMajorVersion == 3 && mscoreMinorVersion == 0 && mscoreUpdateVersion <= 1)
         versionError.open()
      else
         applyToChordsAndRestsInSelection(colorVoices)
      Qt.quit()
      }
}
