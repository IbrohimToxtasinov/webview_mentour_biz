import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class NewArrowBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? color;

  const NewArrowBackButton({super.key, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.transparent,
        child: SvgPicture.asset(
          AppIcons.newArrowLeft,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
