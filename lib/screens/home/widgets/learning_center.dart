import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentour_web_view/data/models/profile/profile_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class LearningCenterWidget extends StatelessWidget {
  final SchoolInfo school;

  const LearningCenterWidget({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 13),
          decoration: BoxDecoration(
            color: t.newMentourContainer1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: t.newMentourBorder2),
            image: school.logo.path.isEmpty
                ? null
                : DecorationImage(
                    image: NetworkImage(
                      "https://file.mentour.uz/static/${school.logo.name}",
                    ),
                    fit: BoxFit.cover,
                  ),
          ),
          child: school.logo.path.isEmpty
              ? Center(child: SvgPicture.asset(AppIcons.newLearn))
              : null,
        ),
        SizedBox(width: 16),
        Text(
          school.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: t.newMentourText6,
          ),
        ),
      ],
    );
  }
}
