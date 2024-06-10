import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shc_cricket_bookings/login_page.dart';
import 'show_licenses.dart';
import 'globals.dart';
import 'package:flutter/material.dart';
import 'topup_page.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key, required this.selected});
  bool? selected;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool hasPasskey = false;


  Future getAccountData() async{
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
            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 3),
                          left: BorderSide(width: 3),
                          bottom: BorderSide(width: 3),
                          right: BorderSide(width: 3),
                        )
                      ),
                      child: SvgPicture.network(snapshot.data.data['pfp'])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.email_outlined),
                        ),
                        Text(snapshot.data.data['email']),
                      ],
                    ),
                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.account_tree_outlined),
                                  ),
                                  Text(snapshot.data.expand['permissions'][0].data['name']),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.account_balance_outlined),
                                  ),
                                  Text("\$${snapshot.data.data['balance']}"),
                                  TextButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => TopupPage())), child: Text("Redeem a topup code"))
                                ],
                              ),
                            ),
                            const Spacer(),
                  TextButton(onPressed: ()=>showLicenses(context), child: const Text("App Info")),
                ],
              ),
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