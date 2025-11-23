import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/quiz.dart';
import '../../models/question.dart';
import '../../main.dart';
import '../widgets/quiz_review_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentUserRole == 'teacher') {
      return TeacherQuizListForGrading();
    } else {
      return StudentHistoryPage();
    }
  }
}

// =================================================================
// 1. SISWA VIEW (Riwayat Pribadi)
// =================================================================

class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage({Key? key}) : super(key: key);

  Future<String> _getTeacherName(String? email) async {
    if (email == null || email.isEmpty) return "Guru Tidak Diketahui";
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) return snapshot.docs.first['name'] ?? email;
      return email;
    } catch (e) {
      return email;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = quizManager.history
        .where((item) => item['studentEmail'] == currentUserEmail)
        .toList();

    if (allHistory.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Riwayat Kuis Anda')), body: const Center(child: Text('Anda belum menyelesaikan kuis.')),);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kuis Anda')),
      body: ListView.builder(
        itemCount: allHistory.length,
        itemBuilder: (context, index) {
          final historyItem = allHistory[index];
          final Quiz? originalQuiz = quizManager.getQuizByTitle(historyItem['quizTitle']);

          final int pgScore = (historyItem['score'] as int?) ?? 0;
          final int essayScore = (historyItem['essayScore'] as int?) ?? 0;
          final bool essayGraded = (historyItem['essayGraded'] as bool?) ?? false;

          final int totalQuestions = (historyItem['totalQuestions'] as int?)
              ?? originalQuiz?.questions.length
              ?? 0;

          final int totalAutoQuestions = originalQuiz?.questions.where((q) => q.type != 'essay').length ?? 0;
          final int wrongPgAnswers = totalAutoQuestions - pgScore;

          final int totalCorrect = pgScore + essayScore;
          final double finalGrade = totalQuestions > 0
              ? (totalCorrect / totalQuestions) * 100
              : 0;

          final String? teacherEmail = originalQuiz?.creatorEmail;

          Color statusColor;
          Color borderColor;
          if (!essayGraded && originalQuiz?.questions.any((q) => q.type == 'essay') == true) {
            statusColor = Colors.orange.withOpacity(0.1);
            borderColor = Colors.orange;
          } else {
            statusColor = finalGrade >= 60 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
            borderColor = finalGrade >= 60 ? Colors.green : Colors.red;
          }

          return Card(
            margin: const EdgeInsets.all(8.0),
            color: statusColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(historyItem['quizTitle'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (teacherEmail != null)
                    FutureBuilder<String>(
                      future: _getTeacherName(teacherEmail),
                      builder: (context, snapshot) => Text("Oleh: ${snapshot.data ?? '...'}", style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ),
                  const SizedBox(height: 5),

                  if (!essayGraded && originalQuiz?.questions.any((q) => q.type == 'essay') == true)
                    const Text("Status: Menunggu Penilaian Guru ⏳", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12))
                  else ...[
                    Text("PG Benar: $pgScore | Salah: $wrongPgAnswers"),
                    if (originalQuiz?.questions.any((q) => q.type == 'essay') == true)
                      Text("Esai Benar: $essayScore"),
                    const Divider(),
                    Text("NILAI AKHIR: ${finalGrade.toStringAsFixed(0)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: finalGrade >= 60 ? Colors.greenAccent : Colors.redAccent)),
                  ]
                ],
              ),
              trailing: essayGraded || (originalQuiz?.questions.any((q) => q.type == 'essay') != true)
                  ? CircleAvatar(
                backgroundColor: finalGrade >= 60 ? Colors.green : Colors.red,
                child: Text(finalGrade.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
                  : const Icon(Icons.hourglass_bottom, color: Colors.orange, size: 30),
              onTap: () {
                if (originalQuiz != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizReviewPage(
                        historyItem: historyItem,
                        originalQuiz: originalQuiz,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kuis asli sudah dihapus oleh guru.")));
                }
              },
            ),
          );
        },
      ),
    );
  }
}


// =================================================================
// 2. TINGKAT 1: GURU - Daftar Kuis (QuizGradingList)
// =================================================================

class TeacherQuizListForGrading extends StatefulWidget {
  const TeacherQuizListForGrading({Key? key}) : super(key: key);

  @override
  State<TeacherQuizListForGrading> createState() => _TeacherQuizListForGradingState();
}

class _TeacherQuizListForGradingState extends State<TeacherQuizListForGrading> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 1. Filter semua riwayat yang merupakan kuis guru ini
    final historyItemsToShow = quizManager.history.where((item) {
      final Quiz? quiz = quizManager.getQuizByTitle(item['quizTitle']);
      return quiz != null && quiz.creatorEmail == currentUserEmail;
    }).toList();

    if (historyItemsToShow.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Daftar Penilaian')),
        body: const Center(child: Text('Belum ada tugas siswa yang tersimpan untuk kuis Anda.')),
      );
    }

    // 2. Kelompokkan riwayat berdasarkan Judul Kuis
    Map<String, List<Map<String, dynamic>>> groupedHistory = {};
    for (var item in historyItemsToShow) {
      final title = item['quizTitle'] as String;
      if (!groupedHistory.containsKey(title)) {
        groupedHistory[title] = [];
      }
      groupedHistory[title]!.add(item);
    }

    // 3. Filter Kuis berdasarkan search query
    final filteredQuizTitles = groupedHistory.keys.where((title) {
      final queryLower = _searchQuery.toLowerCase();
      return title.toLowerCase().contains(queryLower);
    }).toList();

    // 4. Urutkan berdasarkan kuis yang belum dinilai
    filteredQuizTitles.sort((a, b) {
      final aPending = groupedHistory[a]!.any((item) => (item['essayGraded'] == false && quizManager.getQuizByTitle(item['quizTitle'])?.questions.any((q) => q.type == 'essay') == true));
      final bPending = groupedHistory[b]!.any((item) => (item['essayGraded'] == false && quizManager.getQuizByTitle(item['quizTitle'])?.questions.any((q) => q.type == 'essay') == true));

      if (aPending && !bPending) return -1;
      if (!aPending && bPending) return 1;
      return a.compareTo(b);
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kuis yang Dikerjakan'),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: filteredQuizTitles.isEmpty
          ? Center(child: Text('Tidak ada kuis yang cocok dengan: "$_searchQuery"'))
          : ListView.builder(
        itemCount: filteredQuizTitles.length,
        itemBuilder: (context, index) {
          final quizTitle = filteredQuizTitles[index];
          final submissions = groupedHistory[quizTitle]!;

          final int totalSubmissions = submissions.length;
          final int needGrading = submissions.where((item) {
            final Quiz? originalQuiz = quizManager.getQuizByTitle(item['quizTitle']);
            final bool hasEssay = originalQuiz?.questions.any((q) => q.type == 'essay') ?? false;
            final bool isGraded = (item['essayGraded'] as bool?) ?? false;
            return hasEssay && !isGraded;
          }).length;

          final bool isPending = needGrading > 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            color: isPending ? Colors.orange.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isPending ? Colors.orange : Colors.blue, width: 1),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isPending ? Colors.orange : Colors.blue,
                child: Text(totalSubmissions.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              title: Text(quizTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Total Jawaban: $totalSubmissions\n' +
                    (isPending ? '⚠️ PERLU DINILAI: $needGrading siswa' : '✅ Semua Selesai Dinilai'),
                style: TextStyle(color: isPending ? Colors.orangeAccent : Colors.blueAccent),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TeacherGradingPage(
                      quizTitle: quizTitle,
                      submissions: submissions,
                      onGradeSubmitted: () => setState(() {}),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =================================================================
// 3. TINGKAT 2: GURU - Daftar Siswa per Kuis (TeacherGradingPage)
// =================================================================

class TeacherGradingPage extends StatefulWidget {
  final String quizTitle;
  final List<Map<String, dynamic>> submissions;
  final VoidCallback onGradeSubmitted;

  const TeacherGradingPage({
    Key? key,
    required this.quizTitle,
    required this.submissions,
    required this.onGradeSubmitted,
  }) : super(key: key);

  @override
  State<TeacherGradingPage> createState() => _TeacherGradingPageState();
}

class _TeacherGradingPageState extends State<TeacherGradingPage> {
  String _searchQuery = '';

  void _refreshList() { setState(() { widget.onGradeSubmitted(); }); }

  void _navigateToGrading(Map<String, dynamic> historyItem, int historyIndex, bool hasEssay, Quiz? originalQuiz) async {
    if (originalQuiz == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kuis asli tidak ditemukan.")));
      return;
    }

    if (hasEssay) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EssayGradingPage(
            historyItem: historyItem,
            originalQuiz: originalQuiz,
            historyIndex: historyIndex,
            onGradeSubmitted: _refreshList,
          ),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizReviewPage(
            historyItem: historyItem,
            originalQuiz: originalQuiz,
          ),
        ),
      );
    }
    _refreshList();
  }

  @override
  Widget build(BuildContext context) {

    // Filter submissions (jawaban siswa) berdasarkan query
    final filteredSubmissions = widget.submissions.where((item) {
      final studentNameLower = (item['playerName'] as String).toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return studentNameLower.contains(queryLower);
    }).toList();

    // Urutkan: yang belum dinilai di atas
    filteredSubmissions.sort((a, b) {
      final Quiz? originalQuiz = quizManager.getQuizByTitle(widget.quizTitle);
      final bool hasEssay = originalQuiz?.questions.any((q) => q.type == 'essay') ?? false;

      if (!hasEssay) return 0; // Urutan tetap jika tidak ada esai

      final aGraded = (a['essayGraded'] as bool?) ?? false;
      final bGraded = (b['essayGraded'] as bool?) ?? false;

      if (!aGraded && bGraded) return -1;
      if (aGraded && !bGraded) return 1;
      return (a['playerName'] as String).compareTo(b['playerName'] as String);
    });


    return Scaffold(
      appBar: AppBar(
        title: Text('Jawaban Siswa untuk: ${widget.quizTitle}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari Nama Siswa...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: filteredSubmissions.isEmpty
          ? Center(child: Text('Tidak ada siswa yang cocok dengan: "$_searchQuery"'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredSubmissions.length,
        itemBuilder: (context, index) {
          final historyItem = filteredSubmissions[index];

          // Cari index riwayat di list global quizManager.history
          final realIndex = quizManager.history.indexWhere((element) =>
          element['quizTitle'] == historyItem['quizTitle'] &&
              element['studentEmail'] == historyItem['studentEmail']
          );

          final Quiz? originalQuiz = quizManager.getQuizByTitle(historyItem['quizTitle']);

          final bool hasEssay = originalQuiz?.questions.any((q) => q.type == 'essay') ?? false;

          final isGradedByTeacher = (historyItem['essayGraded'] as bool?) ?? false;
          final int pgScore = (historyItem['score'] as int?) ?? 0;
          final int essayScore = (historyItem['essayScore'] as int?) ?? 0;

          final int totalQuestions = (historyItem['totalQuestions'] as int?)
              ?? originalQuiz?.questions.length
              ?? 0;

          final int totalCorrect = pgScore + essayScore;
          final double finalGrade = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

          // Penentuan warna dan tampilan
          Color cardColor;
          Color borderColor;
          IconData leadingIcon;
          Color iconColor;
          String statusText;
          Widget trailingWidget;

          if (!hasEssay) {
            // PG/TF ONLY -> Otomatis selesai dan biru
            cardColor = Colors.blue.withOpacity(0.1);
            borderColor = Colors.blue;
            leadingIcon = Icons.check_circle_outline;
            iconColor = Colors.blue;
            // UPDATED: Tampilkan Nilai Akhir
            statusText = "✅ Nilai Akhir: ${finalGrade.toStringAsFixed(0)}";

            // Trailing: Tampilkan Nilai dalam CircleAvatar
            trailingWidget = CircleAvatar(
              backgroundColor: finalGrade >= 60 ? Colors.green : Colors.red,
              child: Text(finalGrade.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );

          } else if (isGradedByTeacher) {
            // Esai sudah dinilai
            cardColor = finalGrade >= 60 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1);
            borderColor = finalGrade >= 60 ? Colors.green : Colors.red;
            leadingIcon = Icons.check;
            iconColor = finalGrade >= 60 ? Colors.green : Colors.red;
            statusText = "Nilai Akhir: ${finalGrade.toStringAsFixed(0)}";

            // Trailing: Tampilkan Nilai dalam CircleAvatar
            trailingWidget = CircleAvatar(
              backgroundColor: finalGrade >= 60 ? Colors.green : Colors.red,
              child: Text(finalGrade.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            );

          } else {
            // Esai belum dinilai
            cardColor = Colors.orange.withOpacity(0.1);
            borderColor = Colors.orange;
            leadingIcon = Icons.edit_note;
            iconColor = Colors.orange;
            statusText = "⚠️ PERLU DINILAI";

            // Trailing: Tampilkan ikon panah untuk masuk ke halaman penilaian
            trailingWidget = const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16);
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            color: cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(leadingIcon, color: iconColor),
              ),
              title: Text(historyItem['playerName'] ?? 'Siswa Tidak Dikenal', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Status: ' + statusText,
                style: TextStyle(color: hasEssay && !isGradedByTeacher ? Colors.orangeAccent : Colors.white70),
              ),
              trailing: trailingWidget,
              onTap: () {
                if (realIndex != -1) {
                  _navigateToGrading(historyItem, realIndex, hasEssay, originalQuiz);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data riwayat tidak valid atau telah dihapus.")));
                }
              },
            ),
          );
        },
      ),
    );
  }
}


// =================================================================
// 4. Sub-View: Halaman Input Nilai Esai (EssayGradingPage)
// =================================================================

class EssayGradingPage extends StatefulWidget {
  final Map<String, dynamic> historyItem;
  final Quiz originalQuiz;
  final int historyIndex;
  final VoidCallback onGradeSubmitted;

  const EssayGradingPage({
    Key? key,
    required this.historyItem,
    required this.originalQuiz,
    required this.historyIndex,
    required this.onGradeSubmitted,
  }) : super(key: key);

  @override
  State<EssayGradingPage> createState() => _EssayGradingPageState();
}

class _EssayGradingPageState extends State<EssayGradingPage> {
  final Map<int, bool> _essayGrades = {};
  int _calculatedEssayScore = 0;

  String _getSafeUserAnswer(Map<dynamic, dynamic> answers, int index) {
    if (answers.containsKey(index)) return answers[index].toString();
    if (answers.containsKey(index.toString())) return answers[index.toString()].toString();
    return '-';
  }

  @override
  void initState() {
    super.initState();
    // Muat detail esai yang sudah ada dari history
    if (widget.historyItem.containsKey('essayGradingDetails')) {
      Map<String, dynamic> details = widget.historyItem['essayGradingDetails'] as Map<String, dynamic>;
      details.forEach((key, value) {
        _essayGrades[int.parse(key)] = value as bool;
      });
    }
    _recalculateScore();
  }

  void _recalculateScore() {
    int score = 0;
    _essayGrades.forEach((key, isCorrect) {
      if (isCorrect) score++;
    });
    setState(() {
      _calculatedEssayScore = score;
    });
  }

  void _submitGrade() async {
    Map<String, bool> detailsToSave = {};
    _essayGrades.forEach((k, v) => detailsToSave[k.toString()] = v);

    quizManager.updateEssayScore(widget.historyIndex, _calculatedEssayScore, detailsToSave);
    await saveAppState();

    widget.onGradeSubmitted();
    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nilai berhasil disimpan!')));
  }

  Widget _buildAutoGradedCard(Question question, int index, Map<dynamic, dynamic> userAnswers) {
    final String userAnswer = _getSafeUserAnswer(userAnswers, index);
    final bool isCorrect = userAnswer == question.correctAnswer;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isCorrect ? Colors.green : Colors.red, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(question.type == 'true_false' ? 'True/False' : 'Pilihan Ganda', style: const TextStyle(fontSize: 10)),
                  backgroundColor: Colors.black26,
                ),
                const Spacer(),
                Text(isCorrect ? "Otomatis: Benar (+1)" : "Otomatis: Salah (0)",
                    style: TextStyle(color: isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${index + 1}. ${question.questionText}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Divider(),
            const Text("Jawaban Siswa:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(userAnswer, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
            const SizedBox(height: 8),
            if (!isCorrect)
              Text("Kunci Jawaban: ${question.correctAnswer}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildEssayGradingCard(Question question, int index, Map<dynamic, dynamic> userEssayAnswers) {
    final String answer = _getSafeUserAnswer(userEssayAnswers, index);
    final bool? currentGrade = _essayGrades[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blueAccent, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Chip(label: Text('ESAI', style: TextStyle(fontSize: 10)), backgroundColor: Colors.blueAccent),
                const Spacer(),
                Text(currentGrade == true ? "+1 Poin (Benar)" : currentGrade == false ? "0 Poin (Salah)" : "Belum Dinilai",
                    style: TextStyle(color: currentGrade == true ? Colors.green : (currentGrade == false ? Colors.red : Colors.grey), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${index + 1}. ${question.questionText}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text("Jawaban Siswa:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(answer, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 15),
            const Text("Penilaian Guru:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { setState(() { _essayGrades[index] = true; _recalculateScore(); }); },
                    icon: const Icon(Icons.check),
                    label: const Text("BENAR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentGrade == true ? Colors.green : Colors.grey[800],
                      foregroundColor: currentGrade == true ? Colors.white : Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { setState(() { _essayGrades[index] = false; _recalculateScore(); }); },
                    icon: const Icon(Icons.close),
                    label: const Text("SALAH"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentGrade == false ? Colors.red : Colors.grey[800],
                      foregroundColor: currentGrade == false ? Colors.white : Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAnswers = Map.from(widget.historyItem['userAnswers'] ?? {});
    final userEssayAnswers = Map.from(widget.historyItem['userEssayAnswers'] ?? {});
    final pgScore = (widget.historyItem['score'] as int?) ?? 0;

    final int totalQuestions = (widget.historyItem['totalQuestions'] as int?) ?? 0;
    final int totalCorrect = pgScore + _calculatedEssayScore;
    final double finalGrade = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menilai: ${widget.historyItem['playerName']}'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              border: Border(bottom: BorderSide(color: Colors.grey.shade800)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [const Text("PG Benar", style: TextStyle(color: Colors.grey)), Text("$pgScore", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                const Icon(Icons.add, color: Colors.grey, size: 16),
                Column(children: [const Text("Esai Benar", style: TextStyle(color: Colors.blueAccent)), Text("$_calculatedEssayScore", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent))]),
                const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
                Column(children: [const Text("TOTAL AKHIR", style: TextStyle(color: Colors.green)), Text(finalGrade.toStringAsFixed(0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green))]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.originalQuiz.questions.length,
              itemBuilder: (context, index) {
                final question = widget.originalQuiz.questions[index];
                if (question.type == 'multiple_choice' || question.type == 'true_false') {
                  return _buildAutoGradedCard(question, index, userAnswers);
                } else {
                  return _buildEssayGradingCard(question, index, userEssayAnswers);
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              border: Border(top: BorderSide(color: Colors.grey.shade800)),
            ),
            child: ElevatedButton.icon(
              onPressed: _submitGrade,
              icon: const Icon(Icons.save),
              label: const Text('SIMPAN PENILAIAN AKHIR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}