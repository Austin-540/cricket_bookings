import 'package:flutter/material.dart';

class MonthAvailabilityView extends StatefulWidget {
  MonthAvailabilityView({super.key, required this.selected});
  bool selected;

  @override
  State<MonthAvailabilityView> createState() => _MonthAvailabilityViewState();
}

class _MonthAvailabilityViewState extends State<MonthAvailabilityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
    );
  }
}