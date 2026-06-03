import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/tables.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';



final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(
      () => ManagerStateNotifier(),
);


class ManagerStateNotifier extends AsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    try {
      ref.watch(simulatedTimeProvider.notifier);
      state = AsyncData(ManagerState());
      state = AsyncLoading();
      return await ManagerState.getMyRestaurants();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }


  Future<void> getReservationsFromRestaurants(int restaurantId) async {
    final current = state.value;
    state = const AsyncLoading();
    if (current == null) return;


    try {
      final reservations = await ReservationsManager.getReservationsFromRestaurant(restaurantId);
      state = AsyncData(
        current.copyWith(
          reservations: reservations,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  Future<void> selectRestaurant(RestaurantSearchResult restaurant) async {
    final current = state.value!;
    state = const AsyncLoading();

    try {
      final reservations = await ReservationsManager.getReservationsFromRestaurant(restaurant.id);
      final tables = await Tables.getAllTablesFromRestaurant(restaurant.id);

      state = AsyncData(
        current.copyWith(
          selectedRestaurant: restaurant,
          reservations: reservations,
          restaurantTables: tables
        ),
      );
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
      print(e);
    }
  }

  Future<void> saveTable(int capacity, int numerTable) async {
    final current = state.value!;
    state = const AsyncLoading();

    try {
      await Tables.saveTable(capacity, numerTable, state.value!.selectedTable!.id);

      final updatedTable = Tables(
        id: current.selectedTable!.id,
        restaurant: current.selectedTable!.restaurant,
        tableNumber: numerTable,
        capacity: capacity,
      );

      final updatedTables = current.restaurantTables.map((t) {
        return t.id == updatedTable.id ? updatedTable : t;
      }).toList();

      state = AsyncData(
        current.copyWith(
          restaurantTables: updatedTables,
          selectedTable: updatedTable,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
      print(e);
    }
  }

  Future<void> selectTable(Tables table) async {
    final current = state.value!;
    state = const AsyncLoading();

    try {
      state = AsyncData(
        current.copyWith(
          selectedTable: table,
        ),
      );
    } catch (e) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
      print(e);
    }
  }

  Future<void> selectReservations(ReservationsManager reservation) async {
    final current = state.value;
    state = const AsyncLoading();

    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedReservation: reservation,
      ),
    );
  }

  void selectFilter(String filter) async {
    final current = state.value;
    state = const AsyncLoading();
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        reservationFilter: filter,
      ),
    );
  }

  Future<void> getTablesAvailable() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncLoading();

    try {
      final tables = await TablesExtended.getTablesExtendedAvailable(current.selectedReservation!.id);
      state = AsyncData(
        current.copyWith(
          tables: tables,
        ),
      );
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }
  //
  // Future<void> getAllTablesFromRestaurant() async {
  //   final current = state.value;
  //   if (current == null) return;
  //   state = const AsyncLoading();
  //
  //   try {
  //     final tables = await TablesExtended.getAllTablesFromRestaurant(current.selectedRestaurant!.id);
  //     state = AsyncData(
  //       current.copyWith(
  //         restaurantTables: tables,
  //       ),
  //     );
  //   } catch (e) {
  //     throw "Something went wrong!\nPlease try again later.";
  //   }
  // }

  bool isTableChosen(TablesExtended table) {
    return state.asData?.value.selectedReservation!.tables!.any((t) => t.id == table.id) ?? false;
  }

  Future<void> assignTables(Set<int> tablesId) async {
    final current = state.value;


    try {
      await ManagerState.chooseTable(
        current!.selectedReservation!.id,
        tablesId.toList(),
      );

      final updatedReservation = ReservationsManager(
        id: current.selectedReservation!.id,
        clientName: current.selectedReservation!.clientName,
        clientEmail: current.selectedReservation!.clientEmail,
        clientPhone: current.selectedReservation!.clientPhone,
        restaurantName: current.selectedReservation!.restaurantName,
        datetime: current.selectedReservation!.datetime,
        numberOfGuests: current.selectedReservation!.numberOfGuests,
        status: "confirmed",
        specialRequests: current.selectedReservation!.specialRequests,
        tables: current.tables
            .where((t) => tablesId.contains(t.id))
            .map((t) => Tables(
          id: t.id,
          restaurant: t.restaurant,
          tableNumber: t.tableNumber,
          capacity: t.capacity,
        ))
            .toList(),
        );

      final updatedReservations = current.reservations.map((r) {
        return r.id == current.selectedReservation!.id ? updatedReservation : r;
      }).toList();

      final updatedRestaurants = current.restaurants.map((r) {
        if (r.id == current.selectedRestaurant!.id) {
          return RestaurantSearchResult(
            id: r.id,
            name: r.name,
            city: r.city,
            address: r.address,
            phone: r.phone,
            description: r.description,
            rating: r.rating,
            priceRange: r.priceRange,
            lastReservationAt: r.lastReservationAt,
            pendingRequestsCount: r.pendingRequestsCount - 1,
          );
        }
        return r;
      }).toList();

      state = AsyncData(
        current.copyWith(
          reservations: updatedReservations,
          restaurants: updatedRestaurants,
          selectedReservation: updatedReservation,
          showSuccessMessage: true,
        ),
      );

      } catch (e) {
        throw "Something went wrong!\nPlease try again later.";
      }
  }

  void clearSuccessMessage() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        showSuccessMessage: false,
      ),
    );
  }

  void clearCancelMessage() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        showCancelMessage: false,
      ),
    );
  }

  void clearCompleteMessage() {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        showCompleteMessage: false,
      ),
    );
  }

  Future<void> refreshMyResto() async {
    state = const AsyncLoading();

    final data = await ManagerState.getMyRestaurants();

    state = AsyncData(data);
  }

  Future<void> refreshAssignTables() async {
    state = const AsyncLoading();

    final current = state.value;
    final tables = await TablesExtended.getTablesExtendedAvailable(current!.selectedReservation!.id);

    state = AsyncData(
      current.copyWith(
        tables: tables,
      ),
    );
  }

  Future<void> refreshSelectedReservations() async {
    final current = state.value;
    for (var reservation in current!.reservations) {
      if(reservation.id == current.selectedReservation!.id) {
        await selectReservations(reservation);
      }
    }
  }

  Future<void> refreshReservations() async {
    await getReservationsFromRestaurants(state.value!.selectedRestaurant!.id);
  }

  Future<void> cancelReservation() async {
    await updateReservationStatus(
      status: "cancelled",
      api: ManagerState.cancelReservation,
      tables: []
    );
  }

  Future<void> completeReservation() async {
    await updateReservationStatus(
      status: "completed",
      api: ManagerState.completeReservation,
      tables: state.value!.selectedReservation!.tables
    );
  }


  Future<void> updateReservationStatus({
    required String status,
    required Future<void> Function(int reservationId) api,
    required List<Tables>? tables
  }) async {

    final current = state.value;

    state = const AsyncLoading();

    try {
      await api(
        current!.selectedReservation!.id,
      );


      final updatedReservation = ReservationsManager(
        id: current.selectedReservation!.id,
        clientName: current.selectedReservation!.clientName,
        clientEmail: current.selectedReservation!.clientEmail,
        clientPhone: current.selectedReservation!.clientPhone,
        restaurantName: current.selectedReservation!.restaurantName,
        datetime: current.selectedReservation!.datetime,
        numberOfGuests: current.selectedReservation!.numberOfGuests,
        status: status,
        specialRequests: current.selectedReservation!.specialRequests,
        tables: tables,
      );

      final updatedReservations = current.reservations
          .map((r) => r.id == updatedReservation.id ? updatedReservation : r)
          .toList();

      final updatedRestaurants = current.restaurants.map((r) {
        if (r.id == current.selectedRestaurant?.id) {
          return RestaurantSearchResult(
            id: r.id,
            name: r.name,
            city: r.city,
            address: r.address,
            phone: r.phone,
            description: r.description,
            rating: r.rating,
            priceRange: r.priceRange,
            lastReservationAt: r.lastReservationAt,
            pendingRequestsCount: (r.pendingRequestsCount - 1).clamp(0, 999999),
          );
        }
        return r;
      }).toList();

      final isCompleted = status == "completed";
      final isCancelled = status == "cancelled";


      state = AsyncData(
        current.copyWith(
          reservations: updatedReservations,
          selectedReservation: updatedReservation,
          restaurants: updatedRestaurants,
          showCompleteMessage: isCompleted,
          showCancelMessage: isCancelled
        ),
      );

      print(state.value!.selectedReservation!.status);
    } catch (_) {
      state = AsyncValue.error(
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }
}
