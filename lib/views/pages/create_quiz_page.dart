// lib/views/pages/create_quiz_page.dart

import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../../services/quiz_manager.dart'; // Akses Service
import '../../main.dart'; // Import main.dart untuk mengakses quizManager

class CreateQuizPage extends StatefulWidget {
  const CreateQuizPage({Key? key}) : super(key: key);

  @override
  _CreateQuizPageState createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final _quizTitleController = TextEditingController();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  String? _correctAnswer;
  String _questionType = 'multiple_choice';
  final List<Question> _currentQuestions = [];
  int _selectedTimerDuration = 0;
  final Map<int, String> _timerOptions = {
    0: 'Tidak Ada Timer',
    30: '30 Detik',
    60: '1 Menit',
    300: '5 Menit',
    600: '10 Menit',
  };

  void _addQuestion() {
    if (_questionType == 'multiple_choice') {
      if (_questionController.text.isEmpty || _correctAnswer == null || _optionControllers.any((c) => c.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi!')),
        );
        return;
      }
      List<String> options = _optionControllers.map((c) => c.text).toList();
      final newQuestion = Question(
        questionText: _questionController.text,
        options: options,
        correctAnswer: _correctAnswer!,
        type: _questionType,
      );
      _currentQuestions.add(newQuestion);
    } else if (_questionType == 'true_false') {
      if (_questionController.text.isEmpty || _correctAnswer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teks pertanyaan dan jawaban harus diisi!')),
        );
        return;
      }
      final newQuestion = Question(
        questionText: _questionController.text,
        options: ['True', 'False'],
        correctAnswer: _correctAnswer!,
        type: 'true_false',
      );
      _currentQuestions.add(newQuestion);
    } else { // essay
      if (_questionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teks pertanyaan harus diisi!')),
        );
        return;
      }
      final newQuestion = Question(
        questionText: _questionController.text,
        options: [],
        type: 'essay',
      );
      _currentQuestions.add(newQuestion);
    }

    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswer = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soal berhasil ditambahkan!')),
    );
  }

  void _saveQuiz() {
    if (_quizTitleController.text.isEmpty || _currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan setidaknya satu soal harus ada!')),
      );
      return;
    }
    final newQuiz = Quiz(
      title: _quizTitleController.text,
      questions: List.from(_currentQuestions),
      timerDuration: _selectedTimerDuration,
    );
    quizManager.addQuiz(newQuiz); // Gunakan Service

    _quizTitleController.clear();
    _currentQuestions.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kuis berhasil disimpan!')),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _quizTitleController.dispose();
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Soal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _quizTitleController,
              decoration: const InputDecoration(labelText: 'Judul Kuis'),
            ),
            const SizedBox(height: 20),
            // Dropdown untuk jenis pertanyaan
            DropdownButton<String>(
              value: _questionType,
              onChanged: (String? newValue) {
                setState(() {
                  _questionType = newValue!;
                  _correctAnswer = null;
                });
              },
              items: const <String>['multiple_choice', 'true_false', 'essay']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'multiple_choice' ? 'Pilihan Ganda' : value == 'true_false' ? 'True/False' : 'Esai'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Dropdown untuk durasi timer
            Row(
              children: [
                const Text('Durasi Timer: '),
                DropdownButton<int>(
                  value: _selectedTimerDuration,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedTimerDuration = newValue!;
                    });
                  },
                  items: _timerOptions.entries
                      .map<DropdownMenuItem<int>>((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Teks Pertanyaan'),
            ),
            if (_questionType == 'multiple_choice') ...[
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return ListTile(
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'Opsi ${String.fromCharCode(65 + index)}'),
                  ),
                  leading: Radio<String>(
                    value: controller.text,
                    groupValue: _correctAnswer,
                    onChanged: (String? value) {
                      setState(() {
                        _correctAnswer = value;
                      });
                    },
                  ),
                );
              }).toList(),
            ] else if (_questionType == 'true_false') ...[
              ListTile(
                title: const Text('True'),
                leading: Radio<String>(
                  value: 'True',
                  groupValue: _correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      _correctAnswer = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('False'),
                leading: Radio<String>(
                  value: 'False',
                  groupValue: _correctAnswer,
                  onChanged: (String? value) {
                    setState(() {
                      _correctAnswer = value;
                    });
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Tambah Soal'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveQuiz,
              child: const Text('Simpan Kuis'),
            ),
          ],
        ),
      ),
    );
  }
}