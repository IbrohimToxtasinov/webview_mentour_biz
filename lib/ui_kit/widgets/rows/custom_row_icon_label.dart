import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';

class CustomRowIconLabel extends StatelessWidget {
  final String icon;
  final String label;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomRowIconLabel({
    super.key,
    this.icon = "",
    required this.label,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return icon.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).mentourIconColor,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
              SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14))),
            ],
          )
        : Text(label, style: TextStyle(fontSize: 16));
  }
}
