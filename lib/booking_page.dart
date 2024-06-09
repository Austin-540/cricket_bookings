import 'package:flutter/material.dart';
import 'globals.dart';
import 'checkout_page.dart';

class TimeSlot {
  // ignore: non_constant_identifier_names
  TimeSlot({required this.startTime, required this.endTime, required this.booked, required this.am_or_pm});
    final int startTime;
    final int endTime;
    final bool booked;
    // ignore: non_constant_identifier_names
    final String am_or_pm;

}

class BookingPage extends StatefulWidget {
  BookingPage({super.key, required this.selected});
  bool selected;
  

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<bool> checkboxesSelected = [];
  DateTime? datePicked = DateTime.now();
  Future? getTimeslots;

  Future getTheTimeslots() async {
      final pbTimeslots = await pb.collection("timeslots").getFullList(sort: '-created');
      checkboxesSelected = List.filled(pbTimeslots.length, false);
      List<TimeSlot> formattedTimeslots = [];
      for (final timeslot in pbTimeslots) {
        formattedTimeslots.add(TimeSlot(
          am_or_pm: timeslot.data['am_or_pm'],
          booked: false, //CHANGE THIS
          startTime: timeslot.data['start_time'],
          endTime: timeslot.data['end_time']
        ));
      }

      formattedTimeslots.sort((a,b) => a.startTime.compareTo(b.startTime));
      formattedTimeslots.sort((a, b) => a.am_or_pm.compareTo(b.am_or_pm));
      return formattedTimeslots;
      
      
  }

  @override
  void initState() {
    checkboxesSelected = [];
    if (widget.selected == true){getTimeslots = getTheTimeslots();} 

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.selected) {
      return const Text("Not Selected! You should not see this screen!");
    }
    getTimeslots ??= getTheTimeslots();

    
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: () async {
        List<TimeSlot> tslots = await getTimeslots;
        List<TimeSlot> selectedTimeslots =tslots.where((timeSlot) => checkboxesSelected[tslots.indexOf(timeSlot)]).toList();
        if (selectedTimeslots.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You need to select at least 1 timeslot"),));
        } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(timeslots: selectedTimeslots, date: datePicked!)));
        }

      }, label: const Text("Checkout"), icon: const Icon(Icons.shopping_cart_outlined),),
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
          FutureBuilder(future: getTimeslots, 
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [for (var i=0; i< snapshot.data.length; i++) ... [
              Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text("${snapshot.data[i].startTime} - ${snapshot.data[i].endTime} ${snapshot.data[i].am_or_pm}", style: const TextStyle(fontSize: 40),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Checkbox(
                        
                        value: checkboxesSelected[i], onChanged: snapshot.data[i].booked? null:(value){
                          setState(() {
                            checkboxesSelected[i] = value!;
                          });
                      } ,),
                      snapshot.data[i].booked? const Text("Booked"): const Text("Available")
                    ],
                  ),
                )
              ],),
            ),
          )
          ]],
              );
            } else if (snapshot.hasError) {
              return const Icon(Icons.error_outline);
            }
            else {
              return const CircularProgressIndicator();
            }
          } 
          ,),
          
          
        ],
        ),
    );
  }
}