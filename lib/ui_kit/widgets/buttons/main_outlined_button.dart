import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class MainOutlinedButton extends StatelessWidget {
  const MainOutlinedButton({
    super.key,
    required this.onTap,
    required this.label,
    this.enabled = true,
  });

  final void Function() onTap;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: enabled ? onTap : null,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: t.mentourIconColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: t.mentourIconColor, fontSize: 18),
        ),
      ),
    );
  }
}
