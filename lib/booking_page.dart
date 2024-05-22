import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  BookingPage({super.key, required this.selected});
  bool selected;
  

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? datePicked = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    if (!widget.selected) {
      return const Text("Not Selected! You should not see this screen!");
    }

    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a timeslot"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ElevatedButton(onPressed: () async{
            DateTime? datePickerPicked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2085));
            setState(() {
              datePicked = datePickerPicked ?? DateTime.now();
            });
          }, child: const Text("Pick a different date")),
          Text("Date selected: $datePicked")
        ],
        ),
    );
  }
}