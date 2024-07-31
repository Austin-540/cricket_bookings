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
    final String am_or_pm; // either "AM" or "PM" or "Noon"

}

// ignore: must_be_immutable
class BookingPage extends StatefulWidget {
  BookingPage({super.key, required this.selected, required this.comingFromCalendarView, required this.comingFromCalendarDate});
  bool selected; // determines if the loading spinner is shown
  bool loadingAfterDateChange = false;
  final bool comingFromCalendarView;
  final DateTime? comingFromCalendarDate;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<bool> checkboxesSelected = []; // initialise List of selected checkboxes
  DateTime? datePicked;
  Future? getTimeslots;
  bool firstTimeOpened = true;
  String appBarTitle = "Book a timeslot"; // The default title of the app bar, can be dynamically changed

  @override
  void initState() {
    super.initState();
    if (!widget.comingFromCalendarView) {
      // If opened through the bottom nav bar, the default dateTime is now
      datePicked = DateTime.now();
    } else {
      // Otherwise its the date from the calendar view
      datePicked = widget.comingFromCalendarDate;
    }
  }

  Future getDatePicked() async{
    await Future.delayed(const Duration(milliseconds: 100));
    DateTime? datePickerPicked;
    if (!widget.comingFromCalendarView){
      if (!mounted) return;
      datePickerPicked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year+2));
    } else {
      datePickerPicked = widget.comingFromCalendarDate;
    }
    if (datePickerPicked != null) {
      // If datePickerPicked is null, then the variable the UI uses to show the date (datePicked) isn't updated
      setState(() {
      datePicked = datePickerPicked;
      widget.loadingAfterDateChange = true;
      getTimeslots = getTheTimeslots();
      });
    }
  }

  Future getTheTimeslots() async {
    // appBarTitle is (D)D-(M)M-YYYY format
      appBarTitle = "${datePicked!.day}-${datePicked!.month}-${datePicked!.year}";
      if (! widget.selected) {
        return;
      }
      var pbJSON = await pb.send("/api/shc/gettimeslots/${datePicked!.day}/${datePicked!.month}/${datePicked!.year}");
      List pbSlots = pbJSON['slots'];

      pbSlots.sort((a, b) => a['start_time'].compareTo(b['start_time']));
      pbSlots.sort((a, b) => a['am_or_pm'].compareTo(b['am_or_pm']));
      // Sort the timeslots by start_time then am_or_pm, resulting in an overall sort of earliest to latest

      setState(() {
        widget.loadingAfterDateChange = false;
        checkboxesSelected = List.filled(pbSlots.length, false);
      });

      return pbSlots;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.selected) {
      return const Text("Not Selected! You should not see this screen!");
    }
    if (firstTimeOpened) {
      getDatePicked();
      firstTimeOpened = false;
    }
    getTimeslots ??= getTheTimeslots();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(onPressed: () async {
        List<dynamic> tslots = await getTimeslots;
        List<dynamic> selectedTimeslots =tslots.where((timeSlot) => checkboxesSelected[tslots.indexOf(timeSlot)]).toList();
        if (selectedTimeslots.isEmpty) {
          if (!context.mounted) return;
          // If the user hasn't selected any timeslots, dont let them checkout
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You need to select at least 1 timeslot"),));
        } else {
          if (!context.mounted) return;
          // Go to checkout page
        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(timeslots: selectedTimeslots, date: datePicked!)));
        }
      }, label: const Text("Checkout"), icon: const Icon(Icons.shopping_cart_outlined),),
      appBar: AppBar(
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(appBarTitle),
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
                  !widget.comingFromCalendarView?
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async{
            DateTime? datePickerPicked = await showDatePicker(
              context: context, firstDate: DateTime.now(), lastDate: DateTime(DateTime.now().year+2));
            setState(() {
              datePicked = datePickerPicked ?? datePicked;
              widget.loadingAfterDateChange = true;
              getTimeslots = getTheTimeslots();
            });
          }, label: const Text("Pick a different date")):const SizedBox(),
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
                            // Update the checkboxes list to reflect the new value
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
          ],
          const SizedBox(height: 80,)],
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
