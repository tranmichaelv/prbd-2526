import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';

// import 'abstract_async_notifier.dart';

final myRestaurantsProvider = AsyncNotifierProvider<MyRestaurantsNotifier,List<RestaurantSearchResult>>(
      () => MyRestaurantsNotifier(),
);


class MyRestaurantsNotifier extends AsyncNotifier<List<RestaurantSearchResult>> {
  @override
  Future<List<RestaurantSearchResult>> build() async {
    try {
      return await RestaurantSearchResult.getMyRestaurants();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> getMyRestaurants() async {
    state = const AsyncLoading();
    try {
      final restaurants = await RestaurantSearchResult.getMyRestaurants();
      state = AsyncData(restaurants);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}