import 'package:get/get.dart';

import '../controllers/tambahcc_controller.dart';

class TambahccBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahccController>(
      () => TambahccController(),
    );
  }
}
