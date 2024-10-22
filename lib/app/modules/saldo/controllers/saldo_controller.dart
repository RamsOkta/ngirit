import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SaldoController extends GetxController {
  var accounts = <Map<String, dynamic>>[].obs; // Daftar akun dari Firestore
  var totalSaldo = 0.obs; // Total saldo
  var pengeluaranPerCard = {}.obs;

  @override
  void onInit() {
    super.onInit();
    listenToAccountUpdates(); // Dengerin perubahan akun real-time
  }

  void fetchPengeluaran(String namaKartu) async {
    try {
      var pengeluaranSnapshot = await FirebaseFirestore.instance
          .collection('pengeluaran')
          .where('akun', isEqualTo: namaKartu)
          .get();

      double totalPengeluaran = pengeluaranSnapshot.docs.fold(
        0.0,
        (total, doc) => total + double.tryParse(doc['nominal'] ?? '0')!,
      );

      // Simpan total pengeluaran untuk kartu ini di dalam map pengeluaranPerCard
      pengeluaranPerCard[namaKartu] = totalPengeluaran;

      // Update UI setelah data pengeluaran diambil
      update();
    } catch (e) {
      print("Error fetching pengeluaran for $namaKartu: $e");
    }
  }

  // Fungsi buat ngelisten perubahan akun dan hitung saldo akhir
  void listenToAccountUpdates() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Mengawasi perubahan pada koleksi 'accounts'
        FirebaseFirestore.instance
            .collection('accounts')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((accountSnapshot) async {
          accounts.clear();
          var totalSaldoTemp = 0; // Inisialisasi sementara untuk total saldo

          for (var doc in accountSnapshot.docs) {
            var accountData = doc.data();
            String namaAkun = accountData['nama_akun'].toString().toUpperCase();

            int saldoAwal = int.tryParse(accountData['saldo_awal']) ?? 0;

            // Stream real-time buat pendapatan
            var pendapatanStream = FirebaseFirestore.instance
                .collection('pendapatan')
                .where('akun', isEqualTo: namaAkun)
                .where('user_id', isEqualTo: user.uid)
                .snapshots();

            // Stream real-time buat pengeluaran
            var pengeluaranStream = FirebaseFirestore.instance
                .collection('pengeluaran')
                .where('akun', isEqualTo: namaAkun)
                .where('user_id', isEqualTo: user.uid)
                .snapshots();

            // Tunggu data dari pendapatan dan pengeluaran
            var pendapatanSnapshot = await pendapatanStream.first;
            var pengeluaranSnapshot = await pengeluaranStream.first;

            int totalPendapatan = pendapatanSnapshot.docs.fold(0, (total, doc) {
              return total + (int.tryParse(doc['nominal']) ?? 0);
            });

            int totalPengeluaran =
                pengeluaranSnapshot.docs.fold(0, (total, doc) {
              return total + (int.tryParse(doc['nominal']) ?? 0);
            });

            int saldoAkhir = saldoAwal + totalPendapatan - totalPengeluaran;

            // Tambahin ke daftar akun
            accounts.add({
              'id': doc.id, // ID dokumen akun
              'nama_akun': accountData['nama_akun'],
              'saldo_awal': saldoAwal,
              'icon': accountData['icon'] ?? 'account_circle',
              'total_pendapatan': totalPendapatan,
              'total_pengeluaran': totalPengeluaran,
              'saldo_akhir': saldoAkhir,
            });

            totalSaldoTemp += saldoAkhir; // Tambah saldo akhir ke total saldo
          }

          // Update total saldo di akhir proses
          totalSaldo.value = totalSaldoTemp;
        });
      }
    } catch (e) {
      print('Error fetching accounts: $e');
      Get.snackbar('Error', 'Failed to load accounts: ${e.toString()}');
    }
  }

  Future<void> updateSaldo(String id, String newSaldo) async {
    try {
      await FirebaseFirestore.instance.collection('accounts').doc(id).update({
        'saldo_awal': newSaldo, // Mengupdate saldo sebagai String
      });
      ;
      listenToAccountUpdates(); // Ambil ulang data setelah update
    } catch (e) {
      print('Error updating saldo: $e');
    }
  }
}
