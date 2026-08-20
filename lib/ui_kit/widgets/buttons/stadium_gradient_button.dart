import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class StadiumGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;
  final double height;
  final double width;
  final List<Color>? gradientColors;
  final Color? labelColor;
  final double labelFontSize;
  final IconData? icon;

  const StadiumGradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.enabled = true,
    this.height = 56,
    this.width = double.infinity,
    this.gradientColors,
    this.labelColor,
    this.labelFontSize = 18,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final colors =
        gradientColors ?? [t.newMentourPrimary6, t.newMentourPrimary7];

    return GestureDetector(
      onTap: (enabled && !isLoading) ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors,
            ),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: t.mentourWhite,
                    ),
                  )
                : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: t.mentourWhite),
                      SizedBox(width: 8),
                      Text(
                        label,
                        style: TextStyle(
                          color: labelColor ?? t.mentourWhite,
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: labelColor ?? t.mentourWhite,
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
