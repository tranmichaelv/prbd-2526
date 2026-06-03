import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:prbd_2526_c03/models/reservation.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/providers/available_slots_provider.dart';
import 'package:prbd_2526_c03/providers/reservations_provider.dart';

class ReservationAddPage extends ConsumerStatefulWidget {
  final RestaurantSearchResult? restaurant;
  final Reservation? reservation;

  const ReservationAddPage({
    super.key,
    this.restaurant,
    this.reservation,
  }) : assert(restaurant != null || reservation != null);

  @override
  ConsumerState<ReservationAddPage> createState() => _ReservationAddPageState();
}

class _ReservationAddPageState extends ConsumerState<ReservationAddPage> {
  DateTime selectedDate = DateTime(2024, 12, 4);
  DateTime? selectedSlot;

  int numberOfGuests = 2;

  final TextEditingController specialRequestsController =
  TextEditingController();

  final simulatedTime = DateTime(2024, 12, 4, 16, 0);

  bool get isEdit => widget.reservation != null;

  int get restaurantId {
    if (isEdit) {
      return widget.reservation!.restaurantId;
    }

    return widget.restaurant!.id;
  }

  String get restaurantName {
    if (isEdit) {
      return widget.reservation!.restaurantName;
    }

    return widget.restaurant!.name;
  }

  DateTime get firstSelectableDate {
    return DateTime(
      simulatedTime.year,
      simulatedTime.month,
      simulatedTime.day,
    );
  }

  String? get specialRequests {
    final text = specialRequestsController.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      selectedDate = widget.reservation!.datetime;
      selectedSlot = widget.reservation!.datetime;
      numberOfGuests = widget.reservation!.numberOfGuests;
      specialRequestsController.text =
          widget.reservation!.specialRequests ?? '';
    }

    Future.microtask(() {
      _loadSlots();
    });
  }

  void _loadSlots() {
    ref.read(availableSlotsProvider.notifier).loadSlots(
      restaurantId: restaurantId,
      date: selectedDate,
    );
  }

  void _changeDate(int days) {
    final newDate = selectedDate.add(Duration(days: days));

    if (newDate.isBefore(firstSelectableDate)) {
      return;
    }

    setState(() {
      selectedDate = newDate;
      selectedSlot = null;
    });

    _loadSlots();
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    specialRequestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(availableSlotsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          isEdit ? 'Modifier la réservation' : 'Nouvelle réservation',
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les données',
            onPressed: _loadSlots,
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
                  restaurantName,
                  style: const TextStyle(
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
                              initialDate: selectedDate.isBefore(
                                firstSelectableDate,
                              )
                                  ? firstSelectableDate
                                  : selectedDate,
                              firstDate: firstSelectableDate,
                              lastDate: simulatedTime.add(
                                const Duration(days: 60),
                              ),
                              locale: const Locale('fr', 'FR'),
                            );

                            if (pickedDate == null) return;

                            setState(() {
                              selectedDate = pickedDate;
                              selectedSlot = null;
                            });

                            _loadSlots();
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
                                        DateFormat(
                                          'EEEE d/MM/yyyy',
                                          'fr_FR',
                                        ).format(selectedDate),
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
                      onPressed: () {
                        _changeDate(-1);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _changeDate(1);
                      },
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
                    final slotDates = slots
                        .map((slot) => slot.slotDateTime)
                        .toList();

                    if (isEdit &&
                        selectedSlot != null &&
                        _sameDay(selectedSlot!, selectedDate) &&
                        !slotDates.any(
                              (date) => date.isAtSameMomentAs(selectedSlot!),
                        )) {
                      slotDates.add(selectedSlot!);
                      slotDates.sort();
                    }

                    if (slotDates.isEmpty) {
                      return const Text('Aucun créneau disponible');
                    }

                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: slotDates.map((slotDate) {
                        final isSelected =
                            selectedSlot != null &&
                                selectedSlot!.isAtSameMomentAs(slotDate);

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedSlot = slotDate;
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
                                DateFormat('HH:mm').format(slotDate),
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
                  subtitle: Text('$numberOfGuests'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: numberOfGuests > 1
                            ? () {
                          setState(() {
                            numberOfGuests--;
                          });
                        }
                            : null,
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

                const SizedBox(height: 16),

                TextFormField(
                  controller: specialRequestsController,
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
                        const SnackBar(
                          content: Text('Veuillez choisir un créneau.'),
                        ),
                      );
                      return;
                    }

                    try {
                      if (isEdit) {
                        await Reservation.updateReservation(
                          reservationId: widget.reservation!.id,
                          datetime: selectedSlot!,
                          numberOfGuests: numberOfGuests,
                          specialRequests: specialRequests,
                        );
                      } else {
                        await Reservation.addReservation(
                          restaurantId: restaurantId,
                          datetime: selectedSlot!,
                          numberOfGuests: numberOfGuests,
                          specialRequests: specialRequests,
                        );
                      }

                      await ref
                          .read(reservationsProvider.notifier)
                          .loadReservations();

                      if (!context.mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    } catch (e) {
                      print('ERREUR UPDATE/ADD RESERVATION: $e');
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? 'Impossible de modifier la réservation.'
                                : 'Impossible de créer la réservation.',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: Icon(isEdit ? Icons.edit : Icons.add),
                  label: Text(
                    isEdit
                        ? 'Modifier la réservation'
                        : 'Créer la réservation',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}