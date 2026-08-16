import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:card4k/core/settings_manager.dart';

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
}

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

class GroupProvider {
  final SettingsManager _settingsManager = SettingsManager();
  late Database _database;

  final _currentGroupController = StreamController<Group?>.broadcast();
  Stream<Group?> get currentGroupStream => _currentGroupController.stream;
  Group? _lastEmittedGroup;
  Group? get currentGroup => _lastEmittedGroup;

  final _allGroupsController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get allGroupsStream => _allGroupsController.stream;
  List<Group>? _allGroups;
  List<Group>? get groups => _allGroups;

  GroupProvider();
  
    Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, 'storage.db');

    final sqlAssets = await Future.wait([
      _settingsManager.loadString('assets/sql/group/create_table.sql'),
      _settingsManager.loadString('assets/sql/card/create_table.sql'),
      _settingsManager.loadString('assets/sql/group/001_add_group.sql'),
    ]);

    final createGroupsTableScheme = sqlAssets[0];
    final createCardsTableScheme = sqlAssets[1];

    _database = await openDatabase(path, version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(createGroupsTableScheme);
        await db.execute(createCardsTableScheme);
      }
    );  

    await Future.wait([
      refreshCurrentGroup(),
      refreshAllGroups(),
    ]);
  }

  Future<void> refreshCurrentGroup() async {
    Group? group = await getLastUsedGroup();
    _lastEmittedGroup = group;
    _currentGroupController.sink.add(group);
  }

  Future<void> refreshAllGroups() async {
    var groups = await getGroups();
    _allGroups = groups;
    _allGroupsController.sink.add(groups);
  }

  Future<void> addGroup(Group group) async {
    var addGroupScheme = await _settingsManager.loadString('assets/sql/group/001_add_group.sql');
    await _database.rawInsert(addGroupScheme, [group.name, group.color.toARGB32()]);
    await saveLastUsedGroup(group.name);
    await refreshCurrentGroup();
    await refreshAllGroups();
  }

    Future<void> deleteGroup(Group group) async {
    try {
      await _database.rawDelete('DELETE FROM cards WHERE group_name = ?', [group.name]);

      String sql = '';
      try {
        sql = await _settingsManager.loadString('assets/sql/group/005_remove_group.sql');
      } catch (e) {
        print("SQL file not found, using fallback query.");
      }

      if (sql.isNotEmpty) {
        await _database.rawDelete(sql, [group.name]);
      } else {
        await _database.rawDelete('DELETE FROM groups WHERE name = ?', [group.name]);
      }

      final lastUsedName = await getLastUsedGroupName();
      if (lastUsedName == group.name) {
        await _settingsManager.save("last_used_group", "");
      }
      
      await refreshAllGroups();
      await refreshCurrentGroup();

    } catch (e) {
      print("Failed to delete group: $e");
    }
  }

  Future<void> editGroup(Group old, Group newest) async {
    var editGroupScheme = await _settingsManager.loadString('assets/sql/group/002_edit_group.sql');
    await _database.rawUpdate(editGroupScheme, [newest.name, newest.color.toARGB32(), old.name]);

    if (_lastEmittedGroup?.name == old.name && old.name != newest.name) {
      await saveLastUsedGroup(newest.name);
    }
    if (old.name != newest.name) {
      await _database.rawUpdate('UPDATE cards SET group_name = ? WHERE group_name = ?', [newest.name, old.name]);
    }

    await refreshCurrentGroup();
    await refreshAllGroups();
  }

  Future<List<Group>> getGroups() async {
    var getGroupsScheme = await _settingsManager.loadString('assets/sql/group/004_get_groups.sql');
    List<Group> groups = (await _database.rawQuery(getGroupsScheme)).map((map) => Group.fromMap(map)).toList();
    return groups;
  }

  Future<Group?> getGroupByName(String groupName) async {
    var getGroupScheme = await _settingsManager.loadString('assets/sql/group/003_get_group.sql');
    List<Map> groupsCard = await _database.rawQuery(getGroupScheme, [groupName]);
    
    if (groupsCard.isEmpty) {
      return null; 
    }

    var lastUsedGroup = groupsCard.last;
    var getCardsScheme = await _settingsManager.loadString('assets/sql/card/004_get_cards.sql');
    List<Card> cards = (await _database.rawQuery(getCardsScheme, [groupName])).map((map) => Card.fromMap(map)).toList();
    String name = lastUsedGroup['name'];
    Color color = Color(lastUsedGroup['color'] as int);
    return Group(cards: cards, name: name, color: color);
  }

  Future<Group?> getLastUsedGroup() async {
    final savedName = await getLastUsedGroupName();

    if (savedName != null && savedName.isNotEmpty) {
      final group = await getGroupByName(savedName);
      if (group != null) return group;
    }
    
    final allGroups = await getGroups();
    if (allGroups.isNotEmpty) {
      final fallbackGroup = allGroups.first;
      await saveLastUsedGroup(fallbackGroup.name);
      
      return await getGroupByName(fallbackGroup.name); 
    }
  
    return null;
  }

  Future<void> addCardTo(Card card, String groupName) async {
    var addCardScheme = await _settingsManager.loadString('assets/sql/card/001_add_card.sql');
    await _database.rawInsert(addCardScheme, [card.title, card.description, groupName]);
    await refreshCurrentGroup();
  }

  Future<void> deleteCardFrom(Card card, String groupName) async {
    var removeCardScheme = await _settingsManager.loadString('assets/sql/card/002_remove_card.sql');
    await _database.rawDelete(removeCardScheme, [card.title, card.description, groupName]);
    await refreshCurrentGroup();
  }

  Future<void> editCardAt(Card old, Card newest, String groupName) async {
    var editCardSheme = await _settingsManager.loadString('assets/sql/card/003_edit_card.sql');
    await _database.rawUpdate(editCardSheme, [newest.title, newest.description, old.title]);
    await refreshCurrentGroup();
  }

  void deleteGroupTable() async {
    var deleteGroupTableScheme = await _settingsManager.loadString('assets/sql/group/delete_table.sql');
    await _database.rawDelete(deleteGroupTableScheme);
  }

  void deleteCardTable() async {
    var deleteCardTableScheme = await _settingsManager.loadString('assets/sql/card/delete_table.sql');
    await _database.rawDelete(deleteCardTableScheme);
  }

  void deleteDatabase() async {
    var deleteDatabaseScheme = await _settingsManager.loadString('assets/sql/drop_database.sql');
    await _database.rawDelete(deleteDatabaseScheme);
  }

  Future<bool> saveLastUsedGroup(String groupName) => _settingsManager.save("last_used_group", groupName);
  Future<String?> getLastUsedGroupName() => _settingsManager.get("last_used_group");

  void dispose() {
    _currentGroupController.close();
    _allGroupsController.close();
  }
}