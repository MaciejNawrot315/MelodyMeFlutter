import './melody.dart';
import 'package:flutter/material.dart';
import './settings.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Me',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SettingsPack settings = SettingsPack(
      130,
      [60, 62, 64, 67, -1],
      3, //settings that are used to generate the melodies(here initialized with default settings)
      4);
  late FlutterMidi fm; //midi player
  final String songFile = 'assets/sf2/CandyBee.sf2';
  final PageController controller = PageController(initialPage: 0);
  List<Melody> favouritesList = []; //list of the melodies that are "liked"
  List<Melody> melodyList = []; //list of melodies currenttly generated

  void _pushOptions() async {
    //opens Settings view
    settings = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) {
          return const MySettingsPage();
        },
        settings: RouteSettings(
          arguments: settings, //passess current settings to the settings page
        )));
    melodyList =
        []; //clears the melody list after coming bac form settings view
    setState(() {
      controller
          .jumpToPage(0); //jump to the first page of the newly generated pages
    });
  }

  @override
  void initState() {
    super.initState();
    fm = FlutterMidi();
    _load(songFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Melody Me'),
          leading: Builder(builder: (context) {
            return IconButton(
              //overriding basic drawer button with a custom one
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.favorite_border_outlined,
                color: Colors.white,
              ),
            );
          }),
          actions: <Widget>[
            IconButton(
              onPressed: _pushOptions,
              icon: const Icon(Icons.settings),
            ),
          ]),
      drawer: Drawer(
        backgroundColor: Colors.pink[100],
        child: ListView(
            //liked melodies
            children: List.generate(
                favouritesList.length,
                (index) => ListTile(
                    title: Text('Melody number $index'),
                    onTap: () {
                      melodyList =
                          []; //generate new melodies after selecting a liked one
                      setState(() {
                        melodyList.add(favouritesList[
                            index]); //add the liked melody to the first page of the view
                      });
                      Navigator.pop(
                          context); //close the drawer after selecting a melody
                    }))),
      ),
      body: PageView.builder(
        controller: controller,
        itemBuilder: (context, index0) {
          if (index0 >= melodyList.length) {
            //if the melody list is out of gnereted melodies generates a couple more
            melodyList.addAll(List.generate(
                index0 - melodyList.length + 5, (index) => Melody(settings)));
          }
          Melody currentMelody = melodyList[index0];
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 100, 50, 100),
              child: SizedBox(
                height: 200,
                child: GridView.count(
                  crossAxisCount: 2 * currentMelody.subdivision,
                  mainAxisSpacing: 8,
                  childAspectRatio: 4 /
                      currentMelody.subdivision /
                      1, //size the notes based on subdivision of the melody
                  children: List.generate(
                    currentMelody.bars *
                        currentMelody
                            .subdivision, //number of notes in the melody
                    (int index1) => GestureDetector(
                      //gesture detector to detect a container click
                      onTap: () => _playMelody(
                          currentMelody: currentMelody,
                          startNote: index1), //play melody form the chosen note
                      //onLongPress: () => ,
                      child: Container(
                        decoration: BoxDecoration(
                          color: currentMelody.notesList[index1].sound ==
                                  -1 //if current note is empty set its color to the color of its predecessor
                              ? currentMelody.notesList[index1 - 1].color
                              : currentMelody.notesList[index1].color,
                          borderRadius: BorderRadius.circular(7.0),
                          border: Border.all(
                              width: 3.0,
                              color: currentMelody.notesList[index1].played ==
                                      true //if the note is currently played make it larger by coloring its border to the same color
                                  ? currentMelody.notesList[index1].color
                                  : const Color.fromARGB(255, 224, 224, 224)),
                        ),
                        child: Center(
                          child: Text(
                            getLetter(currentMelody.notesList[index1].sound),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  //play button
                  onPressed: () {
                    _playMelody(currentMelody: currentMelody);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(255, 58, 9, 26))),
                  child: const Text('Play'),
                ),
                IconButton(
                    //favourite button
                    onPressed: () {
                      if (favouritesList.contains(melodyList[index0])) {
                        //if the melody is already liked delete it form favourite list
                        favouritesList.remove(melodyList[index0]);
                        setState(() {
                          melodyList[index0].favourite = false;
                        });
                      } else {
                        //otherwise add it to the favourite list
                        favouritesList.add(melodyList[index0]);
                        setState(() {
                          melodyList[index0].favourite = true;
                        });
                      }
                    },
                    icon: melodyList[index0].favourite
                        ? const Icon(
                            Icons.favorite,
                            color: Color.fromARGB(255, 226, 42, 42),
                          )
                        : const Icon(Icons.favorite_border))
              ],
            )
          ]);
        },
      ),
      backgroundColor: Colors.grey[300],
    );
  }

  void _load(String asset) async {
    //load the sound file from assets
    fm.unmute();
    ByteData byte = await rootBundle.load(asset);
    fm.prepare(sf2: byte);
  }

  void _playMelody({required Melody currentMelody, int startNote = 0}) async {
    //playes the passed melody starting form the startNote.Note number 0 by default
    int delay = (240000 / (currentMelody.bpm * currentMelody.subdivision))
        .round(); //calculating the delay between notes
    int length = currentMelody.notesList.length; //length of the melody

    for (var i = startNote; i < length; i++) {
      //for each note
      List<int> emptyIndexes =
          []; //list that contains "notes" that are empty, so the program knows that it need to make them also bigger
      int currentSound = currentMelody.notesList[i].sound;

      if (!mounted)
        return; //checks if the state object is still in the tree(user can swipe the page mid melody, wich causes the page to be disposed)
      fm.playMidiNote(midi: currentSound); //play the sound
      setState(() {
        //updating the size of the note containers
        currentMelody.notesList[i].played = true;
        if (i + 1 < length) {
          for (var j = i + 1; j < length; j++) {
            //for each empty note container make it bigger
            if (currentMelody.notesList[j].sound == -1) {
              currentMelody.notesList[j].played = true;
              emptyIndexes.add(j);
            } else {
              break;
            }
          }
        }
      });

      await Future.delayed(//wait so that the tempo is mantained
          Duration(milliseconds: delay * currentMelody.notesList[i].duration));

      if (!mounted) return;
      fm.stopMidiNote(midi: currentSound); //stop playing the note

      setState(() {
        currentMelody.notesList[i].played = false;
        for (var index in emptyIndexes) {
          //for each empty note make it smaller
          currentMelody.notesList[index].played = false;
        }
      });
    }
  }
}
