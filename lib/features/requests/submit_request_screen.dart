import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/request_validator.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/feedback_views.dart';
import '../../data/repositories/campus_repositories.dart';
import '../../routes/app_routes.dart';
import 'request_entry_type.dart';
import 'submit_request_controller.dart';
import 'widgets/image_attachment_box.dart';
import 'widgets/priority_selector.dart';

class SubmitRequestScreen extends StatelessWidget {
  const SubmitRequestScreen({super.key, required this.entryType});

  final RequestEntryType entryType;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: ErrorView(message: 'You need to be signed in to submit a request.'),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => SubmitRequestController(
        userId: uid,
        requestRepository: Get.find<RequestRepository>(),
        categoryRepository: Get.find<CategoryRepository>(),
      )..loadCategories(),
      child: _SubmitRequestView(entryType: entryType),
    );
  }
}

class _SubmitRequestView extends StatefulWidget {
  const _SubmitRequestView({required this.entryType});

  final RequestEntryType entryType;

  @override
  State<_SubmitRequestView> createState() => _SubmitRequestViewState();
}

class _SubmitRequestViewState extends State<_SubmitRequestView> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handlePop(SubmitRequestController controller) async {
    if (!controller.dirty) {
      Get.back();
      return;
    }
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard request?'),
        content: const Text(
          'You have unsaved changes. If you leave now, this request will not be submitted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) {
      Get.back();
    }
  }

  Future<void> _submit(SubmitRequestController controller) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final requestId = await controller.submit();
    if (!mounted) return;
    if (requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error ?? 'Unable to submit.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.entryType.successMessage)),
    );
    Get.offNamed(AppRoutes.requestDetails, arguments: requestId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SubmitRequestController>();

    return PopScope(
      canPop: !controller.dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop(controller);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.entryType.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => _handlePop(controller),
          ),
        ),
        body: controller.loadingCategories
            ? const LoadingView(message: 'Loading categories...')
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        AppSpacing.sm,
                        AppSpacing.screen,
                        AppSpacing.xxxl,
                      ),
                      children: [
                        AppTextField(
                          label: 'Request Title',
                          controller: controller.titleController,
                          hint: 'e.g. Classroom fan not working',
                          validator: RequestValidator.title,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => controller.markDirty(),
                        ).animate().fade(duration: 300.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.lg),
                        AppDropdownField<String>(
                          label: 'Category',
                          value: controller.categoryId,
                          hint: 'Select a category',
                          validator: RequestValidator.categoryId,
                          onChanged: controller.setCategory,
                          items: controller.categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ),
                              )
                              .toList(),
                        ).animate().fade(duration: 300.ms, delay: 50.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Location',
                          controller: controller.locationController,
                          hint: 'e.g. Block A - Room 203',
                          validator: RequestValidator.location,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => controller.markDirty(),
                        ).animate().fade(duration: 300.ms, delay: 100.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.lg),
                        PrioritySelector(
                          value: controller.priority,
                          onChanged: controller.setPriority,
                        ).animate().fade(duration: 300.ms, delay: 150.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          label: 'Description',
                          controller: controller.descriptionController,
                          hint: 'Describe the issue clearly so staff can help.',
                          maxLines: 5,
                          maxLength: 1000,
                          validator: RequestValidator.description,
                          onChanged: (_) => controller.markDirty(),
                        ).animate().fade(duration: 300.ms, delay: 200.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.lg),
                        ImageAttachmentBox(
                          image: controller.image,
                          onAdd: () => _showImageSourceBottomSheet(context, controller),
                          onRemove: controller.removeImage,
                        ).animate().fade(duration: 300.ms, delay: 250.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton(
                          label: widget.entryType.submitLabel,
                          loading: controller.submitting,
                          onPressed: () => _submit(controller),
                        ).animate().fade(duration: 300.ms, delay: 300.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void _showImageSourceBottomSheet(BuildContext context, SubmitRequestController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            MediaQuery.of(context).padding.bottom + AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
