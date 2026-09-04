import 'package:card4k/data/exceptions/database_operation_exception.dart';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'package:card4k/models/card.dart' as c;
import 'package:card4k/models/group.dart';
import 'settings_repository.dart';
import 'base/group_repository.dart';

import 'package:card4k/constants/sql/card_queries.dart';
import 'package:card4k/constants/sql/group_queries.dart';

import 'dart:developer' as developer;

class SqliteGroupRepository implements GroupRepository {
  final SettingsRepository _settings;
  late Database _database;

  SqliteGroupRepository(this._settings);

  @override
  Future<void> init() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = p.join(databasesPath, 'storage.db');

      _database = await _openOrCreareDatabase(path);
    } catch (e) {
      developer.log('Error occurred when initialize Database: $e');
      throw DatabaseOperationException(entity: Entity.database, action: DatabaseAction.initialize, originalError: e);
    }
  }
  Future<Database> _openOrCreareDatabase(String path) async {
    Database database;
    try {
      database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(GroupQueries.createTable);
          await db.execute(CardQueries.createTable);
        }
      );
    } catch(e) {
      throw Exception('Failed to open the following path: $path database: $e');
    }
    return database;
  } 

  @override
  Future<void> insertGroup(Group group) async {
    try {
      await _database.rawInsert(
        GroupQueries.addGroup,
        [group.name, group.color.toARGB32()],
      );
    } catch(e) {
      developer.log('Failed to insert $group to Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.create, originalError: e);
    } 
  }

  @override
  Future<void> updateGroup(Group old, Group newest) async {
    try {
      await updateGroupInfo(old, newest);
      await updateGroupCardsInfo(old, newest);
    } catch(e) {
      developer.log('Failed to update $old group to $newest in Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.update, originalError: e);
    }
  }
  Future<void> updateGroupInfo(Group old, Group newest) async {
    try {
      await _database.rawUpdate(
        GroupQueries.editGroup,
        [newest.name, newest.color.toARGB32(), old.name],
      );
    } catch (e, st) {
      Error.throwWithStackTrace(Exception('Failed to update group info from $old to $newest: $e'), st);
    }
  }
  Future<void> updateGroupCardsInfo(Group old, Group newest) async {
    if (old.name != newest.name) {
      try {
        await _database.rawUpdate(
          CardQueries.updateCardGroupToNew,
          [newest.name, old.name],
        );
      } catch (e, st) {
        Error.throwWithStackTrace(Exception('Failed to update group cards info from $old to $newest: $e'), st);
      }
    }
  }


  @override
  Future<void> removeGroup(String groupName) async {
    try {
      await _database.rawDelete(CardQueries.removeCardsFromGroup, [groupName]);
      await _database.rawDelete(GroupQueries.removeGroup, [groupName]);
    } catch(e) {
      developer.log('Failed to remove group $groupName in Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.delete, originalError: e);
    }
  }

  @override
  Future<List<Group>> fetchGroups() async {
    List<Map<String, Object?>> rows;
    try {
      rows = await _database.rawQuery(GroupQueries.getGroups);
    } catch(e) {
      developer.log('Failed to fetch groups from Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.read, originalError: e);
    }
    
    final groups = <Group>[];
    try {
      for (final row in rows) {
        final name = row['name'] as String;
        final color = row['color'] != null ? Color(row['color'] as int) : Color(0xFF4CAF50);
        
        final cardRows = await _database.rawQuery(CardQueries.getCards, [name]);
        final cards = cardRows.map((map) => c.Card.fromMap(map)).toList();

        groups.add(Group(
          cards: cards,
          name: name,
          color: color,
        ));
      }
    } catch(e) {
      developer.log('Failed to fetch cards from group Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.read, originalError: e);
    }

    return groups;
  }

  @override
  Future<Group?> fetchGroupByName(String name) async {
    List<Map<String, Object?>> groupRows;
    try {
      groupRows = await _database.rawQuery(GroupQueries.getGroup, [name]);
    } catch (e) {
      developer.log('Failed to fetch group meta by $name from Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.read, originalError: e);
    }
    if (groupRows.isEmpty) return null;

    List<Map<String, Object?>> cardRows = [];
    try {
      cardRows = await _database.rawQuery(CardQueries.getCards, [name]);
    } catch(e) {
      developer.log('Failed to fetch group by $name from Database: $e');
      throw DatabaseOperationException(entity: Entity.group, action: DatabaseAction.read, originalError: e);
    }

    final cards = cardRows.map((map) => c.Card.fromMap(map)).toList();
    final row = groupRows.last;
    return Group(
      cards: cards,
      name: row['name'] as String,
      color: Color(row['color'] as int),
    );
  }

  @override
  Future<void> insertCard(c.Card card, String groupName) async {
    try {
      await _database.rawInsert(
        CardQueries.addCard,
        [card.title, card.description, groupName],
      );
    } catch(e) {
      developer.log('Failed to insert card $card to $groupName: $e');
      throw DatabaseOperationException(entity: Entity.card, action: DatabaseAction.create, originalError: e);
    }
  }

  @override
  Future<void> updateCard(c.Card old, c.Card newest, String groupName) async {
    try {
      await _database.rawUpdate(
        CardQueries.editCard,
        [newest.title, newest.description, old.title],
      );
    } catch(e) {
      developer.log('Failed to update card info from $old to $newest at $groupName: $e');
      throw DatabaseOperationException(entity: Entity.card, action: DatabaseAction.update, originalError: e);
    }
  }

  @override
  Future<void> removeCard(c.Card card, String groupName) async {
    try {
      await _database.rawDelete(
        CardQueries.removeCard,
        [card.title, card.description, groupName],
      );
    } catch(e) {
      developer.log('Failed to remove card $card from $groupName: $e');
      throw DatabaseOperationException(entity: Entity.card, action: DatabaseAction.delete, originalError: e);
    }
  }

  @override
  Future<void> saveLastUsedGroupName(String name) => _settings.save('last_used_group', name);

  @override
  Future<String?> getLastUsedGroupName() => _settings.get('last_used_group');


  @override
  Future<void> close() async => await _database.close();
  
}