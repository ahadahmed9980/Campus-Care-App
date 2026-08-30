import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/notification_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/notification_model.dart';
import '../../routes/app_routes.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount == 0) {
              return const SizedBox.shrink();
            }

            final isMarking = controller.isMarkingAllRead.value;

            return TextButton(
              onPressed: isMarking ? null : controller.markAllAsRead,
              child: isMarking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            );
          }),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Obx(() {
            if (controller.errorMessage.value != null && !controller.isLoading.value) {
              return _ErrorState(
                message: controller.errorMessage.value!,
                onRetry: controller.reload,
              );
            }

            final isLoading = controller.isLoading.value;

            final notificationsList = isLoading && controller.notifications.isEmpty
                ? List.generate(
                    5,
                    (index) => CampusNotification(
                      id: 'mock_$index',
                      title: 'Mock Notification Title $index',
                      message: 'This is a description placeholder for mock notification messages to check layout spacing and visual flow.',
                      type: 'request_resolved',
                      isRead: false,
                      createdAt: DateTime.now(),
                    ),
                  )
                : controller.notifications;

            if (!isLoading && controller.notifications.isEmpty) {
              return const _EmptyNotificationsState();
            }

            return Skeletonizer(
              enabled: isLoading,
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.reload,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth >= 700
                        ? 28.0
                        : 16.0;

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        32,
                      ),
                      itemCount: notificationsList.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notification = notificationsList[index];

                        return _NotificationCard(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                        ).animate().fade(duration: 250.ms, delay: (index * 30).ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
                      },
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(CampusNotification notification) async {
    await controller.markAsRead(notification);

    final requestId = notification.requestId;

    if (requestId != null && requestId.trim().isNotEmpty) {
      Get.toNamed(AppRoutes.requestDetails, arguments: requestId);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final CampusNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unread ? (Get.isDarkMode ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryLight) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(type: notification.type, unread: unread),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: unread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (notification.message.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],

                    const SizedBox(height: 9),

                    Text(
                      _formatNotificationDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.type, required this.unread});

  final String type;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    final iconData = _iconForType(type);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: unread
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, size: 22, color: AppColors.primary),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'request_submitted':
        return Icons.assignment_turned_in_outlined;

      case 'request_status_changed':
      case 'status_changed':
        return Icons.update_outlined;

      case 'request_resolved':
        return Icons.task_alt_outlined;

      case 'announcement':
        return Icons.campaign_outlined;

      case 'maintenance':
        return Icons.build_outlined;

      default:
        return Icons.notifications_none_outlined;
    }
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 38,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              'You’re all caught up. New updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.rejected,
            ),

            const SizedBox(height: 16),

            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

String _formatNotificationDate(DateTime? date) {
  if (date == null) {
    return 'Just now';
  }

  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Just now';
  }

  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }

  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }

  if (difference.inDays == 1) {
    return 'Yesterday';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
