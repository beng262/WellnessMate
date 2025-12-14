import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'home_page.dart' show WellnessMateHomePage;
import 'login.dart' show LoginPage;
import 'login_page.dart' show SimpleLoginPage;
import 'settings.dart';
import 'diary_entry.dart';
import 'firebase_test.dart';
import 'splash_screen.dart';
import 'theme_provider.dart';
import 'theme_selection_page.dart';
import 'calendar_page.dart';
import 'create_task_page.dart';
import 'profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDKJbg9DhiTKtJXlFTZlBMKWsl9sn-g7Jo",
        appId: "1:327402994540:android:38bf170fa9663483ac1149",
        messagingSenderId: "327402994540",
        projectId: "wellnessmate-b4f8f",
        storageBucket: "wellnessmate-b4f8f.firebasestorage.app",
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'WellnessMate',
            theme: themeProvider.getThemeData(),
            home: const AuthWrapper(),
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginPage(),
              '/login_page': (context) => const SimpleLoginPage(),
              '/home': (context) => const WellnessMateHomePage(),
              '/settings': (context) => const SettingsPage(),
              '/diary_entry': (context) => const DiaryEntryPage(),
              '/firebase_test': (context) => const FirebaseTestPage(),
              '/theme_selection': (context) => const ThemeSelectionPage(),
              '/calendar': (context) => const CalendarPage(),
              '/create-task': (context) => const CreateTaskPage(),
              '/profile': (context) => const ProfilePage(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const WellnessMateHomePage();
        } else {
          // User is not logged in
          return const SplashScreen();
        }
      },
    );
  }
}
