// lib/views/pages/create_quiz_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quiz.dart';
import '../../viewmodels/quiz_viewmodel.dart';
import 'create_quiz_page.dart';
import 'edit_quiz_page.dart';

class CreateQuizListPage extends StatelessWidget {
  const CreateQuizListPage({Key? key}) : super(key: key);

  void _showRenameDialog(BuildContext context, int index, Quiz quiz) {
    final viewModel = Provider.of<QuizViewModel>(context, listen: false);
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
                  viewModel.updateQuizTitle(index, _renameController.text);
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

  void _deleteQuiz(BuildContext context, int index) {
    final viewModel = Provider.of<QuizViewModel>(context, listen: false);
    viewModel.deleteQuiz(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kuis berhasil dihapus!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.quizzes.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daftar Kuis Dibuat'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CreateQuizPage()),
                    );
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreateQuizPage()),
                  );
                },
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: viewModel.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = viewModel.quizzes[index];
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
                  );
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
                      onPressed: () => _deleteQuiz(context, index),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}