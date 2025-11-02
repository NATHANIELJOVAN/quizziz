// lib/views/pages/create_quiz_list_page.dart

import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../services/quiz_manager.dart'; // Akses Service
import 'create_quiz_page.dart';
import 'edit_quiz_page.dart';

// Akses instance global quizManager (didefinisikan di main.dart)
// Hapus final QuizManager manager = QuizManager(); jika sudah ada di main.dart
// Kita harus menggunakan nama variabel yang sama dengan yang didefinisikan di main.dart
// Saya asumsikan nama variabel global di main.dart adalah quizManager
import '../../main.dart'; // Import main.dart untuk mengakses quizManager

class CreateQuizListPage extends StatefulWidget {
  const CreateQuizListPage({Key? key}) : super(key: key);

  @override
  State<CreateQuizListPage> createState() => _CreateQuizListPageState();
}

class _CreateQuizListPageState extends State<CreateQuizListPage> {
  void _refreshQuizList() {
    setState(() {});
  }

  void _showRenameDialog(BuildContext context, int index, Quiz quiz) {
    final TextEditingController _renameController = TextEditingController(text: quiz.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ganti Nama Kuis'),
          content: TextField(
            controller: _renameController,
            decoration: const InputDecoration(hintText: 'Masukkan judul baru'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_renameController.text.isNotEmpty) {
                  setState(() {
                    quizManager.quizzes[index].title = _renameController.text;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Judul kuis berhasil diubah!')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _deleteQuiz(int index) {
    setState(() {
      quizManager.quizzes.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kuis berhasil dihapus!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizzes = quizManager.quizzes; // Akses dari global Service

    if (quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Kuis Dibuat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateQuizPage()),
                );
                _refreshQuizList();
              },
            ),
          ],
        ),
        body: const Center(
          child: Text('Belum ada kuis yang dibuat. Klik + untuk memulai.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kuis Dibuat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateQuizPage()),
              );
              _refreshQuizList();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return ListTile(
            title: Text(quiz.title),
            subtitle: Text('${quiz.questions.length} soal'),
            onTap: () {
              // Navigasi ke halaman EditQuizPage saat di-tap
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditQuizPage(
                    quiz: quiz,
                    quizIndex: index,
                  ),
                ),
              ).then((_) => _refreshQuizList());
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showRenameDialog(context, index, quiz),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteQuiz(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}