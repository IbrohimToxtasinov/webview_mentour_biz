import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/vocabulary/vocabulary_bloc.dart';
import 'package:mentour_web_view/cubits/check_vocabulary_answer/check_vocabulary_answer_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_quiz_word_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_icons.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/utils/helpers/no_emoji_input_formatter.dart';

class QuizWordsScreen extends StatefulWidget {
  final String setUuid;
  final String unitId;

  const QuizWordsScreen({
    super.key,
    required this.setUuid,
    required this.unitId,
  });

  @override
  State<QuizWordsScreen> createState() => _QuizWordsScreenState();
}

class _QuizWordsScreenState extends State<QuizWordsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final Map<int, List<TextEditingController>> _cellControllers = {};

  final Map<int, List<FocusNode>> _cellFocusNodes = {};
  final Map<int, bool> _filledByPage = {};
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void dispose() {
    _pageController.dispose();
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

  void _onPageChanged(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      _currentPage = index;
    });
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
        BlocProvider.of<VocabularyDetailCubit>(
          context,
        ).getVocabularyDetail(unitId: widget.unitId);
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop(context);
        return false;
      },
      child: BlocProvider(
        create: (context) =>
            VocabularyBloc()
              ..add(GetVocabularySetQuizById(setUuid: widget.setUuid)),
        child: Builder(
          builder: (context) {
            final t = Theme.of(context);
            return Scaffold(
              backgroundColor: t.mentourBg1,
              body: SafeArea(
                child: Stack(
                  children: [
                    Positioned.fill(
                      top: 60,
                      child: BlocBuilder<VocabularyBloc, VocabularyState>(
                        builder: (context, state) {
                          if (state.formStatus ==
                              FormStatus.getVocabularySetQuizLoading) {
                            return Center(
                              child: Lottie.asset(
                                AppLotties.loader,
                                width: 320,
                                height: 320,
                              ),
                            );
                          } else if (state.formStatus ==
                              FormStatus.getVocabularySetQuizSuccess) {
                            if (state.quizWords.isEmpty) {
                              return Center(
                                child: Text(
                                  "no_words_available".tr(),
                                  style: TextStyle(color: t.mentourText3),
                                ),
                              );
                            }
                            return PageView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemCount: state.quizWords.length,
                              itemBuilder: (context, index) {
                                return _buildQuizWordContent(
                                  context,
                                  state.quizWords[index],
                                  index,
                                );
                              },
                            );
                          } else if (state.formStatus ==
                              FormStatus.getVocabularySetQuizFailure) {
                            return Center(
                              child: Text(
                                state.errorMessage,
                                style: TextStyle(color: t.mentourText3),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: t.mentourBg1),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Center: page counter
                            BlocBuilder<VocabularyBloc, VocabularyState>(
                              builder: (context, state) {
                                if (state.formStatus !=
                                    FormStatus.getVocabularySetQuizSuccess) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  "${_currentPage + 1} ${"of".tr()} ${state.quizWords.length}",
                                  style: TextStyle(
                                    color: t.mentourText3,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            // Left: back button
                            Positioned(
                              left: 0,
                              child: ArrowBackButton(
                                onTap: () async {
                                  _onWillPop(context);
                                },
                              ),
                            ),
                            // Right: check button
                            Positioned(
                              right: 0,
                              child: BlocBuilder<VocabularyBloc, VocabularyState>(
                                builder: (context, state) {
                                  if (state.formStatus !=
                                          FormStatus
                                              .getVocabularySetQuizSuccess ||
                                      state.quizWords.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final isLastPage =
                                      _currentPage ==
                                      state.quizWords.length - 1;
                                  final isFilled =
                                      _filledByPage[_currentPage] ?? false;
                                  return BlocProvider(
                                    key: ValueKey('check_vocab_$_currentPage'),
                                    create: (context) =>
                                        CheckVocabularyAnswerCubit(),
                                    child:
                                        BlocConsumer<
                                          CheckVocabularyAnswerCubit,
                                          CheckVocabularyAnswerState
                                        >(
                                          listener: (context, answerState) {
                                            if (answerState.formStatus ==
                                                FormStatus
                                                    .submitVocabularyAnswerSuccess) {
                                              _showResultBottomSheet(
                                                context: context,
                                                isCorrect:
                                                    answerState.isCorrect,
                                                isLast: answerState.isLast,
                                                percentage:
                                                    answerState.percentage,
                                                coinsEarned:
                                                    answerState.coinsEarned,
                                                message: answerState.message,
                                              );
                                            } else if (answerState.formStatus ==
                                                FormStatus
                                                    .submitVocabularyAnswerFailure) {
                                              showOverlayMessage(
                                                context,
                                                text: answerState.errorMessage,
                                              );
                                            }
                                          },
                                          builder: (context, answerState) {
                                            final isLoading =
                                                answerState.formStatus ==
                                                FormStatus
                                                    .submitVocabularyAnswerLoading;
                                            return SizedBox(
                                              width: 120,
                                              child: MainActionButton(
                                                isGradientButton: true,
                                                height: 36,
                                                isLoading: isLoading,
                                                enabled: isFilled && !isLoading,
                                                onTap: () {
                                                  if (!isFilled || isLoading) {
                                                    return;
                                                  }
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus();
                                                  final currentWord = state
                                                      .quizWords[_currentPage];
                                                  final typedAnswer =
                                                      _buildAnswer(
                                                        _currentPage,
                                                        currentWord.word,
                                                      );
                                                  context
                                                      .read<
                                                        CheckVocabularyAnswerCubit
                                                      >()
                                                      .submitVocabularyAnswer(
                                                        wordUuid: currentWord
                                                            .wordUuid,
                                                        answer: typedAnswer
                                                            .trim(),
                                                        setUuid: widget.setUuid,
                                                        isLast: isLastPage,
                                                      );
                                                },
                                                icon: SvgPicture.asset(
                                                  AppIcons.check,
                                                  colorFilter: ColorFilter.mode(
                                                    t.mentourWhite,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                label: "check".tr(),
                                              ),
                                            );
                                          },
                                        ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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

    // Initialize cell focus nodes
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
                        fontSize: 18,
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
                    //                           .withOpacity(0.3),
                    //                       highlightColor: t.mentourSidebarItem1
                    //                           .withOpacity(0.5),
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
                    // Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
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
                                fontSize: 18,
                                color: Theme.of(
                                  context,
                                ).mentourText3.withOpacity(0.7),
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
                                        width: 30,
                                        height: 30,
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
                                            fontSize: 20,
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

  Future<void> _showResultBottomSheet({
    required BuildContext context,
    required bool isCorrect,
    required bool isLast,
    int? percentage,
    int? coinsEarned,
    String? message,
  }) async {
    final t = Theme.of(context);

    final sfxPlayer = AudioPlayer();
    try {
      await sfxPlayer.play(
        AssetSource(isCorrect ? 'sounds/success.mp3' : 'sounds/failure.mp3'),
      );
      await HapticFeedback.vibrate();
      sfxPlayer.onPlayerComplete.listen((_) {
        sfxPlayer.release().catchError((_) {});
      });
    } catch (e) {
      debugPrint('Sound play error: $e');
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
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
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                    decoration: BoxDecoration(
                      color: t.newMentourContainer1,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          isCorrect ? AppLotties.correct : AppLotties.incorrect,
                          repeat: false,
                          width: 70,
                          height: 70,
                        ),

                        SizedBox(width: 16),

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
                  SizedBox(height: 15),

                  /// CONTINUE BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: StadiumGradientButton(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (isLast) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouterNames.vocabularyResultRoute,
                            arguments: {
                              "setUuid": widget.setUuid,
                              "unitId": widget.unitId,
                            },
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      label: "continue".tr(),
                      height: 50,
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
}

class _WordCellsInput extends StatefulWidget {
  final String answer;
  final List<TextEditingController> cellControllers;
  final List<FocusNode> cellFocusNodes;
  final VoidCallback onChanged;

  const _WordCellsInput({
    required this.answer,
    required this.cellControllers,
    required this.cellFocusNodes,
    required this.onChanged,
  });

  @override
  State<_WordCellsInput> createState() => _WordCellsInputState();
}

class _WordCellsInputState extends State<_WordCellsInput> {
  static const _specialChars = {"’", "‘", "`", '-', '.', "'", ' ', '?'};

  /// Returns true for separators that should be rendered between cells.
  bool _isSpecial(String ch) => _specialChars.contains(ch);

  static const _zws = '\u200b';

  void _onCellChanged(int cellIndex, String value) {
    if (value.isEmpty) {
      // Cell is empty: backspace on an empty cell. Move to previous cell.
      widget.cellControllers[cellIndex].value = const TextEditingValue(
        text: _zws,
        selection: TextSelection.collapsed(offset: 1),
      );
      final prevIndex = cellIndex - 1;
      if (prevIndex >= 0) {
        widget.cellFocusNodes[prevIndex].requestFocus();
        // Clear previous cell for proper backspace behavior
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

    // Use .characters to safely get the last grapheme cluster.
    // This is critical on iOS: emoji are multi-codepoint and naively
    // indexing with clean[clean.length - 1] can return half a surrogate
    // pair, causing a crash. .characters.last returns the full cluster.
    final chars = clean.characters;
    final char = chars.last;

    // If the last grapheme cluster is longer than 1 codepoint it is almost
    // certainly an emoji or special symbol — discard it entirely.
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

    // Move focus to the next cell
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

    // Build row items: either a cell or a special-char text
    final List<Widget> rowItems = [];
    int cellIndex = 0;

    for (int i = 0; i < answer.length; i++) {
      final ch = answer[i];
      if (_isSpecial(ch)) {
        // Render separator / space as text
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
        // Render a letter input cell
        final idx = cellIndex;
        cellIndex++;
        rowItems.add(
          _LetterCell(
            controller: widget.cellControllers[idx],
            focusNode: widget.cellFocusNodes[idx],
            onChanged: (v) => _onCellChanged(idx, v),
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

/// A single letter input cell.
/// Uses a Zero-Width Space (ZWS) trick so that iOS soft-keyboard backspace
/// on an "empty" cell is still detected via [onChanged].
class _LetterCell extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _LetterCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
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
        // ZWS is invisible — treat the cell as filled only if a real char exists
        final displayText = value.text.replaceAll(_zws, '');
        final isFilled = displayText.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 38,
          height: 48,
          decoration: BoxDecoration(
            color: isFilled
                ? t.mentourPrimary1.withOpacity(0.12)
                : t.mentourNavigationBarBg,
            border: Border.all(
              width: 2,
              color: widget.focusNode.hasFocus
                  ? t.mentourPrimary1
                  : (isFilled
                        ? t.mentourPrimary1.withOpacity(0.5)
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
