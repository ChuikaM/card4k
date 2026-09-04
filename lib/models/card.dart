class Card {
  final String title;
  final String description;

  Card({required this.title, required this.description});
  Card.fromMap(Map<String, dynamic> map)
      : title = map['title'] ?? '',
        description = map['description'] ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card && runtimeType == other.runtimeType && title == other.title && description == other.description;

  @override
  int get hashCode => title.hashCode ^ description.hashCode;

  @override
  String toString() => 'Card{name: $title, description: $description}';
  
}