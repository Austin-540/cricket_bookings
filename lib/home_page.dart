import 'dart:convert';
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
    final String? pb_auth = await const FlutterSecureStorage().read(key: "pb_auth");
    if (pb_auth != null) {
      final decoded = jsonDecode(pb_auth);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model = RecordModel.fromJson(
        decoded["model"] as Map<String, dynamic>? ?? {});
      pb.authStore.save(token, model);}
  }
  Future checkVerified() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try{
      final pbAuthModel = pb.authStore.model;
      print(pb.authStore.model.toString());
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Thanks for verifying your email :)"))
            );
            Navigator.pop(context);
          }
          else {
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
        await FlutterSecureStorage().delete(key: "pb_auth");
        pb.authStore.clear();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(defaultEmail: email)), (route) => false);
      } else {
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
          selectedIndex: currentPageIndex,
          destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: "Make a booking"),
          NavigationDestination(icon: Icon(Icons.view_comfy_outlined), label: "See availability"),
          NavigationDestination(icon: Icon(Icons.account_box_outlined), label: "Your account")
        ],),

        body: IndexedStack(index: currentPageIndex,
        children: [
          Placeholder(),
          BookingPage(selected: currentPageIndex==1?true:false),
          Placeholder(),
          AccountPage(selected: currentPageIndex==3?true:false)
        ],),

    );
  }
}


