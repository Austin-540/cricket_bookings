import 'package:flutter/material.dart';
import 'package:shc_cricket_bookings/booking_page.dart';
import 'globals.dart';
import 'package:calendar_view/calendar_view.dart';

class MonthAvailabilityView extends StatefulWidget {
  MonthAvailabilityView({super.key, required this.selected});
  bool selected;

  @override
  State<MonthAvailabilityView> createState() => _MonthAvailabilityViewState();
}

class _MonthAvailabilityViewState extends State<MonthAvailabilityView> {
  DateTime datePicked = DateTime.now();

  int getDaysInMonth(int year, int month) {
if (month == DateTime.february) {
  final bool isLeapYear = (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  return isLeapYear ? 29 : 28;
}
const List<int> daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
return daysInMonth[month - 1];
}


  Future getAvailabilityForTheMonth() async {
    final response =  await pb.send("/api/shc/gettimeslotsmonth/${datePicked.month}/${datePicked.year}");
    print(response);

    for (var day in List.generate(getDaysInMonth(datePicked.year, datePicked.month), (i) => i)) {
      if (response['newMap'].keys.contains(day.toString())) {
        
      } else {
      final event = CalendarEventData(
        title: "${response['slotsAvailablePerDay']}",
    date: DateTime(datePicked.year, datePicked.month, day),
    event: "Event 1",
    color: Colors.greenAccent,
    titleStyle: TextStyle(color: Colors.black)
);
      CalendarControllerProvider.of(context).controller.add(event);
      }
    }


    response['newMap'].forEach((key, value) {
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
    event: "Event 1",
    color: colour
);
setState(() {
CalendarControllerProvider.of(context).controller.add(event);
});

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
    if (!widget.selected) {
      return SizedBox();
    }
    return Scaffold(
      body: MonthView(
        cellAspectRatio: 0.9,
            onPageChange: (date, page) {
            setState(() {
            datePicked = date;
            getAvailabilityForTheMonth();
            });
          },

          onCellTap: (events, date) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(selected: true, comingFromCalendarDate: date, comingFromCalendarView: true,)));
            //add the ability to go to the selected date
          },
          onEventTap: (event, date) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(selected: true, comingFromCalendarDate: date, comingFromCalendarView: true,)));
            //add the ability to go to the selected date
          },
          
          
          )
      
    );
  }
}