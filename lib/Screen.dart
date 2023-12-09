import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'edit_note.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();

  bool bottomSheetOpened = false;
  final notesRef = Hive.box('Notes');
  List<Map<String, dynamic>> notesData = [];
  bool searchOpened = false;
  Color randomColor =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
///////////////////////////////////////////////////////////////////
//List of colors
  final ccolors = [
    Colors.blue.withOpacity(0.1),
    Colors.red.withOpacity(0.1),
    Colors.yellow.withOpacity(0.1),
    Colors.green.withOpacity(0.1),
    Colors.purple.withOpacity(0.1),
    Colors.grey.withOpacity(0.1),
    Colors.orange.withOpacity(0.1),
  ];

  //Method of add note hive
  Future<void> addNote({
    required String title,
    required String description,
    required String date,
  }) async {
    await notesRef
        .add({'title': title, 'description': description, 'date': date});
    getNotes();
    // call notes from cache
  }

  //Method of delete note hive based on key
  void deleteNote({required int noteKey}) async {
    await notesRef.delete(noteKey);
    getNotes();
  }

  //Method of get note hive
  void getNotes() {
    setState(() {
      notesData = notesRef.keys.map((e) {
        final currentNote = notesRef.get(e);
        return {
          'key': e,
          'title': currentNote['title'],
          'description': currentNote['description'],
          'date': currentNote['date']
        };
      }).toList();
    });
    debugPrint("Notes length is : ${notesData.length}");
  }

  //Method of search note hive
  List<Map<String, dynamic>> notesFiltered = [];
  void filterNotes({required String input}) {
    setState(() {
      notesFiltered = notesData
          .where((element) => element['title']
              .toString()
              .toLowerCase()
              .startsWith(input.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    getNotes();
    super.initState();
  }

//building ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (bottomSheetOpened == false) {
              scaffoldKey.currentState!
                  .showBottomSheet((context) {
                    return Container(
                      color: Color(0xff9700b1).withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: const InputDecoration(
                                hintText: 'Title',
                                border: UnderlineInputBorder()),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                                hintText: 'Description',
                                border: UnderlineInputBorder()),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Container(
                              padding: const EdgeInsets.all(15),
                              height: 150,
                              child: Center(
                                  child: TextField(
                                controller:
                                    dateController, //editing controller of this TextField
                                decoration: const InputDecoration(
                                    icon: Icon(Icons
                                        .calendar_today), //icon of text field
                                    labelText:
                                        "Enter Date" //label text of field
                                    ),
                                readOnly:
                                    true, // when true user cannot edit text
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          DateTime.now(), //get today's date
                                      firstDate: DateTime(
                                          2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101));

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd').format(
                                            pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                    print(
                                        formattedDate); //formatted date output using intl package =>  2022-07-04
                                    //You can format date as per your need

                                    setState(() {
                                      dateController.text =
                                          formattedDate; //set foratted date to TextField value.
                                    });
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                              ))),
                          const SizedBox(
                            height: 12,
                          ),
                          Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: MaterialButton(
                              color: Colors.deepPurple,
                              textColor: Colors.white,
                              onPressed: () {
                                if (titleController.text.isNotEmpty &&
                                    descriptionController.text.isNotEmpty) {
                                  addNote(
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      date: dateController.text);
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          backgroundColor: Colors.red,
                                          content:
                                              Text("Please, fill The field,")));
                                }
                              },
                              child: const Text("Add Note"),
                            ),
                          )
                        ],
                      ),
                    );
                  })
                  .closed
                  .then((value) {
                    titleController.clear();
                    descriptionController.clear();
                    setState(() {
                      bottomSheetOpened = false;
                    });
                    debugPrint("Closed...");
                  });
              setState(() {
                bottomSheetOpened = true;
              });
            } else {
              setState(() {
                bottomSheetOpened = false;
              });
              Navigator.pop(context);
            }
          },
          child: Icon(bottomSheetOpened ? Icons.clear : Icons.add),
        ),
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
              tooltip: 'Note App',
              onPressed: () {
                setState(() {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                });
              },
              icon: Icon(Icons.home)),
          title: searchOpened == false
              ? const Text("Notes App")
              : TextField(
                  onChanged: (input) {
                    filterNotes(input: input);
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    filled: true, //<-- SEE HERE

                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    searchOpened = !searchOpened;
                  });
                },
                child: Icon(searchOpened == false ? Icons.search : Icons.clear),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return Card(
                  elevation: 8,
                  shadowColor: Colors.blue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    decoration: BoxDecoration(
                        color: ccolors[index % ccolors.length],
                        borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notesFiltered.isEmpty
                              ? notesData[index]['title']
                              : notesFiltered[index]['title'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(notesFiltered.isEmpty
                            ? notesData[index]['description']
                            : notesFiltered[index]['description']),
                        const SizedBox(
                          height: 7,
                        ),
                        Text(
                          notesFiltered.isEmpty
                              ? notesData[index]['date']
                              : notesFiltered[index]['date'],
                          style: const TextStyle(fontSize: 17),
                        ),

                        // navigate to edit note page
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditNote(
                                    title: notesData[index]['title'],
                                    description: notesData[index]
                                        ['description'],
                                    date: notesData[index]['date'],
                                    noteKey: notesData[index]['key'],
                                  );
                                }));
                              },
                              child: const Icon(Icons.edit),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            //delete item
                            GestureDetector(
                              onTap: () {
                                deleteNote(noteKey: notesData[index]['key']);
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(
                  height: 12.5,
                );
              },
              itemCount: notesFiltered.isEmpty
                  ? notesData.length
                  : notesFiltered.length),
        ));
  }
}
