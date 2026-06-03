import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c03/providers/manager_state_provider.dart';

class CancelReservationDialog extends ConsumerStatefulWidget {

  const CancelReservationDialog({super.key,});

  Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }

  @override
  ConsumerState<CancelReservationDialog> createState() =>
      _CancelReservationDialog();
}

class _CancelReservationDialog extends ConsumerState<CancelReservationDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Annuler la réservation'),
      content: const Text('Êtes-vous sûr de vouloir annuler cette réservation'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
                "Non",
            )
        ),
        TextButton(
            onPressed: () => _cancelReservation(context),
            child: Text(
              "Oui",
              style: TextStyle(color: Colors.red),
            )
        ),
      ],
    );
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final notifier = ref.read(managerStateProvider.notifier);

    await notifier.cancelReservation();

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

}
