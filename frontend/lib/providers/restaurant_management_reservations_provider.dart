import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/providers/my_restaurants_provider.dart';

import 'package:prbd_2526_c03/providers/selected_restaurant_provider.dart';




final restaurantMangementReservationsProvider = AsyncNotifierProvider<RestaurantManagementReservationsNotifier,List<ReservationsManager>>(
      () => RestaurantManagementReservationsNotifier(),
);


final reservationFilterProvider = StateProvider<String>((ref) => 'all');

class RestaurantManagementReservationsNotifier extends AsyncNotifier<List<ReservationsManager>> {
  @override
  Future<List<ReservationsManager>> build() async {
    final resto = ref.watch(selectedRestaurantProvider);

    try {
      return await ReservationsManager.getReservationsFromRestaurant(resto.value!.id);
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> getReservationsFromRestaurants(int restaurantId) async {
    state = const AsyncLoading();
    try {
      final restaurants = await ReservationsManager.getReservationsFromRestaurant(restaurantId);
      state = AsyncData(restaurants);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}