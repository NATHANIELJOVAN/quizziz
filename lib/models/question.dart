// lib/models/question.dart

class Question {
  final String questionText;
  final List<String> options;
  final String? correctAnswer;
  final String type;

  Question({
    required this.questionText,
    required this.options,
    this.correctAnswer,
    this.type = 'multiple_choice',
  });
}