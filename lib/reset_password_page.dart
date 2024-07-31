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
          // Check if the email field is empty. If it is then exit the function early
          if (email == "") return;

          try {
            // Request password reset using the provided email
            await pb.collection('users').requestPasswordReset(email);

            // Check if the widget is still mounted before showing the dialog
            if (!context.mounted) return;

            // Show a success dialog with instructions for the user if they could successfully login
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Check your emails"),
                content: const Text("You've been sent an email to reset your password. It could take a few minutes to arrive."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(defaultEmail: email)),
                      (route) => false,
                    ),
                    child: const Text("Done"),
                  ),
                ],
              ),
            );
          } catch (e) {
            // Show an error dialog if something goes wrong, with the error details
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Something went wrong :/"),
                content: Text(e.toString()),
              ),
            );
          }

        }, child: const Text("Reset Password"))
      ],),
    );
  }
}