// Ini adalah Service Layer yang menampung data persisten (di memori untuk saat ini)

import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizManager {
  final List<Quiz> _quizzes = [];
  final List<Map<String, dynamic>> _history = [];

  // --- Quiz Management ---

  void addQuiz(Quiz newQuiz) {
    _quizzes.add(newQuiz);
  }

  List<Quiz> get quizzes => _quizzes;

  Quiz? getQuizByTitle(String title) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.title.toLowerCase() == title.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  int calculateScore(Quiz quiz, Map<int, String> userAnswers) {
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      if (question.type != 'essay' && userAnswers.containsKey(i) && userAnswers[i] == question.correctAnswer) {
        score++;
      }
    }
    return score;
  }

  // --- History Management ---

  void addHistory({
    required String playerName,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required Map<int, String> userAnswers,
    required Map<int, String> userEssayAnswers,
  }) {
    _history.add({
      'playerName': playerName,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'userAnswers': userAnswers,
      'userEssayAnswers': userEssayAnswers,
    });
  }

  List<Map<String, dynamic>> get history => _history;
}