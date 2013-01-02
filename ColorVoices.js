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
var Yellow = new QColor(230, 180,   0);
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

   for (var staff = 0; staff < curScore.staves; ++staff) {
      cursor.staff = staff;
      for (var voice = 0; voice < 4; voice++) {
         var voiceColor;
         cursor.voice = voice;
         cursor.rewind(); 
         switch (voice)
         {
            case 0:
               voiceColor = new QColor(Blue);
               break;
            case 1:
               voiceColor = new QColor(Green);
               break;
            case 2:
               voiceColor = new QColor(Yellow);
               break;
            case 3:
               voiceColor = new QColor(Purple);
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
      menu: 'Plugins.Notes.Color voices',
      init: init,
      run:  run
};

mscorePlugin;
