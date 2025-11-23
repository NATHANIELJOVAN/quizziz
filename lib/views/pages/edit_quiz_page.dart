import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import 'create_question_page.dart';
import '../../main.dart';

class EditQuizPage extends StatefulWidget {
  final Quiz quiz;
  final int quizIndex;

  const EditQuizPage({Key? key, required this.quiz, required this.quizIndex}) : super(key: key);

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  late int _selectedTimerDuration;
  final Map<int, String> _timerOptions = {
    0: 'Tidak Ada Timer',
    30: '30 Detik',
    60: '1 Menit',
    300: '5 Menit',
    600: '10 Menit',
  };

  @override
  void initState() {
    super.initState();
    _selectedTimerDuration = widget.quiz.timerDuration;
  }

  void _editQuestion(int questionIndex, Question question) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateQuestionPage(
          quiz: widget.quiz,
          questionIndex: questionIndex,
          questionToEdit: question,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _deleteQuestion(int questionIndex) {
    setState(() {
      widget.quiz.questions.removeAt(questionIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pertanyaan berhasil dihapus!')),
    );
  }

  void _addQuestion() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateQuestionPage(
          quiz: widget.quiz,
          questionIndex: -1,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _updateTimerDuration(int? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedTimerDuration = newValue;
        widget.quiz.timerDuration = _selectedTimerDuration;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi timer berhasil diubah!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Kuis: ${widget.quiz.title}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Durasi Timer: '),
                DropdownButton<int>(
                  value: _selectedTimerDuration,
                  onChanged: _updateTimerDuration,
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
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.quiz.questions[index];
                return ListTile(
                  title: Text(question.questionText),
                  subtitle: Text(
                    question.type == 'multiple_choice'
                        ? 'Pilihan Ganda'
                        : question.type == 'true_false'
                        ? 'True/False'
                        : 'Esai',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editQuestion(index, question),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteQuestion(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Pertanyaan Baru'),
            ),
          ),
        ],
      ),
    );
  }
}