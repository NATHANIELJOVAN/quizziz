import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

// Import Models
import 'models/question.dart';
import 'models/quiz.dart';
// Import Services
import 'services/quiz_manager.dart';
// Import ViewModels
import 'viewmodels/quiz_viewmodel.dart';
// Import Views (Pages)
import 'views/pages/main_menu_page.dart';
import 'views/pages/create_quiz_list_page.dart';
import 'views/pages/create_quiz_page.dart';
import 'views/pages/edit_quiz_page.dart';
import 'views/pages/quiz_list_page.dart';
import 'views/pages/quiz_page.dart';
import 'views/pages/history_page.dart';
// Import Views (Widgets)
import 'views/widgets/quiz_review_page.dart';
import 'views/widgets/result_page.dart';
import 'views/widgets/quiz_timer.dart';

// Global instance of the Service Layer
final QuizManager quizManager = QuizManager();

void main() {
  runApp(
    // MultiProvider digunakan untuk menyuntikkan QuizViewModel ke seluruh aplikasi
    ChangeNotifierProvider(
      create: (context) => QuizViewModel(quizManager),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Creator & Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainMenuPage(),
    );
  }
}

// =================================================================
// VIEWS: MainMenuPage (View Utama)
// =================================================================

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