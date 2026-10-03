import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/demo_scenarios.dart';
import '../../data/preferences_snapshot_store.dart';
import '../../data/snapshot_json_codec.dart';
import '../../domain/choose_option.dart';
import '../../domain/snapshot_ports.dart';

final snapshotCodecProvider = Provider<SnapshotCodec>(
  (ref) => SnapshotJsonCodec(),
);
final storeProvider = Provider<SnapshotStore>(
  (ref) => PreferencesSnapshotStore(SharedPreferencesAsync()),
);
final chooseOptionProvider = Provider((ref) => const ChooseOption());
final demoScenariosProvider = Provider((ref) => const DemoScenarios());
