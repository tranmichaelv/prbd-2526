import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/providers/my_restaurants_provider.dart';




final selectedRestaurantProvider = AsyncNotifierProvider<SelectedRestaurantNotifier,RestaurantSearchResult?>(
      () => SelectedRestaurantNotifier(),
);


class SelectedRestaurantNotifier extends AsyncNotifier<RestaurantSearchResult?> {
  @override
  Future<RestaurantSearchResult?> build() async {
    try {
      return null;
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> selectRestaurant(RestaurantSearchResult restaurant) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncData(restaurant);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}