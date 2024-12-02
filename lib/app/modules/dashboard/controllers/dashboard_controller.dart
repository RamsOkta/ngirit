import 'dart:ui';

import 'package:flutter/material.dart';
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
  TextEditingController pengeluaranController = TextEditingController();
  TextEditingController pendapatanController = TextEditingController();
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
  void listenToAccountUpdates() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Listen to account changes
        FirebaseFirestore.instance
            .collection('accounts')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((accountSnapshot) async {
          await _recalculateSaldo(user);
        });

        // Listen to income (pendapatan) changes
        FirebaseFirestore.instance
            .collection('pendapatan')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((_) async {
          await _recalculateSaldo(user);
        });

        // Listen to expense (pengeluaran) changes
        FirebaseFirestore.instance
            .collection('pengeluaran')
            .where('user_id', isEqualTo: user.uid)
            .snapshots()
            .listen((_) async {
          await _recalculateSaldo(user);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load accounts: ${e.toString()}');
    }
  }

// Helper function to recalculate saldo
  Future<void> _recalculateSaldo(User user) async {
    accounts.clear();
    var totalSaldo = 0;

    var accountSnapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('user_id', isEqualTo: user.uid)
        .get();

    for (var doc in accountSnapshot.docs) {
      var accountData = doc.data();
      String namaAkun = accountData['nama_akun'];
      int saldoAwal = int.tryParse(accountData['saldo_awal']) ?? 0;

      // Calculate total pendapatan for this account
      var pendapatanSnapshot = await FirebaseFirestore.instance
          .collection('pendapatan')
          .where('akun', isEqualTo: namaAkun)
          .where('user_id', isEqualTo: user.uid)
          .get();
      int totalPendapatan = pendapatanSnapshot.docs.fold(
          0, (total, doc) => total + int.tryParse(doc['nominal'] ?? '0')!);

      // Calculate total pengeluaran for this account
      var pengeluaranSnapshot = await FirebaseFirestore.instance
          .collection('pengeluaran')
          .where('akun', isEqualTo: namaAkun)
          .where('user_id', isEqualTo: user.uid)
          .get();
      int totalPengeluaran = pengeluaranSnapshot.docs.fold(
          0, (total, doc) => total + int.tryParse(doc['nominal'] ?? '0')!);

      int saldoAkhir = saldoAwal + totalPendapatan - totalPengeluaran;

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

      totalSaldo += saldoAkhir;
    }

    saldo.value = totalSaldo;
    print("Total Saldo: $totalSaldo");
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

  Future<void> showSuccessAnimation(BuildContext context) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 8, sigmaY: 8), // Efek blur pada background
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: Container(
                width: 250, // Ukuran lebih besar agar muat teks dan ikon
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 100,
                    ),
                    SizedBox(height: 10), // Spasi antara ikon dan teks
                    Text(
                      "Data Berhasil Diisi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 400),
    );

    // Tunggu beberapa detik, kemudian tutup dialog
    await Future.delayed(Duration(seconds: 3));
    Navigator.of(context, rootNavigator: true).pop();
  }

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
      default:
        collection = 'pengeluaran';
    }

    if (nominal.isEmpty || nominal == '0,00') {
      Get.snackbar(
        "Error",
        "Nominal tidak boleh kosong atau nol",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition:
            SnackPosition.TOP, // Menampilkan notifikasi di bagian atas
        duration: Duration(seconds: 2),
      );
      return;
    }

    if (controller.deskripsi.value.isEmpty ||
        controller.selectedKategori.value.isEmpty ||
        controller.selectedAkun.value.isEmpty ||
        controller.selectedDate.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua field wajib diisi",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition:
            SnackPosition.TOP, // Menampilkan notifikasi di bagian atas
        duration: Duration(seconds: 2),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String sanitizedNominal = nominal.replaceAll(',', '');

        await FirebaseFirestore.instance.collection(collection).add({
          'user_id': user.uid,
          'nominal': sanitizedNominal,
          'deskripsi': controller.deskripsi.value,
          'kategori': controller.selectedKategori.value,
          'akun': controller.selectedAkun.value,
          'tanggal': controller.selectedDate.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showSuccessAnimation(Get.context!);

        controller.nominalController.clear();
        controller.deskripsiController.clear();
        controller.selectedKategori.value = '';
        controller.selectedAkun.value = '';
        controller.selectedDate.value = '';
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menyimpan data ke $collection",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition:
            SnackPosition.TOP, // Menampilkan notifikasi di bagian atas
        duration: Duration(seconds: 2),
      );
    }
  }

  void clearForm(int selectedTab) {
    if (selectedTab == 0) {
      // Kosongkan controller untuk Pengeluaran
      pengeluaranController.clear();
    } else if (selectedTab == 1) {
      // Kosongkan controller untuk Pendapatan
      pendapatanController.clear();
    }
  }

  void resetFormData() {
    // Reset controller teks
    deskripsiController.clear();

    // Reset nominal (pastikan ini adalah controller nominal yang benar)
    if (selectedTab.value == 0) {
      pengeluaranController.clear();
    } else {
      pendapatanController.clear();
    }

    // Reset semua variabel yang diperlukan
    selectedKategori.value = ''; // Reset kategori
    selectedAkun.value = ''; // Reset akun
    // Reset tanggal
    deskripsi.value = ''; // Reset deskripsi
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
