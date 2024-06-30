import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shc_cricket_bookings/main.dart' as app;
import 'dart:io';

void main() {
  String password = File("/Users/austin/Programming/cricket_bookings/integration_test/password.txt").readAsLinesSync()[0];

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Making then deleting a booking', () {
    testWidgets('Make a booking then delete it',
        (tester) async {
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      app.main();
      await tester.pumpAndSettle();

      expect(find.textContaining('Login'), findsNWidgets(2)); //expect to be on the login page

      expect(find.byType(TextFormField), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).first, "testing@example.com");
      await tester.enterText(find.byType(TextFormField).last, password);

      // Emulate a tap on the floating action button.
      await tester.tap(find.byType(FilledButton).first);
      
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      //made it to the home screen now


      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip("Next month"));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining("27").last);
      await tester.pumpAndSettle();

      await tester.tap(find.text("OK"));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));


      await tester.pumpAndSettle();
      expect(find.textContaining("AM"), findsAtLeast(1));

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      await tester.tap(find.text("Checkout"));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(find.textContaining("\$10"), findsOne);


      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      final listOfMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan"];

      expect(find.textContaining("27 ${listOfMonths[DateTime.now().month]}"), findsOne); //includes the -1 that is normally necessary for list stuff
      //Made a booking and now back to the home page

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.more_horiz).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Cancel it"));
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();



      expect(find.textContaining("Something went wrong"), findsNothing);
      //expect that there is no error dialog open




      
    });
  });
}