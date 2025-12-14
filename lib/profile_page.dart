import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // for current user's UID
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting

// Updated model for a diary entry
class DiaryEntry {
  final String text;
  final DateTime date;
  final String emoji; // path to the custom PNG

  DiaryEntry({required this.text, required this.date, required this.emoji});

  factory DiaryEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiaryEntry(
      text: data['text'] as String,
      date:
          (data['date'] as Timestamp).toDate(), // convert Timestamp to DateTime
      emoji: data['emoji'] ?? 'images/emojis/happy.png', // default if not found
    );
  }

  Map<String, dynamic> toMap() {
    return {'text': text, 'date': date, 'emoji': emoji};
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Placeholder for non-diary parts:
  int dayStreak = 1;

  // We use this to track which diary entry is being displayed
  int _currentDiaryIndex = 0;

  // Constants for layout:
  final double diaryWidth = 321;
  final double diaryHeight = 260; // Updated diary rectangle height

  @override
  void initState() {
    super.initState();
    _checkAndInsertSampleData();
  }

  /// Checks if the diary entries subcollection is empty for this user,
  /// and if so, inserts two sample entries.
  Future<void> _checkAndInsertSampleData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary_entries');
    // Order by date so we fetch the earliest entry first (limit 1)
    final snapshot =
        await collection.orderBy('date', descending: false).limit(1).get();
    if (snapshot.docs.isEmpty) {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      // Short entry for today
      await collection.add({
        'text': "Today was a good day.",
        'date': now, // stored as a Timestamp in Firestore
        'emoji': 'images/emojis/happy.png',
      });
      // Long entry for yesterday
      await collection.add({
        'text':
            "Yesterday was a challenging day. I faced a lot of hurdles and had to overcome numerous obstacles. "
            "It was a long day filled with unexpected events, but I managed to learn a lot from every moment. "
            "I hope today will be better and that I can keep pushing forward, no matter what comes my way. "
            "This long entry should trigger the scrollbar since it exceeds the threshold height.",
        'date': yesterday,
        'emoji': 'images/emojis/sad.png',
      });
    }
  }

  // Save diary entry (if needed)
  Future<void> _saveDiaryEntryToFirebase(
    String text,
    DateTime date,
    String emojiPath,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // No user logged in
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('diary_entries')
        .add({'text': text, 'date': date, 'emoji': emojiPath});
  }

  /// Measures the height of [text] given a [maxWidth] and [style].
  double _measureDiaryTextHeight(
    String text,
    double maxWidth,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: null,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    return textPainter.size.height;
  }

  /// Helper to build a positioned container for decorative rectangles.
  Widget _buildPositionedContainer({
    required double left,
    double? bottom,
    required double top,
    required double width,
    required double height,
    required Color color,
    required double borderRadius,
  }) {
    return Positioned(
      left: left,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  // Format a date as "Fri 18 Sep"
  String _formatDate(DateTime date) {
    return DateFormat('E dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF63B4FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No user logged in.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCAE1FF), Color(0xFF69B7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          // Using StreamBuilder to fetch diary entries in real-time
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('diary_entries')
                    .orderBy('date', descending: false)
                    .limit(50) // limit to 50 entries for performance
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  backgroundColor: const Color(0xFF63B4FF),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading diary entries',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (!snapshot.hasData) {
                return const Scaffold(
                  backgroundColor: Color(0xFF63B4FF),
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }
              
              // Convert snapshot docs to DiaryEntry list
              final diaryEntries =
                  snapshot.data!.docs
                      .map((doc) => DiaryEntry.fromDoc(doc))
                      .toList();
              if (diaryEntries.isEmpty) {
                return Scaffold(
                  backgroundColor: const Color(0xFF63B4FF),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No diary entries found.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/diary_entry'),
                          child: const Text('Add First Entry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Ensure _currentDiaryIndex is within bounds.
              if (_currentDiaryIndex < 0 ||
                  _currentDiaryIndex >= diaryEntries.length) {
                _currentDiaryIndex = diaryEntries.length - 1;
              }
              final currentEntry = diaryEntries[_currentDiaryIndex];
              final diaryText = currentEntry.text;
              final currentDateLabel = _formatDate(currentEntry.date);
              final bool isPastDay =
                  !(currentEntry.date.year == now.year &&
                      currentEntry.date.month == now.month &&
                      currentEntry.date.day == now.day);

              final textStyle = const TextStyle(
                decoration: TextDecoration.none,
                fontSize: 14,
                color: Color(0xff69b6ff),
                fontFamily: 'Belanosima-Regular',
                fontWeight: FontWeight.normal,
              );
              final double textHeight = _measureDiaryTextHeight(
                diaryText,
                226,
                textStyle,
              );
              final bool needsScrollbar = textHeight > 160;

              // Layout calculations (same as before)
              final double backArrowLeft = 20;
              final double diaryLeft = (screenWidth - diaryWidth) / 2;
              final double add2Left = (screenWidth - 40) / 2;
              final double mainProfileLeft = (screenWidth - 328.362) / 2;
              final double streakBarLeft = (screenWidth - 290) / 2;
              final double mainWhiteRectTop = 60;
              final double streakBarTop = 390;
              final double diaryTitleTop = 455;
              final double diaryRectTop = 490;

              final double lightningLeft = streakBarLeft + 6;
              final double lightningTop = streakBarTop + 8;
              final double dayStreakNumberLeft = streakBarLeft + 38;
              final double dayStreakNumberTop = streakBarTop + 9;
              final double dayStreakTextLeft = streakBarLeft + 70;
              final double dayStreakTextTop = streakBarTop + 20;

              final accessoryBarTops = [30.0, 60.0, 90.0, 120.0];
              final accessoryBars =
                  accessoryBarTops
                      .map(
                        (top) => Positioned(
                          left: 0,
                          top: top,
                          width: 30,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff399fff),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      )
                      .toList();

              final diaryRightRectanglesData = [
                {
                  'left': 274.0,
                  'top': 0.0,
                  'width': 47.0,
                  'height': diaryHeight,
                  'color': const Color(0xff0084ff),
                  'radius': 20.0,
                },
                {
                  'left': 270.0,
                  'top': 0.0,
                  'width': 47.0,
                  'height': diaryHeight,
                  'color': const Color(0xffd2e8fd),
                  'radius': 20.0,
                },
              ];
              final diaryRightRectangles =
                  diaryRightRectanglesData
                      .map(
                        (data) => Positioned(
                          left: data['left'] as double,
                          top: data['top'] as double,
                          width: data['width'] as double,
                          height: data['height'] as double,
                          child: Container(
                            decoration: BoxDecoration(
                              color: data['color'] as Color,
                              borderRadius: BorderRadius.circular(
                                data['radius'] as double,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList();

              return Stack(
                children: [
                  // BACK ARROW
                  Positioned(
                    top: 40,
                    left: backArrowLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: Image.asset(
                        'images/BackArrow.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  // "Diary" title
                  Positioned(
                    left: (screenWidth - 100) / 2,
                    top: diaryTitleTop,
                    child: const Text(
                      'Diary',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 24,
                        color: Color(0xffffffff),
                        fontFamily: 'Belanosima-Regular',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // ADD2.png button
                  Positioned(
                    left: add2Left,
                    bottom: 40,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/diary_entry');
                      },
                      child: Image.asset(
                        'images/add2.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  // DIARY RECTANGLE SECTION
                  Positioned(
                    left: diaryLeft,
                    top: diaryRectTop,
                    width: diaryWidth,
                    height: diaryHeight,
                    child: Stack(
                      children: [
                        ...diaryRightRectangles,
                        // Main white rectangle
                        Positioned(
                          left: 15,
                          top: 0,
                          width: 295,
                          height: diaryHeight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        // Top-right icon (emoji)
                        Positioned(
                          left: 260,
                          top: 10,
                          width: 40,
                          height: 40,
                          child: Image.asset(
                            currentEntry.emoji,
                            width: 30,
                            height: 30,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          ),
                        ),
                        // DIARY TEXT container
                        Positioned(
                          left: 45,
                          top: 63,
                          width: 226,
                          height: 120,
                          child:
                              needsScrollbar
                                  ? Scrollbar(
                                    thumbVisibility: true,
                                    thickness: 6,
                                    radius: const Radius.circular(20),
                                    child: SingleChildScrollView(
                                      child: Text(diaryText, style: textStyle),
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    child: Text(diaryText, style: textStyle),
                                  ),
                        ),
                        // Accessory bars on the left
                        ...accessoryBars,
                        // Date text
                        Positioned(
                          left: 40,
                          top: 12,
                          width: 147,
                          height: 24,
                          child: Text(
                            currentDateLabel,
                            style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 20,
                              color: Color(0xff399fff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // Navigation arrows
                        if (isPastDay) ...[
                          Positioned(
                            left: 15,
                            bottom: 10,
                            width: 30,
                            height: 30,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentDiaryIndex > 0) {
                                  setState(() {
                                    _currentDiaryIndex--;
                                  });
                                }
                              },
                              child: Image.asset(
                                'images/backl.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 280,
                            bottom: 10,
                            width: 30,
                            height: 30,
                            child: GestureDetector(
                              onTap: () {
                                if (_currentDiaryIndex <
                                    diaryEntries.length - 1) {
                                  setState(() {
                                    _currentDiaryIndex++;
                                  });
                                }
                              },
                              child: Image.asset(
                                'images/backr.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 145,
                            bottom: 10,
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'images/edit.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ] else
                          Positioned(
                            left: 145,
                            bottom: 10,
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'images/edit.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        // Right side bars
                        _buildPositionedContainer(
                          left: 282,
                          top: 70,
                          width: 6,
                          height: 60,
                          color: const Color(0xffd2e8fd),
                          borderRadius: 20,
                          bottom: null,
                        ),
                        _buildPositionedContainer(
                          left: 282,
                          top: 70,
                          width: 6,
                          height: 20,
                          color: const Color(0xff69b6ff),
                          borderRadius: 20,
                          bottom: null,
                        ),
                      ],
                    ),
                  ),
                  // STREAK BAR
                  Positioned(
                    left: streakBarLeft,
                    top: streakBarTop,
                    width: 290,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Lightning icon
                  Positioned(
                    left: lightningLeft,
                    top: lightningTop,
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      'images/lightning.png',
                      width: 34,
                      height: 34,
                    ),
                  ),
                  // "day streak!!" text
                  Positioned(
                    left: dayStreakTextLeft,
                    top: dayStreakTextTop,
                    width: 105,
                    height: 10,
                    child: const Text(
                      'day streak!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 20,
                        color: Color(0xff69b7ff),
                        fontFamily: 'Belanosima-Regular',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  // Big number for day streak
                  Positioned(
                    left: dayStreakNumberLeft,
                    top: dayStreakNumberTop,
                    width: 35,
                    height: 29,
                    child: Text(
                      '$dayStreak',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 24,
                        color: Color(0xff399fff),
                        fontFamily: 'Belanosima-Regular',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  // MAIN WHITE RECTANGLE (PROFILE DETAILS)
                  Positioned(
                    left: mainProfileLeft,
                    top: mainWhiteRectTop,
                    width: 328.362,
                    height: 320.363,
                    child: Stack(
                      children: [
                        // Right rectangles behind the white box
                        Positioned(
                          left: 264,
                          top: 26,
                          width: 47,
                          height: 108,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff0083ff),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 264,
                          top: 121,
                          width: 47,
                          height: 175,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffd1e7fc),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        // Main white profile details container
                        Positioned(
                          left: 0,
                          top: 26,
                          width: 300,
                          height: 270,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        // Top center rectangle (#0083ff)
                        _buildPositionedContainer(
                          left: 125,
                          top: 16,
                          width: 50,
                          height: 20,
                          color: const Color(0xff0083ff),
                          borderRadius: 30,
                          bottom: null,
                        ),
                        // Smaller rectangle (#69b6ff)
                        _buildPositionedContainer(
                          left: 140,
                          top: 0,
                          width: 20,
                          height: 30,
                          color: const Color(0xff69b6ff),
                          borderRadius: 30,
                          bottom: null,
                        ),
                        // User details texts
                        const Positioned(
                          left: 182,
                          top: 63,
                          width: 72,
                          height: 14,
                          child: Text(
                            'Baby Axo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              color: Color(0xff0083ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 30,
                          top: 184,
                          width: 72,
                          height: 14,
                          child: Text(
                            '1 day',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff0083ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 70,
                          top: 207,
                          width: 72,
                          height: 14,
                          child: Text(
                            'Friends',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff0083ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 52,
                          top: 232,
                          width: 72,
                          height: 14,
                          child: Text(
                            'Bengi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff0083ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 44,
                          top: 255,
                          width: 72,
                          height: 14,
                          child: Text(
                            '2 cm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff0083ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // "She/Her" text
                        const Positioned(
                          left: 197,
                          top: 84,
                          width: 54,
                          height: 14,
                          child: Text(
                            'She/Her',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xffd2e8fd),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // Labels: Age, Friendship, Human, Height
                        const Positioned(
                          left: 20,
                          top: 183,
                          width: 47,
                          height: 14,
                          child: Text(
                            'Age:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff69b6ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 20,
                          top: 207,
                          width: 69,
                          height: 14,
                          child: Text(
                            'Friendship:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff69b6ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 20,
                          top: 231,
                          width: 58,
                          height: 14,
                          child: Text(
                            'Human:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff69b6ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 20,
                          top: 255,
                          width: 58,
                          height: 14,
                          child: Text(
                            'Height:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff69b6ff),
                              fontFamily: 'Belanosima-Regular',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        // Images in the profile details section
                        Positioned(
                          left: 153,
                          top: 145,
                          width: 124,
                          height: 124,
                          child: Image.asset(
                            'images/logo.png',
                            width: 124,
                            height: 124,
                          ),
                        ),
                        Positioned(
                          left: 135,
                          top: 281,
                          width: 30,
                          height: 30,
                          child: Image.asset(
                            'images/edit.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Additional small dot/icon
                  Positioned(
                    left: mainProfileLeft + 146,
                    top: 64,
                    width: 8,
                    height: 8,
                    child: Image.asset('images/dot.png', width: 8, height: 8),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
