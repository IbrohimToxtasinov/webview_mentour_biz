import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/course/course_detail_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

class AttendanceTab extends StatelessWidget {
  final List<Lesson> lessons;

  const AttendanceTab({super.key, required this.lessons});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lessons.isNotEmpty) ...[
          Text(
            "schedule".tr(),
            style: TextStyle(
              color: t.newMentourText3,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _LessonCard(lesson: lessons[index]);
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 6);
            },
            itemCount: lessons.length,
          ),
        ],
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;

  const _LessonCard({required this.lesson});

  ({IconData icon, String labelKey, Color color, Color bgColor})? _badgeData() {
    switch (lesson.attendanceStatus) {
      case 'PRESENT':
        return (
          icon: Icons.check,
          labelKey: 'attendance_present',
          color: const Color(0xFF22C55E),
          bgColor: const Color(0xFF1E2F26),
        );
      case 'ABSENT_WITH_REASON':
      case 'ABSENT_NO_REASON':
      case 'ABSENT':
        return (
          icon: Icons.close,
          labelKey: 'attendance_absent_no_reason',
          color: const Color(0xFFEF4444),
          bgColor: const Color(0xFF352026),
        );
      case 'LATE':
        return (
          icon: Icons.schedule,
          labelKey: 'attendance_was_late',
          color: const Color(0xFFF59E0B),
          bgColor: const Color(0xFF352922),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = _badgeData();

    DateTime sTime = DateTime.parse(lesson.startTime);
    DateTime eTime = sTime.add(Duration(minutes: lesson.durationMinutes));

    final t = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: t.newMentourContainer1,
        border: Border.all(color: t.newMentourBorder2),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: t.newMentourContainer16,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: t.newMentourText10,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              lesson.name,
                              style: TextStyle(
                                color: t.newMentourText3,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badge.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    badge.icon,
                                    size: 14,
                                    fontWeight: FontWeight.w900,
                                    color: badge.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    badge.labelKey.tr(),
                                    style: TextStyle(
                                      color: badge.color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Date and Time Row
                      Row(
                        children: [
                          Icon(
                            fontWeight: FontWeight.w700,
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: t.newMentourText4,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppUtils.getFormattedDateTime(context, sTime),
                            style: TextStyle(
                              color: t.newMentourText4,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.schedule_outlined,
                            fontWeight: FontWeight.w700,
                            size: 14,
                            color: t.newMentourText4,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${DateFormat('HH:mm').format(sTime)} - ${DateFormat('HH:mm').format(eTime)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: t.newMentourText4,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              left: 0,
              top: 24,
              bottom: 24,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: badge.color,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
