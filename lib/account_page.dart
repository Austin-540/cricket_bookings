import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shc_cricket_bookings/login_page.dart';
import 'show_licenses.dart';
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
      appBar: AppBar(title: const Text("Your Account"), 
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        pb.authStore.clear();
        const FlutterSecureStorage().delete(key: "pb_auth");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage(defaultEmail: null,)), (route) => false);

      }, label: const Text("Logout"), icon: const Icon(Icons.logout),),

      body: FutureBuilder(
        future: accountData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Text(snapshot.data.toString()),
                ElevatedButton(onPressed: ()=>showLicenses(context), child: Text("App Info"))
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Something went wrong getting your account data.\n${snapshot.error.toString()}");
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        
      ),);
    
  }
}