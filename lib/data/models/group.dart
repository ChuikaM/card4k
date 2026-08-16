import 'package:card4k/data/models/card.dart';
import 'dart:ui';
import 'package:flutter/src/material/colors.dart';

class Group {
  final List<Card> cards;
  final String name;
  final Color color;

  Group({required this.cards, required this.name, required this.color});
  Group.fromMap(Map<String, dynamic> map)
      : cards = map['cards'] ?? [], 
        name = map['name'] ?? '',
        color = map['color'] != null ? Color(map['color'] as int) : Colors.green;

  int getTotalCards() => cards.length;
}