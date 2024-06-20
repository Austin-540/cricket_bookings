// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';
import 'home_page.dart';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'globals.dart';
import 'reset_password_page.dart';
import 'signup_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.defaultEmail});
  final String? defaultEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"), backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: Column(children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: SizedBox(height: 150, width: 150,child: Placeholder(),)),
        ),
        LoginPageForm(defaultEmail: defaultEmail,),
        OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage())), child: Text("Make an account"))
      ],),
    );
  }
}

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({super.key, required this.defaultEmail});
  final String? defaultEmail;

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {

  Future passkeyLogin()async{
            try {

            
            final username = email.replaceAll(RegExp(r"@"), "__at__");
                              final passkeyAuthenticator = PasskeyAuthenticator();
                  final webAuthnChallenge = await pb.send("/webauthn-begin-login/${base64.encode(utf8.encode(username))}", method: "POST");
                  final platformRes = await passkeyAuthenticator.authenticate(
                    AuthenticateRequestType(
                    relyingPartyId: webAuthnChallenge['publicKey']['rpId'], 
                    challenge: webAuthnChallenge['publicKey']['challenge'], 
                    timeout: webAuthnChallenge['publicKey']['timeout'], 
                    userVerification: "preferred", 
                    allowCredentials: [
                      CredentialType(
                      type: webAuthnChallenge['publicKey']['allowCredentials'][0]['type'], 
                      id: webAuthnChallenge['publicKey']['allowCredentials'][0]['id'], 
                      transports: []
                      )
                      ], 
                    mediation: MediationType.Optional));
                  final res = await pb.send("/webauthn-finish-login/${base64.encode(utf8.encode(username))}", method: "POST", 
                  body: {
                    "type": "public-key",
                    "authenticatorAttachment": "cross-platform",
                    "clientExtensionResults": {},
                    "id": platformRes.userHandle,
                    "rawId": platformRes.rawId,
                    "response": {
                      "authenticatorData": platformRes.authenticatorData,
                      "clientDataJSON": platformRes.clientDataJSON,
                      "signature": platformRes.signature,
                      "userHandle": platformRes.userHandle
                    }
                    
                    
                  }
                  );
                  print(res);
                  final storage = FlutterSecureStorage();
                  pb.authStore.save(res['token'], res['user']);
                  final encoded = jsonEncode(<String, dynamic>{
              "token": pb.authStore.token,
              "model": pb.authStore.model,
            });
            await storage.write(key: "pb_auth", value: encoded);
            if (pb.authStore.model['signup_finished'] == false){
                await pb.collection('users').update(pb.authStore.model['id'], body: {"signup_finised": true});
            }
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> HomePage()), (route) => false);
          } 
          catch (e) {
            setState(() {
            loading = false;
            });
            if (!mounted) return;
            showDialog(context: context, builder: (context) => ErrorDialog(error: e));
          }
          }

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

  double getPaddingWidth() {
    double paddingWidth = 8;
    if (MediaQuery.of(context).size.width > 550) {
      paddingWidth = (MediaQuery.of(context).size.width - 550) / 2;
    }
    return paddingWidth;
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
    email = widget.defaultEmail ?? "";
    tryLogIn();
  }

  String password = "";
  String email = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: AutofillGroup(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: getPaddingWidth()),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        initialValue: widget.defaultEmail,
                        
                        autofillHints: [
                          AutofillHints.email,
                          AutofillHints.username
                        ],
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
                              child: TextFormField(
                                autofillHints: [
                                  AutofillHints.password,
                                ],
                                obscureText: true,
                                decoration: InputDecoration(filled: true,
                                prefixIcon: Icon(Icons.password_outlined),
                                border: OutlineInputBorder(),
                                label: Text("Password (Leave empty to use a passkey)")
                                ),
                                onChanged: (value) => password = value,
                              ),
                            ),
                
                  ],
                ),
              ),
            ),
          ),


        ),

        

        FilledButton.tonal(onPressed: () async {
          if (email == "") return;

          if (password == "") {
              setState(() {
            loading = true;
          });
            await passkeyLogin();
            return;
          }
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
            if (!context.mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage()));


          } catch (e) {
            setState(()=> loading = false);
            if (!mounted) return;
            showDialog(context: context, 
            builder: (context) => ErrorDialog(error: e));

            
          }
          

          }, 
          child: loading? Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ): Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Login"),
          )),
          TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));}, child: Text("Forgot my password or my passkey isn't working")),
          Text("OR"),
      ],
    );
  }
}