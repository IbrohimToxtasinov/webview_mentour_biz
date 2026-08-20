import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool isExam;

  const TaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.isExam = false,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.newMentourContainer1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.newMentourBorder2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.task.title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  "${widget.task.totalQuestions} ${tr("questions")}",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: t.mentourText4,
                  ),
                ),
                SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;
                    final progressWidth =
                        totalWidth * (widget.task.percentages / 100);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 8,
                        width: double.infinity,
                        color: t.newMentourContainer14,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: progressWidth,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0XFF2D60FF), Color(0XFFB7C4FF)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(4),
                //   child: SizedBox(
                //     height: 8,
                //     child: Stack(
                //       children: [
                //         Container(
                //           color: progressBgColor,
                //           width: double.infinity,
                //         ),
                //         FractionallySizedBox(
                //           widthFactor: progress.clamp(0.0, 1.0),
                //           child: Container(color: progressColor),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: widget.task.percentages == 0 ? 0.5 : 1,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0XFF2D60FF), Color(0XFFB7C4FF)],
                  ).createShader(bounds),
                  child: Text(
                    "${(widget.task.percentages).toInt()}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: t.mentourWhite,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: (widget.isExam && widget.task.answeredAll)
                    ? null
                    : widget.onTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: t.newMentourPrimary2,
                  ),
                  child: Center(
                    child: (widget.isExam && widget.task.answeredAll)
                        ? SvgPicture.asset(
                            AppIcons.check,
                            colorFilter: ColorFilter.mode(
                              t.mentourWhite,
                              BlendMode.srcIn,
                            ),
                          )
                        : Icon(
                            Icons.play_arrow_rounded,
                            color: t.mentourWhite,
                            size: 24,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
