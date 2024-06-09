import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shc_cricket_bookings/login_page.dart';
import 'package:passkeys/authenticator.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
import 'package:passkeys/types.dart';

import 'globals.dart';
import 'package:flutter/material.dart';

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
  Future attemptMakePasskey(username, bool useCrossPlatform) async {
    String attachment;
    if (kIsWeb) {
    final browser = Browser.detectOrNull();
     if (browser?.browser == "Safari"){
      attachment = "platform";
    } else {
      attachment = "";
    }
    } else {
      if (useCrossPlatform) {
      attachment = "cross-platform";
    } else {
      attachment = "platform";
    }
    }
    //The attachment can be set to null by regular web apps by not including it in the dictionary of credential
    //creation options. Chrome and Firefox understand that platform = "" means all platforms. Safari will always
    //use platform authenticators, and native platforms will always try platform on the first attempt and cross-platform
    //on the second attempt


    final passkeyAuthenticator = PasskeyAuthenticator();

                  // initiate sign up by calling the relying party server
                  final webAuthnChallenge = await pb.send("/webauthn-begin-registration/${base64.encode(utf8.encode(username))}", method: "POST");
                  // call the platform authenticator to register a new passkey on the device
                  final platformRes = await passkeyAuthenticator.register(RegisterRequestType(
                    challenge: webAuthnChallenge['publicKey']['challenge'], 
                    relyingParty: RelyingPartyType(id: webAuthnChallenge['publicKey']['rp']['id'], name: webAuthnChallenge['publicKey']['rp']['name']),
                 user: UserType(displayName: webAuthnChallenge['publicKey']['user']['displayName'], id: webAuthnChallenge['publicKey']['user']['id'], name: webAuthnChallenge['publicKey']['user']['name']),
                    authSelectionType: AuthenticatorSelectionType(
                      requireResidentKey: true,
                      userVerification: "preferred",
                      residentKey: "preferred",
                      authenticatorAttachment: attachment,
                    ),
                    pubKeyCredParams: [
                      PubKeyCredParamType(type: "public-key", alg: -7),
                      PubKeyCredParamType(type: "public-key", alg: -257)], 
                    timeout: webAuthnChallenge['publicKey']['timeout'],  excludeCredentials: [],
                    attestation: "none"));
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


            if (!mounted) return;
            

            showDialog(
              barrierDismissible: false,
              context: context, builder: (context) => AlertDialog(
              title: const Text("You successfully made a passkey :)"),
              content: const Text("You will now be taken to the login screen. Click login to use your passkey."),
              actions: [TextButton(onPressed: (){Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginPage(defaultEmail: email,)), (route) => false);}, child: const Text("OK"))],
            ));
  }
  String email = "";
  String password = "";
  bool loading = false;
  bool dontShowErrorBecauseSafari = false;

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofillHints: const [AutofillHints.email],
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
            if (email == "") return;
            final username = email.replaceFirst(RegExp(r"@"), "__at__"); //double underscores
            // if (email == "" || password == "") return;
            //temporarily disabled for passkey stuff
      
            setState(() {
              loading = true;
            });
            try{
              await attemptMakePasskey(username, false);
            } catch (e) {
                      final browser = Browser.detectOrNull();
                      if (browser?.browser == "Safari") {
                        try{
                        await pb.send("/api/shc/delete_account_after_passkey_failed/$username");
                      } catch (_) {}
                      }
                    
              try{
              await pb.send("/api/shc/delete_account_after_passkey_failed/$username");
              } catch (_) {}
              setState(()=> loading = false);
              if (!context.mounted) return;
              if (dontShowErrorBecauseSafari) return;
              showDialog(context: context, 
              builder: (context) => AlertDialog(
                title: const Text("Something went wrong creating your passkey :/"),
                content: Text("${e.toString()}\n\nYou can either try again or use a password. If you do not create a passkey now, you will only be able to use a password to login."),
                actions: [TextButton(onPressed: ()async{
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SetPasswordPage(email: email, username: username,)), (route) => false);
                        }, child: const Text("Set a password")),
                  TextButton(onPressed: ()async {
                  try {
                    await attemptMakePasskey(username, true);
                  } catch (e) {
                    try {
                    await pb.send("/api/shc/delete_account_after_passkey_failed/$username");
                    } catch (_){}
                    if (!context.mounted) return;
                    showDialog(context: context, builder: (context) => 
                    AlertDialog(title: const Text("That didn't work again :/",),
                    content: const Text("You will need to make a password."),
                    actions: [
                      TextButton(onPressed: ()async{
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SetPasswordPage(email: email, username: username,)), (route) => false);
                        
                        
                        }, child: const Text("OK"))
                    ],));
                  }
                  }, child: const Text("Try again"))],
              ));
      
              
            }
            
      
            }, 
            child: loading? const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ): const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Sign up"),
            )),
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: kIsWeb? Text("It is recommended that you save your passkey to your phone so that you can login on all your devices.",
              textAlign: TextAlign.center,):null,
            )
        ],
      ),
    );
  }
}

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key, required this.username, required this.email});
    final String username;
  final String email;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  String password = "";
  bool loading = false;
  

  @override
  Widget build(BuildContext context) {
    String username = "${widget.username}__noPasskey";
    return Scaffold(
      appBar: AppBar(title: const Text("Set password"),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(onChanged: (value)=>password = value,
          obscureText: true,
          decoration: const InputDecoration(filled: true,
          prefixIcon: Icon(Icons.password_outlined),
          border: OutlineInputBorder(),
          label: Text("Password"))),
        ),

        FilledButton.tonal(onPressed: ()async{
          setState(() {
            loading = true;
          }); 
          try{
await pb.collection('users').create(
          body: {
            "username": username,
            "email": widget.email,
            "emailVisibility": true,
            "password": password,
            "passwordConfirm": password,
          });
          await pb.collection('users').authWithPassword(widget.email, password);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (route) => false);
          } catch (e) {
            setState(() {
            loading = false;
            });
            showDialog(context: context, builder: (context)=> AlertDialog(
              title: const Text("Something went wrong :/"),
              content: Text(e.toString()),
            ));
          }
          
          
        }, child: loading? const CircularProgressIndicator():const Text("Set password"))
        
      ],),
    );
  }
}