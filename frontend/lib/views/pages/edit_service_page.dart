import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/models/reservations_manager.dart';
import 'package:prbd_2526_c03/models/restaurant_search_result.dart';
import 'package:prbd_2526_c03/models/restaurant_service.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/views/widgets/simuled_time.dart';

class EditServicePageScreen extends ConsumerStatefulWidget  {
  final RestaurantSearchResult restaurant;
  final RestaurantService? service;
  final List<RestaurantService> services;
  final List<ReservationsManager> reservations;

  const EditServicePageScreen({
    super.key,
    required this.restaurant,
    required this.services,
    required this.reservations,
    this.service,
  });

  @override
  ConsumerState<EditServicePageScreen> createState() => _EditServicePageScreenState();

  }

class _EditServicePageScreenState extends ConsumerState<EditServicePageScreen> {
  late String? selectedDay;
  late int? startHour;
  late int? startMinute;
  late int? endHour;
  late int? endMinute;

  @override
  void initState() {
    super.initState();

    selectedDay = widget.service == null
        ? null
        : _dayName(widget.service!.dayOfWeek);

    startHour = widget.service == null
        ? null
        : int.parse(widget.service!.startTime.substring(0, 2));

    startMinute = widget.service == null
        ? null
        : int.parse(widget.service!.startTime.substring(3, 5));

    endHour = widget.service == null
        ? null
        : int.parse(widget.service!.endTime.substring(0, 2));

    endMinute = widget.service == null
        ? null
        : int.parse(widget.service!.endTime.substring(3, 5));
  }

  String _dayName(int day) {
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
      default:
        return 'Dimanche';
    }
  }

  Future<void> _saveService() async {
    if (!_isFormComplete()) return;
    try {
      final dayOfWeek = _dayNumber(selectedDay!);

      final startTime =
          '${startHour!.toString().padLeft(2, '0')}:${startMinute!.toString().padLeft(2, '0')}';

      final endTime =
          '${endHour!.toString().padLeft(2, '0')}:${endMinute!.toString().padLeft(2, '0')}';

      await RestaurantService.saveService(
        serviceId: widget.service?.id,
        restaurantId: widget.restaurant.id,
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _dayNumber(String day) {
    switch (day) {
      case 'Lundi':
        return 1;
      case 'Mardi':
        return 2;
      case 'Mercredi':
        return 3;
      case 'Jeudi':
        return 4;
      case 'Vendredi':
        return 5;
      case 'Samedi':
        return 6;
      default:
        return 7;
    }
  }
  bool _isFormComplete() {
    return selectedDay != null &&
        startHour != null &&
        startMinute != null &&
        endHour != null &&
        endMinute != null;
  }

  String? _validationError() {
    if (!_isFormComplete()) {
      return null;
    }
    final dayOfWeek = _dayNumber(selectedDay!);

    final startTotalMinutes = startHour! * 60 + startMinute!;
    final endTotalMinutes = endHour! * 60 + endMinute!;
    final slotDuration = widget.restaurant.slotDuration;

    if (startTotalMinutes % slotDuration != 0 ||
        endTotalMinutes % slotDuration != 0) {
      return 'Les heures doivent respecter les créneaux de réservation du restaurant.';
    }

    if (endTotalMinutes <= startTotalMinutes) {
      return "L'heure de fin doit être après l'heure de début.";
    }

    if (endTotalMinutes - startTotalMinutes < 60) {
      return "La durée du service doit être d'au moins 1 heure.";
    }

    final hasOverlap = widget.services.any((service) {
      if (widget.service != null && service.id == widget.service!.id) {
        return false;
      }

      if (service.dayOfWeek != dayOfWeek) {
        return false;
      }

      final existingStart =
          int.parse(service.startTime.substring(0, 2)) * 60 +
              int.parse(service.startTime.substring(3, 5));

      final existingEnd =
          int.parse(service.endTime.substring(0, 2)) * 60 +
              int.parse(service.endTime.substring(3, 5));

      return startTotalMinutes < existingEnd &&
          endTotalMinutes > existingStart;
    });

    if (hasOverlap) {
      return 'Ce service chevauche avec un service existant le $selectedDay.';
    }

    if (widget.service != null) {
      final oldService = widget.service!;

      final oldStart =
          int.parse(oldService.startTime.substring(0, 2)) * 60 +
              int.parse(oldService.startTime.substring(3, 5));

      final oldEnd =
          int.parse(oldService.endTime.substring(0, 2)) * 60 +
              int.parse(oldService.endTime.substring(3, 5));

      final lockedReservations = widget.reservations.where((reservation) {
        if (reservation.status != 'pending' &&
            reservation.status != 'confirmed') {
          return false;
        }

        final reservationDay = reservation.datetime.weekday;
        final reservationMinutes =
            reservation.datetime.hour * 60 + reservation.datetime.minute;

        final wasInOldService =
            reservationDay == oldService.dayOfWeek &&
                reservationMinutes >= oldStart &&
                reservationMinutes < oldEnd;

        final isOutsideNewService =
            reservationDay != dayOfWeek ||
                reservationMinutes < startTotalMinutes ||
                reservationMinutes >= endTotalMinutes;

        return wasInOldService && isOutsideNewService;
      }).length;

      if (lockedReservations > 0) {
        return 'Modification impossible : $lockedReservations réservation confirmée ou en attente serait en dehors des horaires du service.';
      }
    }


    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final simulatedTime = DateTime(2024, 12, 4, 16, 0);
    final referenceTime =  ref.watch(referenceTimeProvider);
    final errorMessage = _validationError();
    final canSave = _isFormComplete() && errorMessage == null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(widget.service == null ? 'Ajouter un service' : 'Modifier le service'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Enregistrer',
            onPressed:  canSave ? _saveService : null,
            icon: const Icon(Icons.save),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedDay,
                  hint: const Text('--'),
                  decoration: const InputDecoration(
                    labelText: 'Jour',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lundi', child: Text('Lundi')),
                    DropdownMenuItem(value: 'Mardi', child: Text('Mardi')),
                    DropdownMenuItem(value: 'Mercredi', child: Text('Mercredi')),
                    DropdownMenuItem(value: 'Jeudi', child: Text('Jeudi')),
                    DropdownMenuItem(value: 'Vendredi', child: Text('Vendredi')),
                    DropdownMenuItem(value: 'Samedi', child: Text('Samedi')),
                    DropdownMenuItem(value: 'Dimanche', child: Text('Dimanche')),
                  ],
                  onChanged: (value) {
                    if(value == null) return;
                    setState(() {
                      selectedDay = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: startHour,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Heure de début (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (value) {
                          if(value == null) return;
                          setState(() {
                            startHour = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: startMinute,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (value) {
                          if(value == null) return;
                          setState(() {
                            startMinute = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: endHour,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Heure de fin (heure)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (int h = 0; h < 24; h++)
                            DropdownMenuItem<int?>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')} h'),
                            ),
                        ],
                        onChanged: (value) {
                          if(value == null) return;
                          setState(() {
                            endHour = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: endMinute,
                        hint: const Text('--'),
                        decoration: const InputDecoration(
                          labelText: 'Minutes',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem<int?>(value: 0, child: const Text('00 min')),
                          DropdownMenuItem<int?>(value: 15, child: const Text('15 min')),
                          DropdownMenuItem<int?>(value: 30, child: const Text('30 min')),
                          DropdownMenuItem<int?>(value: 45, child: const Text('45 min')),
                        ],
                        onChanged: (value) {
                          if(value == null) return;
                          setState(() {
                            endMinute = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
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
