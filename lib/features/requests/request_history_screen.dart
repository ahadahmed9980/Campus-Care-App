import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/request_model.dart';
import '../../routes/app_routes.dart';
import 'request_history_controller.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: _RequestAppBar(
        showBackButton: showBackButton,
        controller: controller,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _SearchBar(controller: controller),
            _StatusFilters(controller: controller),
            const SizedBox(height: 4),
            Expanded(child: _RequestBody(controller: controller)),
          ],
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      // leading: showBackButton
      //     ? IconButton(
      //         onPressed: Get.back,
      //         icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
      //       )
      //     : IconButton(
      //         onPressed: () {
      //           // Keep this available for future drawer integration.
      //         },
      //         icon: const Icon(Icons.menu_rounded, size: 24),
      //       ),
      title: const Text(
        'Requests',
        style: TextStyle(
          color: Color(0xFF171717),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          onPressed: () {
            controller.searchFocusNode.requestFocus();
          },
          icon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF222222),
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
              const Icon(
                Icons.tune_rounded,
                color: Color(0xFF222222),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: TextField(
        controller: controller.searchController,
        focusNode: controller.searchFocusNode,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, color: Color(0xFF222222)),
        decoration: InputDecoration(
          hintText: 'Search requests...',
          hintStyle: const TextStyle(color: Color(0xFF9DA2A1), fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF9DA2A1),
            size: 21,
          ),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              onPressed: controller.clearSearch,
              icon: const Icon(
                Icons.close_rounded,
                size: 19,
                color: Color(0xFF777777),
              ),
            );
          }),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFFE7E9E8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFFE7E9E8)),
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
    return Container(
      height: 51,
      color: Colors.white,
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
    return Material(
      color: selected ? const Color(0xFF18865C) : const Color(0xFFF4F5F5),
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
              color: selected ? Colors.white : const Color(0xFF565B5A),
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
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF18865C)),
        );
      }

      if (controller.errorMessage.value != null) {
        return _ErrorState(
          message: controller.errorMessage.value!,
          onRetry: controller.refresh,
        );
      }

      final requests = controller.filteredRequests;

      if (controller.requests.isEmpty) {
        return const _EmptyRequestsState();
      }

      if (requests.isEmpty) {
        return _NoResultsState(controller: controller);
      }

      return RefreshIndicator(
        color: const Color(0xFF18865C),
        onRefresh: controller.refresh,
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
              separatorBuilder: (_, __) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (_, index) {
                return _RequestCard(
                  request: requests[index],
                  controller: controller,
                );
              },
            );
          },
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
    return Material(
      color: Colors.white,
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
            border: Border.all(color: const Color(0xFFEBEDED), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _categoryName(request.categoryId),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF555A59),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          request.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF555A59),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${request.displayId} • ${_formatDate(request.createdAt)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8A8F8E),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Icon(
          Icons.chevron_right_rounded,
          size: 21,
          color: Color(0xFF777D7B),
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
    final config = _statusConfig(status);

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

  _StatusConfig _statusConfig(RequestStatus status) {
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Requests',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<RequestStatus?>(
                value: status,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  const DropdownMenuItem<RequestStatus?>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...RequestStatus.values.map((item) {
                    return DropdownMenuItem<RequestStatus?>(
                      value: item,
                      child: Text(item.label),
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

              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String?>(
                value: categoryId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...widget.controller.categories.map((category) {
                    return DropdownMenuItem<String?>(
                      value: category.id,
                      child: Text(category.name),
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

              const Text(
                'Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(true),
                      child: Text(from == null ? 'From' : _dateText(from!)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.assignment_outlined, size: 54, color: Color(0xFF9AA09E)),
            SizedBox(height: 14),
            Text(
              'No requests yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Your submitted requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF747A78)),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 50,
              color: Color(0xFF9AA09E),
            ),
            const SizedBox(height: 14),
            const Text(
              'No matching requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF747A78)),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Color(0xFF9AA09E),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF747A78)),
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
