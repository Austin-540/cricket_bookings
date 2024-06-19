import 'package:shc_cricket_bookings/home_page.dart';

import 'booking_page.dart';
import 'package:flutter/material.dart';
import 'globals.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key, required this.timeslots, required this.date});
  final DateTime date;
  final List<dynamic> timeslots;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  var balance = -1;

  Future getPbPrices() async {
    final pbCosts = await pb.collection('prices').getFullList(
  sort: '-created',
);

    final userRecord = await pb.collection('users').getOne(pb.authStore.model.id,
          fields: "balance"
          );
          setState(() {
          balance = userRecord.data['balance'];
          });


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

  DateTime timeintToDateTime(int time, DateTime date, String am_or_pm) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      am_or_pm == "PM"? 12+time: time,
    );
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
        body: Center(
          child: Column(children: [
            for (int i = 0; i < widget.timeslots.length; i++) ... [
              Hero(
                tag: "booking_time ${widget.date}",
                child: Material(
                  child: Text("${widget.timeslots[i]['start_time']} - ${widget.timeslots[i]['end_time']} ${widget.timeslots[i]['am_or_pm']}", 
                  style: const TextStyle(fontSize: 50),),
                ),
              ),
            ],
            Text("${widget.date.day}/${widget.date.month} ${widget.date.year}"),
          
            FutureBuilder(
              future: futureBldrData,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return snapshot.hasData?Text("\$${snapshot.data*widget.timeslots.length}", style: TextStyle(
                  fontSize: 30, color: balance==-1? null: balance < snapshot.data*widget.timeslots.length? Colors.red:null)):
                  const Text("Getting the cost...");
              },
            ),
            Text(balance == -1?"Loading...":"Your balance: \$${balance}"),
          
              OutlinedButton(onPressed: ()async{
                if (loading) {
                  return;
                } //This means that pressing the button multiple times will not make multiple bookings
                
                setState(() {
                loading = true;
                });
          try {
          
          final userRecord = await pb.collection('users').getOne(pb.authStore.model.id,
          fields: "balance"
          );
          
          var balance = userRecord.data['balance'];
          if (await getPbPrices() > balance) {
            throw "Balance is too low!";
          }
          
          
                for (final timeslot in widget.timeslots) {
          
                  
          final body = <String, dynamic>{
            "booker": pb.authStore.model.id,
            "start_time": timeintToDateTime(timeslot['start_time'], widget.date, timeslot['am_or_pm']).toIso8601String(),
            "end_time": timeintToDateTime(timeslot['end_time'], widget.date, timeslot['am_or_pm']).toIso8601String(),
            "cost": -1 //this number will be written by PB hooks to ensure bookings cannot be made without paying
            //the purpose of the cost field is to ensure any discounts are taken into account when issuing a refund
          };
          
          final record = await pb.collection('bookings').create(body: body);
          setState(() {
          loading = false;
          
          });
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false,);
                }}
                catch (e) {
                  setState(() {
                    loading = false;
                    showDialog(context: context, builder: (context) => AlertDialog(
                      title: const Text("Something went wrong"),
                      content: Text(e.toString()),
                    ));
                  });
                }
                
              }, child: loading?const CircularProgressIndicator():const Text("Book it")) 
          ],),
        ),
    );
  }
}