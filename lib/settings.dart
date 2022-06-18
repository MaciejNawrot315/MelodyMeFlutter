import 'package:flutter/material.dart';
import 'package:melody_me/melody.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class SettingsPack {
  int bpm;
  List<int> selectedSounds;
  int bars;
  int subdivision;
  SettingsPack(this.bpm, this.selectedSounds, this.bars, this.subdivision);
}

class MySettingsPage extends StatefulWidget {
  const MySettingsPage({Key? key}) : super(key: key);

  @override
  State<MySettingsPage> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  SettingsPack? passedSettings;
  List<int> subdivisions = [1, 2, 4, 8];

  void _showSoundsMultiSelect(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          items: <MultiSelectItem<int>>[
            MultiSelectItem<int>(57, 'A'),
            MultiSelectItem<int>(58, 'A#'),
            MultiSelectItem<int>(59, 'B'),
            MultiSelectItem<int>(60, 'C'),
            MultiSelectItem<int>(61, 'C#'),
            MultiSelectItem<int>(62, 'D'),
            MultiSelectItem<int>(63, 'D#'),
            MultiSelectItem<int>(64, 'E'),
            MultiSelectItem<int>(65, 'F'),
            MultiSelectItem<int>(66, 'F#'),
            MultiSelectItem<int>(67, 'G'),
            MultiSelectItem<int>(68, 'G#'),
            MultiSelectItem<int>(-1, 'empty'),
          ],
          initialValue: passedSettings!.selectedSounds,
          onConfirm: (values) {
            setState(() {
              passedSettings!.selectedSounds = values
                  .map(
                    (e) => e,
                  )
                  .toList() as List<int>;
            });
          },
          colorator: (p0) => getColor(p0
              as int), //color the options based on their corresponding color of the note
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    passedSettings = ModalRoute.of(context)!.settings.arguments
        as SettingsPack; //get the settings passed from the main page
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(children: [
            ListTile(
              title: const Text('BPM:'),
              trailing: DropdownButton<int>(
                  value: passedSettings!.bpm,
                  onChanged: (int? newValue) {
                    setState(() {
                      passedSettings!.bpm = newValue!;
                    });
                  },
                  items: List.generate(
                      150,
                      (index) => DropdownMenuItem<int>(
                            value: index + 30,
                            child: Text((index + 30).toString()),
                          ))),
            ),
            ListTile(
              title: const Text('Sounds Used:'),
              trailing: TextButton(
                onPressed: () {
                  _showSoundsMultiSelect(context);
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink[200])),
                child: const Text('Select'),
              ),
            ),
            ListTile(
              title: const Text('Bars:'),
              trailing: DropdownButton<int>(
                  value: passedSettings!.bars,
                  onChanged: (int? newValue) {
                    setState(() {
                      passedSettings!.bars = newValue!;
                    });
                  },
                  items: List.generate(
                      8,
                      (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text((index + 1).toString()),
                          ))),
            ),
            ListTile(
              title: const Text('Deepest Subdivision:'),
              trailing: DropdownButton<int>(
                  value: passedSettings!.subdivision,
                  onChanged: (int? newValue) {
                    setState(() {
                      passedSettings!.subdivision = newValue!;
                    });
                  },
                  items: List.generate(
                      4,
                      (index) => DropdownMenuItem<int>(
                            value: subdivisions[index],
                            child: Text(subdivisions[index].toString()),
                          ))),
            ),
          ])),
      onWillPop: () async {
        Navigator.pop(
            context, passedSettings); //pass the settings back to the main page
        return false;
      },
    );
  }
}
