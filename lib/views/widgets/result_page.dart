// lib/views/widgets/result_page.dart

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int timeSpent;

  const ResultPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
  }) : super(key: key);

  double get accuracy => (totalQuestions > 0) ? (score / totalQuestions) * 100 : 0.0;
  int get wrongAnswers => totalQuestions - score;

  String getEvaluation() {
    if (accuracy >= 90) {
      return "Luar biasa! Kamu benar-benar menguasai materi 🎓🔥";
    } else if (accuracy >= 70) {
      return "Bagus! Masih ada sedikit ruang untuk berkembang 💪";
    } else if (accuracy >= 50) {
      return "Cukup, tapi kamu bisa belajar lebih giat lagi! 📚";
    } else {
      return "Jangan menyerah! Ini kesempatan buat belajar lebih dalam 💡";
    }
  }

  String getTimeString() {
    int minutes = timeSpent ~/ 60;
    int seconds = timeSpent % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> dataMap = {
      "Benar": score.toDouble(),
      "Salah": wrongAnswers.toDouble(),
    };

    final colorList = <Color>[
      Colors.greenAccent,
      Colors.redAccent,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik & Evaluasi"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Hasil Kuis Kamu 🎯",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Grafik Donat
              PieChart(
                dataMap: dataMap,
                chartRadius: 160,
                colorList: colorList,
                chartType: ChartType.ring,
                ringStrokeWidth: 24,
                centerText: "${accuracy.toStringAsFixed(1)}%",
                chartValuesOptions: const ChartValuesOptions(
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                ),
              ),
              const SizedBox(height: 30),

              // Detail Statistik
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Total Soal: $totalQuestions"),
                      Text("Jawaban Benar: $score"),
                      Text("Jawaban Salah: $wrongAnswers"),
                      Text("Akurasi: ${accuracy.toStringAsFixed(1)}%"),
                      Text("Waktu yang dihabiskan: ${getTimeString()}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Evaluasi
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  getEvaluation(),
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              // Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, "retry");
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Coba Lagi"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, "home");
                    },
                    icon: const Icon(Icons.home),
                    label: const Text("Menu Utama"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}