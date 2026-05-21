import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/restaurants.dart';

// import 'abstract_async_notifier.dart';

final myRestaurantsProvider = AsyncNotifierProvider<MyRestaurantsNotifier,List<Restaurants>>(
      () => MyRestaurantsNotifier(),
);


class MyRestaurantsNotifier extends AsyncNotifier<List<Restaurants>> {
  @override
  Future<List<Restaurants>> build() async {
    try {
      return await Restaurants.getMyRestaurants();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> getMyRestaurants() async {
    state = const AsyncLoading();
    try {
      final restaurants = await Restaurants.getMyRestaurants();
      state = AsyncData(restaurants);
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

}