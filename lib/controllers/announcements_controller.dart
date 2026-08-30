import 'package:get/get.dart';
import '../data/models/campus_models.dart';
import '../data/repositories/campus_repositories.dart';

class AnnouncementsController extends GetxController {
  final AnnouncementRepository _announcementRepository = Get.find<AnnouncementRepository>();

  final announcements = <AnnouncementPreview>[].obs;
  final isLoading = false.obs;
  final errorMsg = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    isLoading.value = true;
    errorMsg.value = null;
    try {
      final list = await _announcementRepository.getPublishedAnnouncements();
      announcements.assignAll(list);
    } catch (e) {
      errorMsg.value = 'Failed to load announcements: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
