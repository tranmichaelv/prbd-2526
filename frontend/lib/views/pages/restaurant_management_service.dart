import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/restaurant_service.dart';
import 'package:prbd_2526_c03/providers/manager_state_provider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/providers/restaurant_services_provider.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_reservations.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_management_tables.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';

import 'edit_service_page.dart';

class RestaurantManagementServicesPageScreen extends ConsumerStatefulWidget {

  final RestaurantSearchResult restaurant;

  const RestaurantManagementServicesPageScreen({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<RestaurantManagementServicesPageScreen> createState() =>
      _RestaurantManagementServicesPageScreenState();

}

  class _RestaurantManagementServicesPageScreenState
  extends ConsumerState<RestaurantManagementServicesPageScreen> {
  @override
  void initState() {
  super.initState();

  Future.microtask(() {
  ref
      .read(restaurantServicesProvider.notifier)
      .loadServices(widget.restaurant.id);
  ref
      .read(managerStateProvider.notifier)
      .getReservationsFromRestaurants(widget.restaurant.id);
  });
  }

  @override
  Widget build(BuildContext context) {
  final servicesAsync = ref.watch(restaurantServicesProvider);
  final managerStateAsync = ref.watch(managerStateProvider);
  final reservations = managerStateAsync.asData?.value.reservations ?? [];

    final theme = Theme.of(context);
    final referenceTime =  ref.watch(referenceTimeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.restaurant.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(restaurantServicesProvider.notifier).loadServices(widget.restaurant.id);
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
        child: servicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) => Center(
            child: Text(e.toString()),
          ),

          data: (services) {
            if (services.isEmpty) {
              return const Center(
                child: Text(
                  'Aucun service. Ajoutez-en un avec le bouton +.',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                for (int day = 1; day <= 7; day++)
                  _DayServicesCard(
                    day: day,
                    services: services
                        .where((service) => service.dayOfWeek == day)
                        .toList(),
                    allServices: services,
                    restaurant: widget.restaurant,
                    reservations: reservations,
                    onRefresh: () {
                      ref
                          .read(restaurantServicesProvider.notifier)
                          .loadServices(widget.restaurant.id);
                    },
                  )

              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'services_fab',
        onPressed: () async {
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditServicePageScreen(
                restaurant: widget.restaurant,
                services: servicesAsync.value ?? [],
                reservations: reservations,
              ),
            ),
          );
          if (saved == true) {
            ref.read(restaurantServicesProvider.notifier).loadServices(widget.restaurant.id);
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => RestaurantManagementReservationsPageScreen(),
                ),
            );
          }

          if (index == 1) {
            return;
          }

          if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RestaurantManagementTablesPageScreen(),
                ),
            );
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

class _DayServicesCard extends StatelessWidget {
  final int day;
  final List<RestaurantService> services;
  final RestaurantSearchResult restaurant;
  final List<RestaurantService> allServices;
  final List<ReservationsManager> reservations;
  final VoidCallback onRefresh;

  const _DayServicesCard({
    required this.day,
    required this.services,
    required this.restaurant,
    required this.allServices,
    required this.reservations,
    required this.onRefresh,
  });

  static const days = {
    1: 'Lundi',
    2: 'Mardi',
    3: 'Mercredi',
    4: 'Jeudi',
    5: 'Vendredi',
    6: 'Samedi',
    7: 'Dimanche',
  };

  bool _isServiceUsed(RestaurantService service) {
      final serviceStart =
          int.parse(service.startTime.substring(0, 2)) * 60 +
              int.parse(service.startTime.substring(3, 5));

      final serviceEnd =
          int.parse(service.endTime.substring(0, 2)) * 60 +
              int.parse(service.endTime.substring(3, 5));

      return reservations.any((reservation) {
        if (reservation.status == 'cancelled') {
          return false;
        }

        if (reservation.datetime.weekday != service.dayOfWeek) {
          return false;
        }

        final reservationMinutes =
            reservation.datetime.hour * 60 + reservation.datetime.minute;

        return reservationMinutes >= serviceStart &&
            reservationMinutes < serviceEnd;
      });
  }

  Future<void> _confirmDelete(
      BuildContext context,
      RestaurantService service,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le service'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer le service du '
                '${days[service.dayOfWeek]} '
                '(${service.startTime.substring(0, 5)} - ${service.endTime.substring(0, 5)}) ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await RestaurantService.deleteService(
        serviceId: service.id,
        restaurantId: restaurant.id,
      );

      onRefresh();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service supprimé avec succès'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer : des réservations non annulées utilisent ce service',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.grey[100],
        child: ListTile(
          leading: const Icon(Icons.schedule, color: Colors.grey),
          title: Text(
            days[day]!,
            style: TextStyle(color: Colors.grey[600]),
          ),
          subtitle: const Text(
            'Aucun service',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.schedule),
        title: Text(days[day]!),
        subtitle: Text(
          services
              .map((service) => '${service.startTime.substring(0, 5)} - ${service.endTime.substring(0, 5)}')
              .join(', '),
        ),
        children: [
          for (final service in services)
            ListTile(
              title: Text('${service.startTime.substring(0, 5)} - ${service.endTime.substring(0, 5)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final saved = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditServicePageScreen(
                            restaurant: restaurant,
                            service: service,
                            services: allServices,
                            reservations: reservations,
                          ),
                        ),
                      );
                      if(saved == true) {
                        onRefresh();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: _isServiceUsed(service) ? Colors.grey : Colors.red,
                    ),
                    tooltip: _isServiceUsed(service)
                        ? 'Impossible de supprimer : des réservations non annulées utilisent ce service'
                        : 'Supprimer le service',
                    onPressed: () {
                      if (_isServiceUsed(service)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Impossible de supprimer : des réservations non annulées utilisent ce service',
                            ),
                          ),
                        );
                        return;
                      }

                      _confirmDelete(context, service);
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
