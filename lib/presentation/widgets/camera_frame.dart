import 'package:flutter/material.dart';

import '../../domain/parking_snapshot.dart';

class CameraFrame extends StatelessWidget {
  const CameraFrame({super.key, required this.parking});

  final ParkingSpot? parking;

  @override
  Widget build(BuildContext context) {
    final selected = parking;
    if (selected == null) return _missingFrame();
    final full = selected.free == 0;
    final statuses = full
        ? const [SpotStatus.occupied, SpotStatus.occupied, SpotStatus.occupied]
        : const [SpotStatus.occupied, SpotStatus.free, SpotStatus.free];
    final asset = full
        ? 'assets/images/parking_full.png'
        : 'assets/images/parking_two_free.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            return Stack(
              children: [
                Positioned.fill(child: Image.asset(asset, fit: BoxFit.fill)),
                Positioned(
                  left: width * 0.025,
                  right: width * 0.025,
                  top: height * 0.12,
                  bottom: height * 0.07,
                  child: Row(
                    children: [
                      for (var index = 0; index < statuses.length; index++) ...[
                        Expanded(
                          child: _BayOutline(
                            id: 'ABC'[index],
                            status: statuses[index],
                          ),
                        ),
                        if (index < 2) SizedBox(width: width * 0.012),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  left: 9,
                  top: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xDD103946),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'FRAGMENT DEMO · NIE TRANSMISJA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _missingFrame() => Container(
    height: 170,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFE8EEF0),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'Wybierz parking, aby zobaczyć przykładowy fragment analizy.',
      ),
    ),
  );
}

class _BayOutline extends StatelessWidget {
  const _BayOutline({required this.id, required this.status});

  final String id;
  final SpotStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SpotStatus.free => ('wolne', const Color(0xFF24C28D)),
      SpotStatus.occupied => ('zajęte', const Color(0xFFFFA06C)),
      SpotStatus.unknown => ('?', const Color(0xFFE3E9EB)),
    };
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        color: const Color(0xC9103946),
        child: Text(
          '$id · $label',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
