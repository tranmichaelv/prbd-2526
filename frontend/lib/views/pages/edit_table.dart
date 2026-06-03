import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/tables.dart';
import 'package:prbd_2526_c03/providers/managerStateProvider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/views/pages/my_restaurants.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MyRestaurantsPageScreen(),
    ),
  );
}

class EditTablePageScreen extends ConsumerStatefulWidget {
  const EditTablePageScreen({super.key});

  @override
  ConsumerState<EditTablePageScreen> createState() => _EditTablePageScreen();
}

class _EditTablePageScreen extends ConsumerState<EditTablePageScreen> {
  late int _temporarySelectedTableNumber;
  late int _temporarySelectedTableCapacity;
  late List<Tables> _allTables = [];
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final selectedTable = ref.read(managerStateProvider).value!.selectedTable!;

    _temporarySelectedTableNumber = selectedTable.tableNumber;
    _temporarySelectedTableCapacity = selectedTable.capacity;
    _allTables = ref.read(managerStateProvider).value!.restaurantTables;
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);

    final theme = Theme.of(context);
    final referenceTime = ref.watch(referenceTimeProvider);

    return asyncState.when(
      data: (state) =>
          data(context, state.selectedTable!, notifier, theme, referenceTime, ref),
      error: (err, _) => error(err, StackTrace.current, notifier),
      loading: () =>
      const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget data(BuildContext context, Tables table, ManagerStateNotifier notifier, dynamic theme, DateTime referenceTime, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Modifier la table'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed: _isValid ?
                () {

            } : null,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (_) => setState(() {}),
                  initialValue: '$_temporarySelectedTableNumber',
                  decoration: const InputDecoration(
                    labelText: 'Numéro de table',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le numéro est requis';
                    }

                    final tableNumber = int.tryParse(value);


                    if (tableNumber == null) {
                      return 'Numéro invalide';
                    }

                    for (final table in _allTables) {
                      if (table.tableNumber == tableNumber && tableNumber != _temporarySelectedTableNumber) {
                        return 'Ce numéro de table est déjà utilisé pour ce restaurant.';
                      }
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Capacité'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _temporarySelectedTableCapacity == 1 || _temporarySelectedTableCapacity <= getMinAllowedCapacity() ? null : () {
                        setState(() {
                          _temporarySelectedTableCapacity --;
                        });
                      },
                      tooltip:  _temporarySelectedTableCapacity == 1 ? 'Capacité minimale (1 personne)' :
                      _temporarySelectedTableCapacity <= getMinAllowedCapacity() ?
                        "Impossible de diminuer la capacité : une ou plusieurs réservations utilisent cette table et nécessitent au moins cette capacité"
                          : ""
                    ),
                    Text(
                      '$_temporarySelectedTableCapacity personnes',
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          _temporarySelectedTableCapacity ++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  bool canUpdateCapacity() {

    final reservationsUsingTable = ref
        .read(managerStateProvider)
        .value!
        .reservations
        .where((r) =>
    (r.status == 'confirmed' || r.status == 'finished') &&
        r.tables!.any((t) => t.id == ref.read(managerStateProvider).value!.selectedTable!.id))
        .toList();

    for (final reservation in reservationsUsingTable) {

      int capacity = 0;

      for (final table in reservation.tables!) {
        if (table.id == ref.read(managerStateProvider).value!.selectedTable!.id) {
          capacity += _temporarySelectedTableCapacity;
        } else {
          capacity += table.capacity;
        }
      }

      if (capacity < reservation.numberOfGuests) {
        return false;
      }
    }

    return true;
  }

  bool get _isValid {
    return (_key.currentState?.validate() ?? false) && canUpdateCapacity();
  }

  int getMinAllowedCapacity() {
    final reservationsUsingTable = ref
        .read(managerStateProvider)
        .value!
        .reservations
        .where((r) =>
    (r.status == 'confirmed' || r.status == 'finished') &&
        r.tables!.any((t) => t.id == ref.read(managerStateProvider).value!.selectedTable!.id))
        .toList();

    if (reservationsUsingTable.isEmpty) return 1;

    return reservationsUsingTable
        .map((r) => r.numberOfGuests)
        .reduce((a, b) => a > b ? a : b);
  }
}
