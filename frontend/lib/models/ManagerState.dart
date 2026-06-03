import 'dart:convert';

import 'package:prbd_2526_c03/core/services/api_client.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/tables.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';

class ManagerState {
  final List<RestaurantSearchResult> restaurants;
  final RestaurantSearchResult? selectedRestaurant;

  final List<ReservationsManager> reservations;
  final ReservationsManager? selectedReservation;

  final String reservationFilter;

  final List<TablesExtended> tables;
  final List<Tables> restaurantTables;
  final Tables? selectedTable;

  final bool showSuccessMessage;
  final bool showCancelMessage;
  final bool showCompleteMessage;


  const ManagerState({
    this.restaurants = const [],
    this.selectedRestaurant,
    this.reservations = const [],
    this.selectedReservation,
    this.reservationFilter = 'all',
    this.tables = const [],
    this.restaurantTables = const [],
    this.selectedTable,
    this.showSuccessMessage = false,
    this.showCancelMessage = false,
    this.showCompleteMessage = false,
  });

  ManagerState copyWith({
    List<RestaurantSearchResult>? restaurants,
    RestaurantSearchResult? selectedRestaurant,
    List<ReservationsManager>? reservations,
    ReservationsManager? selectedReservation,
    String? reservationFilter,
    List<TablesExtended>? tables,
    List<Tables>? restaurantTables,
    Tables? selectedTable,
    bool? showSuccessMessage,
    bool? showCancelMessage,
    bool? showCompleteMessage,
  }) {
    return ManagerState(
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurant:
      selectedRestaurant ?? this.selectedRestaurant,
      reservations: reservations ?? this.reservations,
      selectedReservation:
      selectedReservation ?? this.selectedReservation,
      reservationFilter: reservationFilter ?? this.reservationFilter,
      tables: tables ?? this.tables,
      restaurantTables: restaurantTables ?? this.restaurantTables,
      selectedTable: selectedTable ?? this.selectedTable,
      showSuccessMessage: showSuccessMessage ?? this.showSuccessMessage,
      showCancelMessage: showCancelMessage ?? this.showCancelMessage,
      showCompleteMessage: showCompleteMessage ?? this.showCompleteMessage,
    );
  }

  static Future<ManagerState> getMyRestaurants() async {
    // Simuler un delai
    await Future.delayed(throttleDuration);

    final response =
    await ApiClient.get('get_my_restaurants_test');

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      final restaurants = body
          .map((dynamic item) => RestaurantSearchResult.fromJson(item))
          .toList();
      return ManagerState(
        restaurants: restaurants,
      );
    } else {
      throw Exception('Failed to get favorites pairs');
    }
  }

  static Future<List<ReservationsManager>> getReservationsFromRestaurant(int restaurantId) async {
    final response = await ApiClient.post(
      'get_reservations_from_resto_manager',
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

  static Future<void> chooseTable(int reservationId, List<int> tableIds) async {
    final response = await ApiClient.post(
      'link_table_to_reservation',
      body: json.encode({
        '_reservation_id': reservationId,
        '_table_ids': tableIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> cancelReservation(int reservationId) async {
    final response = await ApiClient.post(
      'cancel_reservation',
      body: json.encode({'_reservation_id': reservationId,}),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

  static Future<void> completeReservation(int reservationId) async {
    final response = await ApiClient.post(
      'complete_reservation',
      body: json.encode({'_reservation_id': reservationId,}),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Failed to load reservations: ${response.statusCode} ${response.body}',
    );
  }

}