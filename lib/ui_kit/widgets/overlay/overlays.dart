import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

void showOverlayMessage(
  BuildContext context, {
  required String text,
  Duration? duration,
  OverlayStatus status = OverlayStatus.failed,
}) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return _OverlaySnackBar(
        status: status,
        duration: duration ?? const Duration(seconds: 4),
        text: text,
        onDismissed: () {
          entry.remove();
        },
      );
    },
  );

  overlay.insert(entry);
}

enum OverlayStatus { success, failed, disabled }

class _OverlaySnackBar extends StatefulWidget {
  const _OverlaySnackBar({
    required this.status,
    required this.duration,
    required this.text,
    required this.onDismissed,
  });

  final OverlayStatus status;

  final Duration duration;

  final String text;

  final VoidCallback onDismissed;

  @override
  State<_OverlaySnackBar> createState() => _OverlaySnackBarState();
}

class _OverlaySnackBarState extends State<_OverlaySnackBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, () {
      widget.onDismissed.call();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Material(
            child: Container(
              color: widget.status == OverlayStatus.failed
                  ? t.mentourError
                  : widget.status == OverlayStatus.disabled
                  ? t.disabledColor
                  : t.mentourPositive,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).mentourWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
