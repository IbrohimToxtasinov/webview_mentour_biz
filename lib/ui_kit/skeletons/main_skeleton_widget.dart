import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:shimmer/shimmer.dart';

class MainSkeletonWidget extends StatelessWidget {
  const MainSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            Theme.of(context).mentourSidebarItem0,
            Theme.of(context).mentourSidebarItem1,
            Theme.of(context).mentourSidebarItem2,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.7),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _shimmerLine(context, width: 160),
              SizedBox(height: 12),
              _shimmerLine(context, width: 200),
              SizedBox(height: 12),
              _shimmerLine(context, width: 140),
              SizedBox(height: 12),
              _shimmerLine(context, width: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerLine(BuildContext context, {required double width}) {
    return Container(
      height: 16,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
