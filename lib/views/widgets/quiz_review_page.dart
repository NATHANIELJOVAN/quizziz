import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';

class QuizReviewPage extends StatelessWidget {
  final Map<String, dynamic> historyItem;
  final Quiz originalQuiz;

  const QuizReviewPage({
    Key? key,
    required this.historyItem,
    required this.originalQuiz,
  }) : super(key: key);

  String _getAnswer(Map<dynamic, dynamic>? map, int idx) {
    if (map == null) return '-';
    return map[idx.toString()] ?? map[idx] ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final int pgScore = historyItem['score'] ?? 0;
    final int essayScore = historyItem['essayScore'] ?? 0;
    final bool essayGraded = historyItem['essayGraded'] ?? false;

    // Ambil detail penilaian esai (jika ada)
    final Map<dynamic, dynamic> essayDetails = historyItem['essayDetails'] ?? {};

    final int totalQuestions = originalQuiz.questions.length;
    final int totalScore = pgScore + essayScore;
    final double finalGrade = totalQuestions > 0 ? (totalScore / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Jawaban")),
      body: Column(
        children: [
          // HEADER
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            color: Theme.of(context).cardColor, // Mengikuti tema
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Hasil: ${historyItem['quizTitle']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Benar PG: $pgScore"),
                      Text("Nilai Esai: ${essayGraded ? essayScore : 'Pending'}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: essayGraded
                            ? (finalGrade >= 60 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: essayGraded ? (finalGrade >= 60 ? Colors.green : Colors.red) : Colors.grey)
                    ),
                    child: Text(
                      essayGraded
                          ? "NILAI AKHIR: ${finalGrade.toStringAsFixed(0)}"
                          : "STATUS: MENUNGGU GURU",
                      style: TextStyle(
                          color: essayGraded ? (finalGrade >= 60 ? Colors.green : Colors.red) : Colors.grey,
                          fontWeight: FontWeight.bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),

          // LIST SOAL
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: originalQuiz.questions.length,
              itemBuilder: (context, index) {
                final question = originalQuiz.questions[index];
                final isEssay = question.type == 'essay';

                final userAnsMap = isEssay ? historyItem['userEssayAnswers'] : historyItem['userAnswers'];
                final safeMap = (userAnsMap is Map) ? userAnsMap : {};
                final userAns = _getAnswer(safeMap, index);

                // --- LOGIKA WARNA BARU ---
                bool isCorrect = false;

                if (isEssay) {
                  // Cek status dari data essayDetails yang disimpan guru
                  if (essayGraded && essayDetails.containsKey(index.toString())) {
                    isCorrect = essayDetails[index.toString()] == true;
                  } else {
                    isCorrect = false; // Default jika belum dinilai
                  }
                } else {
                  // PG/TF
                  isCorrect = (userAns == question.correctAnswer);
                }

                Color borderColor;
                IconData icon;

                if (isEssay && !essayGraded) {
                  // Esai Belum Dinilai: Biru Netral
                  borderColor = Colors.blue;
                  icon = Icons.edit_note;
                } else {
                  // Sudah Dinilai (PG atau Esai): Hijau/Merah
                  borderColor = isCorrect ? Colors.green : Colors.red;
                  icon = isCorrect ? Icons.check_circle : Icons.cancel;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: borderColor.withOpacity(0.5), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Soal ${index + 1} (${question.type})",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Icon(icon, color: borderColor),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(question.questionText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const Divider(),
                        const Text("Jawaban Kamu:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(userAns, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

                        // Tampilkan Kunci (Jika salah dan bukan esai yang belum dinilai)
                        if (!isEssay && !isCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("Kunci: ${question.correctAnswer}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ),

                        // Status Esai
                        if (isEssay)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              essayGraded
                                  ? (isCorrect ? "Guru: Benar (+1)" : "Guru: Salah (0)")
                                  : "(Menunggu penilaian guru)",
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}