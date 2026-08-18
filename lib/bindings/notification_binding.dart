import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../services/notification_service.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(Get.find<NotificationService>()),
        permanent: true,
      );
    }
  }
}
