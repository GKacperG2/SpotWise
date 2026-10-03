import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../domain/parking_snapshot.dart';
import '../viewmodels/parking_vm.dart';
import '../widgets/parking_detail_panel.dart';
import '../widgets/parking_map.dart';

class ParkingScreen extends ConsumerStatefulWidget {
  const ParkingScreen({super.key});

  @override
  ConsumerState<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends ConsumerState<ParkingScreen> {
  late final Timer _clock;
  DateTime _now = DateTime.now();
  String _selectedId = 'P02';

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = ref.read(parkingVmProvider.notifier);
      vm.loadDemo();
      vm.loadHistory();
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parkingVmProvider);
    final snapshot = state.snapshot;
    final stale =
        snapshot == null ||
        snapshot.isStale(_now) ||
        snapshot.sensorState != 'ok';
    final decision = ref.read(chooseOptionProvider)(
      snapshot,
      _now,
      selectedId: _selectedId,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablet = constraints.maxWidth >= 800;
            final map = _mapArea(snapshot, stale);
            final detail = ParkingDetailPanel(
              snapshot: snapshot,
              decision: decision,
              selectedId: _selectedId,
              now: _now,
              error: state.error,
              onOccupy: () =>
                  ref.read(parkingVmProvider.notifier).occupyOne(_selectedId),
              onRelease: () =>
                  ref.read(parkingVmProvider.notifier).releaseOne(_selectedId),
              onRushHour: () =>
                  ref.read(parkingVmProvider.notifier).simulateRushHour(),
              onReset: () => ref.read(parkingVmProvider.notifier).loadDemo(),
              onStale: () => ref.read(parkingVmProvider.notifier).showStale(),
            );
            if (tablet) {
              return Row(
                children: [
                  Expanded(child: map),
                  SizedBox(
                    width: constraints.maxWidth >= 1050 ? 440 : 380,
                    child: detail,
                  ),
                ],
              );
            }
            return Column(
              children: [
                SizedBox(height: constraints.maxHeight * 0.43, child: map),
                Expanded(child: detail),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mapArea(ParkingSnapshot? snapshot, bool stale) => Stack(
    children: [
      Positioned.fill(
        child: ParkingMap(
          spots: snapshot?.spots,
          stale: stale,
          selectedId: _selectedId,
          onSelected: (id) => setState(() => _selectedId = id),
        ),
      ),
      Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x250B303A),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parkuj czy przesiądź się?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  snapshot == null
                      ? 'Ładowanie punktów demonstracyjnych…'
                      : '${snapshot.spots.length} parkingów demo · ${snapshot.availableLocations} dostępnych · ${snapshot.fullLocations} pełnych',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: 16,
        bottom: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendDot(color: Color(0xFF08745A)),
              SizedBox(width: 4),
              Text('wolne', style: TextStyle(fontSize: 11)),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFFA5482D)),
              SizedBox(width: 4),
              Text('zajęte', style: TextStyle(fontSize: 11)),
              SizedBox(width: 10),
              _LegendDot(color: Color(0xFF66737B)),
              SizedBox(width: 4),
              Text('stare', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    ],
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
