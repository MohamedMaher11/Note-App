import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/Screen.dart';
import 'package:intl/intl.dart';

class EditNote extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final int noteKey;

  EditNote(
      {Key? key,
      required this.noteKey,
      required this.description,
      required this.title,
      required this.date})
      : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();
  final datecontroller = TextEditingController();
  final notesRef = Hive.box('Notes');

  void updateNote() {
    notesRef.put(widget.noteKey, {
      'title': titleController.text,
      'description': descriptionController.text,
      'date': datecontroller.text
    });
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    datecontroller.text = widget.date;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (titleController.text != widget.title ||
              descriptionController.text != widget.description ||
              datecontroller.text != widget.date) {
            updateNote();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NotesScreen()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("you didnt change data🙂")));
          }
        },
        child: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        title: Text("Edit"),
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  icon: Icon(Icons.title), //icon of text field
                  labelText: "Edit Title" //label text of field
                  ),
            ),
            SizedBox(
              height: 5,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  icon: Icon(Icons.content_copy_outlined), //icon of text field
                  labelText: "Edit content" //label text of field
                  ),
            ),
            Container(
                padding: const EdgeInsets.all(15),
                height: 150,
                child: Center(
                    child: TextField(
                  controller:
                      datecontroller, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Edit Date" //label text of field
                      ),
                  // when true user cannot edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), //get today's date
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2101));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                      String formattedDate = DateFormat('yyyy-MM-dd').format(
                          pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                      print(
                          formattedDate); //formatted date output using intl package =>  2022-07-04
                      //You can format date as per your need

                      datecontroller.text = formattedDate;
                    } else {
                      print("Date is not selected");
                    }
                  },
                ))),
          ],
        ),
      ),
    );
  }
}
