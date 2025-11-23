import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';

class CreateQuestionPage extends StatefulWidget {
  final Quiz quiz;
  final int questionIndex;
  final Question? questionToEdit;

  const CreateQuestionPage({
    Key? key,
    required this.quiz,
    required this.questionIndex,
    this.questionToEdit,
  }) : super(key: key);

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(4, () => TextEditingController());
  String? _correctAnswer;
  String _questionType = 'multiple_choice';

  @override
  void initState() {
    super.initState();
    if (widget.questionToEdit != null) {
      final question = widget.questionToEdit!;
      _questionController.text = question.questionText;
      _questionType = question.type;
      _correctAnswer = question.correctAnswer;
      if (question.type == 'multiple_choice') {
        for (int i = 0; i < question.options.length && i < _optionControllers.length; i++) {
          _optionControllers[i].text = question.options[i];
        }
      }
    }
  }

  void _saveQuestion() {
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
      if (widget.questionIndex == -1) {
        widget.quiz.questions.add(newQuestion);
      } else {
        widget.quiz.questions[widget.questionIndex] = newQuestion;
      }
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
      if (widget.questionIndex == -1) {
        widget.quiz.questions.add(newQuestion);
      } else {
        widget.quiz.questions[widget.questionIndex] = newQuestion;
      }
    } else {
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
      if (widget.questionIndex == -1) {
        widget.quiz.questions.add(newQuestion);
      } else {
        widget.quiz.questions[widget.questionIndex] = newQuestion;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan berhasil disimpan!')),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
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
        title: Text(widget.questionToEdit == null ? 'Tambah Pertanyaan' : 'Edit Pertanyaan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: _saveQuestion,
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}