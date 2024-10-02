import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngirit/app/modules/profile/views/profile_view.dart';
import '../../home/views/home_view.dart';
import '../../saldo/views/saldo_view.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var username = ''.obs;
  var saldo = 0.obs; // Default saldo 0
  var accounts = <Map<String, dynamic>>[].obs;
  var creditCards = <Map<String, dynamic>>[].obs; // New list for credit cards

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    listenToAccountUpdates();
    listenToCreditCardUpdates(); // New listener for credit cards
  }

  var isSaldoVisible = true.obs;
  var isFakturVisible = true.obs;

  // Fetch user data (username)
  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          username.value = userDoc.data()?['username'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    }
  }

  // Listen for account updates and calculate total saldo
  void listenToAccountUpdates() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('accounts')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((accountSnapshot) {
          var totalSaldo = 0;
          accounts.clear();

          for (var doc in accountSnapshot.docs) {
            var accountData = doc.data();
            int saldoAwal = int.tryParse(accountData['saldo_awal']) ?? 0;

            accounts.add({
              'nama_akun': accountData['nama_akun'],
              'saldo_awal': saldoAwal,
              'icon': accountData['icon'] ?? '',
            });

            totalSaldo += saldoAwal;
          }

          saldo.value = totalSaldo;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load accounts');
    }
  }

  // New function: Listen for credit card updates
  void listenToCreditCardUpdates() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('kartu_kredit') // Pastikan nama koleksi sudah sesuai
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((ccSnapshot) {
          creditCards.clear();

          for (var doc in ccSnapshot.docs) {
            var ccData = doc.data();

            // Debugging: Cetak data yang diambil
            print('Credit card data: $ccData');

            creditCards.add({
              'namaKartu': ccData['namaKartu'] ?? 'No Name',
              'ikonKartu':
                  ccData['ikonKartu'] ?? '', // Jika tidak ada ikon, kosong
              'limitKredit': ccData['limitKredit'] ?? '',
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load credit cards');
    }
  }

  void toggleSaldoVisibility() {
    isSaldoVisible.value = !isSaldoVisible.value;
  }

  void toggleFakturVisibility() {
    isFakturVisible.value = !isFakturVisible.value;
  }

  void manageAccounts() {
    Get.to(() => SaldoView());
  }

  void addAccount(String name, int amount, String icon) {
    accounts.add({'name': name, 'amount': amount, 'icon': icon});
  }

  void onItemTapped(int index) {
    selectedIndex.value = index;
    switch (index) {
      case 0:
        Get.offAll(() => HomeView());
        break;
      case 1:
        Get.offAll(() => SaldoView());
        break;
      case 2:
        Get.offAll(() => ProfileView());
        break;
    }
  }
}
