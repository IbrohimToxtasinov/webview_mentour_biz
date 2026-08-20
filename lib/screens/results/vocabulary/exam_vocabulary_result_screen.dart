import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/check_vocabulary_answer/check_vocabulary_answer_cubit.dart';
import 'package:mentour_web_view/cubits/vocabulary_detail/vocabulary_detail_cubit.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_result_model.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/stadium_gradient_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class ExamVocabularyResultScreen extends StatefulWidget {
  final String setUuid;
  final String unitId;

  const ExamVocabularyResultScreen({
    super.key,
    required this.setUuid,
    required this.unitId,
  });

  @override
  State<ExamVocabularyResultScreen> createState() =>
      _ExamVocabularyResultScreenState();
}

class _ExamVocabularyResultScreenState
    extends State<ExamVocabularyResultScreen> {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _resultPlayer = AudioPlayer();
  bool _showAllQuestions = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _playResultSound(int scorePercentage) async {
    try {
      String soundFile;
      if (scorePercentage < 40) {
        soundFile = 'sounds/failure.mp3';
      } else if (scorePercentage < 80) {
        soundFile = 'sounds/result.mp3';
      } else {
        soundFile = 'sounds/final_success.mp3';
      }
      await _resultPlayer.play(AssetSource(soundFile));
      _resultPlayer.onPlayerComplete.listen((_) {
        _resultPlayer.release().catchError((_) {});
      });
    } catch (e) {
      debugPrint('Result sound error: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    try {
      _resultPlayer.stop().catchError((_) {});
      _resultPlayer.release().catchError((_) {});
    } catch (_) {}
    super.dispose();
  }

  Map<String, String> _scoreMessage(int percentage) {
    if (percentage == 100) {
      return {"text": "perfect_score".tr()};
    } else if (percentage >= 80) {
      return {"text": "excellent".tr()};
    } else if (percentage >= 60) {
      return {"text": "good_job".tr()};
    } else if (percentage >= 40) {
      return {"text": "keep_practicing".tr()};
    } else {
      return {"text": "dont_give_up".tr()};
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        BlocProvider.of<VocabularyDetailCubit>(
          context,
        ).getVocabularyDetail(unitId: widget.unitId);
        return true;
      },
      child: Scaffold(
        backgroundColor: t.newMentourBg1,
        body: SafeArea(
          child: BlocProvider(
            create: (_) =>
                CheckVocabularyAnswerCubit()
                  ..getVocabularySetResult(setUuid: widget.setUuid),
            child:
                BlocConsumer<
                  CheckVocabularyAnswerCubit,
                  CheckVocabularyAnswerState
                >(
                  listener: (context, state) {
                    if (state.formStatus ==
                            FormStatus.getVocabularySetResultSuccess &&
                        state.vocabularyResult != null) {
                      _playResultSound(state.vocabularyResult!.percentage);
                    }
                  },
                  builder: (context, state) {
                    if (state.formStatus ==
                        FormStatus.getVocabularySetResultLoading) {
                      return Center(
                        child: Lottie.asset(
                          AppLotties.loader,
                          width: 320,
                          height: 320,
                        ),
                      );
                    } else if (state.formStatus ==
                            FormStatus.getVocabularySetResultSuccess &&
                        state.vocabularyResult != null) {
                      return _buildContent(context, state.vocabularyResult!);
                    } else if (state.formStatus ==
                        FormStatus.getVocabularySetResultFailure) {
                      return Center(child: Text(state.errorMessage));
                    }
                    return Center(child: Text("no_data".tr()));
                  },
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, VocabularyResultModel result) {
    final scorePercentage = result.percentage;
    final correct = result.correctCount;
    final total = result.totalCount == 0
        ? result.words.length
        : result.totalCount;
    final msg = _scoreMessage(scorePercentage);
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: scorePercentage < 40
                      ? Lottie.asset(
                          AppLotties.finalWrong,
                          repeat: false,
                          width: 100,
                          height: 100,
                        )
                      : scorePercentage < 80
                      ? Lottie.asset(
                          AppLotties.finalAlmost,
                          repeat: false,
                          width: 100,
                          height: 100,
                        )
                      : Lottie.asset(
                          AppLotties.finalSuccess,
                          repeat: false,
                          width: 100,
                          height: 100,
                        ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  msg["text"]!,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: t.newMentourText3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  result.title,
                  style: TextStyle(fontSize: 20, color: t.newMentourText4),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Lottie.asset(AppLotties.coin, height: 50, width: 50),
                        SizedBox(height: 10),
                        Text(
                          "+${result.coinsEarned} Coins",
                          style: TextStyle(
                            fontSize: 18,
                            color: t.mentourText3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Lottie.asset(AppLotties.score, height: 60, width: 60),
                        Text(
                          "+$scorePercentage Score",
                          style: TextStyle(
                            fontSize: 18,
                            color: t.mentourText3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.newMentourContainer1,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: t.newMentourBorder2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "accuracy".tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: t.newMentourText3,
                        ),
                      ),
                      Text(
                        "$scorePercentage%",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: t.newMentourText3,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final progressWidth =
                              totalWidth * (scorePercentage / 100);
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 12,
                              width: double.infinity,
                              color: t.newMentourContainer14,
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
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.newMentourContainer1,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: t.newMentourBorder2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "questions_answered".tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: t.newMentourText3,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "$correct",
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: t.newMentourText3,
                                  height: 1.0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                  left: 4,
                                ),
                                child: Text(
                                  "/ $total",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: t.newMentourText4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = result.words[index];
                          return Container(
                            padding: EdgeInsets.all(17),
                            decoration: BoxDecoration(
                              color: t.newMentourNavigationBg1,
                              border: Border.all(color: t.newMentourBorder2),
                              borderRadius: BorderRadius.circular(48),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${"word".tr()} ${index + 1}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: t.newMentourText4,
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: item.isCorrect
                                        ? t.newMentourPrimary1
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.isCorrect ? Icons.check : Icons.close,
                                    color: t.mentourIconColor2,
                                    size: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 12);
                        },
                        itemCount: _showAllQuestions
                            ? result.words.length
                            : (result.words.length > 3
                                  ? 3
                                  : result.words.length),
                      ),
                      if (result.words.length > 3) ...[
                        SizedBox(height: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              _showAllQuestions = !_showAllQuestions;
                            });
                          },
                          child: Center(
                            child: Text(
                              _showAllQuestions
                                  ? "show_less".tr()
                                  : "view_all".tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: t.newMentourPrimary2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 20),
              child: StadiumGradientButton(
                onTap: () {
                  BlocProvider.of<VocabularyDetailCubit>(
                    context,
                  ).getVocabularyDetail(unitId: widget.unitId);
                  Navigator.of(context).pop();
                },
                label: "close".tr(),
                height: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
