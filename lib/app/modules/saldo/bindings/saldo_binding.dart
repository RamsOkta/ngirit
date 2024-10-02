import 'package:get/get.dart';

import '../controllers/saldo_controller.dart';

class SaldoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SaldoController>(
      () => SaldoController(),
    );
  }
}
