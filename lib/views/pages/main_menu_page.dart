import 'package:flutter/material.dart';
import 'create_quiz_list_page.dart';
import 'quiz_list_page.dart';
import 'history_page.dart';
import '../../main.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool show = true,
    Color iconColor = Colors.blue,
  }) {
    if (!show) return const SizedBox.shrink();

    return SizedBox(
      width: 400,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(icon, size: 50, color: iconColor),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String roleSuffix = currentUserRole == 'teacher' ? '(T)' : '(S)';
    String displayName = "${currentUserName ?? 'User'} $roleSuffix";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              currentUserRole = null;
              currentUserName = null;
              currentUserEmail = null;
              await saveAppState();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MyApp()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // [BARU] 1. Logo Quiz (Icon School)
              const Icon(Icons.school, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 10),

              // [BARU] 2. Card Info User (Nama + Role & Email)
              SizedBox(
                width: 400,
                child: Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentUserEmail ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Menu 1: Buat Soal Kuis (Hanya Teacher)
              _buildMenuItem(
                context: context,
                icon: Icons.edit,
                title: 'Buat Soal Kuis',
                subtitle: 'Buat kuis baru dengan berbagai jenis pertanyaan.',
                show: currentUserRole == 'teacher',
                iconColor: Colors.blueAccent,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateQuizListPage()));
                },
              ),

              // Menu 2: Jawab Soal Kuis (HANYA STUDENT)
              _buildMenuItem(
                context: context,
                icon: Icons.play_arrow,
                title: 'Jawab Soal Kuis',
                subtitle: 'Pilih kuis dan uji kemampuan Anda.',
                show: currentUserRole == 'student',
                iconColor: Colors.green,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QuizListPage()));
                },
              ),

              // Menu 3: Riwayat/Penilaian
              _buildMenuItem(
                context: context,
                icon: Icons.history,
                title: currentUserRole == 'teacher' ? 'Nilai Tugas Esai' : 'Riwayat Kuis',
                subtitle: currentUserRole == 'teacher' ? 'Lihat dan nilai esai siswa.' : 'Lihat hasil kuis Anda.',
                show: currentUserRole == 'student' || currentUserRole == 'teacher',
                iconColor: currentUserRole == 'teacher' ? Colors.purpleAccent : Colors.blueAccent,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HistoryPage()));
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}