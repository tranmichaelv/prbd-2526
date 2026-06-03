import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/manager_state.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/providers/manager_state_provider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';
import 'package:prbd_2526_c03/views/pages/reservation_details_manage.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_service.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_tables.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';

import 'my_restaurants.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: MyRestaurantsPageScreen(),
      ),
    ),
  );
}

class RestaurantManagementReservationsPageScreen extends ConsumerWidget {

  const RestaurantManagementReservationsPageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context , WidgetRef ref) {

    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);


    final theme = Theme.of(context);
    final referenceTime =  ref.watch(referenceTimeProvider);

    if (asyncState.value!.showSuccessMessage == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réservation confirmée avec les tables assignées'),
            backgroundColor: Colors.green,
          ),
        );
        notifier.clearSuccessMessage();
      });
    }


    return asyncState.when(
        data: (state) => data(state, theme, notifier, referenceTime, context),
        error: (err, _) => error(err, StackTrace.current, context),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
  }

  Widget data(ManagerState reservations,  dynamic theme, ManagerStateNotifier notifier,DateTime referenceTime, BuildContext context) {
    final filteredReservations = reservations.reservationFilter == 'all' ?
        reservations.reservations : filterReservations(reservations.reservationFilter, reservations.reservations);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(reservations.selectedRestaurant!.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              notifier.refreshReservations();
            },
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: GestureDetector(
                onTap: () {
                  SimuledTime().show(context);
                },
                child: Tooltip(
                  message:
                  'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                        .format(referenceTime),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {reservations.reservationFilter},
                onSelectionChanged: (value) {
                  notifier.selectFilter(value.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [

                  for (var reservation in filteredReservations)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          notifier.selectReservations(reservation);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                   ReservationDetailsManagePageScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: getIcons(reservation.status),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                      reservation.clientName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.restaurant, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          reservations.selectedRestaurant!.name,
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                            "${DateFormat('EEE', 'fr_FR').format(reservation.datetime)} "
                                            "${DateFormat('dd/MM/yyyy').format(reservation.datetime)}",
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.people, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${reservation.numberOfGuests} convives',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
        ],
      ),
    );
  }
}
Widget error(
    Object error,
    StackTrace stackTrace,
    BuildContext context
    ) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // notifier.getReservationsFromRestaurants(restaurant.id);
            Navigator.push(
                context,
              MaterialPageRoute(
                builder: (context) => MyRestaurantsPageScreen(),
              ),
            );
          },
          child: Text('Retry'),
        ),
      ],
    ),
  );
}

Icon getIcons(String status) {
  switch(status) {
    case 'pending' :
      return Icon(Icons.pending, size: 32, color: Colors.orange);
    case 'confirmed' :
      return Icon(Icons.check_circle, size: 32, color: Colors.green);
    case 'completed' :
      return Icon(Icons.event_available, size: 32, color: Colors.blue);
    default :
      return Icon(Icons.cancel, size: 32, color: Colors.red);
  }
}

List<ReservationsManager> filterReservations(String status, List<ReservationsManager> reservations){
  return reservations.where((i) => i.status == status).toList();
}
