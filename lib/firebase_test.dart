import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({super.key});

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  String _status = 'Testing Firebase connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testFirebaseConnection();
  }

  Future<void> _testFirebaseConnection() async {
    try {
      // Test 1: Check if Firebase Auth is initialized
      setState(() {
        _status = 'Testing Firebase Auth...';
      });
      
      final auth = FirebaseAuth.instance;

      // Test 2: Check if Firestore is accessible
      setState(() {
        _status = 'Testing Firestore connection...';
      });
      
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection_test').get();
      
      // Test 3: Check if user is authenticated
      setState(() {
        _status = 'Checking user authentication...';
      });
      
      final user = auth.currentUser;
      if (user != null) {
        setState(() {
          _status = '✅ Firebase connection successful!\nUser: ${user.email}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '⚠️ Firebase connected but no user logged in';
          _isLoading = false;
        });
      }
      
    } catch (e) {
      setState(() {
        _status = '❌ Firebase connection failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63B4FF),
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: const Color(0xFF63B4FF),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _testFirebaseConnection,
                child: const Text('Retry Test'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 