import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../../main.dart';

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
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teks pertanyaan harus diisi!')));
      return;
    }

    if (_questionType == 'multiple_choice') {
      if (_correctAnswer == null || _optionControllers.any((c) => c.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua opsi dan pilih jawaban benar!')));
        return;
      }
      List<String> options = _optionControllers.map((c) => c.text).toList();
      _currentQuestions.add(Question(
        questionText: _questionController.text,
        options: options,
        correctAnswer: _correctAnswer!,
        type: 'multiple_choice',
      ));
    } else if (_questionType == 'true_false') {
      if (_correctAnswer == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih True atau False!')));
        return;
      }
      _currentQuestions.add(Question(
        questionText: _questionController.text,
        options: ['True', 'False'],
        correctAnswer: _correctAnswer!,
        type: 'true_false',
      ));
    } else { // Essay
      _currentQuestions.add(Question(
        questionText: _questionController.text,
        options: [],
        type: 'essay',
      ));
    }

    // Reset Form Soal
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswer = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Soal berhasil ditambahkan ke daftar!')));
  }

  void _saveQuiz() async {
    if (_quizTitleController.text.isEmpty || _currentQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul kuis dan minimal 1 soal harus ada!')),
      );
      return;
    }

    final newQuiz = Quiz(
      title: _quizTitleController.text,
      questions: List.from(_currentQuestions),
      timerDuration: _selectedTimerDuration,
      creatorEmail: currentUserEmail,
    );

    quizManager.addQuiz(newQuiz);
    await saveAppState();

    if (!mounted) return;

    _quizTitleController.clear();
    _currentQuestions.clear();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kuis berhasil disimpan!')));
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
      appBar: AppBar(title: const Text('Buat Soal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAGIAN JUDUL KUIS ---
            TextField(
              controller: _quizTitleController,
              decoration: const InputDecoration(
                labelText: 'Judul Kuis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 10),

            // --- BAGIAN TIMER ---
            Row(
              children: [
                const Icon(Icons.timer),
                const SizedBox(width: 10),
                const Text('Durasi Timer: '),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _selectedTimerDuration,
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedTimerDuration = newValue!;
                    });
                  },
                  items: _timerOptions.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const Divider(thickness: 2, height: 30),
            const Text("Tambah Pertanyaan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // --- JENIS PERTANYAAN ---
            DropdownButtonFormField<String>(
              value: _questionType,
              decoration: const InputDecoration(
                labelText: 'Tipe Soal',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _questionType = newValue!;
                  _correctAnswer = null;
                });
              },
              items: const [
                DropdownMenuItem(value: 'multiple_choice', child: Text('Pilihan Ganda')),
                DropdownMenuItem(value: 'true_false', child: Text('Benar / Salah')),
                DropdownMenuItem(value: 'essay', child: Text('Esai')),
              ],
            ),
            const SizedBox(height: 15),

            // --- TEKS PERTANYAAN ---
            TextField(
              controller: _questionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Pertanyaan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 15),

            // --- INPUT OPSI JAWABAN ---
            if (_questionType == 'multiple_choice') ...[
              const Text("Opsi Jawaban (Pilih bulatan untuk kunci jawaban):"),
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Opsi ${String.fromCharCode(65 + index)}',
                      isDense: true,
                    ),
                    onChanged: (text) {
                      if (_correctAnswer != null && _correctAnswer == text) {
                        setState(() {});
                      }
                    },
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
              const Text("Kunci Jawaban:"),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('True'),
                      value: 'True',
                      groupValue: _correctAnswer,
                      onChanged: (val) => setState(() => _correctAnswer = val),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('False'),
                      value: 'False',
                      groupValue: _correctAnswer,
                      onChanged: (val) => setState(() => _correctAnswer = val),
                    ),
                  ),
                ],
              ),
            ] else if (_questionType == 'essay') ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Untuk soal esai, jawaban akan dinilai secara manual oleh Guru.",
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // --- TOMBOL AKSI ---
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('TAMBAH SOAL INI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade900,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Soal tersimpan sementara: ${_currentQuestions.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveQuiz,
              icon: const Icon(Icons.save),
              label: const Text('SIMPAN KUIS (SELESAI)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}