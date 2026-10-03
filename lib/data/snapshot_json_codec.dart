import 'dart:convert';

import '../domain/parking_snapshot.dart';
import '../domain/snapshot_ports.dart';

class SnapshotJsonCodec implements SnapshotCodec {
  @override
  ParkingSnapshot decode(String raw, DateTime now) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> || data['schema_version'] != 2) {
        throw const FormatException('Nieobsługiwany format zapisu.');
      }
      final observedAt = DateTime.parse(data['observed_at'] as String);
      if (observedAt.isAfter(now.add(const Duration(seconds: 60)))) {
        throw const FormatException(
          'Zegar źródła jest przesunięty w przyszłość.',
        );
      }
      final rawSpots = data['spots'];
      if (rawSpots is! List || rawSpots.isEmpty) {
        throw const FormatException('Pomiar nie zawiera parkingów.');
      }
      final spots = rawSpots
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const FormatException('Błędny opis parkingu.');
            }
            final capacity = value['capacity'];
            final free = value['free'];
            if (capacity is! int ||
                free is! int ||
                capacity <= 0 ||
                free < 0 ||
                free > capacity) {
              throw const FormatException('Błędna liczba miejsc parkingowych.');
            }
            return ParkingSpot(
              id: value['id'] as String,
              name: value['name'] as String,
              latitude: (value['latitude'] as num).toDouble(),
              longitude: (value['longitude'] as num).toDouble(),
              capacity: capacity,
              free: free,
              known: value['known'] as bool? ?? true,
            );
          })
          .toList(growable: false);
      if (spots.map((spot) => spot.id).toSet().length != spots.length) {
        throw const FormatException('Powtórzone identyfikatory parkingów.');
      }
      return ParkingSnapshot(
        observedAt: observedAt,
        spots: spots,
        dataKind: data['data_kind'] as String,
        sensorState: data['sensor_state'] as String,
        sourceId: data['source_id'] as String,
        modelVersion: data['model_version'] as String,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Nie udało się odczytać zapisanego pomiaru.');
    }
  }

  @override
  String encode(ParkingSnapshot snapshot) => jsonEncode({
    'schema_version': 2,
    'data_kind': snapshot.dataKind,
    'observed_at': snapshot.observedAt.toIso8601String(),
    'source_id': snapshot.sourceId,
    'spots': [
      for (final spot in snapshot.spots)
        {
          'id': spot.id,
          'name': spot.name,
          'latitude': spot.latitude,
          'longitude': spot.longitude,
          'capacity': spot.capacity,
          'free': spot.free,
          'known': spot.known,
        },
    ],
    'model_version': snapshot.modelVersion,
    'sensor_state': snapshot.sensorState,
  });
}
