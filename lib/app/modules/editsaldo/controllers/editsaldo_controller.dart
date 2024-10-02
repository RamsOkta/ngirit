import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditsaldoController extends GetxController {
  // Controllers for the text fields
  final TextEditingController namaAkunController = TextEditingController();
  final TextEditingController saldoAkunController = TextEditingController();

  // Reactive variable for selected icon
  var selectedIcon = Rxn<IconData>();

  // List of icons to choose from
  List<IconData> icons = [
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.attach_money,
    Icons.credit_card,
  ];

  List<String> iconLabels = ['Bank', 'Wallet', 'Money', 'Credit Card'];

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();

    // Jika mengedit akun yang ada, populasi data
    if (Get.arguments != null) {
      var account = Get.arguments;
      namaAkunController.text = account['nama_akun'] ?? ''; // Tambahkan default
      saldoAkunController.text =
          (account['saldo_awal'] ?? 0).toString(); // Tambahkan default
      selectedIcon.value = icons.firstWhere(
        (icon) => icon == account['icon'],
        orElse: () => icons.first, // Set default icon jika tidak ditemukan
      );
    }
  }

  // Function to update saldo in Firestore
  void updateSaldo() {
    if (namaAkunController.text.isNotEmpty &&
        saldoAkunController.text.isNotEmpty &&
        selectedIcon.value != null) {
      String accountId = Get.arguments['id']; // Assuming id is passed

      _firestore.collection('accounts').doc(accountId).update({
        'nama_akun': namaAkunController.text,
        'saldo_awal': int.parse(saldoAkunController.text),
        'icon': selectedIcon.value.toString(),
      }).then((_) {
        Get.snackbar('Success', 'Account updated successfully');
        Get.back(); // Go back to the previous screen
      }).catchError((error) {
        Get.snackbar('Error', 'Failed to update account: $error');
      });
    } else {
      Get.snackbar('Error', 'Please fill in all fields');
    }
  }
}
