import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/audio/custom_audio_player.dart';
import 'package:mentour_web_view/ui_kit/widgets/pronunciation/pronunciation_result_card.dart';
import 'package:mentour_web_view/utils/app_icons.dart';

class SpeakingPronunciationTaskItem extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool isExam;

  const SpeakingPronunciationTaskItem({
    super.key,
    required this.task,
    required this.onTap,
    this.isExam = false,
  });

  @override
  State<SpeakingPronunciationTaskItem> createState() =>
      _SpeakingPronunciationTaskItemState();
}

class _SpeakingPronunciationTaskItemState
    extends State<SpeakingPronunciationTaskItem> {
  bool isExpanded = false;

  String showStatusText(String? status) {
    if (status == null || status.isEmpty) {
      return "not_started".tr();
    }

    switch (status) {
      case "PROCESSING":
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

    final isFinished =
        int.parse(
          widget.task.resSpeaking.first.resExerciseQuestion.content.maxTries,
        ) <=
        widget.task.resSpeaking.first.attempts;
    Color iconBgColor;

    if (isCompleted) {
      iconBgColor = Color(0xFF22C55E);
    } else {
      iconBgColor = t.mentourPrimary2;
    }

    return AnimatedContainer(
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

                    const SizedBox(height: 6),

                    /// Coins
                    if (isFinished)
                      Row(
                        children: [
                          Text(
                            "${widget.task.resSpeaking.first.scores.overallScore}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: t.mentourText3,
                            ),
                          ),
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            AppIcons.coin,
                            height: 20,
                            width: 20,
                          ),
                        ],
                      ),
                  ],
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
                    widthFactor:
                        (widget.task.resSpeaking.first.scores.overallScore /
                                100)
                            .clamp(0.0, 1.0),
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
                "${widget.task.resSpeaking.first.scores.overallScore.floor()} %",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: t.mentourPrimary2,
                ),
              ),

              int.parse(
                        widget
                            .task
                            .resSpeaking
                            .first
                            .resExerciseQuestion
                            .content
                            .maxTries,
                      ) <=
                      widget.task.resSpeaking.first.attempts
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
          if (isExpanded &&
              widget.task.resSpeaking.first.studentAudioUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: CustomAudioPlayer(
                audioUrl: widget.task.resSpeaking.first.studentAudioUrl,
                isLocalFile: false,
                onDelete: null,
              ),
            ),
          if (isExpanded &&
              widget
                  .task
                  .resSpeaking
                  .first
                  .aiResponse
                  .processedWords
                  .isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PronunciationResultCard(
                isTaskItemView: false,
                processedWords:
                    widget.task.resSpeaking.first.aiResponse.processedWords,
                overallScore:
                    widget
                        .task
                        .resSpeaking
                        .first
                        .aiResponse
                        .processedWords
                        .isEmpty
                    ? 0.0
                    : widget.task.resSpeaking.first.aiResponse.processedWords
                              .map(
                                (w) => w.pronunciationAssessment.accuracyScore,
                              )
                              .reduce((a, b) => a + b) /
                          widget
                              .task
                              .resSpeaking
                              .first
                              .aiResponse
                              .processedWords
                              .length,
              ),
            ),
        ],
      ),
    );
  }
}
