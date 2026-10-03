import 'parking_snapshot.dart';

abstract interface class SnapshotCodec {
  ParkingSnapshot decode(String raw, DateTime now);
  String encode(ParkingSnapshot snapshot);
}

abstract interface class SnapshotStore {
  Future<void> save(String raw);
  Future<String?> load();
}
