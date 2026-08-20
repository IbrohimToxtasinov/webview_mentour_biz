import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExamTimerCubit extends Cubit<int> with WidgetsBindingObserver {
  Timer? _timer;
  bool _isPaused = false;
  int? _lastBackgroundTicks;
  final Stopwatch _stopwatch = Stopwatch()..start();

  ExamTimerCubit() : super(0) {
    WidgetsBinding.instance.addObserver(this);
  }

  bool get isPaused => _isPaused;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_lastBackgroundTicks == null && !_isPaused && _timer != null) {
        _lastBackgroundTicks = _stopwatch.elapsedMilliseconds;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_lastBackgroundTicks != null && !_isPaused) {
        final passedMilliseconds = _stopwatch.elapsedMilliseconds - _lastBackgroundTicks!;
        final passedSeconds = passedMilliseconds ~/ 1000;
        _lastBackgroundTicks = null;

        if (passedSeconds > 0) {
          if (this.state > passedSeconds) {
            emit(this.state - passedSeconds);
          } else {
            emit(0);
            _timer?.cancel();
          }
        }
      }
    }
  }

  void startTimer(int initialSeconds) {
    _timer?.cancel();
    _isPaused = false;
    _lastBackgroundTicks = null;
    emit(initialSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        emit(state - 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isPaused = true;
  }

  void resumeTimer() {
    if (!_isPaused) return;
    _isPaused = false;
    _lastBackgroundTicks = null;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 0) {
        emit(state - 1);
      } else {
        _timer?.cancel();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _isPaused = false;
    _lastBackgroundTicks = null;
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    return super.close();
  }
}
