import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key}); 

  Widget buildReulstContent(BuildContext context) {
    final pieChart = SizedBox(
      width: 200,
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 0,
          sections: [
            PieChartSectionData(
              color: const Color(0xFFFF0000),
              value: 20,
              radius: 120,
              showTitle: false,
            ),
            PieChartSectionData(
              color: const Color(0xFF30BE91),
              value: 80,
              radius: 120,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
    final borderDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0xFF2E6252),
          offset: Offset(0, 6),
          blurRadius: 6.0,
          blurStyle: BlurStyle.inner
        )
      ],
      borderRadius: BorderRadius.circular(15.0),
      color: Color(0xFF30BE91),
    );
    final finishButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Center(child: Text("finish", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),)
          )    
      ),
    );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 50, vertical: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Results", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                SizedBox(height: 96,),
                pieChart,
                SizedBox(height: 48,),
                Text("110 of 120\nwere correct!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Spacer(),
                finishButton
              ],
            )
          )   
        ],
      )   
    );
  }

  @override
  Widget build(BuildContext context)
  {
    const Color backgroundColor = Color(0xFF303030);
    final result = buildReulstContent(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: result
      ),
    );
  }
}