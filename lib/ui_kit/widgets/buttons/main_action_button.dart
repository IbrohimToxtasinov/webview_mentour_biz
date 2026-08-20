import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class MainActionButton extends StatelessWidget {
  const MainActionButton({
    super.key,
    required this.onTap,
    required this.label,
    this.buttonColor,
    this.height = 48,
    this.width = double.infinity,
    this.padding = EdgeInsets.zero,
    this.labelColor,
    this.disabledColor,
    this.labelFontSize = 18,
    this.enabled = true,
    this.isLoading = false,
    this.isGradientButton = false,
    this.icon,
  });

  final void Function() onTap;
  final String label;
  final double height;
  final double? width;
  final EdgeInsets padding;
  final Widget? icon;
  final bool enabled;
  final bool isGradientButton;
  final bool isLoading;
  final Color? buttonColor;
  final Color? labelColor;
  final Color? disabledColor;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: (enabled && !isLoading) ? onTap : null,
      child: isGradientButton
          ? Container(
              padding: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: buttonColor != null
                    ? buttonColor?.withOpacity(0.7)
                    : t.newMentourPrimary2.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Opacity(
                opacity: enabled ? 1 : 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    color: buttonColor ?? t.newMentourPrimary2,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  width: width,
                  padding: padding,
                  height: height,
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: t.mentourWhite,
                            ),
                          ),
                        )
                      : icon == null
                      ? Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: labelColor ?? t.mentourWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            icon ?? SizedBox(),
                            SizedBox(width: 5),
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: t.newMentourText9,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: enabled
                    ? buttonColor ?? t.mentourPrimary2
                    : (buttonColor ?? disabledColor ?? t.mentourPrimary2)
                          .withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
              width: width,
              padding: padding,
              height: height,
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: t.mentourWhite,
                        ),
                      ),
                    )
                  : icon == null
                  ? Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: labelColor ?? t.mentourWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: labelFontSize,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        icon ?? SizedBox(),
                        SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            color: labelColor ?? t.mentourWhite,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
