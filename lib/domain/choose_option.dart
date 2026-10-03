import 'parking_snapshot.dart';

enum TravelChoice { park, parkAndRide, noCurrentMeasurement }

class TravelDecision {
  const TravelDecision(this.choice, this.reason);
  final TravelChoice choice;
  final String reason;
}

class ChooseOption {
  const ChooseOption();

  TravelDecision call(
    ParkingSnapshot? snapshot,
    DateTime now, {
    required String selectedId,
  }) {
    if (snapshot == null) {
      return const TravelDecision(
        TravelChoice.noCurrentMeasurement,
        'Uruchom scenariusz demonstracyjny, aby zobaczyć pomiar.',
      );
    }
    if (snapshot.isStale(now) || snapshot.sensorState != 'ok') {
      return const TravelDecision(
        TravelChoice.noCurrentMeasurement,
        'Ostatni pomiar jest nieaktualny. Odśwież analizę obrazu.',
      );
    }
    final matches = snapshot.spots.where((spot) => spot.id == selectedId);
    if (matches.isEmpty || matches.first.status == SpotStatus.unknown) {
      return const TravelDecision(
        TravelChoice.noCurrentMeasurement,
        'Wybrany parking nie ma aktualnego, pewnego pomiaru.',
      );
    }
    final selected = matches.first;
    if (selected.free == 0) {
      return TravelDecision(
        TravelChoice.parkAndRide,
        '${selected.name} jest obecnie pełny. Wybierz inny parking lub P+R.',
      );
    }
    return TravelDecision(
      TravelChoice.park,
      '${selected.name}: ${selected.free} z ${selected.capacity} miejsc jest wolnych w demonstracyjnym pomiarze.',
    );
  }
}
