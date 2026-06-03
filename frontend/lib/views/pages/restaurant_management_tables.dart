import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';
import 'package:prbd_2526_c03/providers/managerStateProvider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/views/pages/edit_table.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_reservations.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';

import '../../models/tables.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: RestaurantManagementTablesPageScreen(),
    ),
  );
}

class RestaurantManagementTablesPageScreen extends ConsumerWidget {
  const RestaurantManagementTablesPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);

    final theme = Theme.of(context);
    final referenceTime = ref.watch(referenceTimeProvider);

    return asyncState.when(
      data: (state) => data(state.selectedRestaurant!, theme, notifier, referenceTime, context, state.restaurantTables),
      error: (err, _) => error(err, StackTrace.current, context),
      loading: () =>
      const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget data(RestaurantSearchResult restaurant,  dynamic theme, ManagerStateNotifier notifier,DateTime referenceTime, BuildContext context, List<Tables> tables) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(restaurant.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {},
          ),
        ],
        elevation: 2,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Align(
          alignment: Alignment.topCenter,
          child: SafeArea(
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
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                for(var table in tables)
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.table_restaurant, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Table ${table.tableNumber}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${table.capacity} personnes',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              notifier.selectTable(table);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditTablePageScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'tables_fab',
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2,
        onTap: (selectedIndex) {
          switch (selectedIndex) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantManagementReservationsPageScreen(),
                ),
              );
            case 1:
              print(selectedIndex);
            case 2:
              {}
            default:
              throw UnimplementedError('no widget for $selectedIndex');
          }
        },
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
