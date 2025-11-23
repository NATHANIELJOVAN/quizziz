// lib/models/quiz.dart

import 'question.dart';

class Quiz {
  String title;
  final List<Question> questions;
  int timerDuration;
  String? creatorEmail;

  DateTime createdAt;
  DateTime? updatedAt;

  Quiz({
    required this.title,
    required this.questions,
    this.timerDuration = 0,
    this.creatorEmail,
    DateTime? createdAt,
    this.updatedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'title': title,
    'timerDuration': timerDuration,
    'creatorEmail': creatorEmail,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    title: json['title'] as String,
    timerDuration: json['timerDuration'] as int,
    creatorEmail: json['creatorEmail'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    questions: (json['questions'] as List? ?? [])
        .map((qJson) => Question.fromJson(qJson as Map<String, dynamic>))
        .toList(),
  );
}