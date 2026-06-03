import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prbd_2526_c03/providers/reference_time_provider.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';

class SimuledTime extends ConsumerStatefulWidget  {

  const SimuledTime({super.key,});

  Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }

  @override
  ConsumerState<SimuledTime> createState() => _SimuledTimeState();
}

class _SimuledTimeState extends ConsumerState<SimuledTime> {
  DateTime? _temporarySimulatedTime;

  @override
  void initState() {
    super.initState();
    _temporarySimulatedTime = ref.read(referenceTimeProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simulatedTimeProvider);

    return AlertDialog(
      title: const Text('Modifier le temps simulé'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Date"),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(_temporarySimulatedTime!),
            ),
            trailing: const Icon(Icons.chevron_right),

            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _temporarySimulatedTime,
                firstDate: DateTime(1800),
                lastDate: DateTime(2100),
              );

              final time = state.dateTime;
              if (date == null) return;

              final newDatetime = DateTime(
                date.year,
                date.month,
                date.day,
                time!.hour,
                time.minute,
              );

              setState(() {
                _temporarySimulatedTime = newDatetime;
              });


             },
          ),
          ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text("Heure"),
              subtitle: Text(
                DateFormat('HH:mm').format(_temporarySimulatedTime!),
              ),
              trailing: const Icon(Icons.chevron_right),

              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: _temporarySimulatedTime!.hour,
                      minute: _temporarySimulatedTime!.minute
                  ),
                );

                final date = state.dateTime;
                if (time == null) return;

                final newDatetime = DateTime(
                  date!.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                setState(() {
                  _temporarySimulatedTime = newDatetime;
                });

              },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              "Annuler",
            )
        ),
        TextButton(
            onPressed: () => {

            },
            child: Text(
              "Effacer(null)",
            )
        ),
      TextButton(
          onPressed: () => {
            ref.read(simulatedTimeProvider.notifier).saveSimulatedTime(_temporarySimulatedTime!),
            Navigator.pop(context),
          },
          child: Text(
            "Valider",
          )
        ),
      ],
    );
  }
}
