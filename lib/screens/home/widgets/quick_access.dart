import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class QuickAccessWidget extends StatelessWidget {
  final String schoolId;

  const QuickAccessWidget({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: t.newMentourContainer1,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.newMentourBorder2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              "quick_access".tr().toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: t.newMentourText2,
              ),
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouterNames.groupsRoute);
                  },
                  bgColor: t.mentourPrimary1,
                  icon: AppIcons.newTasks,
                  label: "tasks".tr(),
                ),
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouterNames.rankingRoute);
                  },
                  bgColor: t.newMentourContainer2,
                  icon: AppIcons.newRanking,
                  label: "ranking".tr(),
                ),
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouterNames.coursesRoute);
                  },
                  bgColor: t.newMentourContainer10,
                  icon: AppIcons.newCourses,
                  label: "courses".tr(),
                ),
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouterNames.coinScoreRoute,
                      arguments: schoolId,
                    );
                  },
                  bgColor: t.newMentourContainer3,
                  icon: AppIcons.newMarket,
                  label: "market".tr(),
                ),
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouterNames.libraryRoute);
                  },
                  bgColor: t.newMentourContainer4,
                  icon: AppIcons.newLibrary,
                  label: "library".tr(),
                ),
                _QuickAccessItem(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouterNames.notificationsRoute,
                    );
                  },
                  bgColor: t.newMentourContainer8,
                  icon: AppIcons.newNotification,
                  label: "notifications".tr(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final String label;
  final String icon;
  final Color bgColor;
  final Function() onTap;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SvgPicture.asset(icon),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).newMentourText3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
