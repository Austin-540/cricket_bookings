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
import 'package:url_launcher/url_launcher.dart';

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
          child: Center(child: SizedBox(height: 150, width: 150,child: Image.network("https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fsacredheart.ibcdn.nz%2Fmedia%2F2021_10_13_crest-4x4.jpg&f=1&nofb=1&ipt=9cff44c61eec55e45fd440e3714faa23e37f26dc22b61562663115441d7b73ef&ipo=images"),)),
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

  Future passkeyLogin() async {
    try {
      // Replace @ with __at__ in the username
      final username = email.replaceAll(RegExp(r"@"), "__at__");

      // Begin webauthn login and get challenge
      final webAuthnChallenge = await pb.send(
        "/webauthn-begin-login/${base64.encode(utf8.encode(username))}",
        method: "POST",
      );

      final passkeyAuthenticator = PasskeyAuthenticator();
      final platformRes = await passkeyAuthenticator.authenticate( //use the Platform passkey authenticator
        AuthenticateRequestType(
          relyingPartyId: webAuthnChallenge['publicKey']['rpId'],
          challenge: webAuthnChallenge['publicKey']['challenge'],
          timeout: webAuthnChallenge['publicKey']['timeout'],
          userVerification: "preferred",
          allowCredentials: [
            CredentialType(
              type: webAuthnChallenge['publicKey']['allowCredentials'][0]['type'],
              id: webAuthnChallenge['publicKey']['allowCredentials'][0]['id'],
              transports: [],
            ),
          ],
          mediation: MediationType.Optional,
        ),
      );

      final body = {
          "type": "public-key",
          "authenticatorAttachment": "cross-platform",
          "clientExtensionResults": {},
          "id": platformRes.rawId,
          "rawId": platformRes.rawId,
          "response": {
            "authenticatorData": platformRes.authenticatorData,
            "clientDataJSON": platformRes.clientDataJSON,
            "signature": platformRes.signature,
            "userHandle": platformRes.userHandle,
          },
        };
        print(body);

      // Finish webauthn login
      final res = await pb.send(
        "/webauthn-finish-login/${base64.encode(utf8.encode(username))}",
        method: "POST",
        body: body,
      );

      // Save token and user model in PB auth store
      final storage = FlutterSecureStorage();
      pb.authStore.save(res['token'], res['user']);

      // Save auth data to storage
      final encoded = jsonEncode(<String, dynamic>{
        "token": pb.authStore.token,
        "model": pb.authStore.model,
      });
      await storage.write(key: "pb_auth", value: encoded);

      // Update signup_finished status
      if (pb.authStore.model['signup_finished'] == false) {
        await pb.collection('users').update(pb.authStore.model['id'], body: {"signup_finised": true});
      }

      // Navigate to home page without ability to return
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
    } catch (e) {
      setState(() {
        loading = false;
      });
      if (!mounted) return;
      showDialog(context: context, builder: (context) => ErrorDialog(error: e));
    }
  }

  //check if the user login data is already in storage
  Future tryLogIn() async {
    const storage = FlutterSecureStorage();
    // Read the stored authentication data from storage
    final String? pb_auth = await storage.read(key: "pb_auth");
    if (pb_auth != null) {
      // Decode the stored data
      final decoded = jsonDecode(pb_auth);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model = RecordModel.fromJson(
        decoded["model"] as Map<String, dynamic>? ?? {}
      );
      // Save the authentication data in the auth store
      pb.authStore.save(token, model);
      // Navigate to the home page without the ability to return
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

        

        // Login button
        FilledButton.tonal(
          onPressed: () async {
            if (loading) return;

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

            try {
              // Authenticate to PB with password
              await pb.collection('users').authWithPassword(email, password);

              // Save authentication data to storage
              const storage = FlutterSecureStorage();
              final encoded = jsonEncode(<String, dynamic>{
                "token": pb.authStore.token,
                "model": pb.authStore.model,
              });
              await storage.write(key: "pb_auth", value: encoded);

              // Navigate to home page if login was successful
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
            } catch (e) {
              try {
                // Try to authenticate with admin password
                await pb.admins.authWithPassword(email, password);
                setState(() {
                  loading = false;
                });
                // Show dialog for admin account if the password used was for an admin account
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("This is an admin account"),
                    content: Text("You need to go to the admin UI to use this account"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Nevermind")),
                      TextButton(onPressed: () {launchUrl(Uri.parse("https://austin-540.github.io/shc-cricket-admin-ui-pages/"));}, child: Text("OK (Launch URL)"))
                    ],
                  ),
                );
                return;
              } catch (_) {}
              setState(() => loading = false);
              if (!mounted) return;
              showDialog(context: context, builder: (context) => ErrorDialog(error: e));
            }
          },
          child: loading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Login"),
                ),
        ),
          TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));}, child: Text("Forgot my password or my passkey isn't working")),
          Text("OR"),
      ],
    );
  }
}