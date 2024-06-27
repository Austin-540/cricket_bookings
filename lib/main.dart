import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        theme: ThemeData(
          colorSchemeSeed: Colors.blue
        ),
        home: const LoginPage(defaultEmail: null,)
      ),
    );
  }
}
