import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/reservation.dart';

final reservationsProvider = AsyncNotifierProvider<ReservationsNotifier, List<Reservation>>(
    () => ReservationsNotifier()
);

class ReservationsNotifier extends AsyncNotifier<List<Reservation>> {
  @override
  Future<List<Reservation>> build() async {
    return Reservation.getReservations();
  }
  Future<void> loadReservations() async {
    state = const AsyncLoading();

    try {
      final reservations = await Reservation.getReservations();
      state = AsyncData(reservations);

    } catch (e) {
      state = AsyncValue.error('Impossible de charger les réservations.', StackTrace.current);
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    await Reservation.cancelReservation(reservationId);
    await loadReservations();
  }
}