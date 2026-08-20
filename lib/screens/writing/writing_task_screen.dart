import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/check_answer/check_answer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/writing_task/writing_task_cubit.dart';
import 'package:mentour_web_view/screens/grammar/questions_screen.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/image/full_screen_image_viewer.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';

import '../../data/models/writing/writing_question_model.dart';

class WritingTaskScreen extends StatefulWidget {
  final String taskId;
  final String unitId;

  const WritingTaskScreen({
    super.key,
    required this.taskId,
    required this.unitId,
  });

  @override
  State<WritingTaskScreen> createState() => _WritingTaskScreenState();
}

class _WritingTaskScreenState extends State<WritingTaskScreen> {
  final TextEditingController _controller = TextEditingController();

  int _wordCount = 0;
  bool _canSubmit = false;

  int _countWords(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                                child: Row(
                                  children: [
                                    ArrowBackButton(
                                      onTap: () => _onWillPop(context),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: 120,
                                      child: MainActionButton(
                                        isLoading:
                                            checkState.formStatus ==
                                            FormStatus.submitWritingTaskLoading,
                                        isGradientButton: true,
                                        height: 38,
                                        enabled: _canSubmit,
                                        onTap: () async {
                                          FocusScope.of(context).unfocus();
                                          context
                                              .read<CheckAnswerCubit>()
                                              .submitWritingQuestion(
                                                taskId: widget.taskId,
                                                questionId: question.questionId,
                                                writingText: _controller.text,
                                              );
                                        },
                                        labelFontSize: 14,
                                        label: "finish".tr(),
                                      ),
                                    ),
                                  ],
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
                                        _buildAttachmentImageWidget(
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

  Widget _buildAttachmentImageWidget(Content content) {
    final String heroTag = 'question_image_${content.attachmentUrl.hashCode}';
    final t = Theme.of(context);
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _openFullScreenImage(content.attachmentUrl, heroTag),
            child: Hero(
              tag: heroTag,
              child: Container(
                width: double.infinity,
                height: 200,
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: t.newMentourBg1,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    content.attachmentUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2.5,
                          color: t.newMentourPrimary2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _openFullScreenImage(content.attachmentUrl, heroTag),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenImage(String imageUrl, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, _, _) =>
            FullScreenImageViewer(imageUrl: imageUrl, heroTag: heroTag),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }
}
