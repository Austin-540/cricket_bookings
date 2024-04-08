import 'dart:convert';

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
    await Future.delayed(const Duration(milliseconds: 500));
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
      title: const Text("Your email isn't verified"),
      content: const Text("You have been sent a new link to verify your email. You cannot continue without doing this step."),
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

  @override
  void initState() {
    super.initState();
    setupPBAuth();
    checkVerified();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Placeholder(fallbackHeight: 40, fallbackWidth: 200,),
      actions: [
        IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountPage()));

        },)
        
        
        ],),

    );
  }
}


