import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/utils/app_images.dart';

class WritingTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool isExam;

  const WritingTaskItem({
    super.key,
    required this.task,
    this.onTap,
    this.isExam = false,
  });

  @override
  State<WritingTaskItem> createState() => _WritingTaskItemState();
}

class _WritingTaskItemState extends State<WritingTaskItem> {
  bool isExpanded = false;

  String showStatusText(String? status) {
    if (status == null || status.isEmpty) {
      return "not_started".tr();
    }

    switch (status) {
      case "PENDING_REVIEW":
        return "pending_review".tr();

      case "GRADED":
        return "graded".tr();

      default:
        return "not_started".tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isCompleted = widget.task.percentages == 100;
    final isGraded = widget.task.resWriting.first.status == "GRADED";

    Color iconBgColor;

    if (isCompleted) {
      iconBgColor = Color(0xFF22C55E);
    } else {
      iconBgColor = t.mentourPrimary2;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.mentourNavigationBarBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.mentourBorder1, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= TOP ROW =================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                /// STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: t.mentourBorder1,
                  ),
                  child: Text(
                    showStatusText(widget.task.resWriting.first.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.mentourText3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ================= PROGRESS =================
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(width: double.infinity, color: t.mentourContainer1),
                    FractionallySizedBox(
                      widthFactor: (widget.task.percentages / 100).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              t.mentourPrimary2,
                              t.mentourPrimary2.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// ================= BOTTOM ROW =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.task.resWriting.first.score.floor()} %",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: t.mentourPrimary2,
                  ),
                ),

                widget.task.resWriting.first.status == "GRADED"
                    ? AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: isExpanded ? 0.5 : 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 28,
                            color: isExpanded
                                ? t.mentourPrimary2
                                : t.mentourText4,
                          ),
                        ),
                      )
                    : widget.task.resWriting.first.status == "PENDING_REVIEW"
                    ? SizedBox()
                    : GestureDetector(
                        onTap: (widget.isExam && widget.task.answeredAll)
                            ? null
                            : widget.onTap,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: (widget.isExam && widget.task.answeredAll)
                                ? const Color(0xFF22C55E)
                                : iconBgColor,
                          ),
                          child: Center(
                            child: (widget.isExam && widget.task.answeredAll)
                                ? Icon(Icons.check, color: t.mentourWhite)
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

            /// ================= Student Answer =================
            if (isGraded &&
                isExpanded &&
                widget.task.resWriting.first.studentAnswer.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: t.mentourBg1,
                  border: Border.all(color: t.mentourBorder1, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.task.resWriting.first.studentAnswer,
                        style: TextStyle(color: t.mentourText3),
                      ),
                    ),
                  ],
                ),
              ),

            /// ================= TEACHER FEEDBACK =================
            if (isGraded &&
                isExpanded &&
                widget.task.resWriting.first.previousFeedback.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: t.mentourBg1,
                  border: Border.all(color: t.mentourBorder1, width: 2),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.task.resWriting.first.previousFeedback,
                        style: TextStyle(color: t.mentourText3),
                      ),
                    ),
                  ],
                ),
              ),

            /// Coins & Score
            if (isExpanded && isGraded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7.5,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: t.newMentourContainer1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: t.newMentourBorder2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              padding: EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 6,
                              ),
                              decoration: BoxDecoration(
                                color: t.newMentourContainer6,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Lottie.asset(AppLotties.coin, repeat: false),
                              // child: SvgPicture.asset(AppIcons.newCoin),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "COINS",
                                  style: TextStyle(
                                    color: t.newMentourText4,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  widget.task.resWriting.first.coinsAwarded
                                      .toString(),
                                  style: TextStyle(
                                    color: t.newMentourText3,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 26),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7.5,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: t.newMentourContainer1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: t.newMentourBorder2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: t.newMentourContainer6,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Lottie.asset(
                                AppLotties.score,
                                repeat: false,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SCORE",
                                  style: TextStyle(
                                    color: t.newMentourText4,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  widget.task.resWriting.first.score.toString(),
                                  style: TextStyle(
                                    color: t.newMentourText3,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
