import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationDetailsPageScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailsPageScreen({
    super.key,
    required this.reservation,
  });

String getStatuxText(String status) {
  switch(status) {
    case 'pending' :
      return 'En attente';
    case 'confirmed' :
      return 'Confirmée';
    case 'completed' :
      return 'Terminée';
    case 'cancelled' :
      return 'Annulée';
    default :
      return status;
  }
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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final dateTime = DateTime.parse(reservation['datetime']);

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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant),
                          const SizedBox(width: 8),
                           Expanded(
                            child: Text(
                              reservation['restaurant_name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${reservation['restaurant_address']}, ${reservation['restaurant_city']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            reservation['restaurant_phone'],
                            style: TextStyle(color: Colors.grey[600]),
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
                              'Date: ${DateFormat('EEE dd/MM/yyyy', 'fr_FR').format(dateTime)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                           Text('Heure: ${DateFormat('HH:mm').format(dateTime)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 20),
                          const SizedBox(width: 8),
                           Text('Nombre de convives:  ${reservation['number_of_guests']}'),
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
                             getStatuxText(reservation['status']),
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            backgroundColor: getStatusColor(reservation['status']),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      if(reservation['special_requests'] != null && reservation['special_requests'].toString().isNotEmpty ) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Demandes spéciales',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reservation['special_requests'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if(reservation['status'] == 'pending' || reservation['status'] == 'confirmed')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (reservation['status'] == 'pending' &&
                          DateTime.parse(reservation['datetime']).isAfter(simulatedTime))
                          ? () {
                        // TODO: aller vers la page de edit reservation
                      }
                          : null,
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: aller vers la page de cancel reservation
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Annuler'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
