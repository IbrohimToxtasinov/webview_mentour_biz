import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/course/course_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

class CourseCardWidget extends StatelessWidget {
  final CourseModel courseModel;
  final Function()? onTap;

  const CourseCardWidget({super.key, required this.courseModel, this.onTap});

  String _getCourseBg() {
    final subject = courseModel.resGroup.level.subjectName.toLowerCase();
    switch (true) {
      case true when subject.contains('english'):
        return AppImages.englishCourseBg;
      case true when subject.contains('german'):
        return AppImages.germanCourseBg;
      case true when subject.contains('math'):
        return AppImages.mathCourseBg;
      case true when subject.contains('russian'):
        return AppImages.russianCourseBg;
      default:
        return AppImages.courseBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(_getCourseBg(), fit: BoxFit.cover),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: t.brightness == Brightness.light
                        ? [
                            t.mentourBlack.withOpacity(0.3),
                            t.mentourBlack.withOpacity(0.5),
                            t.mentourBlack.withOpacity(0.7),
                            t.mentourBlack.withOpacity(0.8),
                          ]
                        : [
                            t.mentourBlack.withOpacity(0.5),
                            t.mentourBlack.withOpacity(0.8),
                            t.mentourBlack.withOpacity(0.9),
                            t.mentourBlack.withOpacity(0.95),
                          ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppUtils.levelColors(
                            courseModel.resGroup.level.level,
                          ),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: Text(
                          "${courseModel.resGroup.level.subjectName.toUpperCase()} / ${courseModel.resGroup.level.level.toUpperCase()}",
                          style: TextStyle(
                            color: t.mentourWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.mentourWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: Text(
                          courseModel.currentUnitOutOf.toUpperCase(),
                          style: TextStyle(
                            color: t.mentourWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    courseModel.courseName,
                    style: TextStyle(
                      color: t.mentourWhite,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    courseModel.description,
                    style: TextStyle(
                      color: t.mentourWhite.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    courseModel.resGroup.name,
                    style: TextStyle(
                      color: t.mentourWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "average_score".tr(),
                        style: TextStyle(
                          color: t.newMentourText10,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0XFF2D60FF), Color(0XFFB7C4FF)],
                        ).createShader(bounds),
                        child: Text(
                          "${courseModel.unitProgresses.floor()}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: t.mentourWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth = constraints.maxWidth;
                      final progressWidth =
                          totalWidth *
                          (courseModel.unitProgresses.floor() / 100);
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 12,
                          width: double.infinity,
                          color: t.newMentourContainer15,

                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: progressWidth,
                              height: 12,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    t.newMentourPrimary5,
                                    t.newMentourPrimary2,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.white.withOpacity(0.1), height: 1),
                  const SizedBox(height: 20),
                  // Instructor
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF8C42), Color(0xFFFF6B35)],
                          ),
                          border: Border.all(color: t.newMentourBorder1),
                        ),
                        child: Center(
                          child: Text(
                            AppUtils.getInitial(
                              courseModel.resGroup.teacherFullName,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        courseModel.resGroup.teacherFullName,
                        style: TextStyle(
                          color: t.mentourWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
