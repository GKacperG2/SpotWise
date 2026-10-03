import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkuj_czy_przesiadz/app.dart';
import 'package:parkuj_czy_przesiadz/core/di/providers.dart';
import 'package:parkuj_czy_przesiadz/domain/snapshot_ports.dart';
import 'package:parkuj_czy_przesiadz/presentation/viewmodels/parking_vm.dart';

class MemoryStore implements SnapshotStore {
  String? last;

  @override
  Future<String?> load() async => last;

  @override
  Future<void> save(String raw) async => last = raw;
}

void main() {
  for (final size in [const Size(390, 844), const Size(1024, 768)]) {
    testWidgets('20 parkingów działa na ${size.width}px', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [storeProvider.overrideWithValue(MemoryStore())],
          child: const ParkingApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ParkingApp)),
      );
      final initial = container.read(parkingVmProvider).snapshot!;
      expect(initial.spots, hasLength(20));
      expect(initial.fullLocations, 6);
      expect(
        find.text('20 parkingów demo · 14 dostępnych · 6 pełnych'),
        findsOneWidget,
      );
      expect(find.text('Krowodrza'), findsOneWidget);
      expect(find.text('12/60'), findsWidgets);

      final occupy = find.text('Zajmij jedno wolne miejsce');
      await tester.scrollUntilVisible(
        occupy,
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(occupy);
      await tester.drag(
        find.byType(Scrollable).last,
        const Offset(0, -80),
      );
      await tester.pumpAndSettle();
      await tester.tap(occupy);
      await tester.pump();

      final updated = container.read(parkingVmProvider).snapshot!;
      expect(updated.spots.firstWhere((spot) => spot.id == 'P02').free, 11);
      expect(find.text('11/60'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
