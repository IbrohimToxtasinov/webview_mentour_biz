import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class ArrowBackButton extends StatelessWidget {
  final Function()? onTap;

  const ArrowBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          border: Border.all(color: t.mentourBorder1, width: 2),
          shape: BoxShape.circle,
          color: t.mentourNavigationBarBg,
        ),
        child: Center(
          child: Icon(Icons.arrow_back_rounded, color: t.mentourPrimary2),
        ),
      ),
    );
  }
}
