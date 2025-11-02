// lib/views/widgets/quiz_review_page.dart

import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';

class QuizReviewPage extends StatelessWidget {
  final Map<String, dynamic> historyItem;
  final Quiz originalQuiz;

  const QuizReviewPage({
    Key? key,
    required this.historyItem,
    required this.originalQuiz,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int score = historyItem['score'];
    final int totalQuestions = historyItem['totalQuestions'];
    final double percentage = totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review Kuis: ${historyItem['quizTitle']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pemain: ${historyItem['playerName']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Skor: $score/$totalQuestions (${percentage.toStringAsFixed(0)})',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 30),
            ...originalQuiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              final userAnswers = historyItem['userAnswers'] as Map<int, String>;
              final userEssayAnswers = historyItem['userEssayAnswers'] as Map<int, String>;

              if (question.type == 'multiple_choice' || question.type == 'true_false') {
                final userAnswer = userAnswers[index];
                final isCorrect = userAnswer == question.correctAnswer;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${question.questionText}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ...question.options.map((option) {
                          final isUserAnswer = option == userAnswer;
                          final isCorrectAnswer = option == question.correctAnswer;
                          Color color = Colors.black;
                          IconData icon = Icons.radio_button_unchecked;

                          if (isUserAnswer && !isCorrect) {
                            color = Colors.red.shade900;
                            icon = Icons.cancel;
                          } else if (isCorrectAnswer) {
                            color = Colors.green.shade900;
                            icon = Icons.check_circle;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(icon, color: color),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontWeight: isUserAnswer || isCorrectAnswer ? FontWeight.bold : FontWeight.normal,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              } else { // Essay
                return SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question.questionText}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Jawaban Anda (Esai):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(userEssayAnswers[index] ?? 'Tidak Dijawab'),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}