import 'package:card4k/models/card.dart' as c;
import 'dart:ui';

class Group {
  final List<c.Card> cards;
  final String name;
  final Color color;

  Group({required this.cards, required this.name, required this.color});
  Group.fromMap(Map<String, dynamic> map)
      : cards = const <c.Card>[], 
        name = map['name'] ?? '',
        color = map['color'] != null ? Color(map['color'] as int) : Color(0xFF4CAF50);

  int getTotalCards() => cards.length;

  @override
String toString() => 'Group{name: $name, cards_count: ${getTotalCards()}, color: $color}';
  
}