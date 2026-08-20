import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';

class CustomAudioPlayerForQuestions extends StatefulWidget {
  final String audioUrl;
  final String questionId;
  final Function(AudioPlayer) onPlayerCreated;

  const CustomAudioPlayerForQuestions({
    super.key,
    required this.audioUrl,
    required this.questionId,
    required this.onPlayerCreated,
  });

  @override
  State<CustomAudioPlayerForQuestions> createState() =>
      _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayerForQuestions> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isDragging = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _dragPosition = Duration.zero;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    widget.onPlayerCreated(_audioPlayer);
    // Set error handler to catch all audio errors
    _audioPlayer.onPlayerComplete.listen((_) {
      // Audio completed successfully
    });
    _audioPlayer.onLog.listen((message) {
      debugPrint('AudioPlayer log: $message');
    });

    // NOTE: We intentionally skip audio preloading on Flutter Web.
    // Browsers block media loading without a user gesture (Autoplay Policy),
    // which causes MEDIA_ELEMENT_ERROR: Format error (Code: 4).
    // On Web, the source is set lazily when the user taps play.
    if (!kIsWeb) {
      _initAudio();
    }
  }

  Source _getAudioSource(String url) {
    final safeUrl = url.startsWith('http://')
        ? url.replaceFirst('http://', 'https://')
        : url;
    if (kIsWeb && safeUrl.contains('/speakingAudio/')) {
      return UrlSource(safeUrl, mimeType: 'audio/webm');
    }
    return UrlSource(safeUrl);
  }

  Future<void> _initAudio() async {
    if (widget.audioUrl.isEmpty ||
        widget.audioUrl == "null" ||
        widget.audioUrl.trim().isEmpty) {
      return;
    }

    try {
      await _audioPlayer
          .setSource(_getAudioSource(widget.audioUrl))
          .timeout(const Duration(seconds: 5));

      _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration;
          });
        }
      });

      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
        state,
      ) {
        if (!mounted) return;
        setState(() {
          _isPlaying = state == PlayerState.playing;
          // Clear buffering as soon as the player reaches any definitive state
          if (state == PlayerState.playing ||
              state == PlayerState.paused ||
              state == PlayerState.completed ||
              state == PlayerState.stopped) {
            _isBuffering = false;
          }
        });
        // Reset position when audio completes
        if (state == PlayerState.completed) {
          _audioPlayer.seek(Duration.zero).catchError((_) {});
          if (mounted) {
            setState(() {
              _position = Duration.zero;
              _isPlaying = false;
            });
          }
        }
      });

      // Get initial duration with timeout
      try {
        final duration = await _audioPlayer.getDuration().timeout(
          const Duration(seconds: 3),
        );
        if (duration != null && mounted) {
          setState(() {
            _duration = duration;
          });
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Audio initialization error: $e');
      debugPrint('Audio URL: ${widget.audioUrl}');
    }
  }

  /// Sets up player listeners for Web (without preloading source).
  void _initListenersForWeb() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
        if (state == PlayerState.playing ||
            state == PlayerState.paused ||
            state == PlayerState.completed ||
            state == PlayerState.stopped) {
          _isBuffering = false;
        }
      });
      if (state == PlayerState.completed) {
        _audioPlayer.seek(Duration.zero).catchError((_) {});
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _isPlaying = false;
          });
        }
      }
    });
  }

  void _handleAudioError(dynamic error) {
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('❌ AUDIO PLAYER ERROR');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('📍 URL: ${widget.audioUrl}');
    debugPrint('🔹 Error: $error');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );

    // Show overlay message to user
    if (mounted) {
      showOverlayMessage(
        context,
        text: "could_not_play_audio".tr(),
        status: OverlayStatus.failed,
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    try {
      _audioPlayer.stop().catchError((_) {});
    } catch (e) {
      // Ignore stop errors
    }

    try {
      _audioPlayer.release().catchError((_) {});
    } catch (e) {
      // Ignore release errors
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause() async {
    if (!mounted) return;

    if (widget.audioUrl.isEmpty ||
        widget.audioUrl == "null" ||
        widget.audioUrl.trim().isEmpty) {
      return;
    }

    // On Web: ensure listeners are set up before first play
    if (kIsWeb && _positionSubscription == null) {
      _initListenersForWeb();
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause().catchError((e) {
          debugPrint('Error pausing audio: $e');
        });
      } else {
        // Show buffering spinner while audio is fetched from network
        if (mounted) setState(() => _isBuffering = true);
        PlayerState? currentState;
        try {
          currentState = _audioPlayer.state;
        } catch (e) {
          currentState = PlayerState.stopped;
        }

        if (currentState == PlayerState.completed ||
            currentState == PlayerState.stopped ||
            (_duration > Duration.zero && _position == Duration.zero) ||
            (_duration > Duration.zero &&
                _position.inMilliseconds >= _duration.inMilliseconds - 50)) {
          try {
            // Always set source fresh (required on Web to avoid Format Error)
            try {
              await _audioPlayer
                  .setSource(_getAudioSource(widget.audioUrl))
                  .timeout(const Duration(seconds: 5));
            } catch (e) {
              _handleAudioError(e);
              return;
            }
            try {
              await _audioPlayer.seek(Duration.zero);
            } catch (e) {
              debugPrint('Error seeking audio: $e');
            }
            try {
              await _audioPlayer.resume().timeout(const Duration(seconds: 5));
            } catch (e) {
              _handleAudioError(e);
              return;
            }
          } catch (e) {
            _handleAudioError(e);
            return;
          }
        } else if (_position == Duration.zero && _duration == Duration.zero) {
          // First play on web — set source then resume
          try {
            await _audioPlayer
                .setSource(_getAudioSource(widget.audioUrl))
                .timeout(const Duration(seconds: 5));
            await _audioPlayer.resume().timeout(const Duration(seconds: 5));
          } catch (e) {
            _handleAudioError(e);
            return;
          }
        } else {
          try {
            await _audioPlayer.resume().timeout(const Duration(seconds: 3));
          } catch (e) {
            try {
              await _audioPlayer
                  .play(_getAudioSource(widget.audioUrl))
                  .timeout(const Duration(seconds: 3));
            } catch (playError) {
              _handleAudioError(playError);
              return;
            }
          }
        }
      }
    } catch (e) {
      _handleAudioError(e);
    }
  }

  Future<void> _seekTo(Duration position) async {
    if (!mounted) return;
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _rewind5Seconds() async {
    if (!mounted) return;
    try {
      final newPosition = _position - const Duration(seconds: 5);
      await _audioPlayer.seek(
        newPosition < Duration.zero ? Duration.zero : newPosition,
      );
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _forward5Seconds() async {
    if (!mounted) return;
    try {
      final newPosition = _position + const Duration(seconds: 5);
      await _audioPlayer.seek(
        newPosition > _duration ? _duration : newPosition,
      );
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds > 0
        ? _position.inMilliseconds / _duration.inMilliseconds
        : 0.0;
    final t = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: t.newMentourContainer20,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: t.newMentourBorder2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: t.newMentourPrimary2,
                shape: BoxShape.circle,
              ),
              child: _isBuffering
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
            ),
          ),
          const SizedBox(width: 15),

          // Times & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        color: t.newMentourText6,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        color: t.newMentourText6,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) async {
                        final tapPosition = details.localPosition.dx;
                        final newProgress = (tapPosition / constraints.maxWidth)
                            .clamp(0.0, 1.0);
                        final newPosition = Duration(
                          milliseconds: (_duration.inMilliseconds * newProgress)
                              .toInt(),
                        );
                        await _seekTo(newPosition);
                        if (_isPlaying) {
                          try {
                            await _audioPlayer.resume();
                          } catch (_) {}
                        }
                      },
                      onHorizontalDragStart: (details) {
                        setState(() {
                          _isDragging = true;
                          _dragPosition = _position;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        final tapPosition = details.localPosition.dx;
                        final newProgress = (tapPosition / constraints.maxWidth)
                            .clamp(0.0, 1.0);
                        final newPosition = Duration(
                          milliseconds: (_duration.inMilliseconds * newProgress)
                              .toInt(),
                        );
                        setState(() {
                          _dragPosition = newPosition;
                        });
                      },
                      onHorizontalDragEnd: (details) async {
                        await _seekTo(_dragPosition);
                        setState(() {
                          _isDragging = false;
                        });
                        if (_isPlaying) {
                          try {
                            await _audioPlayer.resume();
                          } catch (_) {}
                        }
                      },
                      child: Container(
                        height: 24,
                        width: double.infinity,
                        color: Colors.transparent,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: t.newMentourContainer24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 8,
                              width:
                                  (constraints.maxWidth *
                                          (_isDragging
                                              ? (_duration.inMilliseconds > 0
                                                    ? _dragPosition
                                                              .inMilliseconds /
                                                          _duration
                                                              .inMilliseconds
                                                    : 0.0)
                                              : progress))
                                      .clamp(0.0, constraints.maxWidth),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2D60FF),
                                    Color(0xFFB7C4FF),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Positioned(
                              left:
                                  ((constraints.maxWidth *
                                          (_isDragging
                                              ? (_duration.inMilliseconds > 0
                                                    ? _dragPosition
                                                              .inMilliseconds /
                                                          _duration
                                                              .inMilliseconds
                                                    : 0.0)
                                              : progress))
                                      .clamp(0.0, constraints.maxWidth)) -
                                  6,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: t.newMentourText4,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),

          // Skip Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _rewind5Seconds,
                child: Icon(
                  Icons.replay_5_rounded,
                  color: t.newMentourPrimary2,
                  size: 34,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _forward5Seconds,
                child: Icon(
                  Icons.forward_5_rounded,
                  color: t.newMentourPrimary2,
                  size: 34,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
