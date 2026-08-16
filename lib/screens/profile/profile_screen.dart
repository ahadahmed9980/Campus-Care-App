import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // themeNotifier ko access karne ke liye
import '../../models/student_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<StudentModel?>(
      stream: AuthService().studentProfileStream(user.uid),
      builder: (context, snapshot) {
        final student = snapshot.data;

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── App Bar Header ──
              SliverAppBar(
                expandedHeight: 230,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(student: student, user: user, isDark: isDark),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: student == null
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditProfileScreen(student: student),
                              ),
                            ),
                  ),
                ],
              ),

              // ── Content Details ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Student Info Card
                      _SectionCard(
                        title: 'Student Information',
                        isDark: isDark,
                        children: [
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Student ID',
                            value: student?.studentId ?? '—',
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Department',
                            value: student?.department ?? '—',
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.calendar_month_outlined,
                            label: 'Semester',
                            value: student?.semester ?? '—',
                            isDark: isDark,
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: student?.email ?? user.email ?? '—',
                            isDark: isDark,
                          ),
                          if ((student?.phone ?? '').isNotEmpty)
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: student!.phone,
                              isDark: isDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Settings & Preferences Card
                      _SectionCard(
                        title: 'Settings & Preferences',
                        isDark: isDark,
                        children: [
                          _ActionRow(
                            icon: Icons.notifications_active_outlined,
                            label: 'Notifications', // 👈 Updated label here
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                          ),
                          _ActionRow(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            ),
                          ),
                          // Dark Mode & Push Notifications Toggles
                          _PreferencesToggles(isDark: isDark),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Logout Button
                      _LogoutButton(isDark: isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final StudentModel? student;
  final User user;
  final bool isDark;

  const _ProfileHeader({required this.student, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [AppColors.primaryDark, AppColors.primaryMid],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: Colors.white24,
            ),
            child: ClipOval(
              child: (student?.profilePicture.isNotEmpty ?? false)
                  ? Image.network(
                      student!.profilePicture,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _AvatarPlaceholder(name: student?.fullName ?? ''),
                    )
                  : _AvatarPlaceholder(name: student?.fullName ?? ''),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student?.fullName ?? user.displayName ?? 'Student',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          if ((student?.studentId ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                student!.studentId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  const _AvatarPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      color: AppColors.primaryDark,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Section Card Wrapper ─────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;

  const _SectionCard({required this.title, required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder, width: 1) : null,
        boxShadow: isDark
            ? []
            : const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextDark : AppColors.textDark,
                    fontWeight: FontWeight.w600,
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

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.darkTextDark : AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Preferences Toggles ──────────────────────────────────────
class _PreferencesToggles extends StatefulWidget {
  final bool isDark;
  const _PreferencesToggles({required this.isDark});

  @override
  State<_PreferencesToggles> createState() => _PreferencesTogglesState();
}

class _PreferencesTogglesState extends State<_PreferencesToggles> {
  late bool _isDarkMode;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDark;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? widget.isDark;
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSwitchRow(
          icon: Icons.dark_mode_outlined,
          label: 'Dark Mode',
          value: _isDarkMode,
          isDark: widget.isDark,
          onChanged: (val) async {
            setState(() {
              _isDarkMode = val;
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', val);

            // Dynamically update theme notifier for instant UI update across the app
            themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
          },
        ),
        _buildSwitchRow(
          icon: Icons.notifications_none_outlined,
          label: 'Push Notifications',
          value: _pushNotifications,
          isDark: widget.isDark,
          onChanged: (val) async {
            setState(() {
              _pushNotifications = val;
            });

            // Save preference locally
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('push_notifications', val);

            // Firebase Messaging integration for notifications toggle
            if (val) {
              NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
                alert: true,
                badge: true,
                sound: true,
              );
              if (settings.authorizationStatus == AuthorizationStatus.authorized) {
                await FirebaseMessaging.instance.subscribeToTopic('all_students');
              }
            } else {
              await FirebaseMessaging.instance.unsubscribeFromTopic('all_students');
            }
          },
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String label,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.darkTextDark : AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark ? AppColors.darkBorder : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

// ─── Logout Button & Modal ────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final bool isDark;
  const _LogoutButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A1515) : AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.error.withValues(alpha: 0.3)) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _confirmLogout(context, isDark),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextDark : AppColors.textDark,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: isDark ? AppColors.darkTextMedium : AppColors.textLight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(80, 40),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}