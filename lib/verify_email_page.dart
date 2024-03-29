import 'package:flutter/material.dart';
import 'package:shc_cricket_bookings/signup_page.dart';
import 'globals.dart';
import 'home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.email});
  final String email;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Future isVerified = pb.collection('users').getOne(pb.authStore.model.id, fields: "verified");

  @override
  void initState() {
    super.initState();
    pb.collection('users').requestVerification(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_outlined), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupPage())),),
        title: const Text("Verify your email"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder(
        future: isVerified, builder: (context, snapshot) {
          if (snapshot.hasData) {
            //here double check it hasn't been verified yet
            return TellToVerifyEmail(email: widget.email,);
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text("Something went wrong :/"),
              content: Text(snapshot.error.toString()),
            );
          } else {
            return const Center(child: CircularProgressIndicator(),);
          }
        }),
    );
  }
}

class TellToVerifyEmail extends StatelessWidget {
  const TellToVerifyEmail({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(child: Text("Please click the link sent to\n$email", textAlign: TextAlign.center,)),
            ElevatedButton(onPressed: () async {
        
            final record = await pb.collection('users').getOne(pb.authStore.model.id, fields: "verified");
            if (record.data['verified']) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
            } else {
              showDialog(context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Your email isn't verified"),
                content: const Text("Click the link sent to your email, or click the < button at the top left of this page to type a different email"),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"),)],
              ));
            }
            }, child: const Text("Done"))
          ],
        ),
      ),
    );
  }
}
