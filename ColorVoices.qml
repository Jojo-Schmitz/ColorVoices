//=============================================================================
//  MuseScore
//  Music Score Editor
//  $Id:$
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles Cave   (charlesweb@optusnet.com.au)
//  Copyright (C)2012 Joachim Schmitz (jojo@schmitz-digital.de)
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

// 2011-10-20 ColorVoices
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
         "#1a0cff", // Voice 1 - Blue    26  12 255
         "#197506", // Voice 2 - Green   25 117   6
         "#ffa000", // Voice 3 - Gold   255 160   0
         "#e81e16", // Voice 4 - Red    232  30  22
         "#000000"  // Black (shouldn't happen)
         ];

      for (var track = 0; track < curScore.ntracks; ++track) {
         cursor.track = track;
         cursor.rewind(0); 
               
         while (cursor.segment) {
            if (cursor.element && cursor.element.type == MScore.CHORD) {
               var notes = cursor.element.notes;
               for (var i = 0; i < notes.length; i++) {
                  var note = notes[i];
                  note.color = colors[cursor.voice % 4];
               }
            }
            cursor.next();
         }
      } // end loop tracks

      Qt.quit();
   } // end onRun
}
