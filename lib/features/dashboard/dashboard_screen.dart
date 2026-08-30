import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/feedback_views.dart';
import '../../data/models/campus_models.dart';
import '../../data/models/request_model.dart';
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _buildBody(context, controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DashboardController controller) {
    final isLoadingSkeleton = controller.loading && controller.user == null;

    if (controller.error != null && controller.user == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          ErrorView(message: controller.error!, onRetry: controller.start),
        ],
      );
    }

    final user = controller.user ??
        const StudentUser(
          uid: 'dummy',
          fullName: 'John Doe',
          studentId: '2023-SE-123',
          email: 'johndoe@da.edu.pk',
          departmentName: 'Software Engineering',
          semester: '4th Semester',
        );

    final latestRequest = controller.latestRequest ??
        (isLoadingSkeleton
            ? const CampusRequest(
                id: 'dummy',
                userId: 'dummy',
                title: 'Mock Request Title',
                description: 'Mock Request Description',
                categoryId: 'General',
                location: 'Block C - Room 102',
                status: RequestStatus.submitted,
                priority: RequestPriority.medium,
                imageUrls: [],
                createdAt: null,
              )
            : null);

    final latestAnnouncement = controller.latestAnnouncement ??
        (isLoadingSkeleton
            ? AnnouncementPreview(
                id: 'dummy',
                title: 'Important Campus Notice',
                description:
                    'This is a description placeholder for announcements.',
                category: 'General',
                publishedAt: DateTime.now(),
              )
            : null);

    return Skeletonizer(
      enabled: isLoadingSkeleton,
      child: ListView(
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
                    Text(
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
          ).animate().fade(duration: 350.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.xl),
          StudentInfoCard(
            user: user,
            departmentName: controller.departmentName,
          ).animate().fade(duration: 350.ms, delay: 80.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('Overview')
              .animate()
              .fade(duration: 350.ms, delay: 160.ms),
          const SizedBox(height: AppSpacing.md),
          OverviewGrid(controller: controller)
              .animate()
              .fade(duration: 350.ms, delay: 160.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('Quick Actions')
              .animate()
              .fade(duration: 350.ms, delay: 240.ms),
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
          ).animate().fade(duration: 350.ms, delay: 240.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('Latest Request')
              .animate()
              .fade(duration: 350.ms, delay: 320.ms),
          const SizedBox(height: AppSpacing.md),
          (latestRequest == null
              ? AppCard(
                  child: Text(
                    'You have not submitted a request yet. Use Report a Problem or Submit a Complaint to get started.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : LatestRequestCard(
                  request: latestRequest,
                  onTap: () => Get.toNamed(
                    AppRoutes.requestDetails,
                    arguments: latestRequest.id,
                  ),
                )).animate().fade(duration: 350.ms, delay: 320.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('Latest Announcement')
              .animate()
              .fade(duration: 350.ms, delay: 400.ms),
          const SizedBox(height: AppSpacing.md),
          LatestAnnouncementCard(announcement: latestAnnouncement)
              .animate()
              .fade(duration: 350.ms, delay: 400.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
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
