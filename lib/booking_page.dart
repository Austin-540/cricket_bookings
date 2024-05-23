import 'package:flutter/material.dart';


class TimeSlot {
  TimeSlot({required this.startTime, required this.endTime, required this.booked});
    final int startTime;
    final int endTime;
    final bool booked;
}

class BookingPage extends StatefulWidget {
  BookingPage({super.key, required this.selected});
  bool selected;
  

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? datePicked = DateTime.now();
  final timeslots = [TimeSlot(startTime: 9, endTime: 10, booked: false)];

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
            DateTime? datePickerPicked = await showDatePicker(
              context: context, firstDate: DateTime.now(), lastDate: DateTime(2085));
            setState(() {
              datePicked = datePickerPicked ?? DateTime.now();
            });
          }, child: const Text("Pick a different date")),
          Text("Date selected: $datePicked"),
          for (var i=0; i< timeslots.length; i++) ... [
              Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text("${timeslots[i].startTime} - ${timeslots[i].endTime}", style: const TextStyle(fontSize: 40),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Checkbox(
                        
                        value: false, onChanged: timeslots[i].booked? null:(value){

                      } ,),
                      timeslots[i].booked? const Text("Booked"): const Text("Available")
                    ],
                  ),
                )
              ],),
            ),
          )
          ],
          
        ],
        ),
    );
  }
}