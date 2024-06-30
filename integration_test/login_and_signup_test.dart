import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shc_cricket_bookings/main.dart' as app;
import 'dart:io';
import 'dart:math';


void main() {
  String password = File("/Users/austin/Programming/cricket_bookings/integration_test/password.txt").readAsLinesSync()[0];

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Test - Looking for failed login', () {
    testWidgets('Try to login with no/bad/good details',
        (tester) async {
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton).first);
      await tester.pumpAndSettle();


      expect(find.textContaining('Login'), findsNWidgets(2));

      //Expect nothing to happen if login triggered after doing nothing


      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "testing@example.com");
      await tester.enterText(find.byType(TextFormField).last, "wrong_password");
      final loginButton = find.byType(FilledButton).first;
      await tester.tap(loginButton);
      
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));

      expect(find.textContaining("Something went wrong"), findsOneWidget);




      await tester.tap(find.textContaining("OK"));
      await tester.pumpAndSettle();


      expect(find.textContaining("OK"), findsNothing); //check the popup was cleared



      await tester.enterText(find.byType(TextFormField).first, "testing@example.com");
      await tester.enterText(find.byType(TextFormField).last, password);

      // Emulate a tap on the floating action button.
      await tester.tap(find.byType(FilledButton).first);
      
      await tester.pumpAndSettle();


      expect(find.byIcon(Icons.home_outlined), findsOneWidget);

      
    });
  });

  group("Make an account", () =>
  testWidgets("Making an account", (tester) async {
    //reset everything
      const storage = FlutterSecureStorage();
        await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(OutlinedButton));
      //move to the make account page
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOne);

      await tester.enterText(find.byType(TextField).first, "testing${Random().nextInt(99999)}@example.com");

      await tester.tap(find.byType(FilledButton));

      await tester.pumpAndSettle();

      expect(find.textContaining("Your device doesn't support passkeys."),findsOne);

      await tester.enterText(find.byType(TextField), "password${Random().nextInt(99999999)}");

      await tester.tap(find.byType(FilledButton));

      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 3));

      expect(find.byIcon(Icons.home_outlined), findsOne);

      await Future.delayed(const Duration(seconds: 10));
      await tester.pump();
      expect(find.textContaining("You're almost done"), findsOne);




  }));
}