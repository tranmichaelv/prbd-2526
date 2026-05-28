import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';



final restaurantMangementReservationsProvider = AsyncNotifierProvider<RestaurantManagementReservationsNotifier,List<ReservationsManager>>(
      () => RestaurantManagementReservationsNotifier(),
);



class RestaurantManagementReservationsNotifier extends AsyncNotifier<List<ReservationsManager>> {
  @override
  Future<List<ReservationsManager>> build() async {
    try {
      return await ReservationsManager.getReservationsFromRestaurant();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> getReservationsFromRestaurants() async {
    state = const AsyncLoading();
    try {
      final restaurants = await ReservationsManager.getReservationsFromRestaurant();
      state = AsyncData(restaurants);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}