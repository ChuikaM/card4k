import 'package:flutter/material.dart';
import 'package:card4k/ui/util/widget.dart';

class PairingPage extends StatelessWidget {
  late final VoidCallback _onGoBack;
  
  PairingPage({super.key, required VoidCallback onGoBack}) {
    _onGoBack = onGoBack;
  }

  Widget buildPairingContent(BuildContext context) {
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
    const double width = 160;

    final pairs = Row(
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
            const SizedBox(height: 24),
            buildButton("Japan", borderDecoration, width),
          ],
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildButton("Слово", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("Карточка", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("Захватывающий", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("Япония", borderDecoration, width),
            const SizedBox(height: 24),
            buildButton("Быть честным", borderDecoration, width),
          ],
        ),
        const Spacer()
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
            pairs,
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
    double availableHeight = MediaQuery.sizeOf(context).height;

    final pairing = SizedBox(
      height: availableHeight,
      child: Column(
        children: [
          buildProgressBar(context, _onGoBack),
          buildPairingContent(context)
        ],
      )
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: pairing
      ),
    );
  }
}