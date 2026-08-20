import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/campus_models.dart';
import '../../../data/models/request_model.dart';
import '../dashboard_controller.dart';

class StudentInfoCard extends StatelessWidget {
  const StudentInfoCard({
    super.key,
    required this.user,
    this.departmentName,
  });

  final StudentUser user;
  final String? departmentName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullName.isEmpty ? 'CampusCare Student' : user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(label: 'Student ID', value: user.studentId),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Department',
            value: _departmentValue(departmentName, user),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            label: 'Semester',
            value: user.semesterLabel,
          ),
        ],
      ),
    );
  }

  String _departmentValue(String? departmentName, StudentUser user) {
    final fromController = departmentName?.trim() ?? '';
    if (fromController.isNotEmpty) return fromController;
    final fromProfile = user.departmentName?.trim() ?? '';
    if (fromProfile.isNotEmpty) return fromProfile;
    final fromId = user.departmentId?.trim() ?? '';
    if (fromId.isNotEmpty) return fromId;
    return '—';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class OverviewGrid extends StatelessWidget {
  const OverviewGrid({super.key, required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      children: [
        _OverviewTile(
          count: controller.openCount,
          label: 'Open Requests',
          color: AppColors.open,
          icon: Icons.assignment_outlined,
        ),
        _OverviewTile(
          count: controller.inProgressCount,
          label: 'In Progress',
          color: AppColors.inProgress,
          icon: Icons.timelapse_rounded,
        ),
        _OverviewTile(
          count: controller.resolvedCount,
          label: 'Resolved',
          color: AppColors.resolved,
          icon: Icons.check_circle_outline,
        ),
        _OverviewTile(
          count: controller.announcementCount,
          label: 'Announcements',
          color: AppColors.announcement,
          icon: Icons.campaign_outlined,
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  final int count;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onReportProblem,
    required this.onSubmitComplaint,
    required this.onMyRequests,
    required this.onCampusInfo,
  });

  final VoidCallback onReportProblem;
  final VoidCallback onSubmitComplaint;
  final VoidCallback onMyRequests;
  final VoidCallback onCampusInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.report_gmailerrorred_outlined,
          label: 'Report a\nProblem',
          onTap: onReportProblem,
        ),
        _QuickAction(
          icon: Icons.feedback_outlined,
          label: 'Submit a\nComplaint',
          onTap: onSubmitComplaint,
        ),
        _QuickAction(
          icon: Icons.assignment_outlined,
          label: 'My\nRequests',
          onTap: onMyRequests,
        ),
        _QuickAction(
          icon: Icons.apartment_outlined,
          label: 'Campus\nInfo',
          onTap: onCampusInfo,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LatestAnnouncementCard extends StatelessWidget {
  const LatestAnnouncementCard({super.key, required this.announcement});

  final AnnouncementPreview? announcement;

  @override
  Widget build(BuildContext context) {
    if (announcement == null) {
      return const AppCard(
        child: Text(
          'No announcements have been published yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.announcement.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: AppColors.announcement,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement!.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement!.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormatters.shortDate(announcement!.publishedAt),
                  style: const TextStyle(
                    fontSize: 12,
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

class LatestRequestCard extends StatelessWidget {
  const LatestRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final CampusRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.location,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormatters.relative(request.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(status: request.status, compact: true),
        ],
      ),
    );
  }
}
