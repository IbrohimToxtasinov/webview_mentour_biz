import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final String levelType;
  final String videoDescription;

  const VideoDetailScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.videoDescription,
    required this.levelType,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late final YoutubePlayerController _controller;
  bool _isFullScreen = false;
  final GlobalKey _playerKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        mute: false,
        loop: true,
        strictRelatedVideos: true,
        enableJavaScript: true,
        origin: 'https://www.youtube-nocookie.com',
        enableCaption: false,
      ),
    );

    _controller.listen((event) {
      if (mounted) {
        final fullScreen = _controller.value.fullScreenOption.enabled;
        if (_isFullScreen != fullScreen) {
          setState(() => _isFullScreen = fullScreen);
          if (fullScreen) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          } else {
            _restorePortrait();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    _restorePortrait();
    super.dispose();
  }

  Future<void> _restorePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _handleBackButton() async {
    if (_isFullScreen) {
      _controller.exitFullScreen();
      return;
    }

    await _restorePortrait();
    if (mounted) Navigator.pop(context);
  }

  Widget _buildPlayer() {
    return YoutubePlayer(
      key: _playerKey,
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    if (_isFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          await _handleBackButton();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(child: _buildPlayer()),
              Positioned(
                bottom: 20,
                right: 24,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      _controller.exitFullScreen();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _handleBackButton();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 24, bottom: 2),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          NewArrowBackButton(onTap: _handleBackButton),
                          Text(
                            "video_detail".tr(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: t.newMentourText7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    _buildPlayer(),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          _controller.enterFullScreen();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppUtils.levelColors(widget.levelType),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.levelType,
                          style: TextStyle(
                            color: t.mentourWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.videoTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: t.newMentourText3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.videoDescription,
                        style: TextStyle(
                          fontSize: 16,
                          color: t.newMentourText4,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
