import 'dart:convert';
import 'package:prbd_2526_c03/core/services/api_client.dart';
import 'package:prbd_2526_c03/models/Table.dart';

class ReservationsManager {
  final int id;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String restaurantName;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;
  final List<Table> tables;

  const ReservationsManager({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.restaurantName,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
    required this.tables,
  });

  factory ReservationsManager.fromJson(Map<String, dynamic> json) {
    return ReservationsManager(
      id: json['id'],
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      clientPhone: json['client_phone'],
      restaurantName: json['restaurant_name'],
      datetime: DateTime.parse(json['datetime']),
      numberOfGuests: json['number_of_guests'],
      status: json['status'],
      specialRequests: json['special_requests'],
      tables: (json['tables'] as List<dynamic>)
          .map((e) => Table.fromJson(e))
          .toList(),
    );
  }

  static Future<List<ReservationsManager>> getReservationsFromRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
        'get_reservations_from_resto_manager',
        anonymous: true,
        body: json.encode({'_restaurant_id': restaurantId,
        }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => ReservationsManager.fromJson(item))
          .toList();
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }
}