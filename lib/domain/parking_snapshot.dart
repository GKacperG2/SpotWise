enum SpotStatus { free, occupied, unknown }

class ParkingSpot {
  const ParkingSpot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.free,
    this.known = true,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int capacity;
  final int free;
  final bool known;

  int get occupied => capacity - free;
  SpotStatus get status => !known
      ? SpotStatus.unknown
      : free == 0
      ? SpotStatus.occupied
      : SpotStatus.free;

  ParkingSpot copyWith({int? free, bool? known}) => ParkingSpot(
    id: id,
    name: name,
    latitude: latitude,
    longitude: longitude,
    capacity: capacity,
    free: free ?? this.free,
    known: known ?? this.known,
  );
}

class ParkingSnapshot {
  const ParkingSnapshot({
    required this.observedAt,
    required this.spots,
    required this.dataKind,
    required this.sensorState,
    required this.sourceId,
    required this.modelVersion,
  });

  final DateTime observedAt;
  final List<ParkingSpot> spots;
  final String dataKind;
  final String sensorState;
  final String sourceId;
  final String modelVersion;

  int get free =>
      spots.where((spot) => spot.known).fold(0, (sum, spot) => sum + spot.free);
  int get occupied => spots
      .where((spot) => spot.known)
      .fold(0, (sum, spot) => sum + spot.occupied);
  int get unknown => spots.where((spot) => !spot.known).length;
  int get capacity => spots.fold(0, (sum, spot) => sum + spot.capacity);
  int get availableLocations =>
      spots.where((spot) => spot.status == SpotStatus.free).length;
  int get fullLocations =>
      spots.where((spot) => spot.status == SpotStatus.occupied).length;
  bool isStale(DateTime now) => now.difference(observedAt).inSeconds >= 30;
  bool get isDemo => dataKind == 'tabletop_demo' || dataKind == 'scenario_demo';

  ParkingSnapshot copyWith({
    DateTime? observedAt,
    List<ParkingSpot>? spots,
    String? sensorState,
  }) => ParkingSnapshot(
    observedAt: observedAt ?? this.observedAt,
    spots: spots ?? this.spots,
    dataKind: dataKind,
    sensorState: sensorState ?? this.sensorState,
    sourceId: sourceId,
    modelVersion: modelVersion,
  );
}
