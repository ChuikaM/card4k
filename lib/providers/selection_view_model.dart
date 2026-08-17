import 'package:flutter/foundation.dart';

import 'package:card4k/models/card.dart';
import 'package:card4k/models/group.dart';
import 'package:card4k/data/repositories/group_repository.dart';

class SelectionViewModel extends ChangeNotifier {
  final GroupRepository _repository;
  SelectionViewModel(this._repository);

}