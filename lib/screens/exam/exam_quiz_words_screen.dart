import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/vocabulary/vocabulary_bloc.dart';
import 'package:mentour_web_view/cubits/check_vocabulary_answer/check_vocabulary_answer_cubit.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_quiz_word_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class ExamQuizWordsScreen extends StatefulWidget {
  final String setUuid;
  final String unitId;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamQuizWordsScreen({
    super.key,
    required this.setUuid,
    required this.unitId,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<ExamQuizWordsScreen> createState() => _ExamQuizWordsScreenState();
}

class _ExamQuizWordsScreenState extends State<ExamQuizWordsScreen>
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

  @override
  bool get inactiveTriggersFreeze => true;

  final PageController _pageController = PageController();
  final ScrollController _numbersScrollController = ScrollController();
  int _currentPage = 0;

  final Map<int, List<TextEditingController>> _cellControllers = {};
  final Map<int, List<FocusNode>> _cellFocusNodes = {};
  final Map<int, bool> _filledByPage = {};
  final Map<int, ScrollController> _scrollControllers = {};

  final Map<String, bool> _submittedByWordUuid = {};

  List<VocabularyQuizWordModel> _quizWords = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
  }

  @override
  void dispose() {
    disposeFreezeObserver();
    _pageController.dispose();
    _numbersScrollController.dispose();
    for (final list in _cellControllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    for (final list in _cellFocusNodes.values) {
      for (final f in list) {
        f.dispose();
      }
    }
    for (final scrollController in _scrollControllers.values) {
      scrollController.dispose();
    }
    super.dispose();
  }

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

  void _onPageChanged(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentPage = index;
    });
    _scrollToQuestion(index);
  }

  String? _flagForLang(String lang) {
    switch (lang.toUpperCase()) {
      case 'UZ':
        return AppImages.uzFlag;
      case 'RU':
        return AppImages.ruFlag;
      case 'TG':
        return AppImages.tgFlag;
      case 'KY':
        return AppImages.kyFlag;
      case 'KAA':
        return AppImages.kaaFlag;
      default:
        return null;
    }
  }

  static const _zws = '\u200b';

  void _onAnswerChanged(int pageIndex) {
    final controllers = _cellControllers[pageIndex] ?? [];
    final filled = controllers.every(
      (c) => c.text.replaceAll(_zws, '').trim().isNotEmpty,
    );
    setState(() {
      _filledByPage[pageIndex] = filled;
    });
  }

  String _buildAnswer(int pageIndex, String answer) {
    final specialChars = {"’", "‘", "`", '-', '.', "'", ' ', '?'};
    final controllers = _cellControllers[pageIndex] ?? [];
    int cellIdx = 0;
    final buffer = StringBuffer();
    for (int i = 0; i < answer.length; i++) {
      final ch = answer[i];
      if (specialChars.contains(ch)) {
        buffer.write(ch);
      } else {
        if (cellIdx < controllers.length) {
          buffer.write(controllers[cellIdx].text.replaceAll(_zws, ''));
          cellIdx++;
        }
      }
    }
    return buffer.toString();
  }

  Future<void> _onWillPop(BuildContext context) async {
    return showExitDialog(
      title: "exit".tr(),
      context: context,
      message: "exit_question_dialog".tr(),
      yesTap: () {
        BlocProvider.of<UnitSectionDetailCubit>(
          context,
        ).getUnitSectionByIdAndType(unitId: widget.unitId, type: "VOCABULARY");
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      },
    );
  }

  void _goToNextPage() {
    int nextUnsubmittedIndex = -1;
    for (int i = _currentPage + 1; i < _quizWords.length; i++) {
      if (!(_submittedByWordUuid[_quizWords[i].wordUuid] ?? false)) {
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
      final firstUnsubmittedIndex = _quizWords.indexWhere(
        (q) => !(_submittedByWordUuid[q.wordUuid] ?? false),
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
      AppRouterNames.examVocabularyResultRoute,
      arguments: {"setUuid": widget.setUuid, "unitId": widget.unitId},
    );
  }

  void _onFinishPressed() {
    final allSubmitted = _quizWords.every(
      (q) => _submittedByWordUuid[q.wordUuid] == true,
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

  Future<void> _saveAnswer(
    VocabularyQuizWordModel word,
    BuildContext blocContext,
  ) async {
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    final isLastPage = _currentPage == _quizWords.length - 1;
    final typedAnswer = _buildAnswer(_currentPage, word.word);

    blocContext.read<CheckVocabularyAnswerCubit>().submitVocabularyAnswer(
      wordUuid: word.wordUuid,
      answer: typedAnswer.trim(),
      setUuid: widget.setUuid,
      isLast: isLastPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              VocabularyBloc()
                ..add(GetVocabularySetQuizById(setUuid: widget.setUuid)),
        ),
        BlocProvider(create: (context) => CheckVocabularyAnswerCubit()),
      ],
      child: BlocConsumer<CheckVocabularyAnswerCubit, CheckVocabularyAnswerState>(
        listener: (context, checkState) {
          if (checkState.formStatus ==
              FormStatus.submitVocabularyAnswerSuccess) {
            if (_quizWords.isNotEmpty && _currentPage < _quizWords.length) {
              setState(() {
                _submittedByWordUuid[_quizWords[_currentPage].wordUuid] = true;
              });
            }
            _goToNextPage();
          } else if (checkState.formStatus ==
                  FormStatus.submitVocabularyAnswerFailure &&
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
            child: BlocBuilder<VocabularyBloc, VocabularyState>(
              builder: (context, state) {
                if (state.formStatus ==
                    FormStatus.getVocabularySetQuizLoading) {
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
                    FormStatus.getVocabularySetQuizSuccess) {
                  if (!_initialized) {
                    _quizWords = List.from(state.quizWords);
                    _initialized = true;
                  }

                  if (_quizWords.isEmpty) {
                    return Scaffold(
                      backgroundColor: t.newMentourBg1,
                      body: Center(child: Text("no_words_available".tr())),
                    );
                  }

                  final currentWord = _quizWords[_currentPage];
                  final isSubmitted =
                      _submittedByWordUuid[currentWord.wordUuid] ?? false;
                  final isFilled = _filledByPage[_currentPage] ?? false;
                  final isLoading =
                      checkState.formStatus ==
                      FormStatus.submitVocabularyAnswerLoading;

                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    floatingActionButton: isSubmitted
                        ? null
                        : SizedBox(
                            width: 120,
                            child: MainActionButton(
                              onTap: () {
                                if (isFilled && !isLoading) {
                                  _saveAnswer(currentWord, blocContext);
                                }
                              },
                              label: "save_answer".tr(),
                              labelColor: t.newMentourText9,
                              isGradientButton: true,
                              isLoading: isLoading,
                              height: 38,
                              enabled: isFilled,
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
                                                    _onWillPop(context),
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
                                                            .withValues(
                                                              alpha: 0.1,
                                                            )
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
                                                  _quizWords.isNotEmpty &&
                                                      _quizWords.every(
                                                        (q) =>
                                                            _submittedByWordUuid[q
                                                                .wordUuid] ==
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
                                    if (_quizWords.length <= 1) {
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
                                                _quizWords.length,
                                                (index) => GestureDetector(
                                                  onTap: () {
                                                    if (_submittedByWordUuid[_quizWords[index]
                                                            .wordUuid] ??
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
                                                          ? t.newMentourPrimary6
                                                          : (_submittedByWordUuid[_quizWords[index]
                                                                        .wordUuid] ??
                                                                    false
                                                                ? t.newMentourPrimary2.withOpacity(0.5)
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
                                  child: PageView.builder(
                                    controller: _pageController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    onPageChanged: _onPageChanged,
                                    itemCount: _quizWords.length,
                                    itemBuilder: (context, index) {
                                      return _buildQuizWordContent(
                                        context,
                                        _quizWords[index],
                                        index,
                                      );
                                    },
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
                    FormStatus.getVocabularySetQuizFailure) {
                  return Scaffold(
                    backgroundColor: t.newMentourBg1,
                    body: Center(
                      child: Text(
                        state.errorMessage,
                        style: TextStyle(color: t.mentourText3),
                      ),
                    ),
                  );
                }
                return Scaffold(
                  backgroundColor: t.newMentourBg1,
                  body: const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizWordContent(
    BuildContext context,
    VocabularyQuizWordModel word,
    int pageIndex,
  ) {
    final answer = word.word;
    final specialChars = {"’", "‘", "`", '-', '.', "'", ' ', '?'};

    final letterCount = answer.characters
        .where((ch) => !specialChars.contains(ch))
        .length;

    if (!_cellControllers.containsKey(pageIndex)) {
      _cellControllers[pageIndex] = List.generate(
        letterCount,
        (_) => TextEditingController(),
      );
      for (final c in _cellControllers[pageIndex]!) {
        c.addListener(() => _onAnswerChanged(pageIndex));
      }
    }

    if (!_cellFocusNodes.containsKey(pageIndex)) {
      _cellFocusNodes[pageIndex] = List.generate(
        letterCount,
        (_) => FocusNode(),
      );
    }

    final cellControllers = _cellControllers[pageIndex]!;
    final cellFocusNodes = _cellFocusNodes[pageIndex]!;

    final scrollController = _scrollControllers.putIfAbsent(pageIndex, () {
      return ScrollController();
    });

    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "spell_the_word_correctly".tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: t.mentourText3,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // SizedBox(height: 10),
                    // Center(
                    //   child: Container(
                    //     width: 200,
                    //     constraints: BoxConstraints(
                    //       maxHeight: 200,
                    //       maxWidth: 200,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     child: ClipRRect(
                    //       borderRadius: BorderRadius.circular(12),
                    //       child: word.image.isNotEmpty
                    //           ? Image.network(
                    //               word.image,
                    //               fit: BoxFit.cover,
                    //               loadingBuilder:
                    //                   (context, child, loadingProgress) {
                    //                     if (loadingProgress == null) {
                    //                       return child;
                    //                     }
                    //                     return Shimmer.fromColors(
                    //                       baseColor: t.mentourSidebarItem0
                    //                           .withValues(alpha: 0.3),
                    //                       highlightColor: t.mentourSidebarItem1
                    //                           .withValues(alpha: 0.5),
                    //                       child: Container(
                    //                         width: 200,
                    //                         height: 200,
                    //                         decoration: BoxDecoration(
                    //                           color: Theme.of(
                    //                             context,
                    //                           ).mentourSidebarItem0,
                    //                           borderRadius:
                    //                               BorderRadius.circular(12),
                    //                         ),
                    //                       ),
                    //                     );
                    //                   },
                    //               errorBuilder: (context, error, stackTrace) {
                    //                 return Image.asset(AppImages.noImage);
                    //               },
                    //             )
                    //           : Image.asset(AppImages.noImage),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: t.mentourNavigationBarBg,
                        border: Border.all(width: 2, color: t.mentourBorder1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (word.partOfSpeech.isNotEmpty) ...[
                            Text(
                              word.partOfSpeech,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).mentourText3.withValues(alpha: 0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                          ...word.translations
                              .where((lw) => lw.value.isNotEmpty)
                              .map((lw) {
                                final flagPath = _flagForLang(lw.lang);
                                if (flagPath == null) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: t.newMentourBorder1,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(flagPath),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          lw.value,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: t.mentourText3,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _WordCellsInput(
                      answer: answer,
                      cellControllers: cellControllers,
                      cellFocusNodes: cellFocusNodes,
                      onChanged: () => _onAnswerChanged(pageIndex),
                      isSubmitted: _submittedByWordUuid[word.wordUuid] ?? false,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WordCellsInput extends StatefulWidget {
  final String answer;
  final List<TextEditingController> cellControllers;
  final List<FocusNode> cellFocusNodes;
  final VoidCallback onChanged;
  final bool isSubmitted;

  const _WordCellsInput({
    required this.answer,
    required this.cellControllers,
    required this.cellFocusNodes,
    required this.onChanged,
    required this.isSubmitted,
  });

  @override
  State<_WordCellsInput> createState() => _WordCellsInputState();
}

class _WordCellsInputState extends State<_WordCellsInput> {
  static const _specialChars = {"’", "‘", "`", '-', '.', "'", ' ', '?'};

  bool _isSpecial(String ch) => _specialChars.contains(ch);

  static const _zws = '\u200b';

  void _onCellChanged(int cellIndex, String value) {
    if (widget.isSubmitted) return;

    if (value.isEmpty) {
      widget.cellControllers[cellIndex].value = const TextEditingValue(
        text: _zws,
        selection: TextSelection.collapsed(offset: 1),
      );
      final prevIndex = cellIndex - 1;
      if (prevIndex >= 0) {
        widget.cellFocusNodes[prevIndex].requestFocus();
        widget.cellControllers[prevIndex].value = const TextEditingValue(
          text: _zws,
          selection: TextSelection.collapsed(offset: 1),
        );
      }
      widget.onChanged();
      return;
    }

    if (value == _zws) {
      widget.onChanged();
      return;
    }

    final clean = value.replaceAll(_zws, '');

    if (clean.isEmpty) {
      widget.cellControllers[cellIndex].value = const TextEditingValue(
        text: _zws,
        selection: TextSelection.collapsed(offset: 1),
      );
      widget.onChanged();
      return;
    }

    final chars = clean.characters;
    final char = chars.last;

    if (char.runes.length > 1) {
      widget.cellControllers[cellIndex].value = const TextEditingValue(
        text: _zws,
        selection: TextSelection.collapsed(offset: 1),
      );
      widget.onChanged();
      return;
    }

    widget.cellControllers[cellIndex].value = TextEditingValue(
      text: _zws + char,
      selection: TextSelection.collapsed(offset: 2),
    );
    widget.onChanged();

    final nextIndex = cellIndex + 1;
    if (nextIndex < widget.cellFocusNodes.length) {
      widget.cellFocusNodes[nextIndex].requestFocus();
    } else {
      widget.cellFocusNodes[cellIndex].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final answer = widget.answer;

    final List<Widget> rowItems = [];
    int cellIndex = 0;

    for (int i = 0; i < answer.length; i++) {
      final ch = answer[i];
      if (_isSpecial(ch)) {
        if (ch == ' ') {
          rowItems.add(const SizedBox(width: 6));
        } else {
          rowItems.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                ch,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: t.mentourText3,
                ),
              ),
            ),
          );
        }
      } else {
        final idx = cellIndex;
        cellIndex++;
        rowItems.add(
          _LetterCell(
            controller: widget.cellControllers[idx],
            focusNode: widget.cellFocusNodes[idx],
            onChanged: (v) => _onCellChanged(idx, v),
            isSubmitted: widget.isSubmitted,
          ),
        );
      }
    }

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 8,
        children: rowItems,
      ),
    );
  }
}

class _LetterCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isSubmitted;

  const _LetterCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isSubmitted,
  });

  @override
  State<_LetterCell> createState() => _LetterCellState();
}

class _LetterCellState extends State<_LetterCell> {
  static const _zws = '\u200b';

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_enforceSelection);
  }

  void _enforceSelection() {
    if (!widget.focusNode.hasFocus) return;
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    if (text.isNotEmpty &&
        (selection.baseOffset != text.length ||
            selection.extentOffset != text.length)) {
      widget.controller.selection = TextSelection.collapsed(
        offset: text.length,
      );
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_enforceSelection);
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      final text = widget.controller.text;
      if (!text.startsWith(_zws)) {
        final newText = _zws + text;
        widget.controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    } else {
      final text = widget.controller.text;
      if (text.startsWith(_zws)) {
        final clean = text.replaceAll(_zws, '');
        widget.controller.value = TextEditingValue(
          text: clean,
          selection: TextSelection.collapsed(offset: clean.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) {
        final displayText = value.text.replaceAll(_zws, '');
        final isFilled = displayText.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 48,
          decoration: BoxDecoration(
            color: widget.isSubmitted
                ? t.mentourPrimary1.withValues(alpha: 0.2)
                : isFilled
                ? t.mentourPrimary1.withValues(alpha: 0.12)
                : t.mentourNavigationBarBg,
            border: Border.all(
              width: 2,
              color: widget.isSubmitted
                  ? t.mentourPrimary1
                  : widget.focusNode.hasFocus
                  ? t.mentourPrimary1
                  : (isFilled
                        ? t.mentourPrimary1.withValues(alpha: 0.5)
                        : t.mentourBorder1),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              enableSuggestions: false,
              autocorrect: false,
              enabled: !widget.isSubmitted,
              inputFormatters: [NoEmojiInputFormatter()],
              cursorColor: t.mentourPrimary1,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: t.mentourText3,
              ),
              contextMenuBuilder: (context, editableTextState) {
                return const SizedBox.shrink();
              },
              onTap: () {
                final text = widget.controller.text;
                if (text.isNotEmpty) {
                  widget.controller.selection = TextSelection.collapsed(
                    offset: text.length,
                  );
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        );
      },
    );
  }
}
