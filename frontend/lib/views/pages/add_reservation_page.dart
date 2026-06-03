import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/reservation.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/providers/available_slots_provider.dart';
import 'package:prbd_2526_c03/providers/reservations_provider.dart';

class ReservationAddPage extends ConsumerStatefulWidget {
  final RestaurantSearchResult restaurant;

  const ReservationAddPage({
    super.key,
    required this.restaurant
  });

  @override
  ConsumerState<ReservationAddPage> createState() => _ReservationAddPageState();
}

class _ReservationAddPageState extends ConsumerState<ReservationAddPage> {
  DateTime selectedDate = DateTime(2024, 12, 4);
  DateTime? selectedSlot;

  int numberOfGuests = 2;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(availableSlotsProvider.notifier).loadSlots(
        restaurantId: widget.restaurant.id,
        date: selectedDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final slotsAsync = ref.watch(availableSlotsProvider);
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
        title: const Text('Nouvelle réservation'),
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
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 Text(
                  restaurant.name
                  ,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                                context: context,
                                firstDate: simulatedTime,
                                lastDate: simulatedTime.add(const Duration(days: 60)),
                                locale : const Locale('fr', 'FR'),
                            );
                            if (pickedDate == null) return;

                            setState(() {
                              selectedDate = pickedDate;
                              selectedSlot = null;
                            });

                            ref.read(availableSlotsProvider.notifier).loadSlots(
                              restaurantId: widget.restaurant.id,
                              date: selectedDate,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Date'),
                                      Text(
                                        DateFormat('EEEE d/MM/yyyy', 'fr_FR').format(selectedDate),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const Divider(),
              slotsAsync.maybeWhen(
                data: (slots) {
                  if (slots.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Le restaurant est fermé ce jour-là.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
                orElse: () => const SizedBox.shrink(),
              ),
                const SizedBox(height: 24),
                const Text(
                  'Créneaux disponibles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                slotsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => const Text(
                    'Impossible de charger les créneaux.',
                  ),
                  data: (slots) {
                    if (slots.isEmpty) {
                      return const Text('Aucun créneau disponible');
                    }

                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: slots.map((slot) {
                        final isSelected = selectedSlot == slot.slotDateTime;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedSlot = slot.slotDateTime;
                            });
                          },
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                DateFormat('HH:mm').format(slot.slotDateTime),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Nombre de convives'),
                  subtitle:  Text('$numberOfGuests'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: numberOfGuests > 1 ? () {
                          setState(() {
                            numberOfGuests--;
                          });
                        }
                        : null
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            numberOfGuests++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Surréservation (capacité)',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'La capacité du restaurant pour ce créneau pourrait être insuffisante pour le nombre de convives demandé.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Demandes spéciales (optionnel)',
                    border: OutlineInputBorder(),
                    hintText: 'Allergies, préférences...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (selectedSlot == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez choisir un créneau.')),
                      );
                      return;
                    }

                    try {
                      await Reservation.addReservation(
                        restaurantId: widget.restaurant.id,
                        datetime: selectedSlot!,
                        numberOfGuests: numberOfGuests,
                        specialRequests: null,
                      );
                      await ref.read(reservationsProvider.notifier).loadReservations();
                      if (!context.mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Impossible de créer la réservation. ')),
                      );
                    }

                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Créer la réservation'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
