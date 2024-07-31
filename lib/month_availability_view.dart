import 'package:flutter/material.dart';
import 'package:shc_cricket_bookings/booking_page.dart';
import 'globals.dart';
import 'package:calendar_view/calendar_view.dart';

// ignore: must_be_immutable
class MonthAvailabilityView extends StatefulWidget {
  MonthAvailabilityView({super.key, required this.selected});
  bool selected;

  @override
  State<MonthAvailabilityView> createState() => _MonthAvailabilityViewState();
}

class _MonthAvailabilityViewState extends State<MonthAvailabilityView> {
  DateTime datePicked = DateTime.now();
  double ratio = 1;

  int getDaysInMonth(int year, int month) {
if (month == DateTime.february) {
  final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  return isLeapYear ? 29 : 28;
}
const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
return daysInMonth[month - 1];
}


  Future getAvailabilityForTheMonth() async {
    // ask the custom API endpoint for the availability of the month
    final response =  await pb.send("/api/shc/gettimeslotsmonth/${datePicked.month}/${datePicked.year}");

    for (var day in List.generate(getDaysInMonth(datePicked.year, datePicked.month), (i) => i+1)) {
      if (response['newMap'].keys.contains(day.toString())) {
        
      } else {
        if (DateTime(datePicked.year, datePicked.month, day).compareTo(DateTime.now()) > 0 || DateTime(datePicked.year, datePicked.month, day).compareWithoutTime(DateTime.now())) {

        //add an event to the CalendarController (in main.dart)
      final event = CalendarEventData(
        title: "${response['slotsAvailablePerDay']}",
    date: DateTime(datePicked.year, datePicked.month, day),
    event: "Event 1",
    color: Colors.greenAccent,
    titleStyle: const TextStyle(color: Colors.black)
);
if (!mounted) return;
      CalendarControllerProvider.of(context).controller.add(event);
        }
      }
    }




    response['newMap'].forEach((key, value) {
       if (DateTime(datePicked.year, datePicked.month, int.parse(key)).compareTo(DateTime.now()) > 0 || DateTime(datePicked.year, datePicked.month, int.parse(key)).compareWithoutTime(DateTime.now())) {

var colour = Colors.purple;

      if (response['slotsAvailablePerDay'] - value >= 6) {
        colour = Colors.green;
      } else if (response['slotsAvailablePerDay'] - value >= 3) {
        colour = Colors.orange;
      } else {
        colour = Colors.red;
      }
      final day = int.parse(key);
      final event = CalendarEventData(
        title: "${response['slotsAvailablePerDay']-value} Avaliable",
    date: DateTime(datePicked.year, datePicked.month, day),
    event: "Slots",
    color: colour
);
setState(() {
CalendarControllerProvider.of(context).controller.add(event);
});}
        
      

    });
    return response;

  }

  Future? availabilityForTheMonth;
  @override
  void initState() {
    super.initState();

    availabilityForTheMonth = getAvailabilityForTheMonth();
  }


  @override
  Widget build(BuildContext context) {
    ratio = MediaQuery.sizeOf(context).width/500;
    if (!widget.selected) {
      return const SizedBox();
    }
    return Scaffold(
      body: MonthView(
        initialMonth: datePicked,
        cellAspectRatio: ratio,
            onPageChange: (date, page) {
              CalendarControllerProvider.of(context).controller.removeWhere((element) => true);
            setState(() {
            datePicked = date;
            getAvailabilityForTheMonth();
            });
          },

          onCellTap: (events, date) {
            if (date.compareTo(DateTime.now()) <= 0 && !date.compareWithoutTime(DateTime.now())) {
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(selected: true, comingFromCalendarDate: date, comingFromCalendarView: true,)));
          },
          onEventTap: (event, date) {
            if (date.compareTo(DateTime.now()) <= 0) {
              return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(selected: true, comingFromCalendarDate: date, comingFromCalendarView: true,)));
          },

          minMonth: DateTime.now(), //don't let people see previous months
          
          
          )
      
    );
  }
}