import 'dart:async';

import 'package:card4k/data/repositories/group_repository.dart';
import 'package:card4k/providers/sqlite_group_repository.dart';
import 'package:card4k/models/card.dart';
import 'package:card4k/models/group.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupState {
  List<Group> groups;
  Group current;

  GroupState(this.current, this.groups);
}

class GroupsNotifier extends AsyncNotifier<GroupState> {
  @override
  FutureOr<GroupState> build() async {
    var repository = ref.watch(sqliteGroupProvider);

    final currentGroupName = await repository.getLastUsedGroupName();
    if (currentGroupName == null) throw StateError('No current group selected');

    var currentGroup = await repository.fetchGroupByName(currentGroupName);
    if (currentGroup == null) throw StateError('No current group selected');

    var groups = await repository.fetchGroups();
    return GroupState(currentGroup, groups);
  }
  Future<({GroupRepository repo, String currentGroupName})> _getRepoAndCurrentGroup() async {
    final repository = ref.read(sqliteGroupProvider);
    final currentGroupName = await repository.getLastUsedGroupName();
    if (currentGroupName == null) {
      throw StateError('No current group selected');
    }
    return (repo: repository, currentGroupName: currentGroupName);
  }

  Future<void> addGroup(Group group) async {
    var repository = ref.read(sqliteGroupProvider);
    await repository.insertGroup(group);
    await repository.saveLastUsedGroupName(group.name);

    ref.invalidateSelf(); 
  }
  Future<void> editGroup(Group old, Group newest) async {
    var repository = ref.read(sqliteGroupProvider);
    var currentGroupName = await repository.getLastUsedGroupName();
    if(currentGroupName == null) return;

    await repository.updateGroup(old, newest);
    if (currentGroupName == old.name && old.name != newest.name) {
      await repository.saveLastUsedGroupName(newest.name);
    }
    ref.invalidateSelf(); 
  }
  Future<void> deleteGroup(Group group) async {
    var repository = ref.read(sqliteGroupProvider);
    var currentGroupName = await repository.getLastUsedGroupName();
    if(currentGroupName == null) return;

    await repository.removeGroup(group.name);
    if (currentGroupName == group.name) {
      await repository.saveLastUsedGroupName('');
    }
    ref.invalidateSelf(); 
  }
  Future<Group?> selectGroup(String name) async {
    var repository = ref.read(sqliteGroupProvider);
    await repository.saveLastUsedGroupName(name);

    return repository.fetchGroupByName(name);
  }

  Future<void> addCard(Card card) async {
    final context = await _getRepoAndCurrentGroup();
    await context.repo.insertCard(card, context.currentGroupName);
    ref.invalidateSelf(); 
  }
  Future<void> deleteCard(Card card) async {
    final context = await _getRepoAndCurrentGroup();
    await context.repo.removeCard(card, context.currentGroupName);
    ref.invalidateSelf();
  }
  Future<void> editCard(Card old, Card newest) async {
    final context = await _getRepoAndCurrentGroup();
    await context.repo.updateCard(old, newest, context.currentGroupName);
    ref.invalidateSelf();
  }
}

final groupsProvider = AsyncNotifierProvider<GroupsNotifier, GroupState>(
  GroupsNotifier.new,
);