import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shc_cricket_bookings/login_page.dart';
import 'show_licenses.dart';
import 'globals.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key, required this.selected});
  bool? selected;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool hasPasskey = false;


  Future getAccountData() async{
    print("getting account page data...");
  final data = await pb.collection('users').getOne(pb.authStore.model.id,
    expand: 'permissions',
    // fields: 'email, pfp, permissions.name, webauthn_id_b64'
    );

    if (data.data['webauthn_id_b64'] != null && data.data['webauthn_id_b64'] != "") {
      hasPasskey = true;
    }
    return data;
  }
  Future? getAccountDatas;
  

  @override
  Widget build(BuildContext context) {
    if (getAccountDatas == null && widget.selected == true){
    getAccountDatas= getAccountData();}
    print("selected: ${widget.selected.toString()}");
    return widget.selected == null || widget.selected == false? const Text("Page isn't selected -- you shouldn't see this page"): Scaffold(
      appBar: AppBar(title: const Text("Your Account"), 
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {
        pb.authStore.clear();
        const FlutterSecureStorage().delete(key: "pb_auth");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage(defaultEmail: null,)), (route) => false);

      }, label: const Text("Logout"), icon: const Icon(Icons.logout),),

      body: FutureBuilder(
        future: getAccountDatas,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                ElevatedButton(onPressed: ()=>showLicenses(context), child: Text("App Info")),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 3),
                          left: BorderSide(width: 3),
                          bottom: BorderSide(width: 3),
                          right: BorderSide(width: 3),
                        )
                      ),
                      child: SvgPicture.network(snapshot.data.data['pfp'])),
                      Column(
                        children: [
                          Text(snapshot.data.data['email']),
                          Text(snapshot.data.expand['permissions'][0].data['name']),
                          Text("Account balance goes here"),
                          hasPasskey?
                          Text("Your account has a passkey"):
                          Text("Your account doesn't have a passkey")
                        ],
                      ),
                  ],
                )
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