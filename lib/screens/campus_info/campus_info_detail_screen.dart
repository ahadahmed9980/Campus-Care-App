import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/campus_models.dart';

class CampusInfoDetailScreen extends StatelessWidget {
  const CampusInfoDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CampusInfo item = Get.arguments as CampusInfo;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        foregroundColor: isDark ? Colors.white : AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screen,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge & Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isDark
                          ? AppColors.darkTextLight
                          : AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Location card
            _buildSectionHeader(
              context,
              'Location Details',
              Icons.place_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Building',
                    value: item.location.building.isNotEmpty
                        ? item.location.building
                        : '—',
                    icon: Icons.apartment_rounded,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow(
                    context,
                    label: 'Floor',
                    value: item.location.floor.isNotEmpty
                        ? '${item.location.floor} Floor'
                        : '—',
                    icon: Icons.layers_rounded,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow(
                    context,
                    label: 'Room',
                    value: item.location.room.isNotEmpty
                        ? item.location.room
                        : '—',
                    icon: Icons.meeting_room_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Contact Card
            _buildSectionHeader(
              context,
              'Contact Information',
              Icons.contact_phone_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildActionDetailRow(
                    context,
                    label: 'Phone',
                    value: item.contact.phone.isNotEmpty
                        ? item.contact.phone
                        : '—',
                    icon: Icons.phone_android_rounded,
                    onTap: item.contact.phone.isNotEmpty
                        ? () => _launchURL(
                            'tel:${item.contact.phone.replaceAll(RegExp(r'\s+'), '')}',
                          )
                        : null,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildActionDetailRow(
                    context,
                    label: 'Email',
                    value: item.contact.email.isNotEmpty
                        ? item.contact.email
                        : '—',
                    icon: Icons.email_rounded,
                    onTap: item.contact.email.isNotEmpty
                        ? () => _launchURL('mailto:${item.contact.email}')
                        : null,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildActionDetailRow(
                    context,
                    label: 'Website',
                    value: item.contact.website.isNotEmpty
                        ? item.contact.website
                        : '—',
                    icon: Icons.language_rounded,
                    onTap: item.contact.website.isNotEmpty
                        ? () => _launchURL(item.contact.website)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Timings Card
            _buildSectionHeader(
              context,
              'Timings & Operating Hours',
              Icons.access_time_filled_rounded,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.border,
                ),
              ),
              child: Column(children: _buildTimingsList(context, item.timings)),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white54 : AppColors.textMedium,
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textMedium,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canTap = onTap != null && value != '—';

    return GestureDetector(
      onTap: canTap ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: canTap
                ? AppColors.primary
                : (isDark ? Colors.white54 : AppColors.textMedium),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textMedium,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: canTap
                      ? AppColors.primary
                      : (isDark ? Colors.white : AppColors.textDark),
                  decoration: canTap
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
          if (canTap) ...[
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.open_in_new_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTimingsList(
    BuildContext context,
    Map<String, TimeSlot> timings,
  ) {
    final daysOfWeek = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final dayLabels = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };

    final widgets = <Widget>[];

    for (int i = 0; i < daysOfWeek.length; i++) {
      final day = daysOfWeek[i];
      final slot = timings[day];
      final isDark = Theme.of(context).brightness == Brightness.dark;

      final isOpen = slot?.isOpen ?? false;
      final String timeStr;
      if (isOpen) {
        timeStr =
            '${_formatTimeStr(slot?.open)} - ${_formatTimeStr(slot?.close)}';
      } else {
        timeStr = 'Closed';
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                dayLabels[day]!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isOpen
                      ? (isDark ? Colors.white : AppColors.textDark)
                      : (isDark ? Colors.white38 : AppColors.textMedium),
                ),
              ),
            ],
          ),
        ),
      );

      if (i < daysOfWeek.length - 1) {
        widgets.add(const Divider(height: 12, thickness: 0.5));
      }
    }

    return widgets;
  }

  String _formatTimeStr(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final isPm = hour >= 12;
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayMin = minute.toString().padLeft(2, '0');
      final period = isPm ? 'PM' : 'AM';
      return '$displayHour:$displayMin $period';
    } catch (_) {
      return timeStr;
    }
  }

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
