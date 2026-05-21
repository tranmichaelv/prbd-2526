import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/my_restaurants_provider.dart';
import 'package:prbd_2526_c03/restaurants.dart';


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
        home: MyRestaurantsMockupScreen(),
      ),
    ),
  );
}

class MyRestaurantsMockupScreen extends ConsumerWidget {
  const MyRestaurantsMockupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(myRestaurantsProvider);
    final notifier = ref.read(myRestaurantsProvider.notifier);

    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);

    return asyncState.when(
        data: (state) => data(state, notifier, theme, simulatedTime),
        error: (err, _) => error(err, StackTrace.current, notifier),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }

    Widget data(List<Restaurants> restaurants, MyRestaurantsNotifier notifier, dynamic theme, DateTime simulatedTime) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes restaurants'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Rafraîchir les données',
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Déconnexion (Benoît P.)',
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [

              for (var restaurant in restaurants)
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
                              'Dernière réservation: mer. 04/12/2024',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.pending, size: 14, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              '2 demandes en attente',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
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
      MyRestaurantsNotifier notifier,
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
              notifier.getMyRestaurants();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }


}
