

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/services/api_client.dart';

class AvailableSlot {

  final DateTime slotDateTime;

  const AvailableSlot({
   required this.slotDateTime
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
        slotDateTime: DateTime.parse(json['slot_datetime'] as String),
    );
  }

  static Future<List<AvailableSlot>> getAvailableSlots({
    required int restaurantId,
    required DateTime date,
  }) async {
    final response = await ApiClient.post(
      'get_available_slots',
      body: jsonEncode({
        '_restaurant_id': restaurantId,
        '_date': DateFormat('yyyy-MM-dd').format(date),
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);

      return body
          .map((item) => AvailableSlot.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      'Failed to load available slots: ${response.statusCode} ${response.body}',
    );
  }
}