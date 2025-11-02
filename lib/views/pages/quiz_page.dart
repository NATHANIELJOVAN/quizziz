// lib/views/pages/quiz_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import '../widgets/result_page.dart';
import '../widgets/quiz_timer.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;
  const QuizPage({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Map<int, String> userAnswers = {};
  Map<int, String> userEssayAnswers = {};
  bool quizStarted = false;
  late final Stopwatch _stopwatch;
  final _playerNameController = TextEditingController();
  final Map<int, TextEditingController> _essayControllers = {};

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (widget.quiz.questions[i].type == 'essay') {
        _essayControllers[i] = TextEditingController();
      }
    }
  }

  void _startQuiz() {
    if (_playerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama Anda untuk memulai kuis.')),
      );
      return;
    }
    setState(() {
      quizStarted = true;
      _stopwatch.start();
    });
  }

  void _onTimeUp() {
    if (quizStarted) {
      checkAnswers();
    }
  }

  void checkAnswers() async {
    _stopwatch.stop();
    final viewModel = Provider.of<QuizViewModel>(context, listen: false);

    int correctAnswers = viewModel.calculateScore(widget.quiz, userAnswers);
    int totalCountableQuestions = widget.quiz.questions.where((q) => q.type != 'essay').length;

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (widget.quiz.questions[i].type == 'essay') {
        userEssayAnswers[i] = _essayControllers[i]?.text ?? '';
      }
    }

    viewModel.addHistory(
      playerName: _playerNameController.text,
      quizTitle: widget.quiz.title,
      score: correctAnswers,
      totalQuestions: totalCountableQuestions,
      userAnswers: userAnswers,
      userEssayAnswers: userEssayAnswers,
    );

    final result = await showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return ResultPage(
          score: correctAnswers,
          totalQuestions: totalCountableQuestions,
          timeSpent: _stopwatch.elapsed.inSeconds,
        );
      },
      barrierDismissible: false,
      barrierLabel: 'Result',
      transitionDuration: const Duration(milliseconds: 400),
    );

    if (result == "retry") {
      setState(() {
        userAnswers = {};
        userEssayAnswers = {};
        _essayControllers.forEach((_, controller) => controller.clear());
        _stopwatch.reset();
        _stopwatch.start();
      });
    } else if (result == "home") {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _playerNameController.dispose();
    _essayControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!quizStarted) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quiz.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Masukkan nama Anda untuk memulai kuis:', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _playerNameController,
                  decoration: const InputDecoration(labelText: 'Nama Anda', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startQuiz,
                  child: const Text('Mulai Kuis'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Jawab Soal: ${widget.quiz.title}"),
        actions: [
          if (widget.quiz.timerDuration > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: QuizTimer(
                durationInSeconds: widget.quiz.timerDuration,
                onTimeUp: _onTimeUp,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...widget.quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              if (question.type == 'multiple_choice') {
                return buildMultipleChoiceQuestion(question, index);
              } else if (question.type == 'true_false') {
                return buildTrueFalseQuestion(question, index);
              } else {
                return buildEssayQuestion(question, index);
              }
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopwatch.isRunning ? checkAnswers : null,
              child: const Text("Selesai"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMultipleChoiceQuestion(Question question, int index) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
              return ListTile(
                title: Text(option),
                leading: Radio<String>(
                  value: option,
                  groupValue: userAnswers[index],
                  onChanged: (value) {
                    setState(() {
                      userAnswers[index] = value!;
                    });
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildTrueFalseQuestion(Question question, int index) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(
                  label: const Text("True"),
                  selected: userAnswers[index] == "True",
                  onSelected: (selected) {
                    setState(() {
                      userAnswers[index] = "True";
                    });
                  },
                ),
                ChoiceChip(
                  label: const Text("False"),
                  selected: userAnswers[index] == "False",
                  onSelected: (selected) {
                    setState(() {
                      userAnswers[index] = "False";
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEssayQuestion(Question question, int index) {
    return Card(
      margin: const EdgeInsets.all(8.0),
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
            TextField(
              controller: _essayControllers[index],
              decoration: const InputDecoration(
                labelText: 'Jawaban Anda',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}