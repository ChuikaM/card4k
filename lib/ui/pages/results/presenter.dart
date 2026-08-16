import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatelessWidget {
  final int correctPairs;
  final int mistakes;
  final VoidCallback onFinish;

  const ResultPage({
    super.key,
    required this.correctPairs,
    required this.mistakes,
    required this.onFinish,
  });

  Widget buildResultContent(BuildContext context) {
    final sections = <PieChartSectionData>[];
    
    if (mistakes > 0) {
      sections.add(
        PieChartSectionData(
          color: const Color(0xFFFF0000),
          value: mistakes.toDouble(),
          radius: 120,
          showTitle: false,
        ),
      );
    }
    
    sections.add(
      PieChartSectionData(
        color: const Color(0xFF30BE91),
        value: correctPairs > 0 ? correctPairs.toDouble() : 1.0, 
        radius: 120,
        showTitle: false,
      ),
    );

    final pieChart = SizedBox(
      width: 200,
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 0,
          sections: sections,
        ),
      ),
    );

    final borderDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2E6252),
          offset: const Offset(0, 6),
          blurRadius: 6.0,
          blurStyle: BlurStyle.inner,
        )
      ],
      borderRadius: BorderRadius.circular(15.0),
      color: const Color(0xFF30BE91),
    );

    final finishButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: onFinish,
        borderRadius: BorderRadius.circular(15),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              "finish",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Results",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 96),
                pieChart,
                const SizedBox(height: 48),
                Text(
                  "$correctPairs pairs matched!\n$mistakes mistakes.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                finishButton,
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF303030);
    final result = buildResultContent(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: result),
    );
  }
}