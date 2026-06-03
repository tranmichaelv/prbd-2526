import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/services/api_client.dart';

class Reservation {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String restaurantCity;
  final String restaurantAddress;
  final String restaurantPhone;
  final DateTime datetime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;

  const Reservation({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantCity,
    required this.restaurantAddress,
    required this.restaurantPhone,
    required this.datetime,
    required this.numberOfGuests,
    required this.status,
    this.specialRequests,
  });

  Reservation copyWith({
    int? id,
    int? restaurantId,
    String? restaurantName,
    String? restaurantCity,
    String? restaurantAddress,
    String? restaurantPhone,
    DateTime? datetime,
    int? numberOfGuests,
    String? status,
    String? specialRequests,
  }) {
    return Reservation(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantCity: restaurantCity ?? this.restaurantCity,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
      datetime: datetime ?? this.datetime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      restaurantId: json['restaurant_id'] as int,
      restaurantName: json['restaurant_name'] as String,
      restaurantCity: json['restaurant_city'] as String,
      restaurantAddress: json['restaurant_address'] as String,
      restaurantPhone: json['restaurant_phone'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      numberOfGuests: json['number_of_guests'] as int,
      status: json['status'] as String,
      specialRequests: json['special_requests'] as String?,
    );
  }

  static Future<List<Reservation>> getReservations() async {
    final response = await ApiClient.get('get_reservations');

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body
          .map((dynamic item) => Reservation.fromJson(item))
          .toList();
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> addReservation({
    required int restaurantId,
    required DateTime datetime,
    required int numberOfGuests,
    String? specialRequests,
}) async {
      final response = await ApiClient.post(
        'add_reservation',
        body: jsonEncode({
          '_restaurant_id': restaurantId,
          '_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
          '_number_of_guests': numberOfGuests,
          '_special_requests': specialRequests,
        }),
      );

      // print('ADD RESERVATION STATUS: ${response.statusCode}');
      // print('ADD RESERVATION BODY: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to add reservation: ${response.statusCode} ${response.body}');
      }
}

  static Future<void> updateReservation({
    required int reservationId,
    required DateTime datetime,
    required int numberOfGuests,
    String? specialRequests,
  }) async {
    final response = await ApiClient.post(
      'update_reservation',
      body: jsonEncode({
        '_reservation_id': reservationId,
        '_datetime': DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime),
        '_number_of_guests': numberOfGuests,
        '_special_requests': specialRequests,
      }),
    );



    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update reservation: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<int> cancelReservation(int reservationId) async {
    final response = await ApiClient.post(
      'cancel_reservation',
      body: jsonEncode({
        '_reservation_id': reservationId,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body == null) {
        throw Exception('Réservation introuvable.');
      }

      return body as int;
    }

    final body = jsonDecode(response.body);
    throw Exception(
      body['message'] ?? 'Impossible d’annuler la réservation.',
    );
  }
}