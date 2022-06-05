import 'package:flutter/material.dart';
import 'dart:math';
import './settings.dart';

final List<Color> colors = [
  //table of colors indexed acording to the sound division
  const Color.fromARGB(255, 0, 230, 0),
  const Color.fromARGB(255, 7, 251, 176),
  const Color.fromARGB(255, 0, 109, 250),
  const Color.fromARGB(255, 44, 2, 243),
  const Color.fromARGB(255, 126, 0, 204),
  const Color.fromARGB(255, 70, 0, 84),
  const Color.fromARGB(255, 102, 4, 81),
  const Color.fromARGB(255, 214, 1, 3),
  const Color.fromARGB(255, 255, 67, 2),
  const Color.fromARGB(255, 255, 136, 0),
  const Color.fromARGB(255, 238, 254, 5),
  const Color.fromARGB(255, 155, 242, 5),
];
final List<String> letters = [
  'C',
  'C#',
  'D',
  'D#',
  'E',
  'F',
  'F#',
  'G',
  'G#',
  'A',
  'A#',
  'B'
];
Color getColor(int soundNumber) {
  //returns the color linked with the given sound number
  if (soundNumber < 0) {
    return const Color.fromARGB(255, 224, 224, 224);
  } else {
    return colors[soundNumber % 12];
  }
}

class Note {
  //represent a single note
  int sound;
  int duration;
  bool played = false;
  Note(this.sound, this.duration) {
    color = Colors.white;
  }
  late Color color;
}

class Melody {
  late List<Note> notesList; //list of the notes in the melody
  bool favourite = false;
  late int bpm;
  late int bars;
  late int subdivision;
  Melody(SettingsPack settings) {
    bpm = settings.bpm;
    bars = settings.bars;
    subdivision = settings.subdivision;
    var rand = Random();
    notesList = List.generate(
        settings.bars * settings.subdivision,
        (index) => Note(
            settings
                .selectedSounds[rand.nextInt(settings.selectedSounds.length)],
            1));
    while (notesList[0].sound == -1) {
      //generate the first note untill its not empty
      notesList[0] = Note(
          settings.selectedSounds[rand.nextInt(settings.selectedSounds.length)],
          1);
    }
    notesList[0].color =
        getColor(notesList[0].sound); //set the color of the firs note
    int emptyCounter =
        0; //counts how many notes in a row are currently empty(counting from the end of the list)
    for (var i = notesList.length - 1; i >= 0; i--) {
      if (notesList[i].sound == -1) {
        //if the note is empty
        emptyCounter++;
        notesList[i].duration = 0; //set its duration to 0
      } else {
        notesList[i].duration +=
            emptyCounter; //increase the duration of the note based on how many notes ahead of it are empty
        for (var j = emptyCounter; j >= 0; j--) {
          //for each empty note ahead change its color to the "main" note that is played during the "emptiness"
          notesList[i + j].color = getColor(notesList[i].sound);
        }
        emptyCounter = 0;
      }
    }
    if (emptyCounter > 0) {
      notesList[0].duration = emptyCounter;
    }
  }
}

String getLetter(int soundNumber) {
  if (soundNumber < 0) {
    return ' ';
  } else {
    return letters[soundNumber % 12];
  }
}
