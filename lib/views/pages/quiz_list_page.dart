import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/quiz.dart';
import '../../services/quiz_manager.dart';
import '../../main.dart'; // Akses Global
import 'quiz_page.dart';

class QuizListPage extends StatefulWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  State<QuizListPage> createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  String _searchQuery = '';

  String _getTimerText(int duration) {
    if (duration == 0) return 'Tidak Ada Timer';
    if (duration < 60) return '$duration Detik';
    return '${duration ~/ 60} Menit';
  }

  // Fungsi Helper untuk mengambil Nama Guru dari Firestore
  Future<String> _getTeacherName(String? email) async {
    if (email == null || email.isEmpty) return "Tidak Diketahui";
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['name'] ?? email;
      }
      return email;
    } catch (e) { return email; }
  }

  @override
  Widget build(BuildContext context) {
    final allQuizzes = quizManager.quizzes;

    // Logika Filter
    final filteredQuizzes = allQuizzes.where((quiz) {
      final titleLower = quiz.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kuis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari Judul Kuis...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredQuizzes.length,
          itemBuilder: (context, index) {
            final quiz = filteredQuizzes[index];

            // FIX: Gunakan ?? '' untuk mengatasi error nullable (String? -> String)
            final isCompleted = quizManager.isQuizCompleted(quiz.title, currentUserEmail ?? '');

            final onTapAction = isCompleted
                ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anda sudah menyelesaikan kuis ini.')),
              );
            }
                : () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)),
              );
            };

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              color: isCompleted ? Colors.grey.withOpacity(0.1) : Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isCompleted ? Colors.green : Colors.blue.withOpacity(0.6)),
              ),
              child: ListTile(
                onTap: onTapAction,
                leading: CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green : Colors.blue.withOpacity(0.1),
                  child: Icon(isCompleted ? Icons.check_circle : Icons.library_books, color: isCompleted ? Colors.white : Colors.blue, size: 24),
                ),
                title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${isCompleted ? "Sudah Dikerjakan" : "Siap Dikerjakan"}',
                        style: TextStyle(color: isCompleted ? Colors.greenAccent : Colors.greenAccent, fontSize: 12)),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.list_alt, size: 14, color: Colors.yellow[400]),
                        const SizedBox(width: 4),
                        Text('${quiz.questions.length} Soal', style: TextStyle(fontSize: 12, color: Colors.yellow[400])),
                        const SizedBox(width: 12),
                        Icon(Icons.timer, size: 14, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(_getTimerText(quiz.timerDuration), style: TextStyle(fontSize: 12, color: Colors.red[400])),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // FutureBuilder for Teacher Name
                    FutureBuilder<String>(
                      future: _getTeacherName(quiz.creatorEmail),
                      builder: (context, snapshot) {
                        final teacherName = snapshot.data ?? 'Memuat...';
                        return Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.blue[400]),
                            const SizedBox(width: 4),
                            // FIX: Gunakan ?? '' untuk memastikan non-null String
                            Text('Guru: ${teacherName}', style: TextStyle(fontSize: 12, color: Colors.blue[400])),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                trailing: Icon(isCompleted ? Icons.lock : Icons.arrow_forward_ios, color: isCompleted ? Colors.red : Colors.blueAccent),
              ),
            );
          },
        ),
      ),
    );
  }
}