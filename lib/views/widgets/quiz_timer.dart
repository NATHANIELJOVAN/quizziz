import 'package:flutter/material.dart';
import 'dart:async';

class QuizTimer extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onTimeUp;

  const QuizTimer({
    Key? key,
    required this.durationInSeconds,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> {
  late int remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.durationInSeconds;
    _startTimer();
  }

  void _startTimer() {
    if (widget.durationInSeconds <= 0) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.durationInSeconds <= 0) {
      return const SizedBox.shrink();
    }
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return Text(
      "$minutes:$seconds",
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }
}