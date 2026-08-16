import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget buildProgressBar(
  BuildContext context,
  VoidCallback onGoBack, {
  int current = 0,
  int total = 0,
}) {
  final double progress = total <= 0
      ? 0.0
      : (current / total).clamp(0.0, 1.0).toDouble();

  return SizedBox(
    height: 64,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const SizedBox(width: 10),
        IconButton(
          onPressed: () {
            onGoBack.call();
          },
          icon: SvgPicture.asset("assets/icon/close.svg"),
          iconSize: 48,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2EC4B6)),
              minHeight: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "${total != 0 ? current : 0}/$total",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(width: 10),
      ],
    ),
  );
}

Widget buildButton(String text, Decoration borderDecoration, double width) {
  return Ink(
    decoration: borderDecoration,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: width,
        height: 64,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}

Future buildAnimatedPage(BuildContext context, Widget childWidget){
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Modal G',
    barrierColor: const Color(0xA0212121),
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
      child: Align(
        alignment: Alignment.topRight, 
        child: childWidget,
      ),
    ),
  );
}