// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/check_answer/check_answer_cubit.dart';
import 'package:mentour_web_view/cubits/speaking_task/speaking_task_cubit.dart';
import 'package:mentour_web_view/cubits/unit_section_details/unit_section_details_cubit.dart';
import 'package:mentour_web_view/cubits/upload_speaking/upload_speaking_cubit.dart';
import 'package:mentour_web_view/cubits/exam_timer/exam_timer_cubit.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/audio/custom_audio_player.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/main_action_button.dart';
import 'package:mentour_web_view/ui_kit/widgets/dialogs/exit_dialog.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/ui_kit/widgets/pronunciation/pronunciation_result_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class ExamSpeakingPronunciationTaskScreen extends StatefulWidget {
  final String taskId;
  final String unitId;
  final int maxAttempts;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamSpeakingPronunciationTaskScreen({
    super.key,
    required this.taskId,
    required this.unitId,
    required this.maxAttempts,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<ExamSpeakingPronunciationTaskScreen> createState() =>
      _ExamSpeakingPronunciationTaskScreenState();
}

class _ExamSpeakingPronunciationTaskScreenState
    extends State<ExamSpeakingPronunciationTaskScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        ExamFreezeObserver {
  @override
  bool get freezeEnabled => widget.freezeScreen;

  @override
  bool get inactiveTriggersFreeze => false;

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

  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _resultShown = false;
  late int _attemptsLeft = 0;
  late final FlutterTts _flutterTts;

  late AnimationController _animationController;
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  String? _audioPath;

  @override
  void initState() {
    _attemptsLeft = widget.maxAttempts;
    super.initState();
    initFreezeObserver();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
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

  @override
  void dispose() {
    disposeFreezeObserver();
    _animationController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _stopRecording() async {
    _animationController.stop();
    _animationController.reset();
    final path = await _audioRecorder.stop();
    if (path != null) {
      if (kIsWeb) {
        await _audioPlayer.setSourceUrl(path);
      } else {
        await _audioPlayer.setSourceDeviceFile(path);
      }
    }
    setState(() {
      _isRecording = false;
      if (path != null) {
        _audioPath = path;
        _hasRecorded = true;
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_hasRecorded) return;
    if (_isRecording) {
      await _stopRecording();
    } else {
      try {
        pauseFreezeObserver();
        final hasPermission = await _audioRecorder.hasPermission();
        resumeFreezeObserver();

        if (!hasPermission) {
          if (mounted) {
            showOverlayMessage(
              context,
              text: 'microphone_permission_denied'.tr(),
            );
          }
          return;
        }

        String? recordPath;
        if (!kIsWeb) {
          final cacheDir = await getTemporaryDirectory();
          recordPath =
              '${cacheDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }
        await _audioRecorder.start(
          const RecordConfig(
            encoder: kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc,
          ),
          path: recordPath ?? '',
        );
        setState(() {
          _isRecording = true;
        });
        _animationController.repeat(reverse: true);
      } catch (e) {
        if (mounted) {
          showOverlayMessage(
            context,
            text: 'microphone_permission_denied'.tr(),
          );
        }
        debugPrint('Recording error: $e');
      }
    }
  }

  Future<void> _resetForRetry() async {
    await _audioPlayer.stop();
    if (_audioPath != null && !kIsWeb) {
      try {
        final file = File(_audioPath!);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    setState(() {
      _hasRecorded = false;
      _audioPath = null;
      _resultShown = false;
    });
  }

  Future<void> _speakWord(String word) async {
    if (word.isEmpty || word.trim().isEmpty) {
      return;
    }
    try {
      if (kIsWeb) {
        // On web, call speak() synchronously (no await) so the browser
        // keeps the user-gesture context and does not block audio playback.
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

  Future<void> _onWillPop(BuildContext context) async {
    if (_audioPath != null && !kIsWeb) {
      try {
        final f = File(_audioPath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    return showExitDialog(
      title: "exit".tr(),
      context: context,
      message: "exit_question_dialog".tr(),
      yesTap: () {
        BlocProvider.of<UnitSectionDetailCubit>(
          context,
        ).getUnitSectionByIdAndType(unitId: widget.unitId, type: "SPEAKING");
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
            create: (context) => CheckAnswerCubit(),
            child: BlocConsumer<CheckAnswerCubit, CheckAnswerState>(
              listener: (context, checkState) {
                if (checkState.formStatus ==
                    FormStatus.submitPronunciationSuccess) {
                  context
                      .read<UnitSectionDetailCubit>()
                      .getUnitSectionByIdAndType(
                        unitId: widget.unitId,
                        type: "SPEAKING",
                      );
                  Navigator.of(context).pop(true);
                } else if (checkState.formStatus ==
                        FormStatus.submitPronunciationFailure &&
                    checkState.errorMessage.isNotEmpty) {
                  showOverlayMessage(context, text: checkState.errorMessage);
                }
              },
              builder: (context, checkState) {
                return BlocProvider(
                  create: (context) =>
                      SpeakingTaskCubit()
                        ..getSpeakingQuestion(taskId: widget.taskId),
                  child: BlocBuilder<SpeakingTaskCubit, SpeakingTaskState>(
                    builder: (context, speakingState) {
                      if (speakingState.formStatus ==
                          FormStatus.getSpeakingQuestionLoading) {
                        return Center(
                          child: Lottie.asset(
                            AppLotties.loader,
                            width: 320,
                            height: 320,
                          ),
                        );
                      }

                      if (speakingState.formStatus ==
                          FormStatus.getSpeakingQuestionSuccess) {
                        final question =
                            speakingState.questionModel.questions.first;

                        return BlocProvider(
                          create: (_) => UploadSpeakingCubit(),
                          child: BlocConsumer<UploadSpeakingCubit, UploadSpeakingState>(
                            listener: (context, uploadState) {
                              if (uploadState.status ==
                                      FormStatus
                                          .checkPronunciationTaskFailure ||
                                  uploadState.status ==
                                      FormStatus.uploadFileFailure) {
                                showOverlayMessage(
                                  context,
                                  text: uploadState.errorMessage.isNotEmpty
                                      ? uploadState.errorMessage
                                      : 'something_went_wrong'.tr(),
                                  status: OverlayStatus.failed,
                                );
                              }
                              if (uploadState.status ==
                                  FormStatus.checkPronunciationTaskSuccess) {
                                setState(() {
                                  _resultShown = true;
                                  _attemptsLeft--;
                                });
                              }
                            },
                            builder: (context, uploadState) {
                              final isChecking =
                                  uploadState.status ==
                                      FormStatus.uploadFileLoading ||
                                  uploadState.status ==
                                      FormStatus.checkPronunciationTaskLoading;

                              final isSuccess =
                                  uploadState.status ==
                                  FormStatus.checkPronunciationTaskSuccess;

                              final attemptsExhausted = _attemptsLeft <= 0;

                              // Calculate average accuracy score across all processed words
                              double? overallScore;
                              if (uploadState
                                  .aiResponse
                                  .processedWords
                                  .isNotEmpty) {
                                overallScore =
                                    uploadState.aiResponse.processedWords
                                        .map(
                                          (w) => w
                                              .pronunciationAssessment
                                              .accuracyScore,
                                        )
                                        .reduce((a, b) => a + b) /
                                    uploadState
                                        .aiResponse
                                        .processedWords
                                        .length;
                              }

                              final isPerfect =
                                  isSuccess &&
                                  overallScore != null &&
                                  overallScore >= 100.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: BlocBuilder<ExamTimerCubit, int>(
                                        builder: (context, remainingSeconds) {
                                          final hours =
                                              remainingSeconds ~/ 3600;
                                          final minutes =
                                              (remainingSeconds % 3600) ~/ 60;
                                          final seconds = remainingSeconds % 60;
                                          final timeStr = hours > 0
                                              ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                                              : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

                                          return Row(
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
                                              const Spacer(),

                                              /// Finish button
                                              SizedBox(
                                                width: 100,
                                                child: MainActionButton(
                                                  enabled:
                                                      _attemptsLeft <
                                                      widget.maxAttempts,
                                                  isLoading:
                                                      checkState.formStatus ==
                                                      FormStatus
                                                          .submitPronunciationLoading,
                                                  isGradientButton: true,
                                                  height: 34,
                                                  onTap: () {
                                                    if (_attemptsLeft <= 0) {
                                                      context
                                                          .read<
                                                            CheckAnswerCubit
                                                          >()
                                                          .submitSpeakingPronunciation(
                                                            taskId:
                                                                widget.taskId,
                                                            questionId: question
                                                                .questionId,
                                                          );
                                                    } else {
                                                      _showFinishConfirmDialog(
                                                        context,
                                                        questionId:
                                                            question.questionId,
                                                      );
                                                    }
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
                                          children: [
                                            const SizedBox(height: 12),

                                            _AttemptsChip(
                                              attemptsLeft: _attemptsLeft,
                                              maxAttempts: widget.maxAttempts,
                                            ),
                                            const SizedBox(height: 8),

                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 24,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: t.mentourNavigationBarBg,
                                                border: Border.all(
                                                  color: t.mentourBorder1,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    question
                                                            .content
                                                            .instruction
                                                            .isEmpty
                                                        ? question.instruction
                                                        : question
                                                              .content
                                                              .instruction,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: t.mentourText3,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          question
                                                              .content
                                                              .targetWord,
                                                          style: TextStyle(
                                                            fontSize: 22,
                                                            color: t
                                                                .mentourPrimary1,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            letterSpacing: 1.2,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      GestureDetector(
                                                        onTap: () => _speakWord(
                                                          question
                                                              .content
                                                              .targetWord,
                                                        ),
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: t
                                                                .mentourPrimary1,
                                                          ),
                                                          child: Icon(
                                                            Icons.volume_up,
                                                            color:
                                                                t.mentourWhite,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            if (attemptsExhausted && !isSuccess)
                                              _NoAttemptsCard()
                                            else ...[
                                              if (!_resultShown)
                                                GestureDetector(
                                                  onTap: attemptsExhausted
                                                      ? null
                                                      : _toggleRecording,
                                                  child: AnimatedBuilder(
                                                    animation:
                                                        _animationController,
                                                    builder: (context, _) {
                                                      return Container(
                                                        width:
                                                            100 +
                                                            (_animationController
                                                                    .value *
                                                                20),
                                                        height:
                                                            100 +
                                                            (_animationController
                                                                    .value *
                                                                20),
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: _isRecording
                                                              ? Colors.redAccent
                                                                    .withOpacity(
                                                                      0.2,
                                                                    )
                                                              : Colors
                                                                    .transparent,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Container(
                                                          width: 80,
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                attemptsExhausted
                                                                ? t.mentourBorder1
                                                                      .withOpacity(
                                                                        0.5,
                                                                      )
                                                                : (_hasRecorded
                                                                      ? t.mentourBorder1
                                                                      : (_isRecording
                                                                            ? Colors.redAccent
                                                                            : t.mentourPrimary1)),
                                                            boxShadow:
                                                                (_hasRecorded ||
                                                                    attemptsExhausted)
                                                                ? null
                                                                : [
                                                                    BoxShadow(
                                                                      color:
                                                                          _isRecording
                                                                          ? Colors.redAccent.withOpacity(
                                                                              0.5,
                                                                            )
                                                                          : t.mentourPrimary1.withOpacity(
                                                                              0.3,
                                                                            ),
                                                                      blurRadius:
                                                                          15,
                                                                      spreadRadius:
                                                                          5,
                                                                    ),
                                                                  ],
                                                          ),
                                                          child: Icon(
                                                            _isRecording
                                                                ? Icons
                                                                      .stop_rounded
                                                                : Icons
                                                                      .mic_rounded,
                                                            color: Colors.white,
                                                            size: 40,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),

                                              if (!_resultShown) ...[
                                                const SizedBox(height: 10),
                                                Text(
                                                  _isRecording
                                                      ? "recording...".tr()
                                                      : (_hasRecorded
                                                            ? "recording_saved"
                                                                  .tr()
                                                            : "tap_to_record"
                                                                  .tr()),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: t.mentourText3,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],

                                              /// ── Audio player ──
                                              if (_hasRecorded &&
                                                  _audioPath != null) ...[
                                                const SizedBox(height: 16),
                                                CustomAudioPlayer(
                                                  audioUrl: _audioPath!,
                                                  isLocalFile: true,
                                                  onDelete: _resultShown
                                                      ? null
                                                      : _resetForRetry,
                                                ),
                                                const SizedBox(height: 16),
                                              ],

                                              if (_hasRecorded &&
                                                  !isChecking) ...[
                                                if (!_resultShown)
                                                  MainActionButton(
                                                    isLoading: false,
                                                    isGradientButton: true,
                                                    enabled: !_isRecording,
                                                    onTap: () {
                                                      if (_audioPath == null) {
                                                        return;
                                                      }
                                                      context
                                                          .read<
                                                            UploadSpeakingCubit
                                                          >()
                                                          .uploadSpeakingPronunciationFileAndEvaluate(
                                                            file: File(
                                                              _audioPath!,
                                                            ),
                                                            questionId: question
                                                                .questionId,
                                                          );
                                                    },
                                                    label: 'check'.tr(),
                                                  )
                                                else if (!isPerfect &&
                                                    !attemptsExhausted)
                                                  MainActionButton(
                                                    isLoading: false,
                                                    isGradientButton: false,
                                                    enabled: true,
                                                    onTap: () async {
                                                      await _resetForRetry();
                                                    },
                                                    label: 'try_again'.tr(),
                                                  ),
                                              ],

                                              if (isChecking) ...[
                                                const SizedBox(height: 8),
                                                MainActionButton(
                                                  isLoading: true,
                                                  isGradientButton: true,
                                                  enabled: false,
                                                  onTap: () {},
                                                  label: 'check'.tr(),
                                                ),
                                              ],
                                            ],

                                            if (isSuccess &&
                                                uploadState
                                                    .aiResponse
                                                    .processedWords
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 20),
                                              PronunciationResultCard(
                                                processedWords: uploadState
                                                    .aiResponse
                                                    .processedWords,
                                                overallScore: overallScore,
                                              ),
                                            ],

                                            const SizedBox(height: 40),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }

                      if (speakingState.formStatus ==
                          FormStatus.getSpeakingQuestionFailure) {
                        return Center(child: Text(speakingState.errorMessage));
                      }

                      return Center(child: Text("something_went_wrong".tr()));
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showFinishConfirmDialog(
    BuildContext context, {
    required String questionId,
  }) {
    final checkAnswerCubit = context.read<CheckAnswerCubit>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final t = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: Container(
            decoration: BoxDecoration(
              color: t.mentourNavigationBarBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "finish_warning_message".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, color: t.mentourText3),
                    ),
                  ),
                  Text(
                    "finish_confirmation_message".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: t.mentourText4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: t.mentourPrimary2,
                            foregroundColor: t.mentourWhite,
                            side: BorderSide(color: t.mentourBorder1, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(120, 40),
                          ),
                          child: Text(
                            'no'.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            checkAnswerCubit.submitSpeakingPronunciation(
                              taskId: widget.taskId,
                              questionId: questionId,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: t.mentourIconColor,
                            side: BorderSide(color: t.mentourBorder1, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size(120, 40),
                          ),
                          child: Text(
                            'yes'.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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

class _AttemptsChip extends StatelessWidget {
  final int attemptsLeft;
  final int maxAttempts;

  const _AttemptsChip({required this.attemptsLeft, required this.maxAttempts});

  @override
  Widget build(BuildContext context) {
    final isEmpty = attemptsLeft <= 0;
    final color = isEmpty
        ? const Color(0xFFEF4444)
        : attemptsLeft <= 2
        ? const Color(0xFFF59E0B)
        : const Color(0xFF22C55E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.loop_rounded, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            '$attemptsLeft/$maxAttempts',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoAttemptsCard extends StatelessWidget {
  const _NoAttemptsCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.block_rounded, color: Color(0xFFEF4444), size: 48),
          const SizedBox(height: 12),
          Text(
            'attempts_exhausted'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: t.mentourText3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
