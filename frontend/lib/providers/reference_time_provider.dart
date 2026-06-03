import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/providers/simulated_time_provider.dart';

final referenceTimeProvider = Provider((ref) => ref.watch(simulatedTimeProvider).dateTime ?? DateTime.now());
