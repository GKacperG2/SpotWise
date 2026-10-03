import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/parking_snapshot.dart';

enum ParkingPhase { empty, ready, invalid }

class ParkingState {
  const ParkingState({
    this.phase = ParkingPhase.empty,
    this.snapshot,
    this.error,
    this.history,
  });

  final ParkingPhase phase;
  final ParkingSnapshot? snapshot;
  final ParkingSnapshot? history;
  final String? error;
}

final parkingVmProvider = NotifierProvider<ParkingVm, ParkingState>(
  ParkingVm.new,
);

class ParkingVm extends Notifier<ParkingState> {
  @override
  ParkingState build() => const ParkingState();

  Future<void> loadHistory() async {
    final raw = await ref.read(storeProvider).load();
    if (raw == null) return;
    try {
      final history = ref
          .read(snapshotCodecProvider)
          .decode(raw, DateTime.now());
      state = ParkingState(
        phase: state.phase,
        snapshot: state.snapshot,
        history: history,
      );
    } on FormatException {
      // Niekompatybilny zapis z wcześniejszego MVP nie staje się pomiarem.
    }
  }

  Future<void> loadDemo() async =>
      _setSnapshot(ref.read(demoScenariosProvider).krakow(DateTime.now()));

  Future<void> occupyOne(String id) async => _updateSpot(
    id,
    (spot) => spot.free > 0 ? spot.copyWith(free: spot.free - 1) : spot,
  );

  Future<void> releaseOne(String id) async => _updateSpot(
    id,
    (spot) =>
        spot.free < spot.capacity ? spot.copyWith(free: spot.free + 1) : spot,
  );

  Future<void> simulateRushHour() async {
    final snapshot = state.snapshot;
    if (snapshot == null) return;
    final updated = [
      for (final spot in snapshot.spots)
        spot.free == 0
            ? spot
            : spot.copyWith(
                free: (spot.free - (spot.capacity / 10).ceil()).clamp(
                  0,
                  spot.capacity,
                ),
              ),
    ];
    await _setSnapshot(
      snapshot.copyWith(
        observedAt: DateTime.now(),
        spots: updated,
        sensorState: 'ok',
      ),
    );
  }

  void showStale() {
    final snapshot = state.snapshot;
    if (snapshot == null) return;
    state = ParkingState(
      phase: ParkingPhase.ready,
      history: state.history,
      snapshot: snapshot.copyWith(
        observedAt: DateTime.now().subtract(const Duration(seconds: 45)),
        sensorState: 'stopped',
      ),
    );
  }

  Future<void> _updateSpot(
    String id,
    ParkingSpot Function(ParkingSpot spot) update,
  ) async {
    final snapshot = state.snapshot;
    if (snapshot == null) return;
    final updated = [
      for (final spot in snapshot.spots) spot.id == id ? update(spot) : spot,
    ];
    await _setSnapshot(
      snapshot.copyWith(
        observedAt: DateTime.now(),
        spots: updated,
        sensorState: 'ok',
      ),
    );
  }

  Future<void> _setSnapshot(ParkingSnapshot snapshot) async {
    state = ParkingState(
      phase: ParkingPhase.ready,
      snapshot: snapshot,
      history: snapshot,
    );
    await ref
        .read(storeProvider)
        .save(ref.read(snapshotCodecProvider).encode(snapshot));
  }
}
