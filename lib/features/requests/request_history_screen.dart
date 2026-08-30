import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/models/request_model.dart';
import '../../routes/app_routes.dart';
import 'request_history_controller.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestHistoryController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F8F8),
      appBar: _RequestAppBar(
        showBackButton: showBackButton,
        controller: controller,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(
              children: [
                _SearchBar(controller: controller)
                    .animate()
                    .fade(duration: 300.ms)
                    .slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
                _StatusFilters(controller: controller)
                    .animate()
                    .fade(duration: 300.ms, delay: 50.ms)
                    .slideY(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                const SizedBox(height: 4),
                Expanded(child: _RequestBody(controller: controller)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// APP BAR
// -----------------------------------------------------------------------------

class _RequestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _RequestAppBar({
    required this.showBackButton,
    required this.controller,
  });

  final bool showBackButton;
  final RequestHistoryController controller;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Text(
        'Requests',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF171717),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ).animate().fade(duration: 350.ms).slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            controller.searchFocusNode.requestFocus();
          },
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white : const Color(0xFF222222),
            size: 25,
          ),
        ),
        IconButton(
          tooltip: 'Filter',
          onPressed: () {
            _showFilterSheet(context, controller);
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.tune_rounded,
                color: isDark ? Colors.white : const Color(0xFF222222),
                size: 23,
              ),
              Obx(() {
                if (!controller.hasActiveFilters) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF18865C),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showFilterSheet(
    BuildContext context,
    RequestHistoryController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (_) {
        return _FilterSheet(controller: controller);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// SEARCH
// -----------------------------------------------------------------------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF222222)),
        decoration: InputDecoration(
          hintText: 'Search requests...',
          hintStyle: TextStyle(color: isDark ? const Color(0xFF888888) : const Color(0xFF9DA2A1), fontSize: 13),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF9DA2A1),
            size: 21,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: controller.clearSearch,
              icon: Icon(
                Icons.close_rounded,
                size: 19,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF777777),
              ),
            );
          }),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE7E9E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE7E9E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFF18865C), width: 1.2),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STATUS FILTERS
// -----------------------------------------------------------------------------

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.controller});

  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 51,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      child: Obx(
        () => ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _StatusFilterChip(
              label: 'All',
              selected: controller.selectedStatus.value == null,
              onTap: () {
                controller.setStatus(null);
              },
            ),
            ...RequestStatus.values.map(
              (status) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _StatusFilterChip(
                  label: status.label,
                  selected: controller.selectedStatus.value == status,
                  onTap: () {
                    controller.setStatus(status);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: selected
          ? const Color(0xFF18865C)
          : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F5F5)),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected
                  ? Colors.white
                  : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF565B5A)),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// REQUEST BODY
// -----------------------------------------------------------------------------

class _RequestBody extends StatelessWidget {
  const _RequestBody({required this.controller});

  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.errorMessage.value != null && !controller.isLoading.value) {
        return _ErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.reload,
        );
      }

      final isLoading = controller.isLoading.value;

      final requests = isLoading && controller.requests.isEmpty
          ? List.generate(
              5,
              (index) => CampusRequest(
                id: 'mock_$index',
                userId: 'dummy',
                title: 'Mock Request Title $index',
                description: 'Mock Request Description text for spacing and layout testing.',
                categoryId: 'internet',
                location: 'Block A - Room 203',
                priority: RequestPriority.medium,
                imageUrls: const [],
                status: RequestStatus.submitted,
                createdAt: DateTime.now(),
              ),
            )
          : controller.filteredRequests;

      if (!isLoading && controller.requests.isEmpty) {
        return const _EmptyRequestsState();
      }

      if (!isLoading && requests.isEmpty) {
        return _NoResultsState(controller: controller);
      }

      return Skeletonizer(
        enabled: isLoading,
        child: RefreshIndicator(
          color: const Color(0xFF18865C),
          onRefresh: controller.reload,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final horizontalPadding = constraints.maxWidth >= 700 ? 28.0 : 16.0;

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  28,
                ),
                itemCount: requests.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(height: 10);
                },
                itemBuilder: (_, index) {
                  return _RequestCard(
                    request: requests[index],
                    controller: controller,
                  ).animate().fade(duration: 250.ms, delay: (index * 30).ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
                },
              );
            },
          ),
        ),
      );
    });
  }
}

// -----------------------------------------------------------------------------
// REQUEST CARD
// -----------------------------------------------------------------------------

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.controller});

  final CampusRequest request;
  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.requestDetails, arguments: request.id);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 118),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBEDED),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryIcon(categoryId: request.categoryId),
              const SizedBox(width: 13),
              Expanded(
                child: _RequestInformation(
                  request: request,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 8),
              _RequestTrailing(status: request.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig(categoryId);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(config.icon, color: Colors.white, size: 21),
    );
  }

  _CategoryConfig _categoryConfig(String categoryId) {
    final value = categoryId.toLowerCase();

    if (value.contains('electric')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFFFFB51B),
        icon: Icons.bolt_rounded,
      );
    }

    if (value.contains('plumb') || value.contains('water')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFF8150D9),
        icon: Icons.water_drop_outlined,
      );
    }

    if (value.contains('internet') ||
        value.contains('wifi') ||
        value.contains('network')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFF20B77A),
        icon: Icons.wifi_rounded,
      );
    }

    if (value.contains('mainten') || value.contains('furniture')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFFE92E35),
        icon: Icons.chair_outlined,
      );
    }

    if (value.contains('clean')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFF3D8EEB),
        icon: Icons.cleaning_services_outlined,
      );
    }

    if (value.contains('hostel')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFF8150D9),
        icon: Icons.home_work_outlined,
      );
    }

    if (value.contains('security')) {
      return const _CategoryConfig(
        backgroundColor: Color(0xFFE94B4B),
        icon: Icons.security_outlined,
      );
    }

    return const _CategoryConfig(
      backgroundColor: Color(0xFF18865C),
      icon: Icons.assignment_outlined,
    );
  }
}

class _CategoryConfig {
  const _CategoryConfig({required this.backgroundColor, required this.icon});

  final Color backgroundColor;
  final IconData icon;
}

class _RequestInformation extends StatelessWidget {
  const _RequestInformation({required this.request, required this.controller});

  final CampusRequest request;
  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _categoryName(request.categoryId),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF555A59),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          request.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF555A59),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${request.displayId} • ${_formatDate(request.createdAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF8A8F8E),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  String _categoryName(String categoryId) {
    final value = categoryId.trim();

    if (value.isEmpty) {
      return 'General';
    }

    // Humanize Firebase category IDs.
    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date unavailable';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _RequestTrailing extends StatelessWidget {
  const _RequestTrailing({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.chevron_right_rounded,
          size: 21,
          color: isDark ? const Color(0xFF888888) : const Color(0xFF777D7B),
        ),
        const SizedBox(height: 18),
        _StatusBadge(status: status),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _statusConfig(status, isDark);

    return Container(
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: config.foreground,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(RequestStatus status, bool isDark) {
    if (isDark) {
      switch (status) {
        case RequestStatus.submitted:
          return const _StatusConfig(
            background: Color(0xFF2A2D2D),
            foreground: Color(0xFFA6ADAB),
          );
        case RequestStatus.underReview:
          return const _StatusConfig(
            background: Color(0xFF132D4C),
            foreground: Color(0xFF6FA8E8),
          );
        case RequestStatus.inProgress:
          return const _StatusConfig(
            background: Color(0xFF4C3312),
            foreground: Color(0xFFFBB040),
          );
        case RequestStatus.resolved:
          return const _StatusConfig(
            background: Color(0xFF0F3A26),
            foreground: Color(0xFF4EDB95),
          );
        case RequestStatus.rejected:
          return const _StatusConfig(
            background: Color(0xFF4E1618),
            foreground: Color(0xFFFA6A6F),
          );
      }
    } else {
      switch (status) {
        case RequestStatus.submitted:
          return const _StatusConfig(
            background: Color(0xFFF0F2F2),
            foreground: Color(0xFF656B69),
          );
        case RequestStatus.underReview:
          return const _StatusConfig(
            background: Color(0xFFDDEEFF),
            foreground: Color(0xFF2580C7),
          );
        case RequestStatus.inProgress:
          return const _StatusConfig(
            background: Color(0xFFFFE9C9),
            foreground: Color(0xFFE89326),
          );
        case RequestStatus.resolved:
          return const _StatusConfig(
            background: Color(0xFFDDF4E9),
            foreground: Color(0xFF269764),
          );
        case RequestStatus.rejected:
          return const _StatusConfig(
            background: Color(0xFFFFE0E0),
            foreground: Color(0xFFD43B3B),
          );
      }
    }
  }
}

class _StatusConfig {
  const _StatusConfig({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

// -----------------------------------------------------------------------------
// FILTER SHEET
// -----------------------------------------------------------------------------

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller});

  final RequestHistoryController controller;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  RequestStatus? status;
  String? categoryId;
  DateTime? from;
  DateTime? to;

  @override
  void initState() {
    super.initState();

    status = widget.controller.selectedStatus.value;
    categoryId = widget.controller.selectedCategoryId.value;
    from = widget.controller.selectedDateFrom.value;
    to = widget.controller.selectedDateTo.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 20),

              Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<RequestStatus?>(
                key: ValueKey(status),
                initialValue: status,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem<RequestStatus?>(
                    value: null,
                    child: Text('All statuses', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ),
                  ...RequestStatus.values.map((item) {
                    return DropdownMenuItem<RequestStatus?>(
                      value: item,
                      child: Text(item.label, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    status = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String?>(
                key: ValueKey(categoryId),
                initialValue: categoryId,
                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  ),
                  ...widget.controller.categories.map((category) {
                    return DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    categoryId = value;
                  });
                },
              ),

              const SizedBox(height: 18),

              Text(
                'Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : null,
                        side: isDark ? const BorderSide(color: Color(0xFF2C2C2C)) : null,
                      ),
                      onPressed: () => _pickDate(true),
                      child: Text(from == null ? 'From' : _dateText(from!)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : null,
                        side: isDark ? const BorderSide(color: Color(0xFF2C2C2C)) : null,
                      ),
                      onPressed: () => _pickDate(false),
                      child: Text(to == null ? 'To' : _dateText(to!)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : null,
                        side: isDark ? const BorderSide(color: Color(0xFF2C2C2C)) : null,
                      ),
                      onPressed: () {
                        setState(() {
                          status = null;
                          categoryId = null;
                          from = null;
                          to = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF18865C),
                      ),
                      onPressed: _apply,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: (isFrom ? from : to) ?? DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        from = picked;
      } else {
        to = picked;
      }
    });
  }

  String _dateText(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _apply() {
    if (from != null && to != null && from!.isAfter(to!)) {
      Get.snackbar(
        'Invalid date range',
        'The start date cannot be after the end date.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    widget.controller.setStatus(status);
    widget.controller.setCategory(categoryId);
    widget.controller.setDateRange(from, to);

    Get.back();
  }
}

// -----------------------------------------------------------------------------
// EMPTY / ERROR STATES
// -----------------------------------------------------------------------------

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 54,
              color: isDark ? const Color(0xFF6E7472) : const Color(0xFF9AA09E),
            ),
            const SizedBox(height: 14),
            Text(
              'No requests yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your submitted requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF747A78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.controller});

  final RequestHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 50,
              color: isDark ? const Color(0xFF6E7472) : const Color(0xFF9AA09E),
            ),
            const SizedBox(height: 14),
            Text(
              'No matching requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF747A78),
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : null,
                side: isDark ? const BorderSide(color: Color(0xFF2C2C2C)) : null,
              ),
              onPressed: () {
                controller.clearSearch();
                controller.clearFilters();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: isDark ? const Color(0xFF6E7472) : const Color(0xFF9AA09E),
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF747A78),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF18865C),
              ),
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
