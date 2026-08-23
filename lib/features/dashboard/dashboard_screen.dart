import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/feedback_views.dart';
import '../../data/models/campus_models.dart';
import '../../data/repositories/campus_repositories.dart';
import '../../routes/app_routes.dart';
import '../requests/request_entry_type.dart';
import '../requests/request_history_screen.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: ErrorView(message: 'You need to be signed in to view the dashboard.'),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => DashboardController(
        uid: uid,
        userRepository: Get.find<UserRepository>(),
        requestRepository: Get.find<RequestRepository>(),
        announcementRepository: Get.find<AnnouncementRepository>(),
      )..start(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DashboardController>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.start,
          child: _buildBody(context, controller),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardController controller) {
    if (controller.loading && controller.user == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          LoadingView(message: 'Loading your dashboard...'),
        ],
      );
    }

    if (controller.error != null && controller.user == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          ErrorView(message: controller.error!, onRetry: controller.start),
        ],
      );
    }

    final user = controller.user!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormatters.greeting()}, ${user.firstName} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Here’s what needs your attention today.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            _Avatar(user: user),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StudentInfoCard(
          user: user,
          departmentName: controller.departmentName,
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle('Overview'),
        const SizedBox(height: AppSpacing.md),
        OverviewGrid(controller: controller),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: AppSpacing.md),
        QuickActionsRow(
          onReportProblem: () => _openSubmit(
            context,
            RequestEntryType.problem,
          ),
          onSubmitComplaint: () => _openSubmit(
            context,
            RequestEntryType.complaint,
          ),
          onMyRequests: () => _openMyRequests(context),
          onCampusInfo: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Campus Info is owned by Developer 4.'),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle('Latest Request'),
        const SizedBox(height: AppSpacing.md),
        if (controller.latestRequest == null)
          const AppCard(
            child: Text(
              'You have not submitted a request yet. Use Report a Problem or Submit a Complaint to get started.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          LatestRequestCard(
            request: controller.latestRequest!,
            onTap: () => Get.toNamed(
              AppRoutes.requestDetails,
              arguments: controller.latestRequest!.id,
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        const _SectionTitle('Latest Announcement'),
        const SizedBox(height: AppSpacing.md),
        LatestAnnouncementCard(announcement: controller.latestAnnouncement),
      ],
    );
  }

  void _openSubmit(BuildContext context, RequestEntryType type) {
    Get.toNamed(AppRoutes.submitRequest, arguments: type);
  }

  void _openMyRequests(BuildContext context) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(1);
      return;
    }
    Get.to(() => const RequestHistoryScreen());
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final StudentUser user;

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl;
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl)
          : null,
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              user.initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}
