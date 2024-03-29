import 'package:shc_cricket_bookings/login_page.dart';
import 'account_page.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future checkVerified() async {
  final record = await pb.collection('users').getOne(pb.authStore.model.id,
  fields: "email, verified"
);

  if (!record.data['verified']){
    await pb.collection('users').requestVerification(record.data['email']);
    showDialog(context: context,
    barrierDismissible: false,
     builder: (context) => AlertDialog(
      title: const Text("Your email isn't verified"),
      content: const Text("You have been sent a new link to verify your email. You cannot continue without doing this step."),
      actions: [
        TextButton(onPressed: (){
          pb.authStore.clear();
          const FlutterSecureStorage().delete(key: "pb_auth");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
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

  }

  @override
  void initState() {
    super.initState();
    checkVerified();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Placeholder(fallbackHeight: 40, fallbackWidth: 200,),
      actions: [
        IconButton(icon: Icon(Icons.account_circle_outlined), onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));

        },)
        
        
        ],),

    );
  }
}


