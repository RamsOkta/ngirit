import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngirit/app/modules/profile/views/profile_view.dart';
import '../../home/views/home_view.dart';
import '../../saldo/views/saldo_view.dart';

class DashboardController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var selectedIndex = 0.obs;
  var username = ''.obs;
  var saldo = 0.obs; // Default saldo 0
  var accounts = <Map<String, dynamic>>[].obs;
  var creditCards = <Map<String, dynamic>>[].obs;
  var pengeluaranPerCard = {}.obs; // Define pengeluaranPerCard
  var selectedTab = 0.obs; // New list for credit cards
  var selectedAkun = ''.obs;
  var selectedKategori = ''.obs;
  var selectedDate = ''.obs;
  var deskripsi = ''.obs; // Variabel untuk menyimpan deskripsi
  var profileImageUrl = ''.obs;
  TextEditingController deskripsiController = TextEditingController();

  TextEditingController nominalController = TextEditingController();
  @override
  @override
  void onClose() {
    deskripsiController.dispose();
    nominalController.dispose(); // Dispose nominalController juga
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    listenToAccountUpdates();
    listenToCreditCardUpdates(); // New listener for credit cards
    fetchProfileImage();
  }

  var isSaldoVisible = true.obs;
  var isFakturVisible = true.obs;
  String get userId {
    return _auth.currentUser?.uid ??
        ''; // Mengembalikan UID pengguna yang sedang login
  }

  void fetchProfileImage() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((userDoc) {
          if (userDoc.exists) {
            // Misalkan URL gambar profil disimpan dengan nama field 'profilePictureUrl'
            profileImageUrl.value = userDoc.data()?['profilePictureUrl'] ?? '';
          }
        });
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
  }

  // Fungsi untuk mendengarkan perubahan data user (username)
  void fetchUserData() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((userDoc) {
          if (userDoc.exists) {
            username.value = userDoc.data()?['username'] ?? '';
          }
        });
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
        // Mengawasi perubahan pada koleksi 'accounts'
        FirebaseFirestore.instance
            .collection('accounts')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((accountSnapshot) async {
          accounts.clear();
          var totalSaldo = 0;

          // Looping secara asinkron untuk setiap dokumen akun
          for (var doc in accountSnapshot.docs) {
            var accountData = doc.data();
            String namaAkun = accountData['nama_akun'].toString().toUpperCase();

            // Ambil saldo awal dari koleksi accounts
            int saldoAwal = int.tryParse(accountData['saldo_awal']) ?? 0;

            // Stream real-time untuk pendapatan
            var pendapatanStream = FirebaseFirestore.instance
                .collection('pendapatan')
                .where('akun', isEqualTo: namaAkun)
                .where('user_id', isEqualTo: user.uid)
                .snapshots();

            // Stream real-time untuk pengeluaran
            var pengeluaranStream = FirebaseFirestore.instance
                .collection('pengeluaran')
                .where('akun', isEqualTo: namaAkun)
                .where('user_id', isEqualTo: user.uid)
                .snapshots();

            // Mendengarkan stream pendapatan dan pengeluaran secara paralel
            var pendapatanSnapshot = await pendapatanStream.first;
            var pengeluaranSnapshot = await pengeluaranStream.first;

            // Hitung total pendapatan
            int totalPendapatan = pendapatanSnapshot.docs.fold(0, (total, doc) {
              return total + (int.tryParse(doc['nominal']) ?? 0);
            });

            // Hitung total pengeluaran
            int totalPengeluaran =
                pengeluaranSnapshot.docs.fold(0, (total, doc) {
              return total + (int.tryParse(doc['nominal']) ?? 0);
            });

            // Hitung saldo akhir
            int saldoAkhir = saldoAwal + totalPendapatan - totalPengeluaran;

            // Cek apakah akun sudah ada di list
            var existingAccountIndex = accounts.indexWhere(
                (account) => account['nama_akun'] == accountData['nama_akun']);
            if (existingAccountIndex != -1) {
              accounts[existingAccountIndex] = {
                'nama_akun': accountData['nama_akun'],
                'saldo_awal': saldoAwal,
                'icon': accountData['icon'] ?? '',
                'total_pendapatan': totalPendapatan,
                'total_pengeluaran': totalPengeluaran,
                'saldo_akhir': saldoAkhir,
              };
            } else {
              accounts.add({
                'nama_akun': accountData['nama_akun'],
                'saldo_awal': saldoAwal,
                'icon': accountData['icon'] ?? '',
                'total_pendapatan': totalPendapatan,
                'total_pengeluaran': totalPengeluaran,
                'saldo_akhir': saldoAkhir,
              });
            }

            // Menambahkan saldo akhir ke total saldo
            totalSaldo += saldoAkhir;
          }

          // Mengupdate nilai total saldo setelah looping selesai
          saldo.value = totalSaldo;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load accounts: ${e.toString()}');
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

            // Fetch pengeluaran untuk kartu ini
            String cardName = ccData['namaKartu'] ?? 'No Name';
            fetchPengeluaran(cardName);

            creditCards.add({
              'namaKartu': cardName,
              'ikonKartu': ccData['ikonKartu'] ?? '',
              'limitKredit': ccData['limitKredit'] ?? '0',
            });
          }
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load credit cards');
    }
  }

  // Fungsi untuk mengambil kartu kredit dari Firestore

  // Fungsi untuk mengambil pengeluaran berdasarkan nama kartu kredit
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

  // Fungsi untuk mendapatkan total pengeluaran dari nama kartu
  double getPengeluaran(String namaKartu) {
    return pengeluaranPerCard[namaKartu] ?? 0.0;
  }

  // Function to save form data to Firestore
  Future<void> saveFormData(String nominal) async {
    final controller = Get.find<DashboardController>();
    String collection;
    switch (controller.selectedTab.value) {
      case 0:
        collection = 'pengeluaran';
        break;
      case 1:
        collection = 'pendapatan';
        break;
      // case 2:
      //   collection = 'transfer';
      //   break;
      default:
        collection = 'pengeluaran';
    }

    if (controller.selectedKategori.isNotEmpty &&
        controller.selectedAkun.isNotEmpty &&
        controller.selectedDate.isNotEmpty) {
      try {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await FirebaseFirestore.instance.collection(collection).add({
            'user_id': user.uid,
            'nominal': nominal,
            'deskripsi': controller.deskripsi.value,
            'kategori': controller.selectedKategori.value,
            'akun': controller.selectedAkun.value,
            'tanggal': controller.selectedDate.value,
            'createdAt': FieldValue.serverTimestamp(),
          });
          Get.snackbar('Success', 'Data berhasil disimpan ke $collection');
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal menyimpan data ke $collection');
      }
    } else {
      Get.snackbar('Error', 'Pastikan semua field diisi');
    }
  }

  // Function to reset the form fields

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

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/login'); // Redirect to login page after logout
      print("User logged out");
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out');
    }
  }
}
