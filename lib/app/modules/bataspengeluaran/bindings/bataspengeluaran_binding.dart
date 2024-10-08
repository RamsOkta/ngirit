import 'package:get/get.dart';

import '../controllers/bataspengeluaran_controller.dart';

class BataspengeluaranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BataspengeluaranController>(
      () => BataspengeluaranController(),
    );
  }
}
