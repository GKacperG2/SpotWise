import 'package:flutter/material.dart';

import '../../domain/choose_option.dart';
import '../../domain/parking_snapshot.dart';
import 'camera_frame.dart';

class ParkingDetailPanel extends StatelessWidget {
  const ParkingDetailPanel({
    super.key,
    required this.snapshot,
    required this.decision,
    required this.selectedId,
    required this.now,
    required this.error,
    required this.onOccupy,
    required this.onRelease,
    required this.onRushHour,
    required this.onReset,
    required this.onStale,
  });

  final ParkingSnapshot? snapshot;
  final TravelDecision decision;
  final String selectedId;
  final DateTime now;
  final String? error;
  final VoidCallback onOccupy;
  final VoidCallback onRelease;
  final VoidCallback onRushHour;
  final VoidCallback onReset;
  final VoidCallback onStale;

  @override
  Widget build(BuildContext context) {
    final current =
        snapshot != null &&
        !snapshot!.isStale(now) &&
        snapshot!.sensorState == 'ok';
    final matches = snapshot?.spots.where((item) => item.id == selectedId);
    final parking = matches == null || matches.isEmpty ? null : matches.first;
    final status = current ? parking?.status : SpotStatus.unknown;
    final (statusLabel, statusColor) = switch (status) {
      SpotStatus.free => ('Dostępny', const Color(0xFF08745A)),
      SpotStatus.occupied => ('Pełny', const Color(0xFFB2472D)),
      _ => ('Brak aktualnych danych', const Color(0xFF5F6E76)),
    };
    final (
      decisionTitle,
      decisionIcon,
      decisionColor,
    ) = switch (decision.choice) {
      TravelChoice.park => (
        'Parkuj',
        Icons.local_parking,
        const Color(0xFF08745A),
      ),
      TravelChoice.parkAndRide => (
        'Wybierz inny lub P+R',
        Icons.directions_transit,
        const Color(0xFF9A5516),
      ),
      TravelChoice.noCurrentMeasurement => (
        'Sprawdź pomiar',
        Icons.schedule,
        const Color(0xFF526773),
      ),
    };

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(
            parking?.name ?? 'Wybierz parking',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            parking == null
                ? 'Dotknij punktu na mapie'
                : '${parking.id} · Kraków · dane demonstracyjne',
            style: const TextStyle(color: Color(0xFF526773)),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 18,
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'stan parkingu',
                      style: TextStyle(color: Color(0xFF526773)),
                    ),
                  ],
                ),
              ),
              if (parking != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      current ? '${parking.free}/${parking.capacity}' : '—',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'wolne',
                      style: TextStyle(color: Color(0xFF526773)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6F5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(decisionIcon, color: decisionColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        decisionTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: decisionColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(decision.reason),
                if (decision.choice == TravelChoice.park) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Miejsce nie jest rezerwowane i może zostać zajęte przed przyjazdem.',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Przykładowy fragment analizy obrazu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          CameraFrame(parking: parking),
          const SizedBox(height: 8),
          const Text(
            'Wygenerowany kadr pokazuje zasadę analizy. Liczby całego parkingu na mapie są demonstracyjne.',
            style: TextStyle(fontSize: 12, color: Color(0xFF526773)),
          ),
          const SizedBox(height: 14),
          const _AnalysisSteps(),
          const SizedBox(height: 14),
          const Text(
            'Szacunek demonstracyjny: parking 18 min · P+R 25 min',
            style: TextStyle(fontSize: 13, color: Color(0xFF526773)),
          ),
          if (snapshot != null) ...[
            const SizedBox(height: 6),
            Text(
              'Ostatni pomiar: ${_time(snapshot!.observedAt)} · ${current ? 'aktualny' : 'nieaktualny'}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF526773)),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: const TextStyle(
                color: Color(0xFFB0302B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: current && parking != null && parking.free > 0
                ? onOccupy
                : null,
            icon: const Icon(Icons.directions_car),
            label: const Text('Zajmij jedno wolne miejsce'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed:
                current && parking != null && parking.free < parking.capacity
                ? onRelease
                : null,
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Zwolnij jedno miejsce'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: [
              TextButton.icon(
                onPressed: snapshot == null ? null : onRushHour,
                icon: const Icon(Icons.trending_down, size: 18),
                label: const Text('Godzina szczytu'),
              ),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Resetuj demo'),
              ),
              TextButton.icon(
                onPressed: snapshot == null ? null : onStale,
                icon: const Icon(Icons.signal_wifi_off, size: 18),
                label: const Text('Awaria pomiaru'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'MVP: model obrazu nie jest wytrenowany. Wszystkie zmiany są symulacją do prezentacji.',
            style: TextStyle(fontSize: 12, color: Color(0xFF526773)),
          ),
        ],
      ),
    );
  }

  String _time(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}

class _AnalysisSteps extends StatelessWidget {
  const _AnalysisSteps();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F6F7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.videocam_outlined, size: 19),
        SizedBox(width: 5),
        Text(
          'Kadr',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Expanded(child: Icon(Icons.chevron_right, size: 17)),
        Icon(Icons.crop_free, size: 19),
        SizedBox(width: 5),
        Text(
          'Pola',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Expanded(child: Icon(Icons.chevron_right, size: 17)),
        Icon(Icons.task_alt, size: 19),
        SizedBox(width: 5),
        Text(
          'Status',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
