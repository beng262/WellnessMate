import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isRepeatSelected = false;
  final TextEditingController goalController = TextEditingController();
  bool _isAdding = false; // Loading state

  @override
  void initState() {
    super.initState();

    // Print Firebase app info to confirm connection and project setup
    final fbApp = Firebase.app();
    print('==> CreateTaskPage initState');
    print('Firebase app name: ${fbApp.name}');
    print('Firebase app options: ${fbApp.options}');
  }

  /// Stream of suggestions from 'example_tasks' collection
  Stream<QuerySnapshot> get suggestionsStream =>
      _firestore.collection('example_tasks').snapshots();

  /// Adds a new task document to the top-level 'tasks' collection
  Future<void> _addTaskToFirestore() async {
    // If already adding, ignore further taps
    if (_isAdding) {
      print('==> _addTaskToFirestore: already adding, ignoring tap...');
      return;
    }

    // Validate input
    if (goalController.text.isEmpty) {
      _showSnackBar('Please enter a task name');
      return;
    }

    setState(() => _isAdding = true);
    print('==> _addTaskToFirestore triggered');
    print('==> Attempting to add task: "${goalController.text}"');

    try {
      // Attempt to add the doc
      final docRef = await _firestore.collection('tasks').add({
        'task_name': goalController.text,
        'date': FieldValue.serverTimestamp(),
        'isCompleted': false,
        'isRepeating': isRepeatSelected,
      });

      print('==> Successfully added task with ID: ${docRef.id}');
      Navigator.pop(context); // Go back to home page
    } catch (e, stackTrace) {
      print('==> Error adding task: $e');
      print('Stack trace: $stackTrace');
      _showSnackBar('Failed to add task. Check your connection');
    } finally {
      setState(() => _isAdding = false);
    }
  }

  /// Apply a suggestion to the text field
  void _useSuggestion(String suggestionText) {
    setState(() => goalController.text = suggestionText);
    _showSnackBar('Suggestion applied');
  }

  /// Delete a suggestion from 'example_tasks' collection
  Future<void> _deleteSuggestion(String docId) async {
    try {
      await _firestore.collection('example_tasks').doc(docId).delete();
      _showSnackBar('Suggestion deleted');
    } catch (e) {
      _showSnackBar('Failed to delete suggestion');
    }
  }

  /// Show a quick SnackBar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFCAE1FF), Color(0xFF69B7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // White card for new goal input
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: 340,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Top row with target icon and exit icon
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('images/target.png', width: 50, height: 50),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            'images/exit1.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TextField for entering the goal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: goalController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new goal...',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // <-- Bold hint text
                          fontFamily: 'Belanosima-Regular',
                          color: Color(0xff74bcff),
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Belanosima-Regular',
                        fontWeight: FontWeight.bold, // <-- Bold user-typed text
                        color: Color(0xff74bcff),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Bottom row: "Repeat" toggle + Add button (or loading spinner)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Repeat toggle
                        GestureDetector(
                          onTap:
                              () => setState(
                                () => isRepeatSelected = !isRepeatSelected,
                              ),
                          child: Row(
                            children: [
                              Image.asset(
                                'images/refresh.png',
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Repeat',
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isRepeatSelected
                                          ? const Color(0xff3DA0FF)
                                          : const Color(0xffB9DDFF),
                                  fontFamily: 'Belanosima-Regular',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add button or loading spinner
                        _isAdding
                            ? const Padding(
                              padding: EdgeInsets.only(right: 20),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xff74bcff),
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : GestureDetector(
                              onTap: _addTaskToFirestore,
                              child: Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xff74bcff),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Belanosima-Regular',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // "Suggestions:" label
            Container(
              margin: const EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Suggestions:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Belanosima-Regular',
                ),
              ),
            ),
            const SizedBox(height: 10),

            // StreamBuilder that lists suggestions from 'example_tasks'
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: suggestionsStream,
                builder: (context, snapshot) {
                  // Check for errors
                  if (snapshot.hasError) {
                    print('Suggestions stream error: ${snapshot.error}');
                    return _buildErrorWidget();
                  }
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingWidget();
                  }
                  // If data is available
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final suggestionText = doc['title'] ?? 'Untitled';
                      return _buildSuggestionItem(suggestionText, doc.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single suggestion item widget
  Widget _buildSuggestionItem(String text, String docId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        // If user taps anywhere on the container (except the delete icon), apply suggestion
        onTap: () => _useSuggestion(text),
        child: Container(
          width: 300,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff74bcff),
                    fontFamily: 'Belanosima-Regular',
                  ),
                ),
              ),
              // Delete button (exit1.png)
              GestureDetector(
                onTap: () => _deleteSuggestion(docId),
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image(
                      image: AssetImage('images/exit1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() => Center(
    child: CircularProgressIndicator(color: Colors.white.withOpacity(0.5)),
  );

  Widget _buildErrorWidget() => Center(
    child: Text(
      'Failed to load suggestions',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontFamily: 'Belanosima-Regular',
      ),
    ),
  );
}
