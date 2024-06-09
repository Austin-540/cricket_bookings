import 'booking_page.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.timeslots, required this.date});
  final DateTime date;
  final List<TimeSlot> timeslots;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {

  Future getPbPrices() async {
    final pbCosts = await pb.collection('prices').getFullList(
  sort: '-created',
);


    //now get my account type

    final myPermission = await pb.collection('users').getFirstListItem(
  'id = "${pb.authStore.model.id}"',
  fields: "permissions",
  expand: "permissions"
);


  final foundPrice = pbCosts.firstWhere((x) => x.data['account_type'] == myPermission.data["permissions"]).data['price'];
  return foundPrice;
  }
  Future? futureBldrData;
  @override
  void initState() {
    super.initState();
    futureBldrData = getPbPrices();
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
        body: Column(children: [
          for (int i = 0; i < widget.timeslots.length; i++) ... [
            Text("${widget.timeslots[i].startTime} - ${widget.timeslots[i].endTime} ${widget.timeslots[i].am_or_pm}", 
            style: const TextStyle(fontSize: 50),),
          ],
          Text("${widget.date.day}/${widget.date.month} ${widget.date.year}"),

          FutureBuilder(
            future: futureBldrData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData?Text("\$${snapshot.data*widget.timeslots.length}", style: const TextStyle(fontSize: 30)):const Text("Getting the cost...");
            },
          ),

            OutlinedButton(onPressed: ()async{
              if (loading) {
                return;
              } //This means that pressing the button multiple times will not make multiple bookings
              setState(() {
              loading = true;
              });
              final body = <String, dynamic>{
  "booker": "RELATION_RECORD_ID",
  "start_time": "2022-01-01 10:00:00.123Z",
  "end_time": "2022-01-01 10:00:00.123Z",
  "cost": 123
};

final record = await pb.collection('bookings').create(body: body);
            }, child: loading?const CircularProgressIndicator():const Text("Book it")) 
        ],),
    );
  }
}