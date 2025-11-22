import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../widgets/result_page.dart';
import '../widgets/quiz_timer.dart';
import '../../main.dart';

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

  int _remainingTimeSeconds = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _playerNameController.text = currentUserName ?? '';
    _remainingTimeSeconds = widget.quiz.timerDuration;

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (widget.quiz.questions[i].type == 'essay') {
        _essayControllers[i] = TextEditingController();
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (currentUserRole != 'student' || _quizCompleted || !quizStarted) {
      return true;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Anda tidak bisa keluar saat kuis berlangsung!')),
    );
    return false;
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
    if (quizStarted && !_quizCompleted) {
      checkAnswers();
    }
  }

  void checkAnswers() async {
    _stopwatch.stop();

    int correctAnswers = quizManager.calculateScore(widget.quiz, userAnswers);
    int totalAllQuestions = widget.quiz.questions.length;

    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (widget.quiz.questions[i].type == 'essay') {
        String answerText = _essayControllers[i]?.text.trim() ?? '';
        if (answerText.isEmpty) answerText = "Tidak Dijawab";
        userEssayAnswers[i] = answerText;
      }
    }

    quizManager.addHistory(
      playerName: _playerNameController.text,
      studentEmail: currentUserEmail,
      quizTitle: widget.quiz.title,
      score: correctAnswers,
      totalQuestions: totalAllQuestions,
      userAnswers: userAnswers,
      userEssayAnswers: userEssayAnswers,
    );

    setState(() {
      _quizCompleted = true;
    });

    await saveAppState();

    if (!mounted) return;

    int totalEssayCount = widget.quiz.questions.where((q) => q.type == 'essay').length;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          score: correctAnswers,
          totalQuestions: totalAllQuestions,
          totalEssay: totalEssayCount,
          timeSpent: _stopwatch.elapsed.inSeconds,
        ),
      ),
    );

    if (!mounted) return;

    if (result == "retry") {
      setState(() {
        userAnswers = {};
        userEssayAnswers = {};
        _essayControllers.forEach((_, controller) => controller.clear());
        _stopwatch.reset();
        _stopwatch.start();
        _quizCompleted = false;
        _remainingTimeSeconds = widget.quiz.timerDuration;
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
    bool canPop = !quizStarted || _quizCompleted || currentUserRole != 'student';

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(quizStarted ? "Jawab Soal: ${widget.quiz.title}" : widget.quiz.title),
          automaticallyImplyLeading: canPop,
          actions: [
            if (quizStarted && widget.quiz.timerDuration > 0 && !_quizCompleted)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: QuizTimer(
                  durationInSeconds: _remainingTimeSeconds,
                  onTimeUp: _onTimeUp,
                ),
              ),
          ],
        ),
        body: !quizStarted ? _buildStartScreen() : _buildQuizContent(),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Masukkan nama Anda untuk memulai kuis:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                labelText: 'Nama Anda',
                border: OutlineInputBorder(),
                hintText: 'Silakan ketik nama lengkap',
              ),
              enabled: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startQuiz,
              child: const Text('Mulai Kuis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return SingleChildScrollView(
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
            onPressed: !_quizCompleted ? checkAnswers : null,
            child: const Text("Selesai"),
          ),
        ],
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