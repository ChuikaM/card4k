import 'package:card4k/core/group_provider.dart' as gp;

class GroupsPresenter {
  gp.GroupProvider groupProvider;

  GroupsPresenter({
    required this.groupProvider
  });

  Future<List<gp.Group>> getGroups() async => await groupProvider.getGroups();
  
  Future<void> addGroup(gp.Group old, gp.Group newest) async => await groupProvider.addGroup(newest);
  
}