import 'dart:convert';
import 'package:prbd_2526_c03/services/api_client.dart';


class TablesExtended {
  final int id;
  final int restaurant;
  final int tableNumber;
  final int capacity;
  final bool occupied;

  const TablesExtended({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    required this.capacity,
    required this.occupied,
  });

  factory TablesExtended.fromJson(Map<String, dynamic> json) {
    return TablesExtended(
      id: json['id'],
      restaurant: json['restaurant'],
      tableNumber: json['table_number'],
      capacity: json['capacity'],
      occupied: json['occupied']
    );
  }

  static Future<List<TablesExtended>> getTablesExtendedAvailable(int reservationId) async {
    final response = await ApiClient.post(
      'get_available_table_for_reservations',
      body: json.encode({'_reservation_id': reservationId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => TablesExtended.fromJson(item))
          .toList();
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }
}