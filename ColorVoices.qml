//=============================================================================
//  MuseScore
//  Music Score Editor
//  $Id:$
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles Cave   (charlesweb@optusnet.com.au)
//  Copyright (C)2012, 2013 Joachim Schmitz (jojo@schmitz-digital.de)
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

// 02Jan2013 ColorVoices
// The purpose of this plugin is to color the notes of each voice.

import QtQuick 1.0
import MuseScore 1.0


MuseScore {
   version: "1.0"
   description: "This plugin colors the notes of each voice"
   menuPath: 'Plugins.Notes.Color voices'
   onRun: {
      if (typeof curScore === 'undefined')
         Qt.quit();

      var cursor = curScore.newCursor();
      var colors = [
         "#0000ff", // Voice 1 - Blue     0   0 255
         "#009600", // Voice 2 - Green    0 150   0
         "#e6b432", // Voice 3 - Yellow 230 180  50
         "#c800c8", // Voice 4 - Purple 200   0 200
         "#000000"  // Black (shouldn't happen)
         ];

      for (var track = 0; track < curScore.ntracks; ++track) {
         cursor.track = track;
         cursor.rewind(0); 
               
         while (cursor.segment) {
            if (cursor.element && cursor.element.type == Element.CHORD) {
               var notes = cursor.element.notes;
               for (var i = 0; i < notes.length; i++) {
                  var note = notes[i];
                  if (note.color != "#000000")
                     note.color = "#000000";
                  else
                     note.color = colors[cursor.voice % 4];
               }
            }
            else if (cursor.element && cursor.element.type == Element.REST) {
               var rest = cursor.element;
               if (rest.color != "#000000")
                  rest.color = "#000000";
               else
                  rest.color = colors[cursor.voice % 4];
            }
            cursor.next();
         }
      } // end loop tracks

      Qt.quit();
   } // end onRun
}
