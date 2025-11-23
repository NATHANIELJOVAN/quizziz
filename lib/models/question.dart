// lib/models/question.dart test

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

  Map<String, dynamic> toJson() => {
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
    'type': type,
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionText: json['questionText'] as String,
    options: List<String>.from(json['options'] as List),
    correctAnswer: json['correctAnswer'] as String?,
    type: json['type'] as String,
  );
}