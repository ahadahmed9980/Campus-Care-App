import 'package:get/get.dart';

import 'auth_binding.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
