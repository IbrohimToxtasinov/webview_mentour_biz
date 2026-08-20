import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/check_answer/check_answer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/cubits/writing_task/writing_task_cubit.dart';
import 'package:mentour_web_view/screens/grammar/questions_screen.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

import '../../data/models/writing/writing_question_model.dart';

class ExamWritingTaskScreen extends StatefulWidget {
  final String taskId;
  final String unitId;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamWritingTaskScreen({
    super.key,
    required this.taskId,
    required this.unitId,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<ExamWritingTaskScreen> createState() => _ExamWritingTaskScreenState();
}

class _ExamWritingTaskScreenState extends State<ExamWritingTaskScreen>
    with WidgetsBindingObserver, ExamFreezeObserver {
  final TextEditingController _controller = TextEditingController();

  int _wordCount = 0;
  bool _canSubmit = false;

  @override
  bool get freezeEnabled => widget.freezeScreen;

  @override
  bool get noScreenshot => widget.noScreenshot;

  @override
  String get freezeIdentifier => widget.unitId;

  @override
  int get freezeTimerSeconds =>
      widget.freezeTimer > 0 ? widget.freezeTimer : 30;

  @override
  void onFreezeExpired() {
    // Dialog closes itself — nothing else needed here.
  }

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
  }

  @override
  void dispose() {
    disposeFreezeObserver();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onWillPop(BuildContext context) async {
    return showExitDialog(
      title: "exit".tr(),
      context: context,
      message: "exit_question_dialog".tr(),
      yesTap: () {
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _onWillPop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: t.mentourBg1,
        body: SafeArea(
          child: BlocProvider(
            create: (context) =>
                WritingTaskCubit()..getWritingQuestion(taskId: widget.taskId),
            child: BlocProvider(
              create: (context) => CheckAnswerCubit(),
              child: BlocConsumer<CheckAnswerCubit, CheckAnswerState>(
                listener: (context, checkState) {
                  if (checkState.formStatus ==
                      FormStatus.submitWritingTaskSuccess) {
                    context
                        .read<UnitSectionDetailCubit>()
                        .getUnitSectionByIdAndType(
                          unitId: widget.unitId,
                          type: "WRITING",
                        );
                    showOverlayMessage(
                      context,
                      status: OverlayStatus.success,
                      text:
                          checkState.message ??
                          "Successfully sent your writing answer!",
                    );
                    Navigator.of(context).pop(true);
                  } else if (checkState.formStatus ==
                          FormStatus.submitWritingTaskFailure &&
                      checkState.errorMessage.isNotEmpty) {
                    showOverlayMessage(context, text: checkState.errorMessage);
                  }
                },
                builder: (context, checkState) {
                  return BlocBuilder<WritingTaskCubit, WritingTaskState>(
                    builder: (context, state) {
                      if (state.formStatus ==
                          FormStatus.getWritingQuestionLoading) {
                        return Center(
                          child: Lottie.asset(
                            AppLotties.loader,
                            width: 320,
                            height: 320,
                          ),
                        );
                      } else if (state.formStatus ==
                          FormStatus.getWritingQuestionSuccess) {
                        final question = state.questionModel.questions.first;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: BlocBuilder<ExamTimerCubit, int>(
                                  builder: (context, remainingSeconds) {
                                    final hours = remainingSeconds ~/ 3600;
                                    final minutes =
                                        (remainingSeconds % 3600) ~/ 60;
                                    final seconds = remainingSeconds % 60;
                                    final timeStr = hours > 0
                                        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                                    return Row(
                                      children: [
                                        NewArrowBackButton(
                                          onTap: () => _onWillPop(context),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: remainingSeconds < 60
                                                ? t.mentourError.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : t.newMentourContainer26,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 18,
                                                color: remainingSeconds < 60
                                                    ? t.mentourError
                                                    : t.newMentourPrimary2,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                timeStr,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: remainingSeconds < 60
                                                      ? t.mentourError
                                                      : t.newMentourPrimary2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 120,
                                          child: MainActionButton(
                                            isLoading:
                                                checkState.formStatus ==
                                                FormStatus
                                                    .submitWritingTaskLoading,
                                            isGradientButton: true,
                                            height: 38,
                                            enabled: _canSubmit,
                                            onTap: () async {
                                              FocusScope.of(context).unfocus();
                                              context
                                                  .read<CheckAnswerCubit>()
                                                  .submitWritingQuestion(
                                                    taskId: widget.taskId,
                                                    questionId:
                                                        question.questionId,
                                                    writingText:
                                                        _controller.text,
                                                  );
                                            },
                                            labelFontSize: 14,
                                            label: "finish".tr(),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: t.mentourNavigationBarBg,
                                          border: Border.all(
                                            color: t.mentourBorder1,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          question.content.instruction.isEmpty
                                              ? question.instruction
                                              : question.content.instruction,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: t.mentourText3,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (question
                                              .content
                                              .attachmentUrl
                                              .isNotEmpty &&
                                          question
                                              .content
                                              .attachmentUrl
                                              .isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        _buildAttachmentWidget(
                                          question.content,
                                        ),
                                      ],
                                      const SizedBox(height: 10),

                                      /// ---------------- INSTRUCTION ----------------
                                      if (question
                                          .content
                                          .writingQuestion
                                          .isNotEmpty) ...[
                                        ExpandableInstruction(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          text:
                                              question.content.writingQuestion,
                                          maxLength: 100,
                                        ),
                                        SizedBox(height: 10),
                                      ],

                                      SizedBox(
                                        height: 300,
                                        child: TextField(
                                          autocorrect: false,
                                          inputFormatters: [
                                            NoEmojiInputFormatter(),
                                          ],
                                          contextMenuBuilder:
                                              (context, editableTextState) {
                                                return const SizedBox.shrink();
                                              },
                                          maxLines: null,
                                          textInputAction:
                                              TextInputAction.newline,
                                          keyboardType: TextInputType.multiline,
                                          expands: true,
                                          controller: _controller,
                                          enableSuggestions: false,
                                          cursorColor: t.mentourPrimary2,
                                          cursorWidth: 1.5,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          style: const TextStyle(fontSize: 15),
                                          // maxLength: 3000,
                                          buildCounter:
                                              (
                                                _, {
                                                required currentLength,
                                                maxLength,
                                                required isFocused,
                                              }) {
                                                return null;
                                              },

                                          // inputFormatters: [
                                          //   LengthLimitingTextInputFormatter(
                                          //     3000,
                                          //   ),
                                          // ],
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "type_here".tr(),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            filled: true,
                                            fillColor: t.mentourNavigationBarBg,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: t.mentourBorder1,
                                                width: 2,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: t.mentourBorder1,
                                                width: 2,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: t.mentourPrimary2,
                                                width: 2,
                                              ),
                                            ),
                                          ),

                                          onChanged: (value) {
                                            final count = _countWords(value);

                                            setState(() {
                                              _wordCount = count;
                                              _canSubmit =
                                                  count >=
                                                  question.content.minWords;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      /// ---------------- WORD COUNTER ----------------
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${tr("minimum").substring(0, 3)}: ${question.content.minWords} ${tr("words")}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            "$_wordCount ${tr("words")}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              color: t.mentourPrimary2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 50),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state.formStatus ==
                          FormStatus.getWritingQuestionFailure) {
                        return Center(child: Text(state.errorMessage));
                      } else {
                        return Center(child: Text("something_went_wrong".tr()));
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentWidget(Content content) {
    final mediaType = content.attachmentMediaType.toUpperCase();
    if (mediaType == "IMAGE") {
      final t = Theme.of(context);
      return Center(
        child: Container(
          width: 300,
          constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              content.attachmentUrl,
              width: double.infinity,
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 300,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: t.mentourPrimary2,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                );
              },
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
