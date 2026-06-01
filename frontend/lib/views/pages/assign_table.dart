import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/tables_extended.dart';
import 'package:prbd_2526_c03/providers/managerStateProvider.dart';
import 'package:prbd_2526_c03/providers/reservations_provider.dart';
import 'package:prbd_2526_c03/views/widgets/table_selection_list.dart';

import 'my_restaurants.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyRestaurantsPageScreen(),
    ),
  );
}

class AssignTablesPageScreen extends ConsumerStatefulWidget {

  const AssignTablesPageScreen({
    super.key,
  });

  @override
  ConsumerState<AssignTablesPageScreen> createState() => _AssignTablesState();
}

class _AssignTablesState extends ConsumerState<AssignTablesPageScreen> {
  final Set<int> _temporarySelectedTableIds = {};
  bool _initialized = false;
  int totalCapacity = 0;
  bool enoughCapacity = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final state = ref.read(managerStateProvider).value;

    final currentTables =
        state?.selectedReservation?.tables ?? [];

    for (var table in currentTables) {
      _temporarySelectedTableIds.add(table.id);
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return asyncState.when(
      data: (state) => data(context, state, notifier, theme, simulatedTime),
      error: (err, _) => error(err, StackTrace.current, notifier, context),
      loading: () =>
      const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

    Widget data(BuildContext context, ManagerState state, ManagerStateNotifier notifier, dynamic theme, DateTime simulatedTime) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Assigner des tables'),
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
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Tooltip(
                  message:
                  'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                  child: Text(
                    DateFormat('EEEE dd/MM/yyyy HH:mm', 'fr_FR')
                        .format(simulatedTime),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Réservation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${state.selectedReservation!.numberOfGuests} convives'),
                        Text('${DateFormat('dd/MM/yyyy').format(
                            state.selectedReservation!.datetime)} à ${DateFormat('HH:mm')
                            .format(state.selectedReservation!.datetime)}')
                      ],
                    ),
                  ),
                ),
              ),


              if(totalCapacity > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: enoughCapacity ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          enoughCapacity ?
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                          ) :
                          Icon(
                            Icons.warning_sharp,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Capacité totale: $totalCapacity places',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(enoughCapacity ?
                                  '✓ Capacité suffisante pour ${state.selectedReservation!.numberOfGuests} convives'
                                  : 'Capacité insuffisante: $totalCapacity places pour ${state.selectedReservation!.numberOfGuests} convives',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: enoughCapacity ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sélectionnez les tables disponibles',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    for (var table in state.tables)
                      table.occupied
                          ? Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.grey.shade100,
                        child: CheckboxListTile(
                          value: false,
                          onChanged: null,
                          title: Text(
                            'Table ${table.tableNumber}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          subtitle: Text(
                            'Occupée pour ce service',
                            style: TextStyle(color: Colors.red.shade300),
                          ),
                          secondary: Icon(
                            Icons.table_restaurant,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                          : Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: _temporarySelectedTableIds.contains(table.id),
                          onChanged: (value) {
                            setState(() {
                              if (_temporarySelectedTableIds.contains(table.id)) {
                                _temporarySelectedTableIds.remove(table.id);
                                totalCapacity -= table.capacity;
                              } else {
                                _temporarySelectedTableIds.add(table.id);
                                totalCapacity += table.capacity;
                              }
                              enoughCapacity = totalCapacity >= state.selectedReservation!.numberOfGuests;
                            });
                          },
                          title: Text('Table ${table.tableNumber}'),
                          subtitle: Text('Capacité: ${table.capacity} personnes'),
                          secondary: const Icon(Icons.table_restaurant),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: enoughCapacity ? () async {
                      await notifier.assignTables(_temporarySelectedTableIds);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirmer la réservation'),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
Widget error(
    Object error,
    StackTrace stackTrace,
    ManagerStateNotifier notifier,
    dynamic context
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
            Navigator.pop(context);
          },
          child: Text('Retry'),
        ),
      ],
    ),
  );
}
