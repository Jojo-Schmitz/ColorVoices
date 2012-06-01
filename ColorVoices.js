//=============================================================================
//  MuseScore
//  Music Score Editor
//  $Id:$
//
//  ColorVoices plugin
//
//  Copyright (C)2011 Charles Cave   (charlesweb@optusnet.com.au)
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
// Voice 1 - Blue    26  12 255 
// Voice 2 - Green   25 117 6
// Voice 3 - Gold   255 160 0 
// Voice 4 - Red    232  30 22

var Blue  = new QColor(26, 12, 255);
var Green = new QColor(25, 117, 6);
var Gold   = new QColor(255, 160, 0);
var Red   = new QColor(232, 30, 22);
var Black = new QColor(0, 0, 0);

var voiceColor;

function init()
      {
      }

function run() {
    var cursor = new Cursor(curScore);

   for (var staff = 0; staff < curScore.staves; ++staff) {
       cursor.staff = staff;
       for (var v = 0; v < 3; v++) {
           cursor.voice = v;
           cursor.rewind(); 
           switch (v)
           {
           case 0:
               voiceColor = new QColor(Blue);
               break;
           case 1:
               voiceColor = new QColor(Green);
               break;
           case 2:
               voiceColor = new QColor(Gold);
               break;
           case 3:
               voiceColor = new QColor(Red);
               break;
           }
               
          while (!cursor.eos()) {
              if (cursor.isChord()) {
                  var chord = cursor.chord();
                  var n     = chord.notes;
                  for (var i = 0; i < n; i++) {
                      var note = chord.note(i);
                      note.color = voiceColor;
                  }
              }
            cursor.next();
          }
      }
   }
}

var mscorePlugin = {
      menu: 'Plugins.Notes.ColorVoices',
      init: init,
      run:  run
      };

mscorePlugin;
