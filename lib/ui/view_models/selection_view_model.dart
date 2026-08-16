import 'package:flutter/foundation.dart';

import 'package:card4k/data/models/card.dart';
import 'package:card4k/data/models/group.dart';
import 'package:card4k/data/repositories/group_repository.dart';

class SelectionViewModel extends ChangeNotifier {
  final GroupRepository _repository;
  SelectionViewModel(this._repository);

}