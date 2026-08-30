import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/campus_info_controller.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/models/campus_models.dart';
import '../../routes/app_routes.dart';

class CampusInfoScreen extends StatelessWidget {
  const CampusInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(CampusInfoController());
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Campus Information',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        foregroundColor: isDark ? Colors.white : AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search information...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allItems.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.errorMsg.value != null && controller.allItems.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: isDark ? Colors.redAccent : AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          controller.errorMsg.value!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: controller.fetchCampusInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final items = controller.filteredItems;
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchCampusInfo,
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: isDark ? Colors.white54 : AppColors.textMedium.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No matching campus information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchCampusInfo,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screen,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CampusInfoCard(
                      item: item,
                      onTap: () {
                        Get.toNamed(AppRoutes.campusInfoDetail, arguments: item);
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CampusInfoCard extends StatelessWidget {
  const _CampusInfoCard({
    required this.item,
    required this.onTap,
  });

  final CampusInfo item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedTime = _formatTimings(item.timings);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          item.location.formatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          formattedTime,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextLight : AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.contact.phone.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () => _callNumber(item.contact.phone),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatTimings(Map<String, TimeSlot> timings) {
    if (timings.isEmpty) return 'No timings available';
    
    final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final dayLabels = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };

    final openDays = <String>[];
    String? firstTimeRange;
    bool allSame = true;

    for (final day in daysOfWeek) {
      final slot = timings[day];
      if (slot != null && slot.isOpen) {
        final range = '${slot.open} - ${slot.close}';
        if (firstTimeRange == null) {
          firstTimeRange = range;
        } else if (firstTimeRange != range) {
          allSame = false;
        }
        openDays.add(day);
      }
    }

    if (openDays.isEmpty) return 'Closed';

    String formatTimeStr(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      try {
        final parts = timeStr.split(':');
        if (parts.length < 2) return timeStr;
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        // Formats using 12 hour AM/PM logic
        final isPm = hour >= 12;
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final displayMin = minute.toString().padLeft(2, '0');
        final period = isPm ? 'PM' : 'AM';
        return '$displayHour:$displayMin $period';
      } catch (_) {
        return timeStr;
      }
    }

    if (allSame && firstTimeRange != null && openDays.length > 1) {
      final startDay = openDays.first;
      final endDay = openDays.last;
      
      final startIndex = daysOfWeek.indexOf(startDay);
      final endIndex = daysOfWeek.indexOf(endDay);
      bool consecutive = (endIndex - startIndex + 1) == openDays.length;

      final slot = timings[startDay]!;
      final timeFormatted = '${formatTimeStr(slot.open)} - ${formatTimeStr(slot.close)}';

      if (consecutive) {
        return '${dayLabels[startDay]} - ${dayLabels[endDay]} ($timeFormatted)';
      }
    }

    final buffer = StringBuffer();
    for (final day in daysOfWeek) {
      final slot = timings[day];
      if (slot != null && slot.isOpen) {
        final timeFormatted = '${formatTimeStr(slot.open)} - ${formatTimeStr(slot.close)}';
        buffer.write('${dayLabels[day]}: $timeFormatted, ');
      }
    }
    final result = buffer.toString();
    if (result.endsWith(', ')) {
      return result.substring(0, result.length - 2);
    }
    return result.isEmpty ? 'Closed' : result;
  }
}
