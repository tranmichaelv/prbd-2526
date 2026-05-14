import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/restaurant_service.dart';


class RestaurantDetailsPageScreen extends StatefulWidget {

  final RestaurantSearchResult restaurant;

  const RestaurantDetailsPageScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<RestaurantDetailsPageScreen> createState() =>
    _RestaurantDetailsPageScreenState();
  }

  class _RestaurantDetailsPageScreenState extends State<RestaurantDetailsPageScreen> {
    List<RestaurantService> services = [];
    bool isLoadingServices = true;

    @override
    void initState() {
      super.initState();
      loadServices();
    }

    Future<void> loadServices() async {
      final result = await RestaurantService.getByRestaurant(widget.restaurant.id);

      if (!mounted) return;
      setState(() {
        services = result;
        isLoadingServices = false;
      });

    }

    String getDayName(int day) {
      switch (day) {
        case 1:
          return 'Lundi';
        case 2:
          return 'Mardi';
        case 3:
          return 'Mercredi';
        case 4:
          return 'Jeudi';
        case 5:
          return 'Vendredi';
        case 6:
          return 'Samedi';
        case 7:
          return 'Dimanche';
        default:
          return '';
      }
    }

    String formatTime(String time) {
      return time.substring(0, 5);
    }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Détails du restaurant'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(restaurant.rating?.toStringAsFixed(1) ?? '-'),
                  const SizedBox(width: 16),
                  Text('€' * (restaurant.priceRange ?? 0)),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                   Text(restaurant.city),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      restaurant.address,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
               Text(restaurant.description ?? 'Aucune description'),
              const SizedBox(height: 24),
              const Text(
                'Horaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (isLoadingServices)
                const SizedBox.shrink()
              else if (services.isEmpty)
                const Text('Aucun horaire disponible')
              else
                Column(
                  children: services.map((service) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              getDayName(service.dayOfWeek),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${formatTime(service.startTime)} - ${formatTime(service.endTime)}',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Réserver'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
