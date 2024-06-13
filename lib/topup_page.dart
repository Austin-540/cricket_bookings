import 'package:shc_cricket_bookings/home_page.dart';

import 'globals.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  String code = "";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Topup"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                decoration: const InputDecoration(
              filled: true,
              prefixIcon: Icon(Icons.wallet_giftcard_outlined),
              border: OutlineInputBorder(),
              label: Text("Topup code"),
              error: null //Use this when the topup codes have a fixed length
              
            ),
            onChanged: (value) => code = value,),
          ),
          ElevatedButton(onPressed: ()async{
            try {
            final code_data = await pb.send("/api/shc/topup/getdetails", body: {"data": code}, method: "POST");
              final email_data = await pb.collection('users').getOne(pb.authStore.model.id,
              fields: "email"
    );
              if (code_data['redeemed'] == true) {
                throw "This code has already been redeemed";
              }
            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) => AlertDialog(
              title: Text("Redeem this \$${code_data['value']} code?"),
              content: Text("It will be added to your account (${email_data.data['email']})"),
              actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text("Nevermind")),
              TextButton(onPressed: () async {
                try {
                final pbResponse = await pb.send("/api/shc/topup/usecode/${pb.authStore.model.id}", method: "POST", body: {"data": code});
                print(pbResponse);
                Navigator.pop(context);
                Navigator.pop(context);
                } catch (e) {
                  showDialog(context: context, builder: (context) =>AlertDialog(
                    title: Text("Something went wrong"),
                    content: Text(e.toString()),
                  ));
                }
              }, child: Text("Redeem it"),)],
            ));
            } catch (e){
              showDialog(context: context, builder: (context) => AlertDialog(
                title: Text("Something went wrong"),
                content: Text(e.toString()),
              ));
            }
          }, child: Text("Topup"))
        ],
      ),
    );
  }
}
