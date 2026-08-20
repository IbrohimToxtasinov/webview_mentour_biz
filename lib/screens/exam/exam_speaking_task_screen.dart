import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:mentour_web_view/utils/mixins/exam_freeze_observer.dart';

class ExamSpeakingTaskScreen extends StatefulWidget {
  final String taskId;
  final String unitId;
  final bool freezeScreen;
  final int freezeTimer;
  final bool noScreenshot;

  const ExamSpeakingTaskScreen({
    super.key,
    required this.taskId,
    required this.unitId,
    this.freezeScreen = false,
    this.freezeTimer = 30,
    this.noScreenshot = false,
  });

  @override
  State<ExamSpeakingTaskScreen> createState() => _ExamSpeakingTaskScreenState();
}

class _ExamSpeakingTaskScreenState extends State<ExamSpeakingTaskScreen>
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
  late AnimationController _animationController;

  Timer? _timer;
  int _remainingSeconds = 0;
  int _maxSeconds = 0;

  // Audio recording and playback variables
  late final AudioRecorder _audioRecorder;
  late final AudioPlayer _audioPlayer;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    initFreezeObserver();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    // Initialization removed for unused state variables
  }

  @override
  void dispose() {
    disposeFreezeObserver();
    _timer?.cancel();
    _animationController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopRecording(); // Auto stop when time is up
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _animationController.stop();
    _animationController.reset();

    final path = await _audioRecorder.stop();

    if (path != null) {
      if (kIsWeb) {
        // Web: path is a blob URL
        await _audioPlayer.setSourceUrl(path);
      } else {
        // Set audio source to initialize duration early
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
    if (_hasRecorded) return; // Cannot rec again until deleted

    if (_isRecording) {
      await _stopRecording();
    } else {
      try {
        // Pause freeze while system permission dialog is shown.
        // The OS dialog causes the app to briefly go inactive/paused which
        // would otherwise trigger the exam freeze dialog.
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
        // On web: recordPath is null — record package stores blob in memory
        await _audioRecorder.start(
          const RecordConfig(
            encoder: kIsWeb ? AudioEncoder.wav : AudioEncoder.aacLc,
          ),
          path: recordPath ?? '',
        );

        // Start recording
        setState(() {
          _isRecording = true;
          _remainingSeconds = _maxSeconds; // Reset timer
        });
        _animationController.repeat(reverse: true);
        _startTimer();
      } catch (e) {
        // Permission denied or device unavailable
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

  Future<void> _deleteAudio() async {
    await _audioPlayer.stop();
    if (_audioPath != null && !kIsWeb) {
      try {
        final file = File(_audioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    setState(() {
      _hasRecorded = false;
      _audioPath = null;
      _remainingSeconds = _maxSeconds;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                SpeakingTaskCubit()..getSpeakingQuestion(taskId: widget.taskId),
            child: BlocProvider(
              create: (context) => UploadSpeakingCubit(),
              child: BlocConsumer<UploadSpeakingCubit, UploadSpeakingState>(
                listener: (context, uploadState) {
                  if (uploadState.status ==
                      FormStatus.submitSpeakingTaskSuccess) {
                    context
                        .read<UnitSectionDetailCubit>()
                        .getUnitSectionByIdAndType(
                          unitId: widget.unitId,
                          type: "SPEAKING",
                        );
                    showOverlayMessage(
                      context,
                      status: OverlayStatus.success,
                      text: uploadState.message,
                    );
                    Navigator.of(context).pop(true);
                  } else if ((uploadState.status ==
                              FormStatus.submitSpeakingTaskFailure ||
                          uploadState.status == FormStatus.uploadFileFailure) &&
                      uploadState.errorMessage.isNotEmpty) {
                    showOverlayMessage(context, text: uploadState.errorMessage);
                  }
                },
                builder: (context, uploadState) {
                  return BlocBuilder<SpeakingTaskCubit, SpeakingTaskState>(
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
                      } else if (speakingState.formStatus ==
                          FormStatus.getSpeakingQuestionSuccess) {
                        final question =
                            speakingState.questionModel.questions.first;

                        final taskMaxSeconds = question.content.seconds > 0
                            ? question.content.seconds
                            : 0;

                        if (_maxSeconds == 0 && taskMaxSeconds > 0) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _maxSeconds = taskMaxSeconds;
                                _remainingSeconds = taskMaxSeconds;
                              });
                            }
                          });
                        }

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
                                                uploadState.status ==
                                                    FormStatus
                                                        .submitSpeakingTaskLoading ||
                                                uploadState.status ==
                                                    FormStatus
                                                        .uploadFileLoading,
                                            isGradientButton: true,
                                            height: 38,
                                            enabled:
                                                _hasRecorded && !_isRecording,
                                            onTap: () async {
                                              context
                                                  .read<UploadSpeakingCubit>()
                                                  .uploadSpeakingFileAndEvaluate(
                                                    file: File(_audioPath!),
                                                    questionId:
                                                        question.questionId,
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
                                    children: [
                                      const SizedBox(height: 20),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 24,
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
                                                fontWeight: FontWeight.w800,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              question.content.speakingPrompt,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: t.mentourText3
                                                    .withOpacity(0.8),
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 60),

                                      // Timer Display
                                      Text(
                                        _formatTime(_remainingSeconds),
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w800,
                                          color: _isRecording
                                              ? (_remainingSeconds <= 10
                                                    ? Colors.redAccent
                                                    : t.mentourText1)
                                              : t.mentourText3,
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      // Recording Animation and Button
                                      GestureDetector(
                                        onTap: () {
                                          final taskMaxSeconds =
                                              question.content.seconds > 0
                                              ? question.content.seconds
                                              : 0;
                                          _maxSeconds = taskMaxSeconds;
                                          if (!_isRecording && !_hasRecorded) {
                                            _remainingSeconds = _maxSeconds;
                                          }
                                          _toggleRecording();
                                        },
                                        child: AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (context, child) {
                                            return Container(
                                              width:
                                                  100 +
                                                  (_animationController.value *
                                                      20),
                                              height:
                                                  100 +
                                                  (_animationController.value *
                                                      20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _isRecording
                                                    ? Colors.redAccent
                                                          .withOpacity(0.2)
                                                    : Colors.transparent,
                                              ),
                                              alignment: Alignment.center,
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _hasRecorded
                                                      ? t.mentourBorder1
                                                      : (_isRecording
                                                            ? Colors.redAccent
                                                            : t.mentourPrimary1),
                                                  boxShadow: _hasRecorded
                                                      ? null
                                                      : [
                                                          BoxShadow(
                                                            color: _isRecording
                                                                ? Colors
                                                                      .redAccent
                                                                      .withOpacity(
                                                                        0.5,
                                                                      )
                                                                : t.mentourPrimary1
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                            blurRadius: 15,
                                                            spreadRadius: 5,
                                                          ),
                                                        ],
                                                ),
                                                child: Icon(
                                                  _isRecording
                                                      ? Icons.stop_rounded
                                                      : Icons.mic_rounded,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Text(
                                        _isRecording
                                            ? "recording...".tr()
                                            : (_hasRecorded
                                                  ? "recording_saved".tr()
                                                  : "tap_to_record".tr()),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: t.mentourText3,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      if (_hasRecorded) ...[
                                        const SizedBox(height: 40),
                                        if (_audioPath != null)
                                          CustomAudioPlayer(
                                            audioUrl: _audioPath!,
                                            isLocalFile: true,
                                            onDelete: _deleteAudio,
                                          ),
                                      ],
                                      const SizedBox(height: 50),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (speakingState.formStatus ==
                          FormStatus.getSpeakingQuestionFailure) {
                        return Center(child: Text(speakingState.errorMessage));
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
}
