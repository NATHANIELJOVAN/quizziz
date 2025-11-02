// lib/models/quiz.dart

import 'question.dart';

class Quiz {
  String title;
  final List<Question> questions;
  int timerDuration;

  Quiz({
    required this.title,
    required this.questions,
    this.timerDuration = 0,
  });
}