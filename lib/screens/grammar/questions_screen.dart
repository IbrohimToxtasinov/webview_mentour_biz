import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/questions/questions_bloc.dart';
import 'package:mentour_web_view/cubits/check_answer/check_answer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/screens/grammar/widgets/gap_fill_widget.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/screens/grammar/widgets/ordering_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/selection_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/matching_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/multi_select_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/circle_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/tracing_widget.dart';
import 'package:mentour_web_view/screens/grammar/widgets/fixing_answer_widget.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/audio/custom_audio_player_for_questions.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/image/full_screen_image_viewer.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class ExpandableInstruction extends StatefulWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;
  final int maxLength;

  const ExpandableInstruction({
    super.key,
    required this.text,
    this.maxLength = 50,
    required this.fontWeight,
    required this.fontSize,
  });

  @override
  State<ExpandableInstruction> createState() => _ExpandableInstructionState();
}

class _ExpandableInstructionState extends State<ExpandableInstruction> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = true;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isLong = widget.text.length >= widget.maxLength;
    if (!isLong) {
      return Text(
        widget.text,
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          fontStyle: FontStyle.italic,
          color: t.newMentourText4,
        ),
      );
    }

    final visibleText = _expanded
        ? widget.text
        : "${widget.text.substring(0, widget.maxLength)}...";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          visibleText,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: t.newMentourText4,
          ),
        ),
        SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Text(
            _expanded ? "show_less".tr() : "show_more".tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: t.newMentourPrimary2,
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  final String taskId;
  final String unitId;
  final String type;

  const QuestionsScreen({
    super.key,
    required this.taskId,
    required this.unitId,
    required this.type,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCurrentFilled = false;
  bool _isTracingActive = false; // freezes scroll while finger is on canvas
  final Map<String, List<String>> _answersByQuestionId = {};
  final Map<String, String?> _selectionAnswersByQuestionId = {};
  final Map<String, Map<String, String>> _matchingAnswersByQuestionId = {};
  final Map<String, Map<String, dynamic>> _tracingAnswersByQuestionId = {};
  final Map<String, String> _fixingAnswersByQuestionId = {};
  final Map<String, bool> _filledByQuestionId = {};
  final Map<String, AudioPlayer> _audioPlayers = {};

  @override
  void dispose() {
    _pageController.dispose();
    for (var player in _audioPlayers.values) {
      try {
        player.stop().catchError((_) {});
      } catch (e) {
        debugPrint(e.toString());
      }
      try {
        player.release().catchError((_) {});
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    _audioPlayers.clear();
    super.dispose();
  }

  Future<void> _onWillPop(BuildContext context) async {
    return showExitDialog(
      title: "exit".tr(),
      context: context,
      message: "exit_question_dialog".tr(),
      yesTap: () {
        BlocProvider.of<UnitSectionDetailCubit>(
          context,
        ).getUnitSectionByIdAndType(unitId: widget.unitId, type: widget.type);
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
        backgroundColor: t.newMentourBg1,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                top: 16,
                child: BlocProvider(
                  create: (context) =>
                      QuestionsBloc()
                        ..add(GetQuestionsByTaskId(taskId: widget.taskId)),
                  child: BlocProvider(
                    create: (context) => CheckAnswerCubit(),
                    child: BlocConsumer<CheckAnswerCubit, CheckAnswerState>(
                      listener: (context, checkState) {
                        if (checkState.formStatus ==
                            FormStatus.submitGapFillSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            gapFeedback: checkState.gapFeedback,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitGapFillFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitOrderingSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            gapFeedback: checkState.gapFeedback,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                            orderingFeedback: checkState.orderingFeedback,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitOrderingFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitSelectionSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            gapFeedback: checkState.gapFeedback,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitSelectionFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitMatchingSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitMatchingFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitMultiSelectSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitMultiSelectFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitCircleSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitTracingSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                            FormStatus.submitFixingSuccess) {
                          _showResultBottomSheet(
                            isCorrect: checkState.isCorrect,
                            isLast:
                                _currentPage ==
                                context
                                        .read<QuestionsBloc>()
                                        .state
                                        .questionModel
                                        .questions
                                        .length -
                                    1,
                            percentage: checkState.percentage,
                            coinsEarned: checkState.coinsEarned,
                            message: checkState.message,
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitTracingFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        } else if (checkState.formStatus ==
                                FormStatus.submitFixingFailure &&
                            checkState.errorMessage.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(checkState.errorMessage)),
                          );
                        }
                      },
                      builder: (context, checkState) {
                        return BlocBuilder<QuestionsBloc, QuestionsState>(
                          builder: (context, state) {
                            if (state.formStatus ==
                                FormStatus.getQuestionsByTaskIdLoading) {
                              return Center(
                                child: Lottie.asset(
                                  AppLotties.loader,
                                  width: 320,
                                  height: 320,
                                ),
                              );
                            } else if (state.formStatus ==
                                FormStatus.getQuestionsByTaskIdSuccess) {
                              final questions = state.questionModel.questions;
                              final currentQuestion = questions[_currentPage];
                              final questionType = currentQuestion.type
                                  .toUpperCase();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 24,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        NewArrowBackButton(
                                          onTap: () => Navigator.pop(context),
                                        ),
                                        SizedBox(
                                          width: 120,
                                          child: MainActionButton(
                                            isGradientButton: true,
                                            isLoading:
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitGapFillLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitOrderingLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitSelectionLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitMatchingLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitMultiSelectLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitCircleLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitTracingLoading ||
                                                checkState.formStatus ==
                                                    FormStatus
                                                        .submitFixingLoading,
                                            height: 38,
                                            enabled:
                                                (questionType == "GAP_FILL" ||
                                                    questionType ==
                                                        "ORDERING" ||
                                                    questionType ==
                                                        "SELECTION" ||
                                                    questionType ==
                                                        "MATCHING" ||
                                                    questionType ==
                                                        "MULTI_SELECT" ||
                                                    questionType == "CIRCLE" ||
                                                    questionType == "TRACING" ||
                                                    questionType ==
                                                        "FIXING_ANSWER")
                                                ? _isCurrentFilled
                                                : true,
                                            onTap: () async {
                                              FocusScope.of(context).unfocus();

                                              for (var player
                                                  in _audioPlayers.values) {
                                                try {
                                                  await player.stop();
                                                } catch (_) {}
                                              }

                                              final answers =
                                                  _answersByQuestionId[currentQuestion
                                                      .questionId] ??
                                                  [];
                                              final selectedOptionId =
                                                  _selectionAnswersByQuestionId[currentQuestion
                                                      .questionId];
                                              final matchingAnswers =
                                                  _matchingAnswersByQuestionId[currentQuestion
                                                      .questionId];

                                              if (questionType == "GAP_FILL") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForGapFill(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      answers: answers,
                                                    );
                                              } else if (questionType ==
                                                  "ORDERING") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForOrdering(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      answers: answers,
                                                    );
                                              } else if (questionType ==
                                                      "SELECTION" &&
                                                  selectedOptionId != null) {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForSelection(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      selectedOptionId:
                                                          selectedOptionId,
                                                    );
                                              } else if (questionType ==
                                                      "MATCHING" &&
                                                  matchingAnswers != null) {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForMatching(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      matchingPairs:
                                                          matchingAnswers,
                                                    );
                                              } else if (questionType ==
                                                  "MULTI_SELECT") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForMultiSelect(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      multiSelectAnswer:
                                                          answers,
                                                    );
                                              } else if (questionType ==
                                                  "CIRCLE") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForCircle(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      selectedCharIds: answers,
                                                    );
                                              } else if (questionType ==
                                                  "TRACING") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForTracing(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      tracingResults:
                                                          _tracingAnswersByQuestionId[currentQuestion
                                                              .questionId] ??
                                                          {},
                                                    );
                                              } else if (questionType ==
                                                  "FIXING_ANSWER") {
                                                context
                                                    .read<CheckAnswerCubit>()
                                                    .submitQuestionForFixing(
                                                      taskId: widget.taskId,
                                                      questionId:
                                                          currentQuestion
                                                              .questionId,
                                                      fixingAnswer:
                                                          _fixingAnswersByQuestionId[currentQuestion
                                                              .questionId] ??
                                                          "",
                                                    );
                                              }
                                            },
                                            label: "check".tr(),
                                            labelColor: t.newMentourText9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 16),
                                        if (state
                                                    .questionModel
                                                    .questions
                                                    .length !=
                                                1 &&
                                            state
                                                .questionModel
                                                .questions
                                                .isNotEmpty) ...[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "progress".tr().toUpperCase(),
                                                style: TextStyle(
                                                  color: t.newMentourText5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                "${_currentPage + 1}/${state.questionModel.questions.length}",
                                                style: TextStyle(
                                                  color: t.newMentourText12,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              final totalWidth =
                                                  constraints.maxWidth;
                                              final progressWidth =
                                                  totalWidth *
                                                  ((_currentPage + 1) /
                                                      state
                                                          .questionModel
                                                          .questions
                                                          .length);
                                              return ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Container(
                                                  height: 12,
                                                  width: double.infinity,
                                                  color:
                                                      t.newMentourContainer15,

                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                      width: progressWidth,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                        gradient: LinearGradient(
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight,
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
                                          SizedBox(height: 20),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: PageView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller: _pageController,
                                        itemCount: state
                                            .questionModel
                                            .questions
                                            .length,
                                        onPageChanged: (value) {
                                          // Close keyboard when page changes
                                          FocusScope.of(context).unfocus();

                                          setState(() {
                                            _currentPage = value;
                                            final nextQuestion = state
                                                .questionModel
                                                .questions[value];
                                            final questionType = nextQuestion
                                                .type
                                                .toUpperCase();
                                            final isGapFill =
                                                questionType == "GAP_FILL";
                                            final isOrdering =
                                                questionType == "ORDERING";
                                            final isSelection =
                                                questionType == "SELECTION";
                                            final isMatching =
                                                questionType == "MATCHING";
                                            final isMultiSelect =
                                                questionType == "MULTI_SELECT";
                                            final isCircle =
                                                questionType == "CIRCLE";
                                            final isTracing =
                                                questionType == "TRACING";
                                            final isFixing =
                                                questionType == "FIXING_ANSWER";

                                            _isCurrentFilled =
                                                (isGapFill ||
                                                    isOrdering ||
                                                    isSelection ||
                                                    isMatching ||
                                                    isMultiSelect ||
                                                    isCircle ||
                                                    isTracing ||
                                                    isFixing)
                                                ? (_filledByQuestionId[nextQuestion
                                                          .questionId] ??
                                                      false)
                                                : true;
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final question = state
                                              .questionModel
                                              .questions[index];

                                          return Column(
                                            children: [
                                              /// ===== ATTACHMENT AUDIO (SCROLL EMAS) =====
                                              if (question
                                                      .content
                                                      .attachmentUrl
                                                      .isNotEmpty &&
                                                  question
                                                          .content
                                                          .attachmentUrl !=
                                                      "null" &&
                                                  question
                                                          .content
                                                          .attachmentMediaType
                                                          .toUpperCase() ==
                                                      "AUDIO") ...[
                                                _buildAttachmentAudioWidget(
                                                  question.content,
                                                ),
                                                const SizedBox(height: 10),
                                              ],

                                              /// ===== SCROLL QISMI =====
                                              Expanded(
                                                child: CustomScrollView(
                                                  // Freeze scroll while finger is on tracing canvas.
                                                  physics: _isTracingActive
                                                      ? const NeverScrollableScrollPhysics()
                                                      : null,
                                                  keyboardDismissBehavior:
                                                      ScrollViewKeyboardDismissBehavior
                                                          .onDrag,
                                                  slivers: [
                                                    SliverToBoxAdapter(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (question
                                                                  .content
                                                                  .attachmentUrl
                                                                  .isNotEmpty &&
                                                              question
                                                                      .content
                                                                      .attachmentUrl !=
                                                                  "null" &&
                                                              question
                                                                      .content
                                                                      .attachmentMediaType
                                                                      .toUpperCase() ==
                                                                  "IMAGE") ...[
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            _buildAttachmentImageWidget(
                                                              question.content,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],

                                                          /// ===== INSTRUCTION (EXPANDABLE) =====
                                                          if (question
                                                              .content
                                                              .instruction
                                                              .isNotEmpty) ...[
                                                            ExpandableInstruction(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              text: question
                                                                  .content
                                                                  .instruction,
                                                              maxLength: 100,
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                          ],

                                                          /// ===== QUESTION BODY =====
                                                          _buildQuestionBody(
                                                            question,
                                                          ),
                                                          SizedBox(height: 16),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else if (state.formStatus ==
                                FormStatus.getQuestionsByTaskIdFailure) {
                              return Center(child: Text(state.errorMessage));
                            } else {
                              return Center(
                                child: Text("something_went_wrong".tr()),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentAudioWidget(Content content) {
    return CustomAudioPlayerForQuestions(
      audioUrl: content.attachmentUrl,
      questionId: content.hashCode.toString(),
      onPlayerCreated: (player) {
        _audioPlayers[content.hashCode.toString()] = player;
      },
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

  Widget _buildQuestionBody(Question question) {
    switch (question.type.toUpperCase()) {
      case "GAP_FILL":
        return GapFillWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _answersByQuestionId[question.questionId] = answers;
          },
        );
      case "ORDERING":
        return OrderingWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _answersByQuestionId[question.questionId] = answers;
          },
        );
      case "SELECTION":
        return SelectionWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswerChange: (selectedOptionId) {
            _selectionAnswersByQuestionId[question.questionId] =
                selectedOptionId;
          },
        );
      case "MATCHING":
        return MatchingWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _matchingAnswersByQuestionId[question.questionId] = answers;
          },
        );
      case "MULTI_SELECT":
        return MultiSelectWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _answersByQuestionId[question.questionId] = answers;
          },
        );
      case "CIRCLE":
        return CircleWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _answersByQuestionId[question.questionId] = answers;
          },
        );
      case "TRACING":
        return TracingWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswersChange: (answers) {
            _tracingAnswersByQuestionId[question.questionId] = answers;
          },
          onTracingGestureChanged: (isActive) {
            // Toggle scroll freeze when finger is on/off the canvas
            setState(() => _isTracingActive = isActive);
          },
        );
      case "FIXING_ANSWER":
        return FixingAnswerWidget(
          question: question,
          onFilledChange: (filled) {
            setState(() {
              _isCurrentFilled = filled;
              _filledByQuestionId[question.questionId] = filled;
            });
          },
          onAnswerChange: (answer) {
            _fixingAnswersByQuestionId[question.questionId] = answer;
          },
        );
      default:
        return Text(
          question.content.text,
          style: Theme.of(context).textTheme.bodyLarge,
        );
    }
  }

  Future<void> _showResultBottomSheet({
    required bool isCorrect,
    required bool isLast,
    int? percentage,
    Map<String, bool>? gapFeedback,
    int? coinsEarned,
    String? message,
    List<bool>? orderingFeedback,
  }) async {
    final percentageValue = percentage ?? (isCorrect ? 100 : 0);
    final t = Theme.of(context);

    final sfxPlayer = AudioPlayer();
    try {
      await sfxPlayer.play(
        AssetSource(isCorrect ? 'sounds/success.mp3' : 'sounds/failure.mp3'),
      );
      sfxPlayer.onPlayerComplete.listen((_) {
        sfxPlayer.release().catchError((_) {});
      });
    } catch (e) {
      debugPrint('Sound play error: $e');
    }

    final hasMultipleFeedbacks =
        (gapFeedback != null && gapFeedback.length != 1) ||
        (orderingFeedback != null && orderingFeedback.length != 1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: t.newMentourContainer1,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: t.newMentourContainer1,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      hasMultipleFeedbacks
                          ? 20
                          : isCorrect
                          ? 4
                          : 12,
                      16,
                      16,
                    ),
                    decoration: BoxDecoration(
                      color: t.newMentourContainer1,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasMultipleFeedbacks)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: CircularProgressIndicator(
                                  value: percentageValue / 100,
                                  strokeWidth: 6,
                                  backgroundColor: t.newMentourContainer22,
                                  valueColor: AlwaysStoppedAnimation(
                                    isCorrect
                                        ? t.newMentourPrimary1
                                        : t.newMentourPrimary3,
                                  ),
                                ),
                              ),
                              Text(
                                "$percentageValue%",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: t.newMentourText3,
                                ),
                              ),
                            ],
                          )
                        else
                          isCorrect
                              ? Lottie.asset(
                                  AppLotties.correct,
                                  repeat: false,
                                  width: 100,
                                  height: 100,
                                )
                              : Lottie.asset(
                                  AppLotties.incorrect,
                                  repeat: false,
                                  width: 80,
                                  height: 80,
                                ),
                        SizedBox(
                          width: hasMultipleFeedbacks
                              ? 16
                              : isCorrect
                              ? 2
                              : 8,
                        ),

                        /// TEXTS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCorrect ? "great_job".tr() : "not_quite".tr(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: t.newMentourText3,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                (isCorrect
                                    ? "correct_answer".tr()
                                    : "incorrect_try_again".tr()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: t.newMentourText4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          if (orderingFeedback != null &&
                              orderingFeedback.isNotEmpty &&
                              orderingFeedback.length != 1)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: orderingFeedback.asMap().entries.map((
                                e,
                              ) {
                                return _feedbackItem(
                                  label: "${"part".tr()} ${e.key + 1}",
                                  isCorrect: e.value,
                                  context: context,
                                );
                              }).toList(),
                            )
                          else if (gapFeedback != null &&
                              gapFeedback.isNotEmpty &&
                              gapFeedback.length != 1)
                            Builder(
                              builder: (context) {
                                final sortedEntries =
                                    gapFeedback.entries.toList()..sort((a, b) {
                                      final aKey = int.tryParse(a.key) ?? 0;
                                      final bKey = int.tryParse(b.key) ?? 0;
                                      return aKey.compareTo(bKey);
                                    });

                                return Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: sortedEntries.map((e) {
                                    return _feedbackItem(
                                      label: "${"answer".tr()} ${e.key}",
                                      isCorrect: e.value,
                                      context: context,
                                    );
                                  }).toList(),
                                );
                              },
                            ),

                          SizedBox(height: 24),

                          /// CONTINUE BUTTON
                          StadiumGradientButton(
                            onTap: () {
                              Navigator.pop(context);
                              if (isLast) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouterNames.exerciseResultRoute,
                                  arguments: {
                                    "type": widget.type,
                                    "unitId": widget.unitId,
                                    "taskId": widget.taskId,
                                  },
                                );
                              } else {
                                _goToNextPage();
                              }
                            },
                            label: "continue".tr(),
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _feedbackItem({
    required String label,
    required bool isCorrect,
    required BuildContext context,
  }) {
    final t = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isCorrect ? t.newMentourPrimary1 : t.newMentourPrimary3,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: t.newMentourContainer22,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: t.mentourText3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }
}
