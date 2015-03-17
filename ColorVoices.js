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
// Voice 1 - Blue     0   0 255 
// Voice 2 - Green    0 150   0
// Voice 3 - Yellow 230 180  50
// Voice 4 - Purple 200   0 200

var Blue   = new QColor(  0,   0, 255);
var Green  = new QColor(  0, 150,   0);
var Yellow = new QColor(230, 180,  50);
var Purple = new QColor(200,   0, 200);
var Black  = new QColor(  0,   0,   0);

function init()
{
}

function run()
{
   if (typeof curScore === 'undefined')
      return;

   var cursor = new Cursor(curScore);
   cursor.goToSelectionStart();
   var startStaff = cursor.staff;
   cursor.goToSelectionEnd();
   var endStaff   = cursor.staff;
   var endTick    = cursor.tick(); // if no selection, go to end of score

   if (cursor.eos()) { // if no selection
      startStaff = 0; // start with 1st staff
      endStaff = curScore.staves; // and end with last
   }

   for (var staff = startStaff; staff < endStaff; ++staff) {
      for (var voice = 0; voice < 4; voice++) {
         var voiceColor = [ Blue, Green, Yellow, Purple, Black ];
         cursor.goToSelectionStart();
         cursor.staff = staff;
         cursor.voice = voice;
         if (cursor.eos())
            cursor.rewind(); // if no selection, start at beginning of score

         while (cursor.tick() < endTick) {
            if (cursor.isChord()) {
               var chord = cursor.chord();
               var n     = chord.notes;
               for (var i = 0; i < n; i++) {
                  var note = chord.note(i);
                  if (note.color != Black)
                     note.color = Black;
                  else
                     note.color = voiceColor[voice%4];
               }
            }
            cursor.next();
         }
      }
   }
}

var mscorePlugin = {
      menu: 'Plugins.Notes.Color Voices',
      init: init,
      run:  run
};

mscorePlugin;
