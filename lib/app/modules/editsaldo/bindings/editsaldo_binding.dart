import 'package:get/get.dart';

import '../controllers/editsaldo_controller.dart';

class EditsaldoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditsaldoController>(() => EditsaldoController());
  }
}
