import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/quiz_manager.dart';

// Gunakan MVVM Pattern: Menggabungkan state management dan logic
class QuizViewModel extends ChangeNotifier {
  final QuizManager _manager;

  QuizViewModel(this._manager);

  // Getter yang diekspos ke View
  List<Quiz> get quizzes => _manager.quizzes;
  List<Map<String, dynamic>> get history => _manager.history;

  // --- Quiz Management (Create/Edit/Delete) ---

  void addQuiz(Quiz newQuiz) {
    _manager.addQuiz(newQuiz);
    notifyListeners();
  }

  void deleteQuiz(int index) {
    if (index >= 0 && index < _manager.quizzes.length) {
      _manager.quizzes.removeAt(index);
      notifyListeners();
    }
  }

  Quiz? getQuizByTitle(String title) {
    return _manager.getQuizByTitle(title);
  }

  void updateQuizTitle(int index, String newTitle) {
    if (index >= 0 && index < _manager.quizzes.length) {
      _manager.quizzes[index].title = newTitle;
      notifyListeners();
    }
  }

  // --- History/Score Management ---

  void addHistory({
    required String playerName,
    required String quizTitle,
    required int score,
    required int totalQuestions,
    required Map<int, String> userAnswers,
    required Map<int, String> userEssayAnswers,
  }) {
    _manager.addHistory(
      playerName: playerName,
      quizTitle: quizTitle,
      score: score,
      totalQuestions: totalQuestions,
      userAnswers: userAnswers,
      userEssayAnswers: userEssayAnswers,
    );
    notifyListeners();
  }

  int calculateScore(Quiz quiz, Map<int, String> userAnswers) {
    return _manager.calculateScore(quiz, userAnswers);
  }
}