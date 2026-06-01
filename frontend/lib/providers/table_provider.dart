import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';
import 'package:prbd_2526_c03/providers/selected_reservation_provider.dart';




final tableProvider = AsyncNotifierProvider<TablesNotifier,List<TablesExtended>>(
      () => TablesNotifier(),
);


class TablesNotifier extends AsyncNotifier<List<TablesExtended>> {
  @override
  Future<List<TablesExtended>> build() async {
    final reservation = ref.watch(selectedReservationsProvider);

    try {
      return await TablesExtended.getTablesExtendedAvailable(reservation.value!.id);
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }

}