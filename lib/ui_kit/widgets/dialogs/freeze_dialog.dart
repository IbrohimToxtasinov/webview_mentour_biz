import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

/// Shows a freeze dialog with a countdown timer.
///
/// When [freezeSeconds] expires the dialog is dismissed automatically.
/// [onExpired] is called AFTER the dialog closes — it should NOT navigate away;
/// just reset state or clear storage.
///
/// The timer automatically **pauses** when the app goes to background while the
/// dialog is visible, and **resumes** when the app comes back to foreground.
Future<void> showFreezeDialog({
  required BuildContext context,
  required int freezeSeconds,

  /// Called when the countdown reaches zero (after dialog is closed).
  /// Do NOT call Navigator.pop() here — the dialog closes itself.
  required VoidCallback onExpired,
  Function(int)? onTick,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _FreezeDialogContent(
      freezeSeconds: freezeSeconds,
      onExpired: onExpired,
      onTick: onTick,
    ),
  );
}

class _FreezeDialogContent extends StatefulWidget {
  final int freezeSeconds;
  final VoidCallback onExpired;
  final Function(int)? onTick;

  const _FreezeDialogContent({
    required this.freezeSeconds,
    required this.onExpired,
    this.onTick,
  });

  @override
  State<_FreezeDialogContent> createState() => _FreezeDialogContentState();
}

class _FreezeDialogContentState extends State<_FreezeDialogContent>
    with WidgetsBindingObserver {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.freezeSeconds;
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // ── Lifecycle — pause timer when app goes to background ───────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App went to background or notification shade pulled down — stop timer
        _pauseCountdown();
      case AppLifecycleState.resumed:
        // App came back to foreground — resume timer
        _resumeCountdown();
      default:
        break;
    }
  }

  // ── Timer control ─────────────────────────────────────────────────────────

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pauseCountdown() {
    _timer?.cancel();
    _timer = null;
  }

  void _resumeCountdown() {
    if (_timer != null) return; // already running
    if (_remaining <= 0) return; // already expired
    _startCountdown();
  }

  void _tick() {
    if (!mounted) {
      _timer?.cancel();
      return;
    }

    if (_remaining <= 1) {
      _timer?.cancel();
      _timer = null;
      setState(() => _remaining = 0);
      widget.onTick?.call(0);

      // Close ONLY the dialog — do not pop any other route
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Notify caller (e.g. clear storage). Caller must NOT navigate away.
      widget.onExpired();
    } else {
      setState(() => _remaining--);
      widget.onTick?.call(_remaining);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isUrgent = _remaining <= 10;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: Container(
          decoration: BoxDecoration(
            color: t.mentourNavigationBarBg,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isUrgent ? Colors.red : Colors.orange).withValues(
                      alpha: 0.12,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_clock_outlined,
                    size: 38,
                    color: isUrgent ? Colors.red : Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'freeze_dialog_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: t.mentourText3,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  'freeze_dialog_message'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: t.mentourText4,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Countdown timer
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: (isUrgent ? Colors.red : Colors.orange).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isUrgent ? Colors.red : Colors.orange).withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 22,
                        color: isUrgent ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(_remaining),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isUrgent ? Colors.red : Colors.orange,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
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
