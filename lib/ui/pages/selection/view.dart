import 'package:flutter/material.dart';
import 'package:card4k/ui/util/widget.dart';

class SelectionPage extends StatelessWidget {
  late final VoidCallback _onGoBack;

  SelectionPage({super.key, required VoidCallback onGoBack}) {
    _onGoBack = onGoBack;
  }

  Widget buildSelectionContent(BuildContext context) {
    final borderDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0xFF7F7F7F),
          offset: Offset(0, 6),
          blurRadius: 6.0,
          blurStyle: BlurStyle.inner
        )
      ],
      borderRadius: BorderRadius.circular(15.0),
      color: Color(0xFFD9D9D9),
    );

    const double width = 320;
    final choices = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildButton("A card", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("A word", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("To be honest", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("Captivating", borderDecoration, width),
          ],
        ),
        const Spacer(),
      ],
    );

    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tap the matching pairs", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const Spacer(),
            Center(child: Text("A card", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),),       
            const Spacer(),
            choices,
            const Spacer(),
          ],
        ),   
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    const Color backgroundColor = Color(0xFF303030);

    final selection = Column(
      children: [
        buildProgressBar(context, _onGoBack),
        buildSelectionContent(context)
      ],
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: selection
      ),
    );
  }
}