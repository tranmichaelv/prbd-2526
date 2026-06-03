import 'dart:convert';
import 'package:prbd_2526_c03/services/api_client.dart';

class RestaurantService {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  
  const RestaurantService({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
});

  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      dayOfWeek: json['day_of_week'],
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  static Future<List<RestaurantService>> getByRestaurantService (int restaurantId) async {
    final response = await ApiClient.post(
      'get_restaurants_services',
      anonymous: true,
      body: json.encode({'_restaurant_id' : restaurantId,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => RestaurantService.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load restaurant services : ${response.statusCode} ${response.body}',);
    }
  }

}