// lib/views/pages/quiz_list_page.dart

import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../services/quiz_manager.dart'; // Akses Service
import 'quiz_page.dart';
import '../../main.dart'; // Import main.dart untuk mengakses quizManager

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  String _getTimerText(int duration) {
    if (duration == 0) return 'Tidak Ada Timer';
    if (duration < 60) return '$duration Detik';
    return '${duration ~/ 60} Menit';
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = quizManager.quizzes; // Akses dari global Service

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pilih Kuis')),
        body: const Center(
          child: Text('Belum ada kuis yang dibuat.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kuis')),
      body: Center(
        child: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              child: ListTile(
                title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${quiz.questions.length} soal\nTimer: ${_getTimerText(quiz.timerDuration)}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}