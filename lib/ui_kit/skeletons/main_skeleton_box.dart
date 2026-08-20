import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class MainSkeletonBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius? radius;
  final bool isHaveBorder;

  const MainSkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.radius,
    this.isHaveBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: t.newMentourContainer1,
        borderRadius: radius ?? BorderRadius.circular(8),
        border: isHaveBorder
            ? Border.all(color: t.newMentourBorder1, width: 1.0)
            : null,
      ),
    );
  }
}
