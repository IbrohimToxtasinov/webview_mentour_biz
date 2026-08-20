import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/cubits/attendance/attendance_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key});

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  ({String icon, Color iconBgColor, String labelKey, Color textColor})
  _badgeData(String attendanceStatus, ThemeData t) {
    switch (attendanceStatus) {
      case 'PRESENT':
        return (
          icon: AppIcons.newDone,
          iconBgColor: t.newMentourContainer5,
          labelKey: 'attendance_present',
          textColor: t.newMentourPrimary1,
        );
      case 'ABSENT_WITH_REASON':
        return (
          icon: AppIcons.newCross,
          iconBgColor: t.newMentourContainer18,
          labelKey: 'attendance_absent_with_reason',
          textColor: t.newMentourPrimary3,
        );
      case 'ABSENT_NO_REASON':
        return (
          icon: AppIcons.newCross,
          iconBgColor: t.newMentourContainer18,
          labelKey: 'attendance_absent_no_reason',
          textColor: t.newMentourPrimary3,
        );
      case 'ABSENT':
        return (
          icon: AppIcons.newCross,
          iconBgColor: t.newMentourContainer18,
          labelKey: 'attendance_absent_no_reason',
          textColor: t.newMentourPrimary3,
        );
      case 'LATE':
        return (
          icon: AppIcons.newClock,
          iconBgColor: t.newMentourContainer19,
          labelKey: 'attendance_was_late',
          textColor: t.newMentourPrimary4,
        );
      default:
        return (
          icon: AppIcons.newDone,
          iconBgColor: t.newMentourContainer5,
          labelKey: 'not_marked',
          textColor: t.newMentourPrimary1,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return BlocProvider(
      create: (context) => AttendanceCubit()..getLastAttendance(),
      child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state.status == FormStatus.getLastAttendanceSuccess) {
            if (state.attendance.status == 'NOT_MARKED' ||
                !state.attendance.isMarked) {
              return const SizedBox.shrink();
            }

            final badge = _badgeData(state.attendance.status, t);

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.newMentourContainer1,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: t.newMentourBorder2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "attendance".tr().toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: t.newMentourText2,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                padding: EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: badge.iconBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SvgPicture.asset(badge.icon),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    badge.labelKey.tr(),
                                    style: TextStyle(
                                      color: badge.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    AppUtils.newGetFormattedDateTime(
                                      context,
                                      DateTime.parse(
                                        state.attendance.lessonDate,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: t.newMentourText4,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
