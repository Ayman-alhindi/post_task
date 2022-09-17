import 'package:feed/Controller/authController.dart';
import 'package:feed/Controller/postController.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(PostController());
    Get.put(AuthController());
  }
}
