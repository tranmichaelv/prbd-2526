import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_client.dart';


class HomeClientMockupScreen extends StatefulWidget {
  const HomeClientMockupScreen({super.key});
  @override
  State<HomeClientMockupScreen> createState() => _HomeClientMockupScreenState();
}

class _HomeClientMockupScreenState extends State<HomeClientMockupScreen> {

  // listes des réservations reçues depuis le backend
  List<dynamic> reservations = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedFilter = 'pending';
  @override
  void initState() {
    super.initState();
    loadReservation();
  }

  Future<void> loadReservation() async {
    try {
      final response = await ApiClient.get('get_reservations');

      if (response.statusCode != 200) {
        throw Exception(response.body);
      }
      setState(() {
        reservations = jsonDecode(response.body);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              loadReservation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
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
                message: 'Date/heure simulée utilisée pour les tests.\nCliquez pour modifier.',
                child: Text(
                  'mercredi 04/12/2024 16:00',
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
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: 'all',
                    icon: Icon(Icons.list, size: 24),
                    tooltip: 'Toutes',
                  ),
                  ButtonSegment(
                    value: 'pending',
                    icon: Icon(Icons.pending, size: 24, color: Colors.orange),
                    tooltip: 'En attente',
                  ),
                  ButtonSegment(
                    value: 'confirmed',
                    icon: Icon(Icons.check_circle, size: 24, color: Colors.green),
                    tooltip: 'Confirmées',
                  ),
                  ButtonSegment(
                    value: 'completed',
                    icon: Icon(Icons.event_available, size: 24, color: Colors.blue),
                    tooltip: 'Terminées',
                  ),
                  ButtonSegment(
                    value: 'cancelled',
                    icon: Icon(Icons.cancel, size: 24, color: Colors.red),
                    tooltip: 'Annulées',
                  ),
                ],
                selected: {selectedFilter},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    // change le filtre quand on clique sur un bouton.
                    selectedFilter = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
      Expanded(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : Builder(
          builder: (context) {
            final filteredReservations = selectedFilter == 'all'
                ? reservations
                : reservations
                .where((r) => r['status'] == selectedFilter)
                .toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: filteredReservations.map((r) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          //  icône dynamique selon le status
                          Tooltip(
                            message: r['status'],
                            child: Icon(
                              r['status'] == 'pending'
                                  ? Icons.pending
                                  : r['status'] == 'confirmed'
                                  ? Icons.check_circle
                                  : r['status'] == 'completed'
                                  ? Icons.event_available
                                  : Icons.cancel,
                              size: 32,
                              color: r['status'] == 'pending'
                                  ? Colors.orange
                                  : r['status'] == 'confirmed'
                                  ? Colors.green
                                  : r['status'] == 'completed'
                                  ? Colors.blue
                                  : Colors.red,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //  nom restaurant
                                Text(
                                  r['restaurant_name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                //  ville
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      r['restaurant_city'],
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                //  date + convives
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('EEE dd/MM/yyyy à HH:mm', 'fr_FR')
                                          .format(DateTime.parse(r['datetime'])),
                                    ),

                                    const SizedBox(width: 12),

                                    const Icon(Icons.people, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${r['number_of_guests']} convives',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: aller vers page création réservation
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
