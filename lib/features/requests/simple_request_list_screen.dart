import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/feedback_views.dart';
import '../../core/widgets/status_chip.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/campus_repositories.dart';
import '../../routes/app_routes.dart';
import 'request_entry_type.dart';

/// Lightweight list so students can open request details from Dashboard.
/// Search, filtering, and sorting are owned by Developer 3.
class SimpleRequestListScreen extends StatelessWidget {
  const SimpleRequestListScreen({
    super.key,
    this.showBackButton = true,
  });

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: ErrorView(message: 'You need to be signed in to view requests.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        automaticallyImplyLeading: showBackButton,
      ),
      body: StreamBuilder<List<CampusRequest>>(
        stream: Get.find<RequestRepository>().watchUserRequests(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const LoadingView(message: 'Loading your requests...');
          }
          if (snapshot.hasError) {
            return const ErrorView(
              message: 'Unable to load your requests right now.',
            );
          }
          final requests = snapshot.data ?? const [];
          if (requests.isEmpty) {
            return EmptyView(
              title: 'No requests yet',
              message:
                  'When you report a problem or submit a complaint, it will show up here.',
              icon: Icons.assignment_outlined,
              actionLabel: 'Report a Problem',
              onAction: () => Get.toNamed(
                AppRoutes.submitRequest,
                arguments: RequestEntryType.problem,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final request = requests[index];
              return AppCard(
                onTap: () => Get.toNamed(
                  AppRoutes.requestDetails,
                  arguments: request.id,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            request.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            DateFormatters.dateTime(request.createdAt),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(status: request.status, compact: true),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
