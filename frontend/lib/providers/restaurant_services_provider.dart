
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/restaurant_service.dart';

final restaurantServicesProvider = AsyncNotifierProvider<RestaurantServicesNotifier, List<RestaurantService>>(
    () => RestaurantServicesNotifier(),
);



class RestaurantServicesNotifier extends AsyncNotifier<List<RestaurantService>> {
  int? _restaurantId;

  @override
  Future<List<RestaurantService>> build() async {
    if(_restaurantId == null) {
      return [];
    }
    return RestaurantService.getByRestaurantService(_restaurantId!);
  }

  Future<void> loadServices(int restaurantId) async {
    _restaurantId = restaurantId;
    state = const AsyncLoading();

    try {
      final services = await RestaurantService.getByRestaurantService(restaurantId);
      state = AsyncData(services);

    } catch (e) {
      state = AsyncValue.error('Impossible de charger les horaires.', StackTrace.current);
    }
  }

}