import 'dart:async';

import 'package:card4k/providers/sqlite_group_provider.dart';
import 'package:card4k/models/card.dart';
import 'package:card4k/models/group.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupState {
  Group? current;
  List<Group> groups;

  GroupState(this.current, this.groups);

  GroupState copyWith({Group? current, List<Group>? groups}) {
    return GroupState(
      current ?? this.current,
      groups ?? this.groups,
    );
  }
}

class GroupsNotifier extends AsyncNotifier<GroupState> {
  @override
  FutureOr<GroupState> build() async {
    final repository = ref.watch(sqliteGroupProvider);

    final allGroups = await repository.fetchGroups();
    if (allGroups.isEmpty) {
      return GroupState(null, []);
    }

    final savedName = await repository.getLastUsedGroupName();
    final current = (savedName != null && savedName.isNotEmpty)
        ? allGroups.firstWhere((g) => g.name == savedName, orElse: () => allGroups.first)
        : allGroups.first;

    if (savedName == null || savedName.isEmpty || current.name != savedName) {
      await repository.saveLastUsedGroupName(current.name);
    }
    return GroupState(current, allGroups);
  }

  Future<void> addGroup(Group group) async {
    var repository = ref.read(sqliteGroupProvider);
    await repository.insertGroup(group);
    await repository.saveLastUsedGroupName(group.name);

    ref.invalidateSelf(); 
  }
  Future<void> editGroup(Group newest) async {
    var repository = ref.read(sqliteGroupProvider);

    var currentGroupName = await repository.getLastUsedGroupName();
    if(currentGroupName == null) return;
    var currentGroup = await repository.fetchGroupByName(currentGroupName);
    if(currentGroup == null) return;

    await repository.updateGroup(currentGroup, newest);
    await repository.saveLastUsedGroupName(newest.name);

    var groups = await repository.fetchGroups();
    state = AsyncData(GroupState(Group(cards: currentGroup.cards, name: newest.name, color: newest.color), groups)); 
  }
  Future<void> deleteGroup(Group group) async {
    var repository = ref.read(sqliteGroupProvider);
    var currentGroupName = await repository.getLastUsedGroupName();
    if(currentGroupName == null) return;

    await repository.removeGroup(group.name);

    var groups = await repository.fetchGroups();
    if(groups.isEmpty) {
      await repository.saveLastUsedGroupName('');
      state = AsyncData(GroupState(null, [])); 
      return;
    }
    final nameToSelect = (currentGroupName != group.name && groups.any((g) => g.name == currentGroupName))
        ? currentGroupName
        : groups.first.name;
    final currentGroup = groups.firstWhere((g) => g.name == nameToSelect, orElse: () => groups.first);
    await repository.saveLastUsedGroupName(nameToSelect);
    state = AsyncData(GroupState(currentGroup, groups)); 
  }
  Future<void> selectGroup(String name) async {
    final repository = ref.read(sqliteGroupProvider);
    final currentGroups = await repository.fetchGroups();

    final newCurrentGroup = currentGroups.firstWhere(
      (g) => g.name == name,
      orElse: () => throw StateError('Group "$name" not found'),
    );
    await repository.saveLastUsedGroupName(name);

    state = AsyncData(state.value!.copyWith(current: newCurrentGroup));
  }

  Future<bool> addCard(Card card) async {
    final currentGroupName = state.value?.current?.name;
    if (currentGroupName == null) return false;

    final repository = ref.read(sqliteGroupProvider);
    await repository.insertCard(card, currentGroupName);
    
    Group? group = await repository.fetchGroupByName(currentGroupName);
    if(group == null) return false;

    state = AsyncData(state.value!.copyWith(current: group));
    
    return true;
  }
  Future<bool> editCard(Card old, Card newest) async {
    final currentGroupName = state.value?.current?.name;
    if (currentGroupName == null) return false;

    final repository = ref.read(sqliteGroupProvider);
    await repository.updateCard(old, newest, currentGroupName);
    
    Group? group = await repository.fetchGroupByName(currentGroupName);
    if(group == null) return false;

    state = AsyncData(state.value!.copyWith(current: group));

    return true;
  }
  Future<void> deleteCard(Card card) async {
    final currentGroupName = state.value?.current?.name;
    if (currentGroupName == null) return;

    final repository = ref.read(sqliteGroupProvider);
    await repository.removeCard(card, currentGroupName);
    
    Group? group = await repository.fetchGroupByName(currentGroupName);
    if(group == null) return;

    state = AsyncData(state.value!.copyWith(current: group));
  }
}

final groupsProvider = AsyncNotifierProvider<GroupsNotifier, GroupState>(
  GroupsNotifier.new,
);