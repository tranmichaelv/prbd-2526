import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/ManagerState.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/providers/managerStateProvider.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';
import 'package:prbd_2526_c03/views/pages/assign_table.dart';
import 'package:prbd_2526_c03/views/widgets/cancel_reservation_dialog.dart';
import 'package:prbd_2526_c03/views/widgets/confirm_reservation_dialog.dart';
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

class ReservationDetailsManagePageScreen extends ConsumerWidget {

  const ReservationDetailsManagePageScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(managerStateProvider);
    final notifier = ref.read(managerStateProvider.notifier);

    final stateSimulatedTime =  ref.watch(simulatedTimeProvider);

    final theme = Theme.of(context);
    final simulatedTime = stateSimulatedTime.dateTime;

    if (asyncState.value!.showCancelMessage == true || asyncState.value!.showCompleteMessage == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: asyncState.value!.showCancelMessage == true ?
              Text('Réservation annulée avec succès') :
              Text('Réservation marquée comme terminée')  ,
            backgroundColor: Colors.black,
          ),
        );
        asyncState.value!.showCancelMessage == true ?
          notifier.clearCancelMessage() :
          notifier.clearCompleteMessage();
      });
    }

    return asyncState.when(
      data: (state) => data(context, state, notifier, theme, simulatedTime!),
      error: (err, _) => error(err, StackTrace.current, notifier, context),
      loading: () =>
      const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget data(BuildContext context, ManagerState reservation, ManagerStateNotifier notifier, dynamic theme, DateTime simulatedTime) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text('Détails de la réservation'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir les données',
              onPressed: () async {
                await notifier.refreshReservations();
                await notifier.refreshSelectedReservations();
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations client',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, size: 20),
                            SizedBox(width: 8),
                            Text('Nom: ${reservation.selectedReservation!.clientName}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, size: 20),
                            SizedBox(width: 8),
                            Text('Email: ${reservation.selectedReservation!.clientEmail}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Téléphone: ${reservation.selectedReservation!.clientPhone ?? "Non renseigné"}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails de la réservation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.restaurant, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reservation.selectedReservation!.restaurantName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Date: ${DateFormat('EEE', 'fr_FR').format(reservation.selectedReservation!.datetime)} '
                              '${DateFormat('dd/MM/yyyy').format(reservation.selectedReservation!.datetime)}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 20),
                            const SizedBox(width: 8),
                            Text('Heure:  ${DateFormat('HH:mm').format(reservation.selectedReservation!.datetime)}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 20),
                            const SizedBox(width: 8),
                            Text('Nombre de convives: ${reservation.selectedReservation!.numberOfGuests}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.info, size: 20),
                            const SizedBox(width: 8),
                            const Text('Statut: '),
                            Chip(
                              label: Text(
                                reservation.selectedReservation!.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: getStatusColor(reservation.selectedReservation!.status),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Demandes spéciales',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation.selectedReservation!.specialRequests ?? '',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tables assignées',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                if (reservation.selectedReservation!.tables!.isNotEmpty)
                  ...reservation.selectedReservation!.tables!.map(
                        (table) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.table_restaurant, size: 20),
                            const SizedBox(width: 8),
                            Text('Table ${table.tableNumber}'),
                            const SizedBox(width: 16),
                            Text(
                              '(${table.capacity} places)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    'Aucune table assignée (en attente de confirmation)',
                  ),

                if(reservation.selectedReservation!.status == 'pending' || reservation.selectedReservation!.status == 'confirmed')
                  ...[
                    const SizedBox(height: 24),
                    reservation.selectedReservation!.status == 'pending' ?
                      ElevatedButton.icon(
                        onPressed: () {
                          notifier.getTablesAvailable();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AssignTablesPageScreen(
                              ),
                            ),
                          );
                        },
                        icon: Icon( Icons.table_restaurant),
                        label: Text('Confirmer et assigner tables'),
                      ) :
                    ElevatedButton.icon(
                      onPressed: () {
                        ConfirmReservationDialog().show(context);
                      },
                      icon: Icon(Icons.check_circle),
                      label: Text('Marquer comme terminée'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        CancelReservationDialog().show(context);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                    ),
                  ]
              ],
            ),
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


Color getStatusColor(String status) {
  switch(status) {
    case 'pending' :
      return Colors.orange;
    case 'confirmed' :
      return Colors.green;
    case 'completed' :
      return Colors.blue;
    case 'cancelled' :
      return Colors.red;
    default :
      return Colors.grey;
  }

}