import 'package:card4k/data/models/group.dart';
import 'package:card4k/data/repositories/group_repository.dart';

class AddGroupUseCase {
  final GroupRepository _repository;
  
  AddGroupUseCase(this._repository);
  
  Future<void> execute(Group group) async {
    if (group.name.trim().isEmpty) {
      //throw InvalidGroupNameException();
    }
    await _repository.insertGroup(group);
  }
}