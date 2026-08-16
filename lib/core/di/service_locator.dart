import 'package:card4k/ui/view_models/groups_view_model.dart';
import 'package:card4k/ui/view_models/selection_view_model.dart';

import 'package:card4k/data/repositories/group_repository.dart';
import 'package:card4k/data/repositories/sqlite_group_repository.dart';
import 'package:card4k/data/settings_manager.dart';

class ServiceLocator {
  static final _instance = ServiceLocator._();
  factory ServiceLocator() => _instance;
  ServiceLocator._();
  
  late final GroupRepository groupRepository;

  late final GroupsViewModel groupsViewModel;
  late final SelectionViewModel selectionViewModel;
  
  void init() {
    groupRepository = SqliteGroupRepository(SettingsManager());

    groupsViewModel = GroupsViewModel(groupRepository);
    selectionViewModel = SelectionViewModel(groupRepository);

  }
}