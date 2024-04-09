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
      appBar: AppBar(title: Text("Reset Password"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),


      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            autofillHints: [AutofillHints.email],
            decoration: InputDecoration(
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
              title: Text("Check your emails"),
              content: Text("You've been sent an email to reset your password. It could take a few minutes to arrive."),
              actions: [TextButton(onPressed: ()=>Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>LoginPage(defaultEmail: email)), (route) => false), child: Text("Done"))],
             ));
          } catch (e) {
            showDialog(context: context,
             builder: (context) => AlertDialog(
              title: Text("Something went wrong :/"),
              content: Text(e.toString()),
             ));
          }

        }, child: Text("Reset Password"))
      ],),
    );
  }
}