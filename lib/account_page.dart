import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shc_cricket_bookings/login_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  
  Future accountData = pb.collection('users').getOne(pb.authStore.model.id,
  expand: 'permissions',
);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Account"), 
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        pb.authStore.clear();
        FlutterSecureStorage().delete(key: "pb_auth");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage(defaultEmail: null,)), (route) => false);

      }, label: Text("Logout"), icon: Icon(Icons.logout),),

      body: FutureBuilder(
        future: accountData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Text(snapshot.data.toString())
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Something went wrong getting your account data.\n${snapshot.error.toString()}");
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        
      ),);
    
  }
}