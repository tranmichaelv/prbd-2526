import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/providers/restaurant_search_provider.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_details_page.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';
import '../../core/tools/app_config.dart';

class SearchRestaurantsPageScreen extends ConsumerStatefulWidget {
  const SearchRestaurantsPageScreen({super.key});

  @override
  ConsumerState<SearchRestaurantsPageScreen> createState() =>
      _SearchRestaurantsPageScreenState();
}

class _SearchRestaurantsPageScreenState extends ConsumerState<SearchRestaurantsPageScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;

  final DateTime simulatedTime = DateTime(2024, 12, 4, 16, 0);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(restaurantSearchProvider.notifier).search(null);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(
      AppConfig.searchDebounceDuration,
          () {
        ref.read(restaurantSearchProvider.notifier).search(_searchController.text);
      },
    );
  }

  String _formatLastReservation(DateTime date) {
    return 'Dernière réservation: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR')
        .format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurants = ref.watch(restaurantSearchProvider);
    final referenceTime =  ref.watch(referenceTimeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Rechercher un restaurant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              ref.read(restaurantSearchProvider.notifier).refresh();
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
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher par nom, ville, description...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: restaurants.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => const Center(
                  child: Text('Impossible de charger les restaurants.'),
                ),
                data: (restaurants) {
                  final maxResults = AppConfig.maxRestaurantSearchResults;

                  final hasTooManyResults = restaurants.length > maxResults;

                  final displayedRestaurants =
                  restaurants.take(maxResults).toList();

                  return Column(
                    children: [
                      if (hasTooManyResults)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          color: Colors.orange.shade50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.orange.shade800,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Trop de résultats trouvés. Veuillez affiner votre recherche pour voir plus de restaurants.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: displayedRestaurants.isEmpty
                            ? const Center(
                          child: Text('Aucun restaurant trouvé.'),
                        )
                            : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: displayedRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant =
                            displayedRestaurants[index];

                            final ratingText =
                            restaurant.rating == null
                                ? '-'
                                : restaurant.rating!
                                .toStringAsFixed(1);

                            final priceText =
                                '€' * (restaurant.priceRange ?? 0);

                            final pendingCount =
                                restaurant.pendingRequestsCount;

                            return Card(
                              margin:
                              const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.restaurant,
                                  size: 40,
                                ),
                                title: Text(restaurant.name),
                                subtitle: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(restaurant.city),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          ratingText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          priceText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (restaurant.lastReservationAt !=
                                        null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _formatLastReservation(
                                                restaurant
                                                    .lastReservationAt!,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (pendingCount > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pending,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            pendingCount == 1
                                                ? '1 demande en attente'
                                                : '$pendingCount demandes en attente',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange,
                                              fontWeight:
                                              FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing:
                                const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailsPageScreen(
                                            restaurant: restaurant,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
