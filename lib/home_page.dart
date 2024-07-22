import 'dart:convert';
import 'package:shc_cricket_bookings/month_availability_view.dart';

import 'booking_page.dart';
import 'package:shc_cricket_bookings/login_page.dart';
import 'account_page.dart';
import 'globals.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  

  Future setupPBAuth() async {
    final String? pbAuth = await const FlutterSecureStorage().read(key: "pb_auth");
    if (pbAuth != null) {
      final decoded = jsonDecode(pbAuth);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model = RecordModel.fromJson(
        decoded["model"] as Map<String, dynamic>? ?? {});
      pb.authStore.save(token, model);}
  }
  Future checkVerified() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try{
      final record = await pb.collection('users').getOne(pb.authStore.model.id,
  fields: "email, verified"
);

  if (!record.data['verified']){
    await pb.collection('users').requestVerification(record.data['email']);
    if (!mounted) return;
    showDialog(context: context,
    barrierDismissible: false,
     builder: (context) => AlertDialog(
      title: const Text("You're almost done"),
      content: const Text("You have been sent a link to verify your email. You cannot continue without doing this step."),
      actions: [
        TextButton(onPressed: (){
          pb.authStore.clear();
          const FlutterSecureStorage().delete(key: "pb_auth");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage(defaultEmail: null,)), (route) => false);
        }, child: const Text("Log out")),
        TextButton(onPressed: () async {  
          final verified = await pb.collection('users').getOne(
            pb.authStore.model.id,
            fields: "verified"
          );
          if (verified.data['verified']) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Thanks for verifying your email :)"))
            );
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
          }
          else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Your email isn't verified!"))
            );
          }
        }, child: const Text("Done"))
      ],
     ));

  }
    } catch(e) {
      if (!pb.authStore.isValid) {
        final String? email = pb.authStore.model.data['email'];
        await const FlutterSecureStorage().delete(key: "pb_auth");
        pb.authStore.clear();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(defaultEmail: email)), (route) => false);
      } else {
        if (!mounted) return;
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("Something went wrong logging in"),
        content: Text("${e.toString()}\n\nYou can either log out or try refreshing"),
        actions: [TextButton(onPressed: () {
          pb.authStore.clear();
        const FlutterSecureStorage().delete(key: "pb_auth");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage(defaultEmail: null,)), (route) => false);
        }, child: const Text("Log Out"))],
      ));
      }
    }
  

  }

  @override
  void initState() {
    super.initState();
    setupPBAuth();
    checkVerified();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int i) {
            setState(() {
              currentPageIndex = i;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: currentPageIndex,
          destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: "Make a booking"),
          NavigationDestination(icon: Icon(Icons.view_comfy_outlined), label: "See availability"),
          NavigationDestination(icon: Icon(Icons.account_box_outlined), label: "Your account")
        ],),

        body: IndexedStack(index: currentPageIndex,
        children: [
          HomePagePage(selected: currentPageIndex==0?true:false,),
          BookingPage(selected: currentPageIndex==1?true:false, comingFromCalendarView: false, comingFromCalendarDate: null,),
          MonthAvailabilityView(selected: currentPageIndex==2?true:false),
          AccountPage(selected: currentPageIndex==3?true:false)
        ],),

    );
  }
}



// ignore: must_be_immutable
class HomePagePage extends StatefulWidget {
  HomePagePage({super.key, required this.selected});
  bool selected;

  @override
  State<HomePagePage> createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePagePage> {

  Future? upcomingBookings;

  Future getUpcomingBookings() async {
      final resultList = await pb.collection('bookings').getList(
  page: 1,
  perPage: 50,
  filter: 'booker = "${pb.authStore.model.id}"',
);

  resultList.items.sort((a, b) => a.data['start_time'].compareTo(b.data['start_time']));

      return resultList.items;
  }


  @override
  void initState() {
    super.initState();

    upcomingBookings = getUpcomingBookings();
  }
  @override
  Widget build(BuildContext context) {
    if (!widget.selected) {
      return const Text("Not selected");
    }


    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: ListView(children: [
        const Text("Your upcoming bookings"),
        FutureBuilder(
          future: upcomingBookings,
          // initialData: InitialData, //Maybe this line will be useful for a hero animation
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(),);
            }
            return Column(children: 
            [

              for (int x = 0; x < snapshot.data.length; x++) ... [
                Hero(
                  tag: "booking_time ${DateTime.parse(snapshot.data[x].data['start_time'])}",
                  child: UpcomingBookingCard(time:snapshot.data[x].data['start_time'], bookingDetails: snapshot.data[x],),
            )],
            ],);
          },
        ),
      ],),

    );
  }
}

class UpcomingBookingCard extends StatefulWidget {
  const UpcomingBookingCard({
    super.key, required this.time, required this.bookingDetails
  });

  final String time;
  final RecordModel bookingDetails;

  @override
  State<UpcomingBookingCard> createState() => _UpcomingBookingCardState();
}

class _UpcomingBookingCardState extends State<UpcomingBookingCard> {
  DateTime? parsedTime;

  @override
  void initState() {
    super.initState();
    parsedTime= DateTime.parse(widget.time);
    
  }

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        Text("${parsedTime!.day} ${["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][parsedTime!.month-1]} ${parsedTime!.year}"),
        const SizedBox(width: 30,),
        Text(parsedTime!.hour<12?"${parsedTime!.hour}:00 AM":"${parsedTime!.hour -12}:00 PM "),
        const Spacer(),
        PopupMenuButton(
          onSelected: (item) => showDialog(barrierColor: const Color.fromARGB(51, 253, 17, 0),barrierDismissible: false,context: context, builder: (context) => CancelBookingDialog(details: widget.bookingDetails)),
          itemBuilder: (context) => [
          const PopupMenuItem(value:"Cancel", child: ListTile(leading: Icon(Icons.delete_outline), title: Text("Cancel Booking")))
        ])
      ],),
    ),);
  }
}



class CancelBookingDialog extends StatefulWidget {
  const CancelBookingDialog({super.key, required this.details});
  final RecordModel details;

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Cancel this booking?"),
      content: Text(widget.details.data['cost'] != 0?"You will be refunded \$${widget.details.data['cost']} onto your account balance.":""),
      actions: [
        !loading?TextButton(onPressed: () => Navigator.pop(context), child: const Text("Nevermind")): const SizedBox(),
        TextButton(onPressed: () async {
          if (loading) {
            return;
          }
          setState(() {
            loading = true;
          });

          try {
          await pb.send("/api/shc/cancelbooking/${widget.details.id}");
          await Future.delayed(const Duration(milliseconds: 500));
          if (!context.mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
          } catch (e) {
            setState(() {
              loading = false;
            });
            showDialog(context: context, builder: (context) => ErrorDialog(error: e));
          }


        }, child: loading?const CircularProgressIndicator(color: Colors.red,):const Text("Cancel it", style: TextStyle(color: Colors.red),),)
      ],
    );
  }
}