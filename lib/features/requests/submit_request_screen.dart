import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
            : Form(
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
                    ),
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
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Location',
                      controller: controller.locationController,
                      hint: 'e.g. Block A - Room 203',
                      validator: RequestValidator.location,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => controller.markDirty(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    PrioritySelector(
                      value: controller.priority,
                      onChanged: controller.setPriority,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: 'Description',
                      controller: controller.descriptionController,
                      hint: 'Describe the issue clearly so staff can help.',
                      maxLines: 5,
                      maxLength: 1000,
                      validator: RequestValidator.description,
                      onChanged: (_) => controller.markDirty(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ImageAttachmentBox(
                      image: controller.image,
                      onAdd: controller.pickImage,
                      onRemove: controller.removeImage,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      label: widget.entryType.submitLabel,
                      loading: controller.submitting,
                      onPressed: () => _submit(controller),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
