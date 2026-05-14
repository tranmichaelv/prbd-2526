import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/views/pages/restaurant_details_page.dart';
import '../../core/tools/app_config.dart';

class SearchRestaurantsPageScreen extends StatefulWidget {
  const SearchRestaurantsPageScreen({super.key});

  @override
  State<SearchRestaurantsPageScreen> createState() =>
      _SearchRestaurantsPageScreenState();
}

class _SearchRestaurantsPageScreenState extends State<SearchRestaurantsPageScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounceTimer;

  List<RestaurantSearchResult> _restaurants = [];

  bool _isLoading = false;
  bool _hasTooManyResults = false;
  String? _errorMessage;

  int _requestId = 0;

  final DateTime simulatedTime = DateTime(2024, 12, 4, 16, 0);

  @override
  void initState() {
    super.initState();

    // charge tous les restaurants au début, sans filtre texte.
    _loadRestaurants();
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
        _loadRestaurants();
      },
    );
  }

  Future<void> _loadRestaurants() async {
    final currentRequestId = ++_requestId;

    final trimmedQuery = _searchController.text.trim();
    final String? query = trimmedQuery.isEmpty ? null : trimmedQuery;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await RestaurantSearchResult.search(query);

      if (!mounted || currentRequestId != _requestId) return;

      final maxResults = AppConfig.maxRestaurantSearchResults;

      setState(() {
        _hasTooManyResults = results.length > maxResults;
        _restaurants = results.take(maxResults).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || currentRequestId != _requestId) return;

      setState(() {
        _restaurants = [];
        _hasTooManyResults = false;
        _isLoading = false;
        _errorMessage = 'Impossible de charger les restaurants.';
      });

      debugPrint(e.toString());
    }
  }

  String _formatLastReservation(DateTime date) {
    return 'Dernière réservation: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR')
        .format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            onPressed: _loadRestaurants,
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
              child: Column(
                children: [
                  if(_hasTooManyResults)
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                        ? Center(child: Text(_errorMessage!))
                        : _restaurants.isEmpty
                        ? const Center(
                      child: Text('Aucun restaurant trouvé.'),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = _restaurants[index];

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
                                if(restaurant.lastReservationAt != null) ...[
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
                                      builder: (context) => RestaurantDetailsPageScreen(restaurant: restaurant),
                                  ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
