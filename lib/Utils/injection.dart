import 'package:feed/Controller/auth_controller.dart';
import 'package:feed/Controller/post_controller.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(PostController(Get.find()));
  }
}
