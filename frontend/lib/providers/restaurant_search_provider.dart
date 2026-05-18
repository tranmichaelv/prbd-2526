

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';

final restaurantSearchProvider = AsyncNotifierProvider<RestaurantSearchNotifier, List<RestaurantSearchResult>>(
    () => RestaurantSearchNotifier(),
);

class RestaurantSearchNotifier extends AsyncNotifier<List<RestaurantSearchResult>> {
  String? _query;

  @override
  Future<List<RestaurantSearchResult>> build() async {
    return RestaurantSearchResult.search(_query);
  }
  Future<void> search(String? query) async {
    _query = query?.trim();

    state = const AsyncLoading();

    try {
      final restaurants = await RestaurantSearchResult.search(_query);
      state = AsyncData(restaurants);

    } catch (e) {
      state = AsyncValue.error('Impossible de charger les restaurants', StackTrace.current);
    }
  }
  Future<void> refresh() async {
    await search(_query);
  }
}