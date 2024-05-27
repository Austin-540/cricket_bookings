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
  List<TimeSlot> timeslots = [TimeSlot(startTime: 9, endTime: 10, booked: false, am_or_pm: "AM")];
  Future? getTimeslots;

  Future getTheTimeslots() async {
      final pbTimeslots = await pb.collection("timeslots").getFullList(sort: '-created');
      print(pbTimeslots);
      return pbTimeslots;
      
  }

  @override
  void initState() {
    checkboxesSelected = List.filled(timeslots.length, false);
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
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        List<TimeSlot> selectedTimeslots = timeslots.where((timeSlot) => checkboxesSelected[timeslots.indexOf(timeSlot)]).toList();
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(timeslots: selectedTimeslots)));

      }, label: Text("Checkout"), icon: Icon(Icons.shopping_cart_outlined),),
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
                children: [for (var i=0; i< timeslots.length; i++) ... [
              Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text("${timeslots[i].startTime} - ${timeslots[i].endTime} ${timeslots[i].am_or_pm}", style: const TextStyle(fontSize: 40),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Checkbox(
                        
                        value: checkboxesSelected[i], onChanged: timeslots[i].booked? null:(value){
                          setState(() {
                            checkboxesSelected[i] = value!;
                          });
                      } ,),
                      timeslots[i].booked? const Text("Booked"): const Text("Available")
                    ],
                  ),
                )
              ],),
            ),
          )
          ]],
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            }
            else {
              return CircularProgressIndicator();
            }
          } 
          ,),
          
          
        ],
        ),
    );
  }
}