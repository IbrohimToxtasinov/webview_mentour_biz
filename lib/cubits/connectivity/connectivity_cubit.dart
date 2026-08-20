import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit()
    : super(ConnectivityState(connectivityResult: ConnectivityResult.mobile)) {
    checkInternet();
  }

  final Connectivity _connectivity = Connectivity();

  void checkInternet() {
    initConnectivity();
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final result = _getPrimaryConnectivityResult(results);
      emit(state.copyWith(connectivityResult: result));
    });
  }

  Future<void> initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }
    final result = _getPrimaryConnectivityResult(results);
    emit(state.copyWith(connectivityResult: result));
  }

  ConnectivityResult _getPrimaryConnectivityResult(
    List<ConnectivityResult> results,
  ) {
    if (results.isEmpty) {
      return ConnectivityResult.none;
    }

    // Remove none from the list
    final activeResults = results
        .where((r) => r != ConnectivityResult.none)
        .toList();

    if (activeResults.isEmpty) {
      return ConnectivityResult.none;
    }

    if (activeResults.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    if (activeResults.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    }
    if (activeResults.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    if (activeResults.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityResult.bluetooth;
    }
    if (activeResults.contains(ConnectivityResult.vpn)) {
      return ConnectivityResult.vpn;
    }

    return activeResults.first;
  }
}
