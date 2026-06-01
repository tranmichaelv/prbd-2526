import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/tables.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';



final managerStateProvider = AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(
      () => ManagerStateNotifier(),
);


class ManagerStateNotifier extends AsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    try {
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
      state = AsyncData(
        current.copyWith(
          selectedRestaurant: restaurant,
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
        showCancellMessage: false,
      ),
    );
  }

  Future<void> refreshMyResto() async {
    state = const AsyncLoading();

    final data = await ManagerState.getMyRestaurants();

    state = AsyncData(data);
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

    final current = state.value;


    try {
      await ManagerState.cancelReservation(
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
        status: "cancelled",
        specialRequests: current.selectedReservation!.specialRequests,
        tables: [],
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
          selectedReservation: updatedReservation,
          restaurants: updatedRestaurants,
          showCancellMessage: true,
        ),
      );

    // } catch (e) {
    //   state = AsyncValue.error(
    //     "Something went wrong!\nPlease try again later.",
    //     StackTrace.current,
    //   );
    // }
    } catch (e, stackTrace) { // 👈 On récupère l'erreur (e) et la ligne du code (stackTrace)
      // 🎯 1. Ceci va s'afficher en GROS et en rouge dans ton terminal de debug (VS Code / Android Studio)
      print('❌ ERREUR DANS cancelReservation: $e');
      print('📋 DÉTAILS DE L\'ERREUR:\n$stackTrace');

      // 🎯 2. On passe la VRAIE erreur au state pour que ton écran l'affiche
      state = AsyncValue.error(
        e.toString(), // 👈 Remplace le texte générique par le vrai message
        stackTrace,
      );
    }
  }
}
