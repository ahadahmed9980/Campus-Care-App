import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/feedback_views.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: StreamBuilder<CampusRequest?>(
        stream: context.read<RequestRepository>().watchRequest(requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const LoadingView(message: 'Loading request...');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Unable to load this request.',
              onRetry: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RequestDetailsScreen(requestId: requestId),
                ),
              ),
            );
          }
          final request = snapshot.data;
          if (request == null) {
            return const EmptyView(
              title: 'Request not found',
              message: 'This request may have been removed.',
              icon: Icons.search_off_outlined,
            );
          }
          return _RequestDetailsBody(request: request);
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
      future: context.read<CategoryRepository>().getActiveCategories(),
      builder: (context, categorySnapshot) {
        final categories = categorySnapshot.data ?? const <RequestCategory>[];
        final matching = categories.where((item) => item.id == request.categoryId);
        final categoryName =
            matching.isEmpty ? request.categoryId : matching.first.name;

        return ListView(
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              request.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
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
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                request.description,
                style: const TextStyle(height: 1.45),
              ),
            ),
            if (request.imageUrls.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Attached Image',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
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
              ),
            ],
            if (request.resolutionInfo != null &&
                request.resolutionInfo!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Resolution',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Text(request.resolutionInfo!),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),
            _StatusOverview(request: request),
          ],
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
                style: const TextStyle(
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
    return AppCard(
      child: Column(
        children: RequestStatus.values.map((status) {
          final reached = _hasReached(request.status, status);
          final current = request.status == status;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  current
                      ? Icons.radio_button_checked
                      : reached
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                  color: current
                      ? status.color
                      : reached
                          ? AppColors.primary
                          : AppColors.border,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  status.label,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                    color: current ? status.color : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasReached(RequestStatus current, RequestStatus step) {
    if (current == RequestStatus.rejected) {
      return step == RequestStatus.submitted || step == RequestStatus.rejected;
    }
    const order = [
      RequestStatus.submitted,
      RequestStatus.underReview,
      RequestStatus.inProgress,
      RequestStatus.resolved,
    ];
    return order.indexOf(step) <= order.indexOf(current) &&
        step != RequestStatus.rejected;
  }
}
