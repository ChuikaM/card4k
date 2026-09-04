
class CardQueries {
  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS cards (
        card_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        group_name TEXT NOT NULL
    );
  ''';
  static const String dropTable = '''
    DROP TABLE cards;
  ''';

  static const String addCard = '''
    INSERT INTO cards (title, description, group_name) VALUES
    (?, ?, ?)
  ''';
  static const String removeCard = '''
    DELETE FROM cards
    WHERE  title = ? AND description = ? AND group_name = ?
  ''';
  static const String removeCardsFromGroup = '''
    DELETE FROM cards 
    WHERE group_name = ?
  ''';
  static const String editCard = '''
    UPDATE cards
    SET title = ?, description = ?
    WHERE title = ?;
  ''';
  static const String getCards = '''
    SELECT * FROM cards WHERE group_name = ?;
  ''';
  static const String updateCardGroupToNew = '''
    UPDATE cards 
    SET group_name = ? 
    WHERE group_name = ?
  ''';

}