import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WellnessMateHomePage extends StatefulWidget {
  const WellnessMateHomePage({Key? key}) : super(key: key);

  @override
  State<WellnessMateHomePage> createState() => _WellnessMateHomePageState();
}

class _WellnessMateHomePageState extends State<WellnessMateHomePage> {
  // Global key for the settings drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // User's chosen axo color from Firestore.
  String _axoColor = "";

  // This function initializes default task suggestions if the user's tasks subcollection is empty.
  Future<void> _initializeTasks() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    // Reference the tasks subcollection under the user document.
    final tasksRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks');
    final snapshot = await tasksRef.get();
    if (snapshot.docs.isEmpty) {
      // Five default task suggestions.
      final suggestions = [
        "Drink a glass of water",
        "Go outside",
        "Start a book",
        "Take a short walk",
        "Meditate for 5 minutes",
      ];
      for (var task in suggestions) {
        await tasksRef.add({
          'task_name': task,
          'isCompleted': false,
          'date': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Load user's additional data (like axoColor) from Firestore.
  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        _axoColor = userDoc.data()?['axoColor'] ?? "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // First, initialize default tasks if needed.
    _initializeTasks();
    // Load the user's data (including the axo color).
    _loadUserData();
  }

  // Helper: Determines the axo image path based on the stored axoColor.
  String getAxoImagePath() {
    if (_axoColor.isNotEmpty) {
      return 'images/${_axoColor}axo.png';
    } else {
      // Default axo image if none is set.
      return 'images/axolotl.png';
    }
  }

  // Build the custom settings drawer.
  Widget _buildSettingsDrawer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF63B4FF),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top logo.
              SizedBox(
                height: 70,
                width: 70,
                child: Image.asset('images/mlogo.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                "Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Belanosima',
                ),
              ),
              const SizedBox(height: 20),
              _buildTopRectangle(
                label: "Pet & Me",
                logoPath: 'images/blogo.png',
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 20),
              const Text(
                "Preferences",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Belanosima',
                ),
              ),
              const SizedBox(height: 20),
              _buildNormalRectangle(
                label: "Notifications",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 10),
              _buildNormalRectangle(
                label: "Language",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 10),
              _buildNormalRectangle(
                label: "Audio",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 10),
              _buildNormalRectangle(
                label: "Theme",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 20),
              const Text(
                "Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Belanosima',
                ),
              ),
              const SizedBox(height: 20),
              _buildNormalRectangle(
                label: "Application Data",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 10),
              _buildNormalRectangle(
                label: "Terms of Service",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 8),
              _buildNormalRectangle(
                label: "Privacy Policy",
                arrowPath: 'images/sarrow.png',
              ),
              const SizedBox(height: 20),
              const Text(
                "Support",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Belanosima',
                ),
              ),
              const SizedBox(height: 20),
              _buildNormalRectangle(
                label: "Contact Us",
                arrowPath: 'images/sarrow.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top rectangle widget with logo and label.
  Widget _buildTopRectangle({
    required String label,
    required String logoPath,
    required String arrowPath,
  }) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF9ACCFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 48, height: 48, child: Image.asset(logoPath)),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Spacer(),
            SizedBox(width: 24, height: 24, child: Image.asset(arrowPath)),
          ],
        ),
      ),
    );
  }

  // Normal rectangle widget for drawer items.
  Widget _buildNormalRectangle({
    required String label,
    required String arrowPath,
  }) {
    return Container(
      height: 30,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF9ACCFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const Spacer(),
            SizedBox(width: 24, height: 24, child: Image.asset(arrowPath)),
          ],
        ),
      ),
    );
  }

  // Mark a task as complete.
  Future<void> _markTaskComplete(DocumentSnapshot doc) async {
    await doc.reference.update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSettingsDrawer(context),
      body: Stack(
        children: [
          // Background image.
          Positioned.fill(
            child: Image.asset('images/background.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 120),
                // ----- PETS SECTION -----
                Stack(
                  children: [
                    // Axo image based on user's selection.
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 90),
                        child: SizedBox(
                          width: 120,
                          height: 130,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Insert Lottie animation for axo when clicked/petted.
                              // e.g., Lottie.asset('assets/animations/axo_animation.json');
                            },
                            child: Image.asset(getAxoImagePath()),
                          ),
                        ),
                      ),
                    ),
                    // Turtle image.
                    Positioned(
                      top: 160, // Adjusted based on axo position.
                      left: (screenWidth / 2) + 56,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Insert Lottie animation for turtle when clicked/petted.
                          // e.g., Lottie.asset('assets/animations/turtle_animation.json');
                        },
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.asset('images/turtle.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ----- TASKS SECTION -----
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Query tasks from the user's tasks subcollection.
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .collection('tasks')
                        .orderBy('date', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Expanded(
                          child: Column(
                            children: const [
                              _EmptyProgressBar(),
                              SizedBox(height: 15),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '0 goals left!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontFamily: 'Belanosima',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No tasks yet!',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }

                      // Separate completed and incomplete tasks.
                      final allDocs = snapshot.data!.docs;
                      final completedDocs = allDocs.where((d) => d['isCompleted'] == true).toList();
                      final incompleteDocs = allDocs.where((d) => d['isCompleted'] == false).toList();

                      // Calculate progress.
                      final totalTasks = allDocs.length;
                      final completedTasks = completedDocs.length;
                      final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

                      return Expanded(
                        child: Column(
                          children: [
                            _ProgressBarSection(
                              progress: progress,
                              completedTasks: completedTasks,
                              totalTasks: totalTasks,
                            ),
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${incompleteDocs.length} goals left!',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontFamily: 'Belanosima',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 240,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: incompleteDocs.length.clamp(0, 4),
                                itemBuilder: (context, index) {
                                  final doc = incompleteDocs[index];
                                  final taskName = doc['task_name'] ?? 'Untitled';
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          'images/dots.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              taskName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF74BCFF),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Image.asset(
                                              'images/stars.png',
                                              width: 20,
                                              height: 20,
                                            ),
                                            IconButton(
                                              icon: Image.asset(
                                                'images/check.png',
                                                width: 20,
                                                height: 20,
                                              ),
                                              onPressed: () => _markTaskComplete(doc),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Settings icon (burger menu trigger) at top left.
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Image.asset('images/settings.png', width: 30, height: 25),
            ),
          ),
          // Bottom Navigation Bar.
          Positioned(
            bottom: 20,
            left: (screenWidth - 330) / 2,
            child: Container(
              width: 330,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3DA0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Image.asset('images/calendar.png', width: 30),
                    onPressed: () {
                      Navigator.pushNamed(context, '/calendar');
                    },
                  ),
                  IconButton(
                    icon: Image.asset('images/add.png', width: 30),
                    onPressed: () async {
                      // Navigate to CreateTaskPage.
                      await Navigator.pushNamed(context, '/create-task');
                      // StreamBuilder updates automatically.
                    },
                  ),
                  IconButton(
                    icon: Image.asset('images/dashboard.png', width: 30),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------ _EmptyProgressBar Widget ------------------
class _EmptyProgressBar extends StatelessWidget {
  const _EmptyProgressBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: 330,
        height: 60,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffd9edff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const Positioned(
              left: 15,
              top: 14,
              child: SizedBox(
                width: 300,
                height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ _ProgressBarSection Widget ------------------
class _ProgressBarSection extends StatelessWidget {
  final double progress;
  final int completedTasks;
  final int totalTasks;

  const _ProgressBarSection({
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    // Blue progress indicator calculations.
    final double maxWidth = 296; // Slight margin
    final double progressIndicatorWidth = maxWidth * progress;
    final double highlightWidth = progressIndicatorWidth > 6 ? progressIndicatorWidth - 6 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: 330,
        height: 60,
        child: Stack(
          children: [
            // Background.
            Container(
              decoration: BoxDecoration(
                color: const Color(0xffd9edff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // White rectangle.
            const Positioned(
              left: 15,
              top: 14,
              child: SizedBox(
                width: 300,
                height: 20,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            // Blue progress indicator.
            Positioned(
              right: 17,
              top: 16,
              child: Container(
                width: progressIndicatorWidth,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xff0082ff),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Highlight on the progress.
            Positioned(
              right: 20,
              top: 19,
              child: Container(
                width: highlightWidth,
                height: 1,
                decoration: BoxDecoration(
                  color: const Color(0xFF90C9FF),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Star icon and progress text.
            Positioned(
              left: 20,
              top: 17,
              child: Row(
                children: [
                  Image.asset('images/stars.png', width: 14, height: 14),
                  const SizedBox(width: 5),
                  Text(
                    '$completedTasks/$totalTasks',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xffa0d1ff),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom rectangle in the progress bar.
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: 330,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Finish your tasks for your pet to grow!',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xffa0d1ff),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Image.asset('images/icon.png', width: 10, height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
