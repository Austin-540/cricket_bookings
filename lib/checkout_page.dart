import 'package:shc_cricket_bookings/home_page.dart';
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
  var balance = -1; // Initializing the balance variable with -1. will be updated once FutureBuilder resolves

  Future getPbPrices() async {
    // get the prices for the currently logged in price
    final pbCosts = await pb.collection('prices').getFullList(
      sort: '-created',
    );

    final userRecord = await pb.collection('users').getOne(pb.authStore.model.id,
          fields: "balance"
    );
    setState(() {
      balance = userRecord.data['balance']; // Updating the balance variable with the user's balance
    });

    // Now get my account type
    final myPermission = await pb.collection('users').getFirstListItem(
      'id = "${pb.authStore.model.id}"',
      fields: "permissions",
      expand: "permissions"
    );

    final foundPrice = pbCosts.firstWhere((x) => x.data['account_type'] == myPermission.data["permissions"]).data['price']; // Finding the price based on the account type
    return foundPrice;
  }

  Future? futureBldrData;
  @override
  void initState() {
    super.initState();
    futureBldrData = getPbPrices();
    //this is in the initState so that the function isn't called every time a setState is called
  }

  // ignore: non_constant_identifier_names
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
          Text("${widget.date.day}/${widget.date.month} ${widget.date.year}"), // Displaying the date of the booking in human readable format

          FutureBuilder(
            future: futureBldrData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData?Text("\$${snapshot.data*widget.timeslots.length}", style: TextStyle(
                fontSize: 30, color: balance==-1? null: balance < snapshot.data*widget.timeslots.length? Colors.red:null)): // Displaying the cost from the snapshot data and make it red if the balance is too low
                const Text("Getting the cost...");
            },
          ),
          Text(balance == -1?"Loading...":"Your balance: \$$balance"), // Displaying the balance

          OutlinedButton(onPressed: ()async{
            if (loading) {
              return;
            } // This means that pressing the button multiple times will not make multiple bookings

            setState(() {
              loading = true; // Show the loading circle
            });
            try {
              final userRecord = await pb.collection('users').getOne(pb.authStore.model.id,
              fields: "balance"
              );

              var balance = userRecord.data['balance']; // Updating the balance variable with the user's newest balance
              if (await getPbPrices() > balance) {
                throw "Balance is too low!"; // Throw an error if the balance is too low
                // Secondary to the check on the server side, not a security issue
              }

              for (final timeslot in widget.timeslots) {
                await pb.send("/api/shc/make_a_booking/${timeintToDateTime(timeslot['start_time'], widget.date, timeslot['am_or_pm']).toIso8601String()}/${timeintToDateTime(timeslot['end_time'], widget.date, timeslot['am_or_pm']).toIso8601String()}",
                method: "POST"); // Make a booking request to the custom API endpoint

                if (!context.mounted) return;

                // Go to home page without allowing to go back
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false,);
              }
            } catch (e) {
              setState(() {
                loading = false;
                showDialog(context: context, builder: (context) => ErrorDialog(error: e));
              });
            }
          }, child: loading?const CircularProgressIndicator():const Text("Book it")) // Display the button with a loading indicator or text depending on the loading variable
        ],),
      ),
    );
  }
}
