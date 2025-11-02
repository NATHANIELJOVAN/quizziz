// lib/main.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pie_chart/pie_chart.dart';

// Import Models
import 'models/question.dart';
import 'models/quiz.dart';
// Import Services
import 'services/quiz_manager.dart';
// Import Views (Pages)
import 'views/pages/main_menu_page.dart';
import 'views/pages/create_quiz_list_page.dart';
import 'views/pages/create_quiz_page.dart';
import 'views/pages/edit_quiz_page.dart';
import 'views/pages/quiz_list_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/history_page.dart';
// Import Views (Widgets)
import 'views/widgets/quiz_review_page.dart';
import 'views/widgets/result_page.dart';
import 'views/widgets/quiz_timer.dart';

// Variabel Service Layer Global (Pengganti QuizData dan QuizHistory)
final QuizManager quizManager = QuizManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Creator & Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMenuPage(),
    );
  }
}