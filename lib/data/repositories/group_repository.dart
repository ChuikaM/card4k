import 'package:card4k/models/card.dart';
import 'package:card4k/models/group.dart';

abstract class GroupRepository {
  Future<void> init();
  Future<void> close();

  Future<void> insertGroup(Group group);
  Future<void> updateGroup(Group old, Group newest);
  Future<void> removeGroup(String groupName);
  Future<List<Group>> fetchGroups(); 
  Future<Group?> fetchGroupByName(String name);

  Future<void> insertCard(Card card, String groupName);
  Future<void> updateCard(Card old, Card newest, String groupName);
  Future<void> removeCard(Card card, String groupName);

  Future<void> saveLastUsedGroupName(String name);
  Future<String?> getLastUsedGroupName();

}