// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'globals.dart';
import 'signup_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: SizedBox(height: 150, width: 150,child: Placeholder(),)),
        ),
        LoginPageForm(),
        OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())), child: Text("Make an account"))
      ],),
    );
  }
}

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key});

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {

  Future tryLogIn() async {
    const storage = FlutterSecureStorage();
    // ignore: non_constant_identifier_names
    final String? pb_auth = await storage.read(key: "pb_auth");
    if (pb_auth != null) {
      final decoded = jsonDecode(pb_auth);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model = RecordModel.fromJson(
        decoded["model"] as Map<String, dynamic>? ?? {});
      pb.authStore.save(token, model);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, _createRoute(), (route) => false);
    }
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
  const end = Offset.zero;
  var curve = Curves.easeOutCubic;
  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween), child: child,);
      }
      );
  }


  @override
  void initState() {
    super.initState();
    tryLogIn();
  }

  String email = "";
  String password = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(filled: true,
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
            label: Text("Email")
            ),
            onChanged: (value) => email = value,
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(filled: true,
            prefixIcon: Icon(Icons.password_outlined),
            border: OutlineInputBorder(),
            label: Text("Password")
            ),
            onChanged: (value) => password = value,
          ),
        ),

        FilledButton.tonal(onPressed: () async {

          setState(() {
            loading = true;
          });
          try{
            await pb.collection('users').authWithPassword(
           email, password,
          );

          const storage = FlutterSecureStorage();

            final encoded = jsonEncode(<String, dynamic>{
              "token": pb.authStore.token,
              "model": pb.authStore.model,
            });
            await storage.write(key: "pb_auth", value: encoded);
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> HomePage()), (route) => false);


          } catch (e) {
            setState(()=> loading = false);
            if (!mounted) return;
            showDialog(context: context, 
            builder: (context) => AlertDialog(
              title: Text("Something went wrong :/"),
              content: Text(e.toString()),
              actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("OK"))],
            ));

            
          }
          

          }, 
          child: loading? Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ): Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Login"),
          ))
      ],
    );
  }
}