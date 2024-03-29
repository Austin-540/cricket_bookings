import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shc_cricket_bookings/login_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Account"), 
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        pb.authStore.clear();
        FlutterSecureStorage().delete(key: "pb_auth");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);

      }, label: Text("Logout"), icon: Icon(Icons.logout),),
    );
  }
}