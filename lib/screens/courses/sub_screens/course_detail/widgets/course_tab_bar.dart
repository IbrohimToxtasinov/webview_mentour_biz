import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class CourseTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> tabKeys;

  const CourseTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.tabKeys,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final icons = [AppIcons.newClock, AppIcons.results, AppIcons.groups];

    return Container(
      decoration: BoxDecoration(
        color: t.newMentourContainer1,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: t.newMentourBorder2, width: 1),
      ),
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 8.0;
          final availableWidth = constraints.maxWidth;
          final tabWidth =
              (availableWidth - (spacing * (tabKeys.length - 1))) /
              tabKeys.length;

          return SizedBox(
            height: 40,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  left: currentIndex * (tabWidth + spacing),
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: t.newMentourPrimary2,
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(tabKeys.length, (index) {
                      final isActive = currentIndex == index;
                      return GestureDetector(
                        onTap: () => onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: tabWidth,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? t.mentourWhite
                                        : t.newMentourContainer25,
                                    shape: BoxShape.circle,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: TweenAnimationBuilder<Color?>(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      tween: ColorTween(
                                        begin: isActive
                                            ? t.newMentourText3
                                            : t.newMentourPrimary2,
                                        end: isActive
                                            ? t.newMentourPrimary2
                                            : t.newMentourText3,
                                      ),
                                      builder: (context, color, child) {
                                        return SvgPicture.asset(
                                          icons[index],
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                            color ?? t.newMentourText3,
                                            BlendMode.srcIn,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isActive
                                          ? t.mentourWhite
                                          : t.newMentourText3,
                                    ),
                                    child: Text(
                                      tabKeys[index].tr(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
