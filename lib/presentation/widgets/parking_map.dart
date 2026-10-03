import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/parking_snapshot.dart';

class ParkingMap extends StatelessWidget {
  const ParkingMap({
    super.key,
    required this.spots,
    required this.stale,
    required this.selectedId,
    required this.onSelected,
  });

  static const _krakowCenter = LatLng(50.0555, 19.9560);

  final List<ParkingSpot>? spots;
  final bool stale;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFDCE5E8),
    child: FlutterMap(
      options: const MapOptions(
        initialCenter: _krakowCenter,
        initialZoom: 12.0,
        minZoom: 10,
        maxZoom: 19,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.parkuj_czy_przesiadz',
          maxNativeZoom: 19,
          panBuffer: 1,
        ),
        MarkerLayer(
          markers: [
            for (final spot in spots ?? const <ParkingSpot>[])
              Marker(
                point: LatLng(spot.latitude, spot.longitude),
                width: 72,
                height: 72,
                child: _ParkingPin(
                  spot: spot,
                  status: stale ? SpotStatus.unknown : spot.status,
                  selected: selectedId == spot.id,
                  onTap: () => onSelected(spot.id),
                ),
              ),
          ],
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xEFFFFFFF)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 10, color: Color(0xFF263238)),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ParkingPin extends StatelessWidget {
  const _ParkingPin({
    required this.spot,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final ParkingSpot spot;
  final SpotStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SpotStatus.free => const Color(0xFF08745A),
      SpotStatus.occupied => const Color(0xFFB2472D),
      SpotStatus.unknown => const Color(0xFF66737B),
    };
    final label = status == SpotStatus.unknown
        ? '—'
        : '${spot.free}/${spot.capacity}';
    final statusLabel = switch (status) {
      SpotStatus.free => '${spot.free} wolnych z ${spot.capacity}',
      SpotStatus.occupied => 'parking pełny',
      SpotStatus.unknown => 'brak aktualnych danych',
    };
    return Semantics(
      button: true,
      selected: selected,
      label: '${spot.name}: $statusLabel',
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('spot-map-${spot.id}'),
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: selected ? 68 : 58,
              height: selected ? 68 : 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: Colors.white,
                  width: selected ? 5 : 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x550B303A),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: selected ? 15 : 13,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    spot.id,
                    style: const TextStyle(
                      color: Color(0xFFE5F4F0),
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
