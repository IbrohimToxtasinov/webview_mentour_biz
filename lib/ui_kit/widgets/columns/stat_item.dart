import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      children: [
        SvgPicture.asset(icon, width: 48, height: 48),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: t.mentourText3,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: t.mentourText4,
          ),
        ),
      ],
    );
  }
}
