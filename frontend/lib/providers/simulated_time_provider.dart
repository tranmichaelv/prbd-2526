import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_c03/models/simulated_time_state.dart';

final simulatedTimeProvider = NotifierProvider<SimulatedTimeNotifier, SimulatedTimeState>(
      () => SimulatedTimeNotifier(),
);


class SimulatedTimeNotifier extends Notifier<SimulatedTimeState> {
  @override
  SimulatedTimeState build() {
    try {
      getSimulatedTime();
      return SimulatedTimeState();
    } catch (e) {
      throw "Something went wrong!\nPlease try again later.";
    }
  }

  Future<void> getSimulatedTime() async {
    try {
      final current = await SimulatedTimeState.getSimulatedTime();

      state = state.copyWith(
        isLoading: false,
        dateTime: current,
      );

    } catch (e) {
      state = state.copyWith(
        error: "Something went wrong!\nPlease try again later.",
        isLoading: false,
      );
    }
  }

  Future<void> saveSimulatedTime(DateTime newDateTime) async {
    state = state.copyWith(isLoading: true);
    try {

      state = state.copyWith(
        isLoading: false,
        dateTime: newDateTime,
      );

      await SimulatedTimeState.saveSimulatedTime(state.dateTime!);

    } catch (e) {
      state = state.copyWith(
        error: "Something went wrong!\nPlease try again later.",
        isLoading: false,
      );
    }
  }

  Future<void> nullTime() async {
    state = state.copyWith(isLoading: true);
    try {

      state = state.copyWith(
        isLoading: false,
        dateTime: null,
      );

      await SimulatedTimeState.nullSimulatedTime();

    } catch (e) {
      state = state.copyWith(
        error: "Something went wrong!\nPlease try again later.",
        isLoading: false,
      );
    }
  }

}