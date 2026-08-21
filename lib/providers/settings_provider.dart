import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card4k/data/repositories/settings_repository.dart';

var settingsProvider = Provider<SettingsRepository>(((ref) => SettingsRepository()));
