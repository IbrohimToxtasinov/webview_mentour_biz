import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/course/group_detail_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

class MyGroupsTabContent extends StatelessWidget {
  final List<GroupDetailModel> groupDetails;

  const MyGroupsTabContent({super.key, required this.groupDetails});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "my_group".tr(),
          style: TextStyle(
            color: t.newMentourText3,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        if (groupDetails.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                "No group details available yet.",
                style: TextStyle(color: t.newMentourText4),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final student = groupDetails[index];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.newMentourContainer1,
                  border: Border.all(color: t.newMentourBorder2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.5), // border width
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.mentourBorder1, // border color
                      ),
                      child: CircleAvatar(
                        backgroundImage: student.attachment.path.isNotEmpty
                            ? NetworkImage(student.attachment.path)
                            : null,
                        child: student.attachment.path.isEmpty
                            ? Text(
                          AppUtils.getInitial(student.fullName),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        student.fullName.replaceFirst(' ', '\n'),
                        style: TextStyle(
                          color: t.newMentourText3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${tr("attendance")}: ${student.attendancePercentage}%",
                          style: TextStyle(
                            color: t.newMentourText4,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(width: 4),
                        Text(
                          "${tr("result")}: ${student.resultPercentage}%",
                          style: TextStyle(
                            color: t.newMentourText4,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemCount: groupDetails.length,
          ),
      ],
    );
  }
}