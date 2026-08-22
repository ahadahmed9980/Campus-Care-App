import 'package:get/get.dart';

import '../controllers/notification_controller.dart';
import '../data/repositories/notification_repository.dart';
import '../services/notification_service.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(
        () => NotificationService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationRepository>()) {
      Get.put<NotificationRepository>(
        NotificationRepository(),
        permanent: true,
      );
    }

    if (!Get.isRegistered<NotificationController>()) {
      Get.put<NotificationController>(
        NotificationController(
          Get.find<NotificationService>(),
          Get.find<NotificationRepository>(),
        ),
        permanent: true,
      );
    }
  }
}