import 'package:card4k/core/group_provider.dart' as gp;

class HomePresenter {
  gp.GroupProvider groupProvider;

  HomePresenter({
    required this.groupProvider
  });

  Future<void> addGroup(gp.Group old, gp.Group newest) async => await groupProvider.addGroup(newest);
  Future<void> editGroup(gp.Group old, gp.Group newest) async => await groupProvider.editGroup(old, newest);
  Future<void> deleteGroup(gp.Group group) async => await groupProvider.deleteGroup(group);
  
}