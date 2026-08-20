import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/questions/questions_bloc.dart';
import 'package:mentour_web_view/cubits/check_answer/check_answer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
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
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/image/full_screen_image_viewer.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class SectionQuestionsScreen extends StatefulWidget {
  final String taskId;
  final String unitId;
  final String type;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const SectionQuestionsScreen({
    super.key,
    required this.taskId,
    required this.unitId,
    required this.type,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<SectionQuestionsScreen> createState() => _SectionQuestionsScreenState();
}

class _SectionQuestionsScreenState extends State<SectionQuestionsScreen>
    with WidgetsBindingObserver, ExamFreezeObserver {
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

  final PageController _pageController = PageController();
  final ScrollController _numbersScrollController = ScrollController();
  int _currentPage = 0;

  void _scrollToQuestion(int index) {
    if (!_numbersScrollController.hasClients) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 52.0; // 44 + 8 margin
    final padding = 20.0;

    final offset =
        (index * itemWidth) + padding - (screenWidth / 2) + (itemWidth / 2);
    final targetOffset = offset.clamp(
      0.0,
      _numbersScrollController.position.maxScrollExtent,
    );

    _numbersScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _isCurrentFilled = false;
  bool _isTracingActive = false;
  final Map<String, List<String>> _answersByQuestionId = {};
  final Map<String, String?> _selectionAnswersByQuestionId = {};
  final Map<String, Map<String, String>> _matchingAnswersByQuestionId = {};
  final Map<String, Map<String, dynamic>> _tracingAnswersByQuestionId = {};
  final Map<String, String> _fixingAnswersByQuestionId = {};
  final Map<String, bool> _filledByQuestionId = {};
  final Map<String, bool> _submittedByQuestionId = {};
  final Map<String, AudioPlayer> _audioPlayers = {};

  List<Question> _questions = [];
  bool _initialized = false;

  @override
  void dispose() {
    disposeFreezeObserver();
    _pageController.dispose();
    _numbersScrollController.dispose();
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

  void _goToNextPage() {
    int nextUnsubmittedIndex = -1;
    for (int i = _currentPage + 1; i < _questions.length; i++) {
      if (!(_submittedByQuestionId[_questions[i].questionId] ?? false)) {
        nextUnsubmittedIndex = i;
        break;
      }
    }

    if (nextUnsubmittedIndex != -1) {
      _pageController.animateToPage(
        nextUnsubmittedIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final firstUnsubmittedIndex = _questions.indexWhere(
        (q) => !(_submittedByQuestionId[q.questionId] ?? false),
      );
      if (firstUnsubmittedIndex != -1 &&
          firstUnsubmittedIndex != _currentPage) {
        _pageController.animateToPage(
          firstUnsubmittedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _finishExam();
      }
    }
  }

  void _finishExam() {
    Navigator.pushReplacementNamed(
      context,
      AppRouterNames.examExerciseResultRoute,
      arguments: {
        "type": widget.type,
        "unitId": widget.unitId,
        "taskId": widget.taskId,
      },
    );
  }

  void _onFinishPressed() {
    final allSubmitted = _questions.every(
      (q) => _submittedByQuestionId[q.questionId] == true,
    );
    if (allSubmitted) {
      _finishExam();
    } else {
      showOverlayMessage(
        context,
        text: "please_complete_all_questions".tr(),
        status: OverlayStatus.failed,
      );
    }
  }

  Future<void> _saveQuestion(
    Question question,
    BuildContext blocContext,
  ) async {
    for (var player in _audioPlayers.values) {
      try {
        await player.stop();
      } catch (_) {}
    }

    final answers = _answersByQuestionId[question.questionId] ?? [];
    final selectedOptionId = _selectionAnswersByQuestionId[question.questionId];
    final matchingAnswers = _matchingAnswersByQuestionId[question.questionId];
    final questionType = question.type.toUpperCase();

    if (questionType == "GAP_FILL") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForGapFill(
        taskId: widget.taskId,
        questionId: question.questionId,
        answers: answers,
      );
    } else if (questionType == "ORDERING") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForOrdering(
        taskId: widget.taskId,
        questionId: question.questionId,
        answers: answers,
      );
    } else if (questionType == "SELECTION" && selectedOptionId != null) {
      blocContext.read<CheckAnswerCubit>().submitQuestionForSelection(
        taskId: widget.taskId,
        questionId: question.questionId,
        selectedOptionId: selectedOptionId,
      );
    } else if (questionType == "MATCHING" && matchingAnswers != null) {
      blocContext.read<CheckAnswerCubit>().submitQuestionForMatching(
        taskId: widget.taskId,
        questionId: question.questionId,
        matchingPairs: matchingAnswers,
      );
    } else if (questionType == "MULTI_SELECT") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForMultiSelect(
        taskId: widget.taskId,
        questionId: question.questionId,
        multiSelectAnswer: answers,
      );
    } else if (questionType == "CIRCLE") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForCircle(
        taskId: widget.taskId,
        questionId: question.questionId,
        selectedCharIds: answers,
      );
    } else if (questionType == "TRACING") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForTracing(
        taskId: widget.taskId,
        questionId: question.questionId,
        tracingResults: _tracingAnswersByQuestionId[question.questionId] ?? {},
      );
    } else if (questionType == "FIXING_ANSWER") {
      blocContext.read<CheckAnswerCubit>().submitQuestionForFixing(
        taskId: widget.taskId,
        questionId: question.questionId,
        fixingAnswer: _fixingAnswersByQuestionId[question.questionId] ?? "",
      );
    } else {
      _goToNextPage();
    }
  }

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              QuestionsBloc()..add(GetQuestionsByTaskId(taskId: widget.taskId)),
        ),
        BlocProvider(create: (context) => CheckAnswerCubit()),
      ],
      child: BlocConsumer<CheckAnswerCubit, CheckAnswerState>(
        listener: (context, checkState) {
          if (checkState.formStatus == FormStatus.submitGapFillSuccess ||
              checkState.formStatus == FormStatus.submitOrderingSuccess ||
              checkState.formStatus == FormStatus.submitSelectionSuccess ||
              checkState.formStatus == FormStatus.submitMatchingSuccess ||
              checkState.formStatus == FormStatus.submitMultiSelectSuccess ||
              checkState.formStatus == FormStatus.submitCircleSuccess ||
              checkState.formStatus == FormStatus.submitTracingSuccess ||
              checkState.formStatus == FormStatus.submitFixingSuccess) {
            if (_questions.isNotEmpty && _currentPage < _questions.length) {
              setState(() {
                _submittedByQuestionId[_questions[_currentPage].questionId] =
                    true;
              });
            }
            _goToNextPage();
          } else if ((checkState.formStatus ==
                      FormStatus.submitGapFillFailure ||
                  checkState.formStatus == FormStatus.submitOrderingFailure ||
                  checkState.formStatus == FormStatus.submitSelectionFailure ||
                  checkState.formStatus == FormStatus.submitMatchingFailure ||
                  checkState.formStatus ==
                      FormStatus.submitMultiSelectFailure ||
                  checkState.formStatus == FormStatus.submitCircleFailure ||
                  checkState.formStatus == FormStatus.submitTracingFailure ||
                  checkState.formStatus == FormStatus.submitFixingFailure) &&
              checkState.errorMessage.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(checkState.errorMessage)));
          }
        },
        builder: (blocContext, checkState) {
          return WillPopScope(
            onWillPop: () async {
              _onWillPop(context);
              return false;
            },
            child: BlocBuilder<QuestionsBloc, QuestionsState>(
              builder: (context, state) {
                if (state.formStatus ==
                    FormStatus.getQuestionsByTaskIdLoading) {
                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    body: Center(
                      child: Lottie.asset(
                        AppLotties.loader,
                        width: 320,
                        height: 320,
                      ),
                    ),
                  );
                } else if (state.formStatus ==
                    FormStatus.getQuestionsByTaskIdSuccess) {
                  if (!_initialized) {
                    _questions = List.from(state.questionModel.questions);
                    _initialized = true;
                  }

                  if (_questions.isEmpty) {
                    return Scaffold(
                      backgroundColor: t.newMentourBg1,
                      body: Center(child: Text("no_questions".tr())),
                    );
                  }

                  final currentQuestion = _questions[_currentPage];
                  final questionType = currentQuestion.type.toUpperCase();
                  final isSubmitted =
                      _submittedByQuestionId[currentQuestion.questionId] ??
                      false;

                  final isLoading =
                      checkState.formStatus ==
                          FormStatus.submitGapFillLoading ||
                      checkState.formStatus ==
                          FormStatus.submitOrderingLoading ||
                      checkState.formStatus ==
                          FormStatus.submitSelectionLoading ||
                      checkState.formStatus ==
                          FormStatus.submitMatchingLoading ||
                      checkState.formStatus ==
                          FormStatus.submitMultiSelectLoading ||
                      checkState.formStatus == FormStatus.submitCircleLoading ||
                      checkState.formStatus ==
                          FormStatus.submitTracingLoading ||
                      checkState.formStatus == FormStatus.submitFixingLoading;

                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    floatingActionButton: isSubmitted
                        ? null
                        : SizedBox(
                            width: 120,
                            child: MainActionButton(
                              isLoading: isLoading,
                              onTap: () =>
                                  _saveQuestion(currentQuestion, blocContext),
                              label: "save_answer".tr(),
                              labelColor: t.newMentourText9,
                              isGradientButton: true,
                              height: 38,
                              enabled:
                                  !((questionType == "GAP_FILL" ||
                                          questionType == "ORDERING" ||
                                          questionType == "SELECTION" ||
                                          questionType == "MATCHING" ||
                                          questionType == "CIRCLE" ||
                                          questionType == "TRACING" ||
                                          questionType == "MULTI_SELECT" ||
                                          questionType == "FIXING_ANSWER") &&
                                      !_isCurrentFilled),
                            ),
                          ),
                    body: SafeArea(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            top: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 24,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              NewArrowBackButton(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: remainingSeconds < 60
                                                      ? t.mentourError
                                                            .withOpacity(0.1)
                                                      : t.newMentourContainer26,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.timer_outlined,
                                                      size: 18,
                                                      color:
                                                          remainingSeconds < 60
                                                          ? t.mentourError
                                                          : t.newMentourPrimary2,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      timeStr,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            remainingSeconds <
                                                                60
                                                            ? t.mentourError
                                                            : t.newMentourPrimary2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 120,
                                            child: Opacity(
                                              opacity:
                                                  _questions.isNotEmpty &&
                                                      _questions.every(
                                                        (q) =>
                                                            _submittedByQuestionId[q
                                                                .questionId] ==
                                                            true,
                                                      )
                                                  ? 1.0
                                                  : 0.5,
                                              child: MainActionButton(
                                                onTap: _onFinishPressed,
                                                label: "finish".tr(),
                                                labelColor: t.newMentourText9,
                                                isGradientButton: true,
                                                height: 38,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                BlocBuilder<ExamTimerCubit, int>(
                                  builder: (context, remainingSeconds) {
                                    if (_questions.length <= 1) {
                                      return const SizedBox(height: 12);
                                    }
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            controller:
                                                _numbersScrollController,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 20,
                                            ),
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: List.generate(
                                                _questions.length,
                                                (index) => GestureDetector(
                                                  onTap: () {
                                                    if (_submittedByQuestionId[_questions[index]
                                                            .questionId] ??
                                                        false) {
                                                      showOverlayMessage(
                                                        context,
                                                        text: "already_completed_question_n"
                                                            .tr(
                                                              namedArgs: {
                                                                'index':
                                                                    '${index + 1}',
                                                              },
                                                            ),
                                                        status: OverlayStatus
                                                            .disabled,
                                                      );
                                                      return;
                                                    }
                                                    _pageController.jumpToPage(
                                                      index,
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 44,
                                                    height: 44,
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _currentPage == index
                                                          ? t.newMentourPrimary2
                                                          : (_submittedByQuestionId[_questions[index]
                                                                        .questionId] ??
                                                                    false
                                                                ? t.newMentourPrimary6
                                                                : t.newMentourBorder3),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "${index + 1}",
                                                      style: TextStyle(
                                                        color: t.mentourWhite,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
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
                                      itemCount: _questions.length,
                                      onPageChanged: (value) {
                                        final currentFocus = FocusScope.of(
                                          context,
                                        );
                                        if (!currentFocus.hasPrimaryFocus &&
                                            currentFocus.focusedChild != null) {
                                          currentFocus.focusedChild!.unfocus();
                                        }
                                        setState(() {
                                          _currentPage = value;
                                          _scrollToQuestion(value);
                                          final nextQuestion =
                                              _questions[value];
                                          final qType = nextQuestion.type
                                              .toUpperCase();
                                          final isGapFill = qType == "GAP_FILL";
                                          final isOrdering =
                                              qType == "ORDERING";
                                          final isSelection =
                                              qType == "SELECTION";
                                          final isMatching =
                                              qType == "MATCHING";
                                          final isMultiSelect =
                                              qType == "MULTI_SELECT";
                                          final isCircle = qType == "CIRCLE";
                                          final isTracing = qType == "TRACING";
                                          final isFixing =
                                              qType == "FIXING_ANSWER";
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
                                        final question = _questions[index];
                                        return _QuestionPageWrapper(
                                          child: Column(
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
                                                            const SizedBox(
                                                              height: 12,
                                                            ),
                                                          ],
                                                          _buildQuestionBody(
                                                            question,
                                                          ),
                                                          const SizedBox(
                                                            height: 70,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                } else if (state.formStatus ==
                    FormStatus.getQuestionsByTaskIdFailure) {
                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    body: Center(child: Text(state.errorMessage)),
                  );
                } else {
                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    body: Center(child: Text("something_went_wrong".tr())),
                  );
                }
              },
            ),
          );
        },
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
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
          isReadOnly: _submittedByQuestionId[question.questionId] ?? false,
        );
      default:
        return Text(
          question.content.text,
          style: Theme.of(context).textTheme.bodyLarge,
        );
    }
  }
}

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
        const SizedBox(height: 4),
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

class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;

  const _FullScreenImageViewer({required this.imageUrl, required this.heroTag});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _resetAnimController;
  Animation<Matrix4>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetAnimController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 250),
        )..addListener(() {
          _transformationController.value = _resetAnimation!.value;
        });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _resetAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.8,
              maxScale: 6.0,
              panEnabled: true,
              scaleEnabled: true,
              child: Hero(
                tag: widget.heroTag,
                child: Image.network(widget.imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String questionId;
  final Function(AudioPlayer) onPlayerCreated;

  const _CustomAudioPlayer({
    required this.audioUrl,
    required this.questionId,
    required this.onPlayerCreated,
  });

  @override
  State<_CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<_CustomAudioPlayer> {
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    widget.onPlayerCreated(_audioPlayer);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      _audioPlayer.onDurationChanged.listen((d) {
        setState(() => _duration = d);
      });
      _audioPlayer.onPositionChanged.listen((p) {
        setState(() => _position = p);
      });
      _audioPlayer.onPlayerStateChanged.listen((s) {
        setState(() => _isPlaying = s == PlayerState.playing);
      });
      _audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      });
      setState(() {});
    } catch (e) {
      debugPrint("Audio init error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.newMentourContainer15,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: t.newMentourPrimary2,
              size: 40,
            ),
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.resume();
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Slider(
                  min: 0,
                  max: _duration.inMilliseconds.toDouble(),
                  value: _position.inMilliseconds.toDouble().clamp(
                    0,
                    _duration.inMilliseconds.toDouble(),
                  ),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: t.newMentourPrimary2,
                  inactiveColor: t.newMentourPrimary2.withOpacity(0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          color: t.newMentourText4,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: t.newMentourText4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPageWrapper extends StatefulWidget {
  final Widget child;

  const _QuestionPageWrapper({required this.child});

  @override
  State<_QuestionPageWrapper> createState() => _QuestionPageWrapperState();
}

class _QuestionPageWrapperState extends State<_QuestionPageWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
