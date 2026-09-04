
class GroupQueries {
  static const String createTable = '''
    CREATE TABLE IF NOT EXISTS groups (
        group_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
    );
  ''';
  static const String dropTable = '''
    DROP TABLE groups;
  ''';

  static const String addGroup = '''
    INSERT INTO groups (name, color) VALUES
    (?, ?)
  ''';
  static const String editGroup = '''
    UPDATE groups
    SET name = ?, color = ?
    WHERE name = ?;
  ''';
  static const String getGroup = '''
    SELECT * FROM groups
    WHERE name = ?;
  ''';
  static const String getGroups = '''
    SELECT name, color FROM groups;
  ''';
  static const String removeGroup = '''
    DELETE FROM groups
    WHERE  name = ?;
  ''';

}