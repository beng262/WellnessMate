import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // The currently displayed month (first day of month).
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  // The currently selected date. Initially set to today.
  DateTime selectedDate = DateTime.now();

  // Navigate to previous month.
  void _goToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
    });
  }

  // Navigate to next month.
  void _goToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
    });
  }

  /// Returns a stream of Firestore query snapshots for daily tasks that have a
  /// 'date' field between the start and end of the selected day.
  Stream<QuerySnapshot> _getDailyTasksForSelectedDate() {
    // Calculate the start and end of the selected day.
    DateTime startOfDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    return FirebaseFirestore.instance
        .collection('daily_tasks')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots();
  }

  /// Helper: generate the calendar grid days (with empty cells for alignment).
  List<DateTime?> _generateCalendarDays() {
    List<DateTime?> calendarDays = [];
    int firstWeekday =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    int offset = firstWeekday - 1; // Monday = 1, so offset = 0 for Monday.
    for (int i = 0; i < offset; i++) {
      calendarDays.add(null);
    }
    int totalDays = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    for (int day = 1; day <= totalDays; day++) {
      calendarDays.add(DateTime(currentMonth.year, currentMonth.month, day));
    }
    return calendarDays;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime?> calendarDays = _generateCalendarDays();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            // Background gradient.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCAE1FF), Color(0xFF69B7FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spacer for the back arrow.
                const SizedBox(height: 60),
                // Month & Year header with left/right navigation arrows (centered).
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _goToPreviousMonth,
                        child: Image.asset(
                          'images/mlarrow.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF0083FF),
                          fontFamily: 'Belanosima',
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _goToNextMonth,
                        child: Image.asset(
                          'images/mrarrow.png',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Weekday labels row.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _WeekDay(label: 'MON'),
                      _WeekDay(label: 'TUE'),
                      _WeekDay(label: 'WED'),
                      _WeekDay(label: 'THU'),
                      _WeekDay(label: 'FRI'),
                      _WeekDay(label: 'SAT'),
                      _WeekDay(label: 'SUN'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Calendar grid.
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                      itemCount: calendarDays.length,
                      itemBuilder: (context, index) {
                        DateTime? day = calendarDays[index];
                        bool isSelected =
                            day != null &&
                            day.year == selectedDate.year &&
                            day.month == selectedDate.month &&
                            day.day == selectedDate.day;
                        return GestureDetector(
                          onTap: () {
                            if (day != null) {
                              setState(() {
                                selectedDate = day;
                              });
                            }
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration:
                                isSelected
                                    ? const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF0083FF),
                                    )
                                    : null,
                            child:
                                day != null
                                    ? Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.white,
                                        fontFamily: 'Belanosima',
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Completed Goals section (positioned 40px below the calendar grid).
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Image.asset('images/target2.png', width: 24, height: 24),
                      const SizedBox(width: 10),
                      const Text(
                        '4 goals finished!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2696FF),
                          fontFamily: 'Belanosima',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Finished tasks list from Firestore.
                Expanded(
                  flex: 3,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getDailyTasksForSelectedDate(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading tasks'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final tasksDocs = snapshot.data!.docs;
                      if (tasksDocs.isEmpty) {
                        return const Center(
                          child: Text('No tasks for this day'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: tasksDocs.length,
                        itemBuilder: (context, index) {
                          var taskData =
                              tasksDocs[index].data() as Map<String, dynamic>;
                          return FinishedTaskWidget(
                            task: taskData['title'] ?? 'Task',
                            // You can implement onPressed to update or delete the task.
                            onPressed: () {
                              // For example, mark task as done or remove it:
                              // FirebaseFirestore.instance
                              //   .collection('daily_tasks')
                              //   .doc(tasksDocs[index].id)
                              //   .delete();
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Back arrow positioned at the top left with a top offset of 40.
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/'); // or Navigator.pop(context)
              },
              child: Image.asset(
                'images/BackArrow.png',
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Weekday label widget with an increased width so that full text is visible.
class _WeekDay extends StatelessWidget {
  final String label;
  const _WeekDay({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 20,
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF3DA0FF),
          fontFamily: 'Belanosima',
        ),
      ),
    );
  }
}

/// Finished task widget that uses strikethrough text.
class FinishedTaskWidget extends StatelessWidget {
  final String task;
  final VoidCallback onPressed;
  const FinishedTaskWidget({
    required this.task,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: 300,
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
          // Dots icon.
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Image.asset('images/dots.png', width: 2, height: 12),
          ),
          // Task text with strikethrough.
          Text(
            task,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF74BCFF),
              fontFamily: 'Belanosima',
              decoration: TextDecoration.lineThrough,
              decorationColor: Color(0xFF2696FF),
              decorationThickness: 1,
            ),
          ),
          // Check icon.
          IconButton(
            icon: Image.asset('images/check2.png', width: 24, height: 24),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
