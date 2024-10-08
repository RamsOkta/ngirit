import 'package:get/get.dart';

import '../controllers/cashflow_controller.dart';

class CashflowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CashflowController>(
      () => CashflowController(),
    );
  }
}
