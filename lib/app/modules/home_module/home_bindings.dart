import 'package:global_sat_501/app/modules/home_module/home_controller.dart';
import 'package:get/get.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class homeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => homeController());
  }
}