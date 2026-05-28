import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/providers/my_restaurants_provider.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';


final reservationDetailsManageProvider = AsyncNotifierProvider<ReservationDetailsManageNotifier,List<ReservationsManager>>(
      () => ReservationDetailsManageNotifier(),
);

final myRestaurantsProvider = AsyncNotifierProvider<MyRestaurantsNotifier,List<RestaurantSearchResult>>(
      () => MyRestaurantsNotifier(),
);


class ReservationDetailsManageNotifier extends AsyncNotifier<List<ReservationsManager>> {
  @override
  Future<List<ReservationsManager>> build() async {
    try {
      return await ReservationsManager.getReservationsFromRestaurant();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


}