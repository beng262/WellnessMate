import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for user UID
import 'package:flutter/material.dart';

class DiaryEntryPage extends StatefulWidget {
  const DiaryEntryPage({super.key});

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _diaryController = TextEditingController();
  String? _chosenEmojiPath;

  // Example placeholders (replace with actual date if you want dynamic)
  final String _dayLabel = 'Fri 19th Sep';
  final String _yearLabel = '2024';

  final List<Map<String, dynamic>> _emojiData = [
    {'path': 'images/loving.png', 'left': 32.0},
    {'path': 'images/crying.png', 'left': 96.0},
    {'path': 'images/sad.png', 'left': 160.0},
    {'path': 'images/neutral.png', 'left': 224.0},
    {'path': 'images/happy.png', 'left': 288.0},
  ];

  Future<void> _saveAndExit() async {
    final text = _diaryController.text.trim();
    final chosenEmoji = _chosenEmojiPath ?? 'images/neutral.png';

    // Get the current user's UID
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Handle the case where no user is logged in
      return;
    }

    // Save to Firestore subcollection for this user
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary_entries')
        .add({
          'text': text.isEmpty ? "No text" : text,
          'date': DateTime.now(), // or FieldValue.serverTimestamp()
          'emoji': chosenEmoji,
        });

    // Go back to profile page
    Navigator.pushNamed(context, '/profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // White rectangle at the top
          Positioned(
            left: 20,
            top: 50,
            width: 320,
            height: 400,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Date label
          Positioned(
            left: 40,
            top: 70,
            child: Text(
              _dayLabel,
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 24,
                color: Color(0xff399fff),
                fontFamily: 'Belanosima-Regular',
              ),
            ),
          ),
          // Year label
          Positioned(
            left: 159,
            top: 79,
            child: Text(
              _yearLabel,
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                color: Color(0xff74bbff),
                fontFamily: 'Belanosima-Regular',
              ),
            ),
          ),
          // "exit.png" in top-right
          Positioned(
            left: 300,
            top: 70,
            child: GestureDetector(
              onTap: _saveAndExit,
              child: Image.asset('images/exit.png', width: 24, height: 24),
            ),
          ),
          // "Write about your day.." text
          Positioned(
            left: 10,
            top: 122,
            width: 248,
            child: Text(
              'Write about your day..',
              textAlign: TextAlign.center,
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 20,
                color: Color(0xff74bcff),
                fontFamily: 'Belanosima-Regular',
              ),
            ),
          ),
          // TextField for diary entry
          Positioned(
            left: 30,
            top: 160,
            width: 280,
            height: 200,
            child: TextField(
              controller: _diaryController,
              maxLines: null,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Type here...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // "How was your day?" text
          Positioned(
            left: 29,
            top: 467,
            width: 311,
            height: 34,
            child: const Text(
              'How was your day?',
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none,
                fontSize: 24,
                color: Color(0xffffffff),
                fontFamily: 'Belanosima-Regular',
              ),
            ),
          ),
          // White rectangle at the bottom for emojis
          Positioned(
            left: 21,
            top: 520,
            width: 320,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // The 5 emoji images
          for (final emoji in _emojiData) ...[
            if (_chosenEmojiPath == emoji['path'])
              Positioned(
                left: (emoji['left'] as double) - 12,
                top: 520,
                child: Container(
                  width: 64,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0x70FFF8DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            Positioned(
              left: emoji['left'] as double,
              top: 535,
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _chosenEmojiPath = emoji['path'];
                  });
                },
                child: Image.asset(emoji['path'], width: 40, height: 40),
              ),
            ),
          ],
          // "Add" button
          Positioned(
            left: 140,
            top: 658,
            width: 80,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 155,
            top: 671,
            width: 50,
            height: 14,
            child: Text(
              'Add',
              textAlign: TextAlign.center,
              style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 24,
                color: Color(0xff74bcff),
                fontFamily: 'Belanosima-Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
