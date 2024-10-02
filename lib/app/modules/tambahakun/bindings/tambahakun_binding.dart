import 'package:get/get.dart';

import '../controllers/tambahakun_controller.dart';

class TambahakunBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahakunController>(
      () => TambahakunController(),
    );
  }
}
