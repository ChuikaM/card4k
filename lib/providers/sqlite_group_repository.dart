import 'package:card4k/data/repositories/sqlite_group_repository.dart';
import 'package:card4k/providers/settings_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

var sqliteGroupProvider = Provider<SqliteGroupRepository>((ref){
  final settings = ref.watch(settingsProvider);
  return SqliteGroupRepository(settings);
});
