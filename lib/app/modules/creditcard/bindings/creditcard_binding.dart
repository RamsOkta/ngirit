import 'package:get/get.dart';

import '../controllers/creditcard_controller.dart';

class CreditcardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreditcardController>(
      () => CreditcardController(),
    );
  }
}
