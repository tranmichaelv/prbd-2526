import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableSelectionList extends ConsumerStatefulWidget  {
  final dynamic state; // Passez le state de votre vue parente
  final dynamic notifier; // Passez le notifier de votre vue parente

  const TableSelectionList({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<TableSelectionList> createState() => _TableSelectionListState();
}

class _TableSelectionListState extends ConsumerState<TableSelectionList> {
  final Set<int> _temporarySelectedTableIds = {};

  @override
  void initState() {
    super.initState();

    final currentTables =
        widget.state.selectedReservation?.tables ?? [];

    for (var table in currentTables) {
      _temporarySelectedTableIds.add(table.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = widget.state;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              for (var table in currentData.tables)
                table.occupied
                    ? Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.grey.shade100,
                  child: CheckboxListTile(
                    value: false,
                    onChanged: null,
                    title: Text(
                      'Table ${table.tableNumber}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      'Occupée pour ce service',
                      style: TextStyle(color: Colors.red.shade300),
                    ),
                    secondary: Icon(
                      Icons.table_restaurant,
                      color: Colors.grey.shade400,
                    ),
                  ),
                )
                    : Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: _temporarySelectedTableIds.contains(table.id),
                    onChanged: (_) {
                      setState(() {
                        if (_temporarySelectedTableIds.contains(table.id)) {
                          _temporarySelectedTableIds.remove(table.id);
                        } else {
                          _temporarySelectedTableIds.add(table.id);
                        }
                      });
                    },
                    title: Text('Table ${table.tableNumber}'),
                    subtitle: Text('Capacité: ${table.capacity} personnes'),
                    secondary: const Icon(Icons.table_restaurant),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Confirmer la réservation'),
            ),
          ),
        ),
      ],
    );
  }
}
