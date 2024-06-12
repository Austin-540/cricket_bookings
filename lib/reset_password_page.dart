import 'package:flutter/material.dart';
import 'package:shc_cricket_bookings/login_page.dart';
import 'globals.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),


      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              filled: true,
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
              label: Text("Email")
            ),
            onChanged: (value) => email = value,
          ),
        ),
        OutlinedButton(onPressed: ()async {
          if (email == "") return;
          try {
          await pb.collection('users').requestPasswordReset(email);
          showDialog(context: context,
             builder: (context) => AlertDialog(
              title: const Text("Check your emails"),
              content: const Text("You've been sent an email to reset your password. It could take a few minutes to arrive."),
              actions: [TextButton(onPressed: ()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginPage(defaultEmail: email)), (route) => false), child: const Text("Done"))],
             ));
          } catch (e) {
            showDialog(context: context,
             builder: (context) => AlertDialog(
              title: const Text("Something went wrong :/"),
              content: Text(e.toString()),
             ));
          }

        }, child: const Text("Reset Password"))
      ],),
    );
  }
}