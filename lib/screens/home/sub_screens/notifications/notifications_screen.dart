import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mentour_web_view/cubits/notifications/notifications_cubit.dart';
import 'package:mentour_web_view/data/models/notification/notification_model.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/ui_kit/theme/colors.dart';
import 'package:mentour_web_view/ui_kit/widgets/buttons/new_arrow_back_button.dart';
import 'package:mentour_web_view/utils/app_images.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          NotificationsCubit(sl.get())..fetchNotifications(refresh: true),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsCubit>().fetchNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: t.newMentourBg1,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: t.newMentourBg1,
              child: Row(
                children: [
                  NewArrowBackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "notifications".tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: t.newMentourText7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state.formStatus ==
                          FormStatus.fetchNotificationsInLoading &&
                      state.notifications.isEmpty) {
                    return Center(
                      child: Lottie.asset(
                        AppLotties.loader,
                        width: 320,
                        height: 320,
                      ),
                    );
                  } else if (state.formStatus ==
                          FormStatus.fetchNotificationsInFailure &&
                      state.notifications.isEmpty) {
                    return Center(
                      child: Text(
                        "error_occurred".tr(),
                        style: TextStyle(color: t.mentourText3),
                      ),
                    );
                  } else if (state.notifications.isEmpty) {
                    return _buildEmptyState(t);
                  }

                  return RefreshIndicator(
                    color: t.newMentourPrimary2,
                    backgroundColor: t.newMentourNavigationBg1,
                    onRefresh: () => context
                        .read<NotificationsCubit>()
                        .fetchNotifications(refresh: true),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount:
                          state.notifications.length +
                          (state.hasReachedMax ? 0 : 1),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index >= state.notifications.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _NotificationCard(
                          notification: state.notifications[index],
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
    );
  }

  Widget _buildEmptyState(ThemeData t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 80,
              color: t.mentourText2,
            ),
            const SizedBox(height: 16),
            Text(
              "notifications_soon".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: t.mentourText3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "notifications_empty".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: t.mentourText4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: t.newMentourContainer1,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: t.newMentourText4.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notification.createdAt.isNotEmpty) ...[
                              Text(
                                _formatDate(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: t.newMentourText3.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: t.newMentourText3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(width: 10),
                                Text(
                                  notification.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: t.newMentourText4,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: t.newMentourContainer1,
          border: Border.all(color: t.newMentourBorder2),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: t.newMentourText3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notification.content,
                    style: TextStyle(color: t.newMentourText4),
                  ),
                ),
              ],
            ),
            if (notification.createdAt.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: t.newMentourText3.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateTime.parse(dateString).toLocal();
      return DateFormat('dd.MM.yyyy / HH:mm').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }
}
