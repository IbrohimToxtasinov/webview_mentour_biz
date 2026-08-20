import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/vocabulary/vocabulary_bloc.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_word_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class LearnWordsScreen extends StatefulWidget {
  final String setUuid;
  final String unitId;
  final bool isQuizWordsTap;

  const LearnWordsScreen({
    super.key,
    required this.setUuid,
    required this.unitId,
    required this.isQuizWordsTap,
  });

  @override
  State<LearnWordsScreen> createState() => _LearnWordsScreenState();
}

class _LearnWordsScreenState extends State<LearnWordsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AudioPlayer _audioPlayer;
  late final FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((_) {});
    _audioPlayer.onLog.listen((message) {
      debugPrint('AudioPlayer log: $message');
    });

    _flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.35);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speakWord(String word) async {
    if (word.isEmpty || word.trim().isEmpty) {
      return;
    }
    try {
      if (kIsWeb) {
        _flutterTts.stop();
        _flutterTts.speak(word);
      } else {
        await _flutterTts.stop();
        await _flutterTts.setSpeechRate(0.35);
        await _flutterTts.speak(word);
      }
    } catch (e) {
      if (mounted) {
        showOverlayMessage(context, text: "could_not_play_audio".tr());
      }
      debugPrint('Error speaking word: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      VocabularyBloc()
        ..add(GetVocabularySetLearnById(setUuid: widget.setUuid)),
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
                    bottom: 80,
                    child: BlocBuilder<VocabularyBloc, VocabularyState>(
                      builder: (context, state) {
                        if (state.formStatus ==
                            FormStatus.getVocabularySetLearnLoading) {
                          return Center(
                            child: Lottie.asset(
                              AppLotties.loader,
                              width: 320,
                              height: 320,
                            ),
                          );
                        } else if (state.formStatus ==
                            FormStatus.getVocabularySetLearnSuccess) {
                          if (state.learnWords.isEmpty) {
                            return Center(
                              child: Text(
                                "no_words_available".tr(),
                                style: TextStyle(color: t.mentourText3),
                              ),
                            );
                          }
                          return PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: state.learnWords.length,
                            itemBuilder: (context, index) {
                              return _buildWordContent(
                                context,
                                state.learnWords[index],
                              );
                            },
                          );
                        } else if (state.formStatus ==
                            FormStatus.getVocabularySetLearnFailure) {
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
                    bottom: 0,
                    child: BlocBuilder<VocabularyBloc, VocabularyState>(
                      builder: (context, state) {
                        if (state.formStatus !=
                            FormStatus.getVocabularySetLearnSuccess ||
                            state.learnWords.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final isLastPage =
                            _currentPage == state.learnWords.length - 1;
                        final isFirstPage = _currentPage == 0;
                        return Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: t.mentourNavigationBarBg,
                          ),
                          child: isLastPage
                              ? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.mentourBg1,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: t.mentourBorder1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          color: Theme.of(
                                            context,
                                          ).mentourText3,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "previous".tr(),
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).mentourText3,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Start Quiz button
                              if (widget.isQuizWordsTap) ...[
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.isQuizWordsTap) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRouterNames.quizWordsRoute,
                                          arguments: {
                                            "setUuid": widget.setUuid,
                                            "unitId": widget.unitId,
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.mentourPrimary1,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                          width: 2,
                                          color: t.mentourBorder1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "start_quiz".tr(),
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).mentourWhite,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          )
                              : Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              if (!isFirstPage)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Container(
                                      height: 45,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.mentourBg1,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                        border: Border.all(
                                          width: 2,
                                          color: t.mentourBorder1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back,
                                            color: Theme.of(
                                              context,
                                            ).mentourText3,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              "previous".tr(),
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).mentourText3,
                                                fontSize: 16,
                                                fontWeight:
                                                FontWeight.w600,
                                              ),
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isFirstPage) SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    height: 45,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.mentourPrimary1,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      border: Border.all(
                                        width: 2,
                                        color: t.mentourBorder1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "forward".tr(),
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).mentourWhite,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow:
                                            TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Theme.of(
                                            context,
                                          ).mentourWhite,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(color: t.mentourBg1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ArrowBackButton(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          BlocBuilder<VocabularyBloc, VocabularyState>(
                            builder: (context, state) {
                              return Text(
                                "${_currentPage + 1} ${"of".tr()} ${state.learnWords.length}",
                                style: TextStyle(
                                  color: t.mentourText3,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
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
    );
  }

  Widget _buildWordContent(BuildContext context, VocabularyWordModel word) {
    final t = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "please_learn_new_words_attentively".tr(),
            style: TextStyle(
              fontSize: 18,
              color: t.mentourText3,
              fontWeight: FontWeight.w500,
            ),
          ),
          // SizedBox(height: 24),
          // Center(
          //   child: Container(
          //     width: 200,
          //     constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(12),
          //       child: word.image.isNotEmpty
          //           ? Image.network(
          //               word.image,
          //               fit: BoxFit.cover,
          //               loadingBuilder: (context, child, loadingProgress) {
          //                 if (loadingProgress == null) {
          //                   return child;
          //                 }
          //                 return Shimmer.fromColors(
          //                   baseColor: Theme.of(
          //                     context,
          //                   ).mentourSidebarItem0.withOpacity(0.3),
          //                   highlightColor: Theme.of(
          //                     context,
          //                   ).mentourSidebarItem1.withOpacity(0.5),
          //                   child: Container(
          //                     width: 200,
          //                     height: 200,
          //                     decoration: BoxDecoration(
          //                       color: t.mentourSidebarItem0,
          //                       borderRadius: BorderRadius.circular(12),
          //                     ),
          //                   ),
          //                 );
          //               },
          //               errorBuilder: (context, error, stackTrace) {
          //                 return Image.asset(AppImages.noImage);
          //               },
          //             )
          //           : Image.asset(AppImages.noImage),
          //     ),
          //   ),
          // ),
          // SizedBox(height: 24),
          // Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
          SizedBox(height: 24),
          _buildWordSection(context, word),
          SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
          SizedBox(height: 16),
          _buildWordDetails(context, word),
        ],
      ),
    );
  }

  Widget _buildWordSection(BuildContext context, VocabularyWordModel word) {
    final t = Theme.of(context);
    return Row(
      children: [
        GestureDetector(
          onTap: () => _speakWord(word.word),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.mentourPrimary1,
            ),
            child: Icon(Icons.volume_up, color: t.mentourWhite, size: 25),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.word,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: t.mentourText3,
                ),
              ),
              if (word.transcription.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  word.transcription,
                  style: TextStyle(
                    fontSize: 18,
                    color: t.mentourText3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordDetails(BuildContext context, VocabularyWordModel word) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (word.partOfSpeech.isNotEmpty) ...[
          Text(
            "${word.partOfSpeech} [${word.partOfSpeech[0].toLowerCase()}]",
            style: TextStyle(fontSize: 18, color: t.mentourText3),
          ),
          SizedBox(height: 8),
        ],
        ...word.translations.where((lw) => lw.value.isNotEmpty).map((lw) {
          final flagPath = _flagForLang(lw.lang);
          if (flagPath == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: t.newMentourBorder1),
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
        SizedBox(height: 8),
        if (word.exampleSentence.isNotEmpty) ...[
          Text(
            "${"example".tr()}:",
            style: TextStyle(
              fontSize: 18,
              color: t.mentourText3.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            word.exampleSentence,
            style: TextStyle(fontSize: 18, color: t.mentourText3),
          ),
        ],
      ],
    );
  }
}
