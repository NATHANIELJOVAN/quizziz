// lib/views/pages/main_menu_page.dart

import 'package:flutter/material.dart';
import 'create_quiz_list_page.dart';
import 'quiz_list_page.dart';
import 'history_page.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({Key? key}) : super(key: key);

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 400,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Icon(icon, size: 50, color: Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuItem(
              context: context,
              icon: Icons.edit,
              title: 'Buat Soal Kuis',
              subtitle: 'Buat kuis baru dengan berbagai jenis pertanyaan.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateQuizListPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.play_arrow,
              title: 'Jawab Soal Kuis',
              subtitle: 'Pilih kuis dan uji kemampuan Anda.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QuizListPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context: context,
              icon: Icons.history,
              title: 'Riwayat Kuis',
              subtitle: 'Lihat hasil dari kuis yang telah diselesaikan.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}