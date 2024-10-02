import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaldoController extends GetxController {
  var accounts = <Map<String, dynamic>>[].obs; // Daftar akun dari Firestore
  var totalSaldo = 0.obs; // Total saldo

  @override
  void onInit() {
    super.onInit();
    fetchAccounts(); // Ambil akun saat inisialisasi
  }

  // Fetch accounts dan hitung total saldo
  Future<void> fetchAccounts() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Query berdasarkan user_id yang cocok dengan pengguna yang login
        var accountSnapshot = await FirebaseFirestore.instance
            .collection('accounts')
            .where('user_id', isEqualTo: user.uid)
            .get();

        accounts.clear();

        // Log untuk memastikan data diambil
        print('Firestore data: ${accountSnapshot.docs.length} accounts found.');

        for (var doc in accountSnapshot.docs) {
          var accountData = doc.data();
          print(
              'Account data: $accountData'); // Menampilkan data akun untuk debugging

          accounts.add({
            'id': doc.id, // Menyimpan ID dokumen
            'nama_akun': accountData['nama_akun'] ?? 'Unknown',
            'saldo_awal': accountData['saldo_awal']?.toString() ??
                '0', // Pastikan saldo sebagai String
            'icon': accountData['icon'] ?? 'account_circle',
          });
        }
      } else {
        print('No user is logged in.');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
      Get.snackbar('Error', 'Failed to load accounts');
    }
  }

  // Fungsi untuk update saldo akun
  Future<void> updateSaldo(String id, String newSaldo) async {
    try {
      await FirebaseFirestore.instance.collection('accounts').doc(id).update({
        'saldo_awal': newSaldo, // Mengupdate saldo sebagai String
      });
      fetchAccounts(); // Ambil ulang data setelah update
    } catch (e) {
      print('Error updating saldo: $e');
    }
  }
}
