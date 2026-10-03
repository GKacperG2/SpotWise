import 'package:shared_preferences/shared_preferences.dart';

import '../domain/snapshot_ports.dart';

class PreferencesSnapshotStore implements SnapshotStore {
  PreferencesSnapshotStore(this._preferences);

  final SharedPreferencesAsync _preferences;
  static const _key = 'last_snapshot_json';

  @override
  Future<String?> load() => _preferences.getString(_key);

  @override
  Future<void> save(String raw) => _preferences.setString(_key, raw);
}
