

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/available_slot.dart';

final availableSlotsProvider = AsyncNotifierProvider<AvailableSlotsNotifier, List<AvailableSlot>>(
      () => AvailableSlotsNotifier(),
);


class AvailableSlotsNotifier extends AsyncNotifier<List<AvailableSlot>> {
  int? _restaurantId;
  DateTime? _date;

  @override
  Future<List<AvailableSlot>> build() async {
    if (_restaurantId == null || _date == null) {
      return [];
    }

    return AvailableSlot.getAvailableSlots(restaurantId: _restaurantId!, date: _date!);

}


  Future<void> loadSlots({
    required int restaurantId,
    required DateTime date,
  }) async {
    _restaurantId = restaurantId;
    _date = date;

    state = const AsyncLoading();

    try {
      final slots = await AvailableSlot.getAvailableSlots(
        restaurantId: restaurantId,
        date: date,
      );

      state = AsyncData(slots);
    } catch (e) {
      state = AsyncValue.error(
        'Impossible de charger les créneaux disponibles.',
        StackTrace.current,
      );
    }
  }
}
