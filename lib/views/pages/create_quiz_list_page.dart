import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../main.dart'; // Mengakses global quizManager, currentUserRole, currentUserEmail, saveAppState
import 'create_quiz_page.dart';
import 'edit_quiz_page.dart';

class CreateQuizListPage extends StatefulWidget {
  const CreateQuizListPage({Key? key}) : super(key: key);

  @override
  State<CreateQuizListPage> createState() => _CreateQuizListPageState();
}

class _CreateQuizListPageState extends State<CreateQuizListPage> {
  String _searchQuery = '';

  void _refreshQuizList() {
    setState(() {});
  }

  void _deleteQuiz(int index) async {
    // Konfirmasi hapus dulu agar aman
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kuis?'),
        content: const Text('Kuis yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(child: const Text('Batal'), onPressed: () => Navigator.pop(context, false)),
          TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.pop(context, true)
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() {
        quizManager.quizzes.removeAt(index);
      });
      await saveAppState(); // Simpan perubahan ke storage
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kuis dihapus!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Security check: Hanya guru yang boleh akses halaman ini
    if (currentUserRole != 'teacher') return const SizedBox.shrink();

    // Filter kuis milik guru ini saja dan sesuai search query
    final filteredQuizzes = quizManager.quizzes.where((quiz) {
      final titleLower = quiz.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      // Cek email pembuat sama dengan user yang login
      return quiz.creatorEmail == currentUserEmail && titleLower.contains(queryLower);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kuis Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Buat Kuis Baru',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateQuizPage()),
              );
              _refreshQuizList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari Judul Kuis...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor, // Sesuaikan dengan tema dark mode
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredQuizzes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            const Text('Belum ada kuis yang Anda buat.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredQuizzes.length,
        itemBuilder: (context, index) {
          final quiz = filteredQuizzes[index];
          // Kita butuh index asli di quizManager untuk fungsi delete/edit yang akurat
          final realIndex = quizManager.quizzes.indexOf(quiz);

          // --- FORMAT TANGGAL ---
          // Format: DD/MM/YYYY
          String dateInfo = "Dibuat: ${quiz.createdAt.day.toString().padLeft(2, '0')}/${quiz.createdAt.month.toString().padLeft(2, '0')}/${quiz.createdAt.year}";

          // Jika ada tanggal update, tambahkan infonya
          if (quiz.updatedAt != null) {
            dateInfo += "\nDiupdate: ${quiz.updatedAt!.day.toString().padLeft(2, '0')}/${quiz.updatedAt!.month.toString().padLeft(2, '0')} ${quiz.updatedAt!.hour}:${quiz.updatedAt!.minute.toString().padLeft(2, '0')}";
          }
          // ---------------------

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                quiz.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.list_alt, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text('${quiz.questions.length} Soal', style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      Icon(Icons.timer, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                          quiz.timerDuration > 0 ? '${quiz.timerDuration} Detik' : 'No Timer',
                          style: const TextStyle(fontSize: 12)
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Menampilkan Info Tanggal
                  Text(
                    dateInfo,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              onTap: () {
                // Buka halaman edit
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditQuizPage(quiz: quiz, quizIndex: realIndex),
                  ),
                ).then((_) => _refreshQuizList());
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _deleteQuiz(realIndex),
              ),
            ),
          );
        },
      ),
    );
  }
}