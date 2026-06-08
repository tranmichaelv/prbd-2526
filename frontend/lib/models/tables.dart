import 'dart:convert';
import 'package:prbd_2526_c03/services/api_client.dart';


class Tables {
  final int id;
  final int restaurant;
  final int tableNumber;
  final int capacity;

  const Tables({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    required this.capacity,
  });

  factory Tables.fromJson(Map<String, dynamic> json) {
    return Tables(
      id: json['id'],
      restaurant: json['restaurant'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
    );
  }

  static Future<List<Tables>> getAllTablesFromRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
      'get_available_table_for_restaurant',
      body: json.encode({'_restaurant_id': restaurantId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => Tables.fromJson(item))
          .toList();
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> saveTable(int capacity, int numberTable, int tableId) async {
    final response = await ApiClient.post(
      'save_table',
      body: json.encode({
        '_number_table': numberTable,
        '_capacity':capacity,
        '_table_id': tableId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> addTable({
  required int restaurantId,
  required int numberOfTable,
  required int capacity
}) async {
    final response = await ApiClient.post(
      'add_table',
      body: jsonEncode({
        '_restaurant_id' : restaurantId,
        '_number_table' : numberOfTable,
        '_capacity' : capacity,
      })
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to add table : ${response.statusCode} ${response.body}',);
    }
  }

  // static Future<List<Tables>> getTablesAvailable(int reservationId) async {
  //   final response = await ApiClient.post(
  //     'get_available_table_for_reservations',
  //     anonymous: true,
  //     body: json.encode({'_reservation_id': reservationId,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> body = jsonDecode(response.body);
  //     return body
  //         .map((dynamic item) => Tables.fromJson(item))
  //         .toList();
  //   }
  //
  //   throw Exception(
  //     'Failed to load reservations: ${response.statusCode} ${response.body}',
  //   );
  // }
}