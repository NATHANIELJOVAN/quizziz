// lib/services/quiz_manager.dart

import '../models/quiz.dart';
import '../models/question.dart';
import 'package:flutter/material.dart';

class QuizManager {
  List<Quiz> _quizzes = [];
  List<Map<String, dynamic>> _history = [];

  // --- Persistence Methods ---
  Map<String, dynamic> toJson() {
    return {
      'quizzes': _quizzes.map((q) => q.toJson()).toList(),
      'history': _history,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _quizzes = (json['quizzes'] as List? ?? [])
        .map((qJson) => Quiz.fromJson(qJson as Map<String, dynamic>))
        .toList();
    _history = List<Map<String, dynamic>>.from(json['history'] as List? ?? []);
  }
  // --- END Persistence Methods ---

  // --- Quiz Management ---

  void addQuiz(Quiz newQuiz) {
    int index = _quizzes.indexWhere((q) => q.title.toLowerCase() == newQuiz.title.toLowerCase());

    if (index != -1) {
      newQuiz.createdAt = _quizzes[index].createdAt;
      newQuiz.updatedAt = DateTime.now();

      // Update data di list
      _quizzes[index] = newQuiz;
    } else {
      _quizzes.add(newQuiz);
    }
  }

  List<Quiz> get quizzes => _quizzes;

  Quiz? getQuizByTitle(String title) {
    try {
      return _quizzes.lastWhere((quiz) => quiz.title.toLowerCase() == title.toLowerCase());
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
    String? studentEmail,
    bool essayGraded = false,
    int essayScore = 0,
  }) {

    // Konversi Key ke String agar aman JSON
    final Map<String, String> safeUserAnswers = {};
    userAnswers.forEach((key, value) => safeUserAnswers[key.toString()] = value);

    final Map<String, String> safeEssayAnswers = {};
    userEssayAnswers.forEach((key, value) => safeEssayAnswers[key.toString()] = value);

    _history.add({
      'playerName': playerName,
      'studentEmail': studentEmail,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'userAnswers': safeUserAnswers,
      'userEssayAnswers': safeEssayAnswers,
      'essayGraded': essayGraded,
      'essayScore': essayScore,
      'essayDetails': {},
      'submissionDate': DateTime.now().toIso8601String(),
    });
  }

  List<Map<String, dynamic>> get history => _history;

  // Update nilai essay jika guru mengoreksi manual nanti
  void updateEssayScore(int historyIndex, int newEssayScore, Map<String, bool> essayDetails) {
    if (historyIndex >= 0 && historyIndex < _history.length) {
      _history[historyIndex]['essayScore'] = newEssayScore;
      _history[historyIndex]['essayDetails'] = essayDetails;
      _history[historyIndex]['essayGraded'] = true;
    }
  }

  // Cek apakah siswa sudah menyelesaikan kuis tertentu
  bool isQuizCompleted(String quizTitle, String studentEmail) {
    if (studentEmail.isEmpty) return false;
    return _history.any((item) =>
    item['quizTitle'] == quizTitle &&
        item['studentEmail'] == studentEmail
    );
  }
}