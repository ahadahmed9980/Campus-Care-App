import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/feedback_views.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';
import '../../routes/app_routes.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: StreamBuilder<CampusRequest?>(
        stream: Get.find<RequestRepository>().watchRequest(requestId),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData;

          if (snapshot.hasError) {
            return ErrorView(
              message: 'Unable to load this request.',
              onRetry: () => Get.offNamed(
                AppRoutes.requestDetails,
                arguments: requestId,
              ),
            );
          }

          final request = snapshot.data ?? (isLoading ? const CampusRequest(
            id: 'dummy',
            userId: 'dummy',
            title: 'Mock Request Title',
            description: 'Mock Request description text showing details about the issue reported by the student for layout and visual styling test purposes.',
            categoryId: 'Internet Issue',
            location: 'Block B - Room 203',
            priority: RequestPriority.medium,
            imageUrls: [],
            status: RequestStatus.submitted,
            createdAt: null,
          ) : null);

          if (request == null) {
            return const EmptyView(
              title: 'Request not found',
              message: 'This request may have been removed.',
              icon: Icons.search_off_outlined,
            );
          }

          return Skeletonizer(
            enabled: isLoading,
            child: _RequestDetailsBody(request: request),
          );
        },
      ),
    );
  }
}

class _RequestDetailsBody extends StatelessWidget {
  const _RequestDetailsBody({required this.request});

  final CampusRequest request;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RequestCategory>>(
      future: Get.find<CategoryRepository>().getActiveCategories(),
      builder: (context, categorySnapshot) {
        final categories = categorySnapshot.data ?? const <RequestCategory>[];
        final matching = categories.where((item) => item.id == request.categoryId);
        final categoryName =
            matching.isEmpty ? request.categoryId : matching.first.name;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              children: [
                Row(
                  children: [
                    StatusChip(status: request.status),
                    const Spacer(),
                    Text(
                      request.displayId,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ).animate().fade(duration: 300.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ).animate().fade(duration: 300.ms, delay: 50.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Column(
                    children: [
                      _DetailRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: categoryName,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.place_outlined,
                        label: 'Location',
                        value: request.location,
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.flag_outlined,
                        label: 'Priority',
                        valueWidget: PriorityDot(priority: request.priority),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.event_outlined,
                        label: 'Date Submitted',
                        value: DateFormatters.dateTime(request.createdAt),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ).animate().fade(duration: 300.ms, delay: 150.ms),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  child: Text(
                    request.description,
                    style: const TextStyle(height: 1.45),
                  ),
                ).animate().fade(duration: 300.ms, delay: 150.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                if (request.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Attached Image',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ).animate().fade(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        request.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.primaryLight,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                ],
                if (request.resolutionInfo != null &&
                    request.resolutionInfo!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const Text(
                    'Resolution',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ).animate().fade(duration: 300.ms, delay: 250.ms),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Text(request.resolutionInfo!),
                  ).animate().fade(duration: 300.ms, delay: 250.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                ],
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ).animate().fade(duration: 300.ms, delay: 300.ms),
                const SizedBox(height: AppSpacing.md),
                _StatusOverview(request: request).animate().fade(duration: 300.ms, delay: 300.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              valueWidget ??
                  Text(
                    value ?? '—',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusOverview extends StatelessWidget {
  const _StatusOverview({required this.request});

  final CampusRequest request;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StatusHistoryEntry>>(
      stream: Get.find<RequestRepository>().watchStatusHistory(request.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const AppCard(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return AppCard(
            child: Text(
              'Unable to load status history.',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        final history = snapshot.data ?? const <StatusHistoryEntry>[];

        if (history.isEmpty) {
          return _FallbackStatusTimeline(request: request);
        }

        return AppCard(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final isLast = index == history.length - 1;

                  return _TimelineItem(
                    entry: entry,
                    isLast: isLast,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.entry,
    required this.isLast,
  });

  final StatusHistoryEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status = entry.status;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 70,
                  margin: const EdgeInsets.only(top: 4),
                  color: AppColors.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: status.color,
                  ),
                ),
                if (entry.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormatters.dateTime(entry.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (entry.message.trim().isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    entry.message,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _FallbackStatusTimeline extends StatelessWidget {
  const _FallbackStatusTimeline({
    required this.request,
  });

  final CampusRequest request;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: request.status.color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.status.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: request.status.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current request status',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
