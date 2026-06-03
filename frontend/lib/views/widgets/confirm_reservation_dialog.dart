import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:prbd_2526_c03/providers/managerStateProvider.dart';

class ConfirmReservationDialog extends ConsumerStatefulWidget {

  const ConfirmReservationDialog({super.key,});

  Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (context) => this);
  }

  @override
  ConsumerState<ConfirmReservationDialog> createState() =>
      _ConfirmReservationDialog();
}

class _ConfirmReservationDialog extends ConsumerState<ConfirmReservationDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terminer la réservation'),
      content: const Text('Voulez-vous marquer cette réservation comme terminée ?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              "Non",
            )
        ),
        TextButton(
            onPressed: () => confirmReservation(context),
            child: Text(
              "Oui",
              style: TextStyle(color: Colors.red),
            )
        ),
      ],
    );
  }

  Future<void> confirmReservation(BuildContext context) async {
    final notifier = ref.read(managerStateProvider.notifier);

    await notifier.completeReservation();

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

}
