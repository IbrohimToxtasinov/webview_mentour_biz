import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class SoonBadge extends StatelessWidget {
  final Color? bgColor;
  final double textSize;

  const SoonBadge({super.key, this.textSize = 10, this.bgColor});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? t.mentourPrimary1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "soon".tr(),
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.w900,
          color: t.mentourWhite,
        ),
      ),
    );
  }
}
