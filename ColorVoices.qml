//=============================================================================
//  MuseScore
//  Music Score Editor
//  $Id:$
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles Cave   (charlesweb@optusnet.com.au)
//  Copyright (C)2012 - 2015 Joachim Schmitz (jojo@schmitz-digital.de)
//  Copyright (C)2014 Jörn Eichler (joerneichler@gmx.de)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//=============================================================================

// The purpose of this plugin is to color the notes of each voice.

import QtQuick 2.1
import MuseScore 1.0


MuseScore {
   version: "1.0"
   description: "This plugin colors the notes and rests of each voice"
   menuPath: 'Plugins.Notes.Color Voices'

   property variant colors : [
         "#1259d0", // Voice 1 - Blue    18  89 208
         "#009234", // Voice 2 - Green    0 146  52
         "#c04400", // Voice 3 - Orange 192  68   0
         "#71167a", // Voice 4 - Purple 113  22 122
         "#000000"  // Black
         ]

   function toggleColor(element, voice) {
      if (typeof element.color === 'undefined')
         console.log("element type " + element.type + " doesn't have color")
      else  {
         if (element.color != colors[4])
            element.color = colors[4]; // black
         else
            element.color = colors[voice % 4];
      } 
   } 

   onRun: {
      if (typeof curScore === 'undefined')
        Qt.quit();

      var cursor = curScore.newCursor();
      var startStaff;
      var endStaff;
      var endTick;
      var fullScore = false;
      cursor.rewind(1);
      if (!cursor.segment) { // no selection
        fullScore = true;
        startStaff = 0; // start with 1st staff
        endStaff = curScore.nstaves - 1; // and end with last
      } else {
        startStaff = cursor.staffIdx;
        cursor.rewind(2);
        if (cursor.tick == 0) {
          // this happens when the selection includes
          // the last measure of the score.
          // rewind(2) goes behind the last segment (where
          // there's none) and sets tick=0
          endTick = curScore.lastSegment.tick + 1;
        } else {
          endTick = cursor.tick;
        }
        endStaff = cursor.staffIdx;
      }
      console.log(startStaff + " - " + endStaff + " - " + endTick)
      for (var staff = startStaff; staff <= endStaff; staff++) {
        for (var voice = 0; voice < 4; voice++) {          
          cursor.rewind(1); // sets voice to 0
          cursor.voice = voice; // voice has to be set after goTo
          cursor.staffIdx = staff;

          if (fullScore)
             cursor.rewind(0) // if no selection, beginning of score

          while (cursor.segment && (fullScore || cursor.tick < endTick)) {
            if (cursor.element) {
               var element = cursor.element;
               toggleColor(element, voice); // this takes care of the rests
               if (element.stem)
                  toggleColor(element.stem, voice)
               if (element.hook)
                  toggleColor(element.hook, voice)
               if (element.beam)
                  toggleColor(element.beam, voice)
               if (element.stemSlash)
                  toggleColor(element.stemSlash, voice)
               if (element.type == Element.CHORD) {
                  var graceChords = element.graceNotes;
                  for (var i = 0; i < graceChords.length; i++) {
                     // iterate through all grace chords
                     var notes = graceChords[i].notes;
                     for (var i = 0; i < notes.length; i++) {
                        var note = notes[i];
                        toggleColor(note, voice);
                     }
                  }

                  var notes = element.notes;
                  for (var i = 0; i < notes.length; i++) {
                     var note = notes[i];
                     toggleColor(note, voice);
                  }
               }
            }
            cursor.next();
          }
        } // end loop voices
      } // end loop staves

      Qt.quit();
   } // end onRun
}
