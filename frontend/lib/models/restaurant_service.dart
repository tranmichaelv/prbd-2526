import 'dart:convert';
import 'package:prbd_2526_c03/core/services/api_client.dart';

class RestaurantService {
  final int id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  
  const RestaurantService({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
});

  factory RestaurantService.fromJson(Map<String, dynamic> json) {
    return RestaurantService(
      id: json['id'],
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

  static Future<void> saveService({
    int? serviceId,
    required int restaurantId,
    required int dayOfWeek,
    required String startTime,
    required String endTime
}) async {
    final response = await ApiClient.post(
      'save_restaurant_service',
      anonymous: true,
      body: jsonEncode({
        '_service_id': serviceId,
        '_restaurant_id': restaurantId,
        '_day_of_week': dayOfWeek,
        '_start_time': startTime,
        '_end_time': endTime,
      }),
    );
    if(response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  static Future<void> deleteService({
    required int serviceId,
    required int restaurantId,
}) async {
    final response = await ApiClient.post(
        'delete_restaurant_service',
        anonymous: true,
      body: jsonEncode({
        '_service_id' : serviceId,
        '_restaurant_id' : restaurantId,
      })
    );
    if(response.statusCode != 200 && response.statusCode != 204 ) {
      throw Exception(response.body);
    }
  }

}