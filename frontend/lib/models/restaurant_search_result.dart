import 'dart:convert';

import 'package:prbd_2526_c03/core/services/api_client.dart';

import '../core/tools/app_config.dart';

class RestaurantSearchResult {
  final int id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final DateTime? lastReservationAt;
  final int pendingRequestsCount;

  const RestaurantSearchResult({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    required this.description,
    required this.rating,
    required this.priceRange,
    required this.lastReservationAt,
    required this.pendingRequestsCount,
  });

  factory RestaurantSearchResult.fromJson(Map<String, dynamic> json) {
    return RestaurantSearchResult(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      description: json['description'] as String?,
      rating: json['rating'] == null
          ? null
          : (json['rating'] as num).toDouble(),
      priceRange: json['price_range'] as int?,
      lastReservationAt: json['last_reservation_at'] == null
          ? null
          : DateTime.parse(json['last_reservation_at'] as String),
      pendingRequestsCount: json['pending_requests_count'] as int? ?? 0,
    );
  }

  static Future<List<RestaurantSearchResult>> search(String? query) async {
    final trimmedQuery = query?.trim();

    final response = await ApiClient.post(
      'search_restaurants',
      anonymous: true, // pas de login encore
      body: json.encode({
        'search_text': trimmedQuery == null || trimmedQuery.isEmpty
            ? null
            : trimmedQuery,
        'result_limit': AppConfig.maxRestaurantSearchResults + 1,
      }),
    );

    if(response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);

      return body
      .map((item) => RestaurantSearchResult.fromJson(
        item as Map<String,dynamic>,
        ),
      )
      .toList();
    } else {
      throw Exception('Failed to search restaurants: ${response.statusCode} ${response.body}',);
    }
  }
}