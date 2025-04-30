import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Import your custom pages
import 'calendar_page.dart';
import 'create_task_page.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'login.dart'; // <-- Make sure this matches the filename of your login page

void main() async {
  debugRepaintRainbowEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensures Firebase is connected
  runApp(const WellnessMateApp());
}

class WellnessMateApp extends StatelessWidget {
  const WellnessMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WellnessMate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Belanosima',
      ),
      // For testing the new onboarding/login flow, start at '/login'
      initialRoute: '/login',
      routes: {
        '/': (context) => const WellnessMateHomePage(),
        '/login': (context) => const LoginPage(), // <-- New route
        '/create-task': (context) => const CreateTaskPage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}
