import 'package:flutter/material.dart';
import 'globals.dart';
import 'checkout_page.dart';

class TimeSlot {
  // ignore: non_constant_identifier_names
  TimeSlot({required this.startTime, required this.endTime, required this.booked, required this.am_or_pm});
    final int startTime;
    final int endTime;
    bool booked;
    // ignore: non_constant_identifier_names
    final String am_or_pm;

}

class BookingPage extends StatefulWidget {
  BookingPage({super.key, required this.selected});
  bool selected;
  bool loadingAfterDateChange = false;
  

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<bool> checkboxesSelected = [];
  DateTime? datePicked = DateTime.now();
  Future? getTimeslots;

  Future getTheTimeslots() async {
      if (! widget.selected) {
        return;
      }
      var pbJSON = await pb.send("/api/shc/gettimeslots/${datePicked.day}/${datePicked.month}/${datePicked.year}");
      List pbSlots = pbJSON['slots'];

      pbSlots.sort((a, b) => a['start_time'].compareTo(b['start_time']));
      pbSlots.sort((a, b) => a['am_or_pm'].compareTo(b['am_or_pm']));

      setState(() {
        widget.loadingAfterDateChange = false;
      });

      return pbSlots;
      
      
  }


  @override
  Widget build(BuildContext context) {
    if (!widget.selected) {
      return const Text("Not Selected! You should not see this screen!");
    }
    getTimeslots ??= getTheTimeslots();

    
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: () async {
        List<dynamic> tslots = await getTimeslots;
        List<dynamic> selectedTimeslots =tslots.where((timeSlot) => checkboxesSelected[tslots.indexOf(timeSlot)]).toList();
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
          
          FutureBuilder(future: getTimeslots, 
          builder: (context, snapshot) {
            if (widget.loadingAfterDateChange) {
              return const Center(child:CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  ElevatedButton(onPressed: () async{
            DateTime? datePickerPicked = await showDatePicker(
              context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year+2));
            setState(() {
              datePicked = datePickerPicked ?? DateTime.now();
              widget.loadingAfterDateChange = true;
              getTimeslots = getTheTimeslots();
            });
          }, child: const Text("Pick a different date")),
          Text("Date selected: $datePicked"),
                  for (var i=0; i< snapshot.data.length; i++) ... [
              Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: [
                Text("${snapshot.data[i]['start_time']} - ${snapshot.data[i]['end_time']} ${snapshot.data[i]['am_or_pm']}", style: const TextStyle(fontSize: 40),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Checkbox(
                        
                        value: checkboxesSelected[i], onChanged: snapshot.data[i]['booked']? null:(value){
                          setState(() {
                            checkboxesSelected[i] = value!;
                          });
                      } ,),
                      snapshot.data[i]['booked']? const Text("Booked"): const Text("Available")
                    ],
                  ),
                )
              ],),
            ),
          )
          ]],
              );
            } else if (snapshot.hasError) {
              return Column(
                children: [
                  const Icon(Icons.error_outline),
                  Text(snapshot.error.toString())
                ],
              );
            }
            else {
              return const Center(child: CircularProgressIndicator());
            }
          } 
          ,),
          
          
        ],
        ),
    );
  }
}