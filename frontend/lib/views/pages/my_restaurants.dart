import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/manager_state.dart';
import 'package:prbd_2526_c03/providers/auth_provider.dart';
import 'package:prbd_2526_c03/providers/manager_state_provider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_reservations.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';


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

class MyRestaurantsPageScreen extends ConsumerWidget {
  const MyRestaurantsPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);

    final theme = Theme.of(context);
    final referenceTime =  ref.watch(referenceTimeProvider);

    return asyncState.when(
      data: (state) => data(context, state, notifier, theme, referenceTime, ref),
      error: (err, _) => error(err, StackTrace.current, notifier),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

    Widget data(BuildContext context, ManagerState restaurants, ManagerStateNotifier notifier, dynamic theme, DateTime referenceTime, WidgetRef ref) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes restaurants'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir les données',
              onPressed: () {
                notifier.refreshMyResto();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion (Benoît P.)',
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();

                if (!context.mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                        (route) => false
                );
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [

              for (var restaurant in restaurants.restaurants)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant, size: 40),
                    title: Text(restaurant.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: Colors
                                .grey),
                            const SizedBox(width: 4),
                            Text(restaurant.address),
                            const SizedBox(width: 12),
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              restaurant.rating != null ? restaurant.rating.toString() : '',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              restaurant.priceRange != null ? '€' * restaurant.priceRange! : '',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors
                                .grey),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.lastReservationAt != null
                                  ? "Dernière réservation: ${DateFormat('EEE', 'fr_FR').format(restaurant.lastReservationAt!)} "
                                  "${DateFormat('dd/MM/yyyy').format(restaurant.lastReservationAt!)}"
                                  : "",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (restaurant.pendingRequestsCount > 0) ...[
                              Icon(
                                Icons.pending,
                                size: 14,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${restaurant.pendingRequestsCount} demandes en attente",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: ()  {
                      notifier.selectRestaurant(restaurant);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RestaurantManagementReservationsPageScreen(
                                ),
                          ),
                        );
                      }
                    }
                  ),
                ),
            ],
          ),
        ),
      );
    }

  Widget error(
      Object error,
      StackTrace stackTrace,
      ManagerStateNotifier notifier,
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
              notifier.build();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }


}
