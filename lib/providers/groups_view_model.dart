import 'package:flutter/foundation.dart';

import 'package:card4k/models/card.dart';
import 'package:card4k/models/group.dart';
import 'package:card4k/data/repositories/group_repository.dart';

class GroupsViewModel extends ChangeNotifier {
  final GroupRepository _repository;
  GroupsViewModel(this._repository);

  Group? _currentGroup;
  Group? get currentGroup => _currentGroup;

  List<Group> _groups = [];
  List<Group> get groups => _groups;
  bool get hasGroups => _groups.isNotEmpty;

  Future<void> init() async {
    await _repository.init();
    await refresh();
  }

  Future<void> refresh() async {
    _groups = await _repository.fetchGroups();
    _currentGroup = await _loadLastUsedGroup();
    notifyListeners();
  }

  Future<Group?> _loadLastUsedGroup() async {
    final saved = await _repository.getLastUsedGroupName();
    if (saved != null && saved.isNotEmpty) {
      final g = await _repository.fetchGroupByName(saved);
      if (g != null) return g;
    }
    if (_groups.isNotEmpty) {
      await _repository.saveLastUsedGroupName(_groups.first.name);
      return _repository.fetchGroupByName(_groups.first.name);
    }
    return null;
  }

  Future<void> addGroup(Group group) async {
    await _repository.insertGroup(group);
    await _repository.saveLastUsedGroupName(group.name);
    await refresh();
  }

  Future<void> editGroup(Group old, Group newest) async {
    await _repository.updateGroup(old, newest);
    if (_currentGroup?.name == old.name && old.name != newest.name) {
      await _repository.saveLastUsedGroupName(newest.name);
    }
    await refresh();
  }

  Future<void> deleteGroup(Group group) async {
    await _repository.removeGroup(group.name);
    if (_currentGroup?.name == group.name) {
      await _repository.saveLastUsedGroupName('');
    }
    await refresh();
  }

  Future<void> selectGroup(String name) async {
    await _repository.saveLastUsedGroupName(name);
    await refresh();
  }

  Future<void> addCard(Card card) async {
    if (_currentGroup == null) return;
    await _repository.insertCard(card, _currentGroup!.name);
    await refresh();
  }
  Future<void> deleteCard(Card card) async {
    if (_currentGroup == null) return;
    await _repository.removeCard(card, _currentGroup!.name);
    await refresh();
  }
  Future<void> editCard(Card old, Card newest) async {
    if (_currentGroup == null) return;
    await _repository.updateCard(old, newest, _currentGroup!.name);
    await refresh();
  }

  @override
  void dispose() {
    _repository.close();
    super.dispose();
  }
}