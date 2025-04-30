// Dynamic and Animated Task Progression Bar
import 'package:flutter/material.dart';

class TaskProgressBar extends StatefulWidget {
  final int currentProgress; // e.g., 6
  final int totalTasks; // e.g., 10

  const TaskProgressBar({
    super.key,
    required this.currentProgress,
    required this.totalTasks,
  });

  @override
  State<TaskProgressBar> createState() => _TaskProgressBarState();
}

class _TaskProgressBarState extends State<TaskProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    double progressRatio = widget.currentProgress / widget.totalTasks;

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: progressRatio,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant TaskProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentProgress != widget.currentProgress) {
      double progressRatio = widget.currentProgress / widget.totalTasks;
      _animation = Tween<double>(
        begin: _animation.value,
        end: progressRatio,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: 330,
        height: 60,
        child: Stack(
          children: [
            // Background bar
            Container(
              width: 330,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xffd9edff),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            // Bottom accent
            Positioned(
              left: 0,
              width: 330,
              top: 41,
              height: 19,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xfff0f8ff),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
              ),
            ),
            // Inner white progress background
            Positioned(
              left: 15,
              width: 300,
              top: 14,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Animated progress bar
            Positioned(
              left: 15,
              top: 14,
              height: 20,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 300 * _animation.value,
                    decoration: BoxDecoration(
                      color: const Color(0xff0082ff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            // Shorter progress highlight
            Positioned(
              left: 15,
              top: 17,
              height: 2,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: (300 * _animation.value) * 0.9, // Slightly shorter
                    decoration: BoxDecoration(
                      color: const Color(0xff3ca0ff),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            // Motivational text
            const Positioned(
              left: 28,
              top: 45,
              child: Text(
                'Finish your tasks daily for your mate to grow!!',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xffa0d1ff),
                  fontFamily: 'Belanosima-Regular',
                ),
              ),
            ),
            // Star Icon and Progress Text aligned side by side
            Positioned(
              left: 230,
              top: 17,
              child: Row(
                children: [
                  Image.asset('images/stars.png', width: 14, height: 14),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.currentProgress}/${widget.totalTasks}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xffa0d1ff),
                      fontFamily: 'Belanosima-Regular',
                    ),
                  ),
                ],
              ),
            ),
            // Notification Icon
            Positioned(
              left: 263,
              top: 44,
              child: Image.asset('images/icon.png', width: 10, height: 10),
            ),
          ],
        ),
      ),
    );
  }
}
