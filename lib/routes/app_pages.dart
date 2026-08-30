import 'package:campus_care_app/features/requests/request_history_screen.dart';
import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/notification_binding.dart';
import '../features/requests/request_details_screen.dart';
import '../features/requests/request_entry_type.dart';
import '../features/requests/submit_request_screen.dart';
import '../models/student_model.dart';
import '../screens/auth/auth_wrapper.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/splash_screen.dart';

import '../screens/home/home_screen.dart';
import '../screens/campus_info/campus_info_screen.dart';
import '../screens/campus_info/campus_info_detail_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/notifications_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage<dynamic>>[
    GetPage(name: '/', page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.authWrapper,
      page: () => const AuthWrapper(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () {
        final data = Get.arguments as StudentModel?;
        return EditProfileScreen(
          student:
              data ??
              StudentModel(
                id: '',
                fullName: '',
                studentId: '',
                department: '',
                semester: '',
                email: '',
                phone: '',
                profilePicture: '',
              ),
        );
      },
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.submitRequest,
      page: () {
        final args = Get.arguments;
        final type = args is RequestEntryType ? args : RequestEntryType.problem;
        return SubmitRequestScreen(entryType: type);
      },
    ),
    GetPage(
      name: AppRoutes.requestDetails,
      page: () {
        final args = Get.arguments;
        final id = args is String ? args : '';
        return RequestDetailsScreen(requestId: id);
      },
    ),
    GetPage(
      name: AppRoutes.requestHistory,
      page: () => const RequestHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.campusInfo,
      page: () => const CampusInfoScreen(),
    ),
    GetPage(
      name: AppRoutes.campusInfoDetail,
      page: () => const CampusInfoDetailScreen(),
    ),
  ];
}
