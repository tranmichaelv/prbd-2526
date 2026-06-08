import 'dart:convert';

import 'package:prbd_2526_c03/services/api_client.dart';

class SimulatedTimeState {
  final DateTime? dateTime;
  final bool isLoading;
  final String? error;

  SimulatedTimeState({
    this.dateTime,
    this.isLoading = false,
    this.error,
  });

  SimulatedTimeState copyWith({
    DateTime? dateTime,
    bool? isLoading,
    String? error,
  }) {
    return SimulatedTimeState(
      dateTime: dateTime,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  static Future<DateTime> getSimulatedTime() async {
    final response = await ApiClient.get(
      'get_simulated_time',
      anonymous: true,
    );

    if (response.statusCode == 200) {
      return DateTime.parse(jsonDecode(response.body));
    }
    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> saveSimulatedTime(DateTime newDateTime) async {
    final response = await ApiClient.post(
        'save_simulated_time',
        anonymous: true,
        body: json.encode({
          '_datetime': newDateTime.toString(),
        })
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }
    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> nullSimulatedTime() async {
    final response = await ApiClient.post(
        'null_simulated_time',
        anonymous: true,
        body: jsonEncode({})
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }
    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }
}
