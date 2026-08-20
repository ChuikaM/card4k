import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../../models/card.dart' as c;
import '../../models/group.dart';
import 'settings_repository.dart';
import 'group_repository.dart';

class SqliteGroupRepository implements GroupRepository {
  final SettingsRepository _settings;
  late Database _database;
  final Map<String, String> _sql = {};

  SqliteGroupRepository(this._settings);

  static const _sqlFiles = [
    'group/create_table.sql',
    'card/create_table.sql',
    'group/001_add_group.sql',
    'group/002_edit_group.sql',
    'group/003_get_group.sql',
    'group/004_get_groups.sql',
    'group/005_remove_group.sql',
    'card/001_add_card.sql',
    'card/002_remove_card.sql',
    'card/003_edit_card.sql',
    'card/004_get_cards.sql',
  ];

  @override
  Future<void> init() async {
    await Future.wait(_sqlFiles.map((file) async {
      _sql[file] = await _settings.loadString('assets/sql/$file');
    }));

    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'storage.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_sql['group/create_table.sql']!);
        await db.execute(_sql['card/create_table.sql']!);
      }
    );
  }

  @override
  Future<void> close() async => await _database.close();

  @override
  Future<void> insertGroup(Group group) async {
    await _database.rawInsert(
      _sql['group/001_add_group.sql']!,
      [group.name, group.color.toARGB32()],
    );
  }
  @override
  Future<void> updateGroup(Group old, Group newest) async {
    await _database.rawUpdate(
      _sql['group/002_edit_group.sql']!,
      [newest.name, newest.color.toARGB32(), old.name],
    );
    if (old.name != newest.name) {
      await _database.rawUpdate(
        'UPDATE cards SET group_name = ? WHERE group_name = ?',
        [newest.name, old.name],
      );
    }
  }
  @override
  Future<void> removeGroup(String groupName) async {
    await _database.rawDelete('DELETE FROM cards WHERE group_name = ?', [groupName]);
    await _database.rawDelete(_sql['group/005_remove_group.sql']!, [groupName]);
  }
    @override
  Future<List<Group>> fetchGroups() async {
    final rows = await _database.rawQuery(_sql['group/004_get_groups.sql']!);
    final groups = <Group>[];

    for (final row in rows) {
      final name = row['name'] as String;
      final color = row['color'] != null ? Color(row['color'] as int) : Color(0xFF4CAF50);
      
      final cardRows = await _database.rawQuery(_sql['card/004_get_cards.sql']!, [name]);
      final cards = cardRows.map((map) => c.Card.fromMap(map)).toList();

      groups.add(Group(
        cards: cards,
        name: name,
        color: color,
      ));
    }

    return groups;
  }
  @override
  Future<Group?> fetchGroupByName(String name) async {
    final groupRows = await _database.rawQuery(_sql['group/003_get_group.sql']!, [name]);
    if (groupRows.isEmpty) return null;

    final row = groupRows.last;
    final cardRows = await _database.rawQuery(_sql['card/004_get_cards.sql']!, [name]);
    final cards = cardRows.map((map) => c.Card.fromMap(map)).toList();

    return Group(
      cards: cards,
      name: row['name'] as String,
      color: Color(row['color'] as int),
    );
  }

  @override
  Future<void> insertCard(c.Card card, String groupName) async {
    await _database.rawInsert(
      _sql['card/001_add_card.sql']!,
      [card.title, card.description, groupName],
    );
  }
  @override
  Future<void> updateCard(c.Card old, c.Card newest, String groupName) async {
    await _database.rawUpdate(
      _sql['card/003_edit_card.sql']!,
      [newest.title, newest.description, old.title],
    );
  }
  @override
  Future<void> removeCard(c.Card card, String groupName) async {
    await _database.rawDelete(
      _sql['card/002_remove_card.sql']!,
      [card.title, card.description, groupName],
    );
  }

  @override
  Future<void> saveLastUsedGroupName(String name) =>
      _settings.save('last_used_group', name);

  @override
  Future<String?> getLastUsedGroupName() => _settings.get('last_used_group');
}