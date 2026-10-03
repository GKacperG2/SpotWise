import 'package:flutter_test/flutter_test.dart';
import 'package:parkuj_czy_przesiadz/data/demo_scenarios.dart';
import 'package:parkuj_czy_przesiadz/data/snapshot_json_codec.dart';
import 'package:parkuj_czy_przesiadz/domain/choose_option.dart';

void main() {
  final now = DateTime.utc(2026, 10, 3, 12);
  final scenarios = DemoScenarios();
  final codec = SnapshotJsonCodec();
  final choose = ChooseOption();

  test('demo ma 20 parkingów, w tym dokładnie 6 pełnych', () {
    final snapshot = scenarios.krakow(now);
    expect(snapshot.spots, hasLength(20));
    expect(snapshot.fullLocations, 6);
    expect(snapshot.availableLocations, 14);
  });

  test('rekomendacja zależy od wybranego parkingu', () {
    final snapshot = scenarios.krakow(now);
    expect(choose(snapshot, now, selectedId: 'P02').choice, TravelChoice.park);
    expect(
      choose(snapshot, now, selectedId: 'P01').choice,
      TravelChoice.parkAndRide,
    );
  });

  test('stary pomiar nie obiecuje miejsca', () {
    final snapshot = scenarios.krakow(now);
    expect(
      choose(
        snapshot,
        now.add(const Duration(seconds: 31)),
        selectedId: 'P02',
      ).choice,
      TravelChoice.noCurrentMeasurement,
    );
  });

  test('lokalny zapis zachowuje 20 parkingów i ich pojemność', () {
    final raw = codec.encode(scenarios.krakow(now));
    final decoded = codec.decode(raw, now);
    expect(decoded.spots, hasLength(20));
    expect(decoded.spots.firstWhere((spot) => spot.id == 'P10').free, 50);
    expect(decoded.spots.firstWhere((spot) => spot.id == 'P10').capacity, 90);
  });
}
