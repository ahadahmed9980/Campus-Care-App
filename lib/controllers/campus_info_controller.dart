import 'package:get/get.dart';
import '../data/models/campus_models.dart';
import '../data/repositories/campus_repositories.dart';

class CampusInfoController extends GetxController {
  final CampusInfoRepository _campusInfoRepository = Get.find<CampusInfoRepository>();

  final allItems = <CampusInfo>[].obs;
  final isLoading = false.obs;
  final errorMsg = RxnString();
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampusInfo();
  }

  Future<void> fetchCampusInfo() async {
    isLoading.value = true;
    errorMsg.value = null;
    try {
      final list = await _campusInfoRepository.getCampusInfoList();
      allItems.assignAll(list);
    } catch (e) {
      errorMsg.value = 'Failed to load campus information: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  List<CampusInfo> get filteredItems {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return allItems;
    }
    return allItems.where((item) {
      final titleMatch = item.title.toLowerCase().contains(query);
      final descMatch = item.description.toLowerCase().contains(query);
      final categoryMatch = item.category.toLowerCase().contains(query);
      final locMatch = item.location.formatted.toLowerCase().contains(query);
      return titleMatch || descMatch || categoryMatch || locMatch;
    }).toList();
  }
}
