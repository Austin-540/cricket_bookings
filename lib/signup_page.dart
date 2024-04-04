import 'dart:convert';

import 'package:shc_cricket_bookings/verify_email_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: const Column(children: [
        SignupPageForm()
      ],),

    );
  }
}



class SignupPageForm extends StatefulWidget {
  const SignupPageForm({super.key});

  @override
  State<SignupPageForm> createState() => _SignupPageFormState();
}

class _SignupPageFormState extends State<SignupPageForm> {
  String email = "";
  String password = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofillHints: [AutofillHints.email],
              decoration: const InputDecoration(filled: true,
              hintText: "Use your SHC email if you have one",
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              label: Text("Email")
              ),
              onChanged: (value) => email = value,
            ),
          ),
      
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofillHints: [AutofillHints.password],
              obscureText: true,
              decoration: const InputDecoration(filled: true,
              prefixIcon: Icon(Icons.password_outlined),
              border: OutlineInputBorder(),
              label: Text("Password")
              ),
              onChanged: (value) { password = value;}
            ),
          ),
      
          FilledButton.tonal(onPressed: () async {
            if (email == "" || password == "") return;
      
            setState(() {
              loading = true;
            });
            try{
              await pb.collection('users').create(body: 
              {
                "email": email,
                "password": password,
                "passwordConfirm": password,
                "emailVisibility": true,
                "permissions": "bio1uv9wg3ibr00"
              });
      
              await pb.collection('users').authWithPassword(email, password);
      
            const storage = FlutterSecureStorage();
      
              final encoded = jsonEncode(<String, dynamic>{
                "token": pb.authStore.token,
                "model": pb.authStore.model,
              });
              await storage.write(key: "pb_auth", value: encoded);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VerifyEmailPage(email: email)),);
      
      
            } catch (e) {
              setState(()=> loading = false);
              if (!mounted) return;
              showDialog(context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Something went wrong :/"),
                content: Text(e.toString()),
                actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))],
              ));
      
              
            }
            
      
            }, 
            child: loading? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ): const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Sign up"),
            ))
        ],
      ),
    );
  }
}