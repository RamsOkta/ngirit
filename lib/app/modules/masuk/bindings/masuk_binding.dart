import 'package:get/get.dart';

import '../controllers/masuk_controller.dart';

class MasukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MasukController>(
      () => MasukController(),
    );
  }
}
