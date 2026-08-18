import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.put<NotificationController>(
      NotificationController(Get.find<NotificationService>()),
      permanent: true,
    );
  }
}
