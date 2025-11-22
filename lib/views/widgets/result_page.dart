import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int totalEssay;
  final int timeSpent;

  const ResultPage({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.totalEssay,
    required this.timeSpent,
  }) : super(key: key);

  String getTimeString() {
    int minutes = timeSpent ~/ 60;
    int seconds = timeSpent % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA STATISTIK ---
    final int totalAutoQuestions = totalQuestions - totalEssay;
    final int wrongAnswers = totalAutoQuestions - score;

    // Akurasi sementara (Hanya PG)
    final double accuracy = totalAutoQuestions > 0
        ? (score / totalAutoQuestions) * 100
        : 0;

    // Data Grafik
    Map<String, double> dataMap = {
      "Benar": score.toDouble(),
      "Salah": wrongAnswers.toDouble(),
    };

    if (totalEssay > 0) {
      dataMap["Menunggu (Esai)"] = totalEssay.toDouble();
    }

    // Warna Grafik
    List<Color> colorList = [
      Colors.green,
      Colors.red,
    ];
    if (totalEssay > 0) {
      colorList.add(Colors.orange);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Sementara"),
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
                "Kuis Selesai! 🚀",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (totalEssay > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text("Nilai Esai ($totalEssay soal) menunggu guru.",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // --- PIE CHART ---
              SizedBox(
                height: 220,
                child: PieChart(
                  dataMap: dataMap,
                  chartRadius: 160,
                  colorList: colorList,
                  chartType: ChartType.ring,
                  ringStrokeWidth: 24,
                  centerText: totalEssay > 0 ? "Pending" : "${accuracy.toStringAsFixed(0)}%",
                  legendOptions: const LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.bottom,
                    showLegends: true,
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValuesInPercentage: false,
                    showChartValues: true,
                    decimalPlaces: 0,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- DETAIL KARTU ---
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _rowDetail("Total Soal", "$totalQuestions"),
                      const Divider(),
                      _rowDetail("Benar (PG/TF)", "$score", color: Colors.green),
                      _rowDetail("Salah (PG/TF)", "$wrongAnswers", color: Colors.red),
                      if (totalEssay > 0)
                        _rowDetail("Esai (Menunggu)", "$totalEssay", color: Colors.orange),
                      const Divider(),
                      _rowDetail("Waktu", getTimeString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, "home"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("KEMBALI KE MENU UTAMA"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowDetail(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}