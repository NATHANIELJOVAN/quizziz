// lib/views/pages/history_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../widgets/quiz_review_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        final history = viewModel.history;

        if (history.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Riwayat Kuis')),
            body: const Center(
              child: Text('Belum ada riwayat kuis yang tersimpan.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Riwayat Kuis')),
          body: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final historyItem = history[index];
              final Quiz? originalQuiz = viewModel.getQuizByTitle(historyItem['quizTitle']);

              final int score = historyItem['score'] as int;
              final int totalQuestions = historyItem['totalQuestions'] as int;
              final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(historyItem['quizTitle'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Pemain: ${historyItem['playerName']}\n'
                          'Skor: $score/$totalQuestions (${percentage.toStringAsFixed(0)})'
                  ),
                  onTap: () {
                    if (originalQuiz != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuizReviewPage(
                            historyItem: historyItem,
                            originalQuiz: originalQuiz,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kuis asli tidak ditemukan.')),
                      );
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}