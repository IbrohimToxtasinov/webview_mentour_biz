import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/blocs/library/library_bloc.dart';
import 'package:mentour_web_view/blocs/profile/profile_bloc.dart';
import 'package:mentour_web_view/data/models/library/video_library_model.dart';
import 'package:mentour_web_view/screens/router.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  String? _parseYoutubeId(String input) {
    String url = input;
    if (input.contains('<iframe')) {
      final RegExp srcRegex = RegExp(r'src="([^"]+)"');
      final match = srcRegex.firstMatch(input);
      if (match != null && match.groupCount >= 1) {
        url = match.group(1) ?? input;
      }
    }

    final RegExp regExp = RegExp(
      r'^.*((youtu.be/)|(v/)|(/u/\w/)|(embed/)|(watch\?))\??v?=?([^#&?]*).*',
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(7)!.length == 11)
        ? match.group(7)
        : null;
  }

  bool isPlatformContent = true;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 24),
              child: Row(
                children: [
                  NewArrowBackButton(onTap: () => Navigator.pop(context)),
                  Text(
                    "video_library".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: t.newMentourText7,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.newMentourContainer1,
                        border: Border.all(color: t.newMentourBorder2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPlatformContent = true;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPlatformContent
                                      ? t.newMentourPrimary2
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "platform_content".tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isPlatformContent
                                        ? t.newMentourText9
                                        : t.newMentourText4,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPlatformContent = false;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isPlatformContent
                                      ? t.newMentourPrimary2
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "my_center".tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: !isPlatformContent
                                        ? t.newMentourText9
                                        : t.newMentourText4,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    BlocProvider(
                      create: (context) => LibraryBloc()
                        ..add(
                          GetLibraryVideos(
                            itemType: "VIDEOS",
                            levelId: BlocProvider.of<ProfileBloc>(
                              context,
                            ).state.profileModel.level.uuid,
                            schoolUuid: BlocProvider.of<ProfileBloc>(
                              context,
                            ).state.profileModel.schoolInfo.uuid,
                          ),
                        ),
                      child: BlocBuilder<LibraryBloc, LibraryState>(
                        builder: (context, state) {
                          if (state.status ==
                              FormStatus.getLibraryVideosInLoading) {
                            return Expanded(
                              child: Center(
                                child: Lottie.asset(
                                  AppLotties.loader,
                                  width: 320,
                                  height: 320,
                                ),
                              ),
                            );
                          } else if (state.status ==
                              FormStatus.getLibraryVideosInSuccess) {
                            final List<VideoLibraryModel> displayedVideos =
                                state.libraryVideos
                                    .where((v) => v.global == isPlatformContent)
                                    .toList();
                            return Expanded(
                              child: displayedVideos.isEmpty
                                  ? Center(
                                      child: Text(
                                        "no_data_yet".tr(),
                                        style: TextStyle(
                                          color: t.mentourIcon1,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: EdgeInsets.only(bottom: 20),
                                      itemCount: displayedVideos.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 20);
                                      },
                                      itemBuilder: (context, index) {
                                        final video = displayedVideos[index];
                                        final String? videoId = _parseYoutubeId(
                                          video.contentUrl,
                                        );
                                        final String thumbnailUrl =
                                            videoId != null
                                            ? "https://img.youtube.com/vi/$videoId/hqdefault.jpg"
                                            : "";
                                        return _VideoItemWidget(
                                          thumbnailUrl: thumbnailUrl,
                                          level: video.level.name,
                                          title: video.title,
                                          description: video.description,
                                          onTap: () {
                                            if (videoId != null) {
                                              Navigator.pushNamed(
                                                context,
                                                AppRouterNames.videoDetailRoute,
                                                arguments: {
                                                  "videoId": videoId,
                                                  "videoTitle": video.title,
                                                  "levelType": video.level.name,
                                                  "videoDescription":
                                                      video.description,
                                                },
                                              );
                                            }
                                          },
                                        );
                                      },
                                    ),
                            );
                          } else if (state.status ==
                              FormStatus.getLibraryVideosInFailure) {
                            return Expanded(
                              child: Center(child: Text(state.errorMessage)),
                            );
                          } else {
                            return SizedBox();
                          }
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
  }
}

class _VideoItemWidget extends StatelessWidget {
  final String thumbnailUrl;
  final String level;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _VideoItemWidget({
    required this.thumbnailUrl,
    required this.level,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: t.newMentourContainer1,
          border: Border.all(color: t.newMentourBorder2),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ThumbnailSection(
              thumbnailUrl: thumbnailUrl,
              level: level,
              levelColor: AppUtils.levelColors(level),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.newMentourText3,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: t.newMentourText4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailSection extends StatefulWidget {
  final String thumbnailUrl;
  final String level;
  final Color levelColor;

  const _ThumbnailSection({
    required this.thumbnailUrl,
    required this.level,
    required this.levelColor,
  });

  @override
  State<_ThumbnailSection> createState() => _ThumbnailSectionState();
}

class _ThumbnailSectionState extends State<_ThumbnailSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Image.network(
                widget.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: t.newMentourBorder2,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.white24,
                    size: 48,
                  ),
                ),
              ),
            ),

            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(0xFFA8B3E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF002583),
                  size: 32,
                ),
              ),
            ),

            // Level badge top-left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.levelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
