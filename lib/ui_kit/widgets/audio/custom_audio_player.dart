import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/overlay/overlays.dart';

// Global stream to broadcast the ID of the currently playing audio
const String _kPauseAll = '__PAUSE_ALL__';
final StreamController<String> _globalAudioStream =
    StreamController<String>.broadcast();

class CustomAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final bool isLocalFile;
  final VoidCallback? onDelete;

  const CustomAudioPlayer({
    super.key,
    required this.audioUrl,
    this.isLocalFile = false,
    this.onDelete,
  });

  /// Pauses all currently playing [CustomAudioPlayer] instances globally.
  static void pauseAll() {
    _globalAudioStream.add(_kPauseAll);
  }

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  late final AudioPlayer _audioPlayer;
  late final StreamSubscription<String> _globalSubscription;
  final String _playerId = UniqueKey().toString();

  bool _isPlaying = false;
  bool _isCompleted = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isCompleted = true;
          _position = Duration.zero;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Listen to global play events. If another player starts (or pauseAll is called), we pause this one.
    _globalSubscription = _globalAudioStream.stream.listen((playingId) {
      if (!mounted) return;
      final shouldPause =
          playingId == _kPauseAll || (playingId != _playerId && _isPlaying);
      if (shouldPause && _isPlaying) {
        try {
          _audioPlayer.pause();
        } catch (_) {
          // Player may already be disposed. Safely ignore.
        }
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });

    // NOTE: We intentionally do NOT preload audio here.
    // On Flutter Web, browsers block media loading without a user gesture
    // (Autoplay Policy). Preloading causes MEDIA_ELEMENT_ERROR: Format error (Code: 4).
    // Audio source is set lazily on the first play tap instead.
    if (!kIsWeb) {
      _initAudioNative();
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

  /// Preloads audio source on native platforms only.
  /// On Web this is skipped to comply with browser autoplay policies.
  Future<void> _initAudioNative() async {
    try {
      if (widget.isLocalFile) {
        await _audioPlayer.setSourceDeviceFile(widget.audioUrl);
      } else {
        await _audioPlayer.setSource(_getAudioSource(widget.audioUrl));
      }
    } catch (_) {
      // Ignore source init errors; they will be surfaced when play is tapped
    }
  }

  @override
  void dispose() {
    _globalSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        // Notify other players to stop
        _globalAudioStream.add(_playerId);

        if (_isCompleted) {
          // Audio finished — set source again and play from beginning
          _isCompleted = false;
          if (widget.isLocalFile && !kIsWeb) {
            await _audioPlayer.play(DeviceFileSource(widget.audioUrl));
          } else {
            // On Web: always set source fresh to avoid stale media element errors
            await _audioPlayer.setSource(_getAudioSource(widget.audioUrl));
            await _audioPlayer.resume();
          }
        } else if (_position > Duration.zero) {
          // Paused in the middle — resume
          await _audioPlayer.resume();
        } else {
          // First play — set source then play
          if (widget.isLocalFile && !kIsWeb) {
            await _audioPlayer.play(DeviceFileSource(widget.audioUrl));
          } else {
            // On Web: set source explicitly before playing
            await _audioPlayer.setSource(_getAudioSource(widget.audioUrl));
            await _audioPlayer.resume();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        showOverlayMessage(context, text: "could_not_open_audio".tr());
      }
    }
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isLocalFile ? t.mentourNavigationBarBg : t.mentourBg1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.mentourBorder1, width: 2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: t.mentourPrimary2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: t.mentourWhite,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    trackHeight: 9.0,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7.0,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14.0,
                    ),
                    activeTrackColor: t.mentourPrimary2,
                    inactiveTrackColor: t.mentourBorder1,
                    thumbColor: t.mentourPrimary2,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: _duration.inMilliseconds.toDouble() > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value:
                        _position.inMilliseconds.toDouble() > 0 &&
                            _position.inMilliseconds <= _duration.inMilliseconds
                        ? _position.inMilliseconds.toDouble()
                        : 0.0,
                    onChanged: (value) async {
                      final position = Duration(milliseconds: value.toInt());
                      await _audioPlayer.seek(position);
                      // If audio was completed and user seeks, reset completed flag
                      if (_isCompleted) {
                        setState(() {
                          _isCompleted = false;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: t.mentourText3,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: t.mentourText3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.onDelete != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
