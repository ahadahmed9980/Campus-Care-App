import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../controllers/theme_controller.dart';
import '../data/repositories/campus_repositories.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<RequestRepository>(RequestRepository(), permanent: true);
    Get.put<CategoryRepository>(CategoryRepository(), permanent: true);
    Get.put<AnnouncementRepository>(AnnouncementRepository(), permanent: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationService>()),
      fenix: true,
    );
  }
}
