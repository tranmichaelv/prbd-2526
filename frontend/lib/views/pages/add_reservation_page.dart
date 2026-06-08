import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/available_slot.dart';

import 'package:prbd_2526_c03/models/reservation.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/providers/available_slots_provider.dart';
import 'package:prbd_2526_c03/providers/reservations_provider.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';

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

  final _fromKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  DateTime? selectedSlot;

  int numberOfGuests = 2;

  final TextEditingController specialRequestsController = TextEditingController();


  // getters
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
    final referenceTime = ref.read(referenceTimeProvider);
    // print('LE TEMPS DE l APPLI ${referenceTime}');
    return DateTime(
      referenceTime.year,
      referenceTime.month,
      referenceTime.day,
    );
  }

  String? get specialRequests {
    final text = specialRequestsController.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // initialisation
  @override
  void initState() {
    super.initState();

    if (isEdit) {
      selectedDate = widget.reservation!.datetime;
      selectedSlot = widget.reservation!.datetime;
      numberOfGuests = widget.reservation!.numberOfGuests;
      specialRequestsController.text =
          widget.reservation!.specialRequests ?? '';
    } else {
      selectedDate = firstSelectableDate;
    }

    Future.microtask(() {
      if (isEdit) {
        _loadSlots();
      } else {
        _firstAvailableSlot();
      }
    });
  }

  // util functions
  void _loadSlots() {

    ref.read(availableSlotsProvider.notifier).loadSlots(
      restaurantId: restaurantId,
      date: selectedDate,
    );
  }

  Future<void> _firstAvailableSlot() async {

    // je récup la date simulé actuellement
    DateTime currentTime = ref.read(referenceTimeProvider);

    DateTime dateToCheck = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day
    );

    // tester les 60 jours a venir seulement pour éviter que ca tourne a l'infini
    for (int i = 0; i < 60; i++) {
      // je récup les créneau dispo d'un restaurant
      final slots = await AvailableSlot.getAvailableSlots(
          restaurantId: restaurantId,
          date: dateToCheck
      );

      final slotsDates = slots
          .map((slots) => slots.slotDateTime)
          .where((slotDate) {
        if (_sameDay(slotDate, currentTime)){
          return slotDate.isAfter(currentTime);
        }

        return true;
      }).toList();
      //print(slotsDates);
      slotsDates.sort();

      if (slotsDates.isNotEmpty) {
        setState(() {
          selectedDate = dateToCheck;
          selectedSlot = slotsDates.first;
        });

        await ref.read(availableSlotsProvider.notifier).loadSlots(
            restaurantId: restaurantId,
            date: selectedDate
        );
        return;
      }

      dateToCheck = dateToCheck.add(const Duration(days: 1));

    }

    setState(() {
      selectedDate = firstSelectableDate;
      selectedSlot = null;
    });

    _loadSlots();
  }

  Future<void> _changeReferenceTime() async {

    // récup la date grace au provider
    final currentReferenceTime = ref.read(referenceTimeProvider);


    final pickedDate = await showDatePicker(
        context: context,
        initialDate: currentReferenceTime,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        locale: const Locale('fr', 'FR')
    );

    if (pickedDate == null) return;

    if (!context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentReferenceTime),
    );

    if (pickedTime == null) return;


    final newReferenceTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute
    );

    await ref.read(simulatedTimeProvider.notifier).saveSimulatedTime(newReferenceTime);

    if (isEdit) {
      _loadSlots();
    } else {
      await _firstAvailableSlot();
    }
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
    final DateTime referenceTime = ref.watch(referenceTimeProvider);

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
                child: InkWell(
                  onTap: _changeReferenceTime,
                  child: Text(
                    DateFormat('EEE dd/MM/yyyy HH:mm', 'fr_FR')
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _fromKey,
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
                              lastDate: referenceTime.add(
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
                      // pour empecher de revenir derrière quand
                      // le premier créneaux dispo n'est plus a cette date la
                      onPressed: selectedDate.isAtSameMomentAs(firstSelectableDate)
                          || selectedDate.isBefore(firstSelectableDate)
                          ? null
                          : () {
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
                        .where((slotDate) {
                      if (_sameDay(slotDate, referenceTime)) {
                        return slotDate.isAfter(referenceTime);
                      }
                      return true;
                    }).toList();

                    if (isEdit
                        && selectedSlot != null
                        && _sameDay(selectedSlot!, selectedDate)
                        && !slotDates.any(
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
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return null;
                    }

                    if (text.length < 10) {
                      return 'Les demandes spécials doivent contenir au moins 10 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () async {

                    if (!_fromKey.currentState!.validate()) {
                      return;
                    }
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
                      // print('ERREUR UPDATE/ADD RESERVATION: $e');
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