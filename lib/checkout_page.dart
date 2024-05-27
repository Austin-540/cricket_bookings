import 'booking_page.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.timeslots});
  final List<TimeSlot> timeslots;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout"),),
        body: Column(children: [
          for (int i = 0; i < widget.timeslots.length; i++) ... [
            Text("${widget.timeslots[i].startTime} - ${widget.timeslots[i].endTime} ${widget.timeslots[i].am_or_pm}"),
          ],
            Text("Cost goes here"),
            OutlinedButton(onPressed: (){
              //code for making a booking goes here
            }, child: Text("Book it"))
        ],),
    );
  }
}