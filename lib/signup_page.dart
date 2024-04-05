import 'dart:convert';

import 'package:shc_cricket_bookings/login_page.dart';
import 'package:shc_cricket_bookings/verify_email_page.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';

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
      
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     autofillHints: [AutofillHints.password],
          //     obscureText: true,
          //     decoration: const InputDecoration(filled: true,
          //     prefixIcon: Icon(Icons.password_outlined),
          //     border: OutlineInputBorder(),
          //     label: Text("Password")
          //     ),
          //     onChanged: (value) { password = value;}
          //   ),
          // ),
      
          FilledButton.tonal(onPressed: () async {
            final username = email.replaceAll(RegExp(r"@"), "__at__"); //double underscores
            // if (email == "" || password == "") return;
            //temporarily disabled for passkey stuff
      
            setState(() {
              loading = true;
            });
            try{
              final passkeyAuthenticator = PasskeyAuthenticator();
                  // initiate sign up by calling the relying party server
                  final webAuthnChallenge = await pb.send("/webauthn-begin-registration/${base64.encode(utf8.encode(username))}", method: "POST");
                  // call the platform authenticator to register a new passkey on the device
                  final platformRes = await passkeyAuthenticator.register(RegisterRequestType(
                    challenge: webAuthnChallenge['publicKey']['challenge'], 
                    relyingParty: RelyingPartyType(id: webAuthnChallenge['publicKey']['rp']['id'], name: webAuthnChallenge['publicKey']['rp']['name']),
                 user: UserType(displayName: webAuthnChallenge['publicKey']['user']['displayName'], id: webAuthnChallenge['publicKey']['user']['id'], name: webAuthnChallenge['publicKey']['user']['name']),
                    authSelectionType: AuthenticatorSelectionType(
                      requireResidentKey: webAuthnChallenge['publicKey']['authenticatorSelection']['requireResidentKey'],
                      userVerification: "preferred",
                      residentKey: "preferred",
                      authenticatorAttachment: "platform",
                    ),
                    pubKeyCredParams: [
                      PubKeyCredParamType(type: "public-key", alg: -7)], 
                    timeout: webAuthnChallenge['publicKey']['timeout'],  excludeCredentials: [],
                    attestation: null));
                  // finish sign up by calling the relying party server again
                  final relyingPartyServerRes = await pb.send(
                    "/webauthn-finish-registration/${base64.encode(utf8.encode(username))}", method: "POST", body: {
                      "id": platformRes.id,
                      "rawId": platformRes.rawId,
                      "authenticatorAttatchment": "cross-platform",
                      "clientExtensionResults": {},
                      "type": "public-key",
                      "response": {
                        "attestationObject": platformRes.attestationObject,
                        "clientDataJSON": platformRes.clientDataJSON
                      }
                    });
      
              // await pb.collection('users').authWithPassword(email, password);
      
            // const storage = FlutterSecureStorage();
      
            //   final encoded = jsonEncode(<String, dynamic>{
            //     "token": pb.authStore.token,
            //     "model": pb.authStore.model,
            //   });
            //   await storage.write(key: "pb_auth", value: encoded);
            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) => AlertDialog(
              title: Text("You successfully made a passkey :)"),
              content: Text("You will now be taken to the login screen. Enter your email then click login with passkey."),
              actions: [TextButton(onPressed: (){Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginPage()), (route) => false);}, child: Text("OK"))],
            ));
              
      
      
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