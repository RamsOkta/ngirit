import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BataspengeluaranController extends GetxController {
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs; // Untuk filtering kategori
  var selectedDate = DateTime.now().obs;
  var selectedDates = ''.obs;
  var accounts = <Map<String, dynamic>>[].obs;
  var saldo = 0.obs;
  // Define saldo variable
  var selectedTab = 0.obs; // New list for credit cards
  var selectedAkun = ''.obs;
  var selectedKategori = ''.obs;

  var deskripsi = ''.obs;
  var creditCards = <Map<String, dynamic>>[].obs;

  TextEditingController deskripsiController = TextEditingController();
  TextEditingController pengeluaranController = TextEditingController();
  TextEditingController pendapatanController = TextEditingController();
  TextEditingController nominalController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get userId =>
      auth.currentUser?.uid; // Dapatkan user ID dari Firebase Auth

  // Transaksi yang akan diambil dari Firestore
  var transactions = <Map<String, dynamic>>[].obs;
  var income = 0.obs;
  var expense = 0.obs;
  var balance = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions(); // Panggil saat controller diinisialisasi
    listenToAccountUpdates();
    listenToCreditCardUpdates();
  }

  void onClose() {
    deskripsiController.dispose();
    nominalController.dispose(); // Dispose nominalController juga
    super.onClose();
  }

  DateTime get startOfMonth =>
      DateTime(selectedDate.value.year, selectedDate.value.month, 1);
  DateTime get endOfMonth {
    final nextMonth =
        DateTime(selectedDate.value.year, selectedDate.value.month + 1, 1);
    return nextMonth.subtract(
        Duration(seconds: 1)); // Memastikan akhir bulan hingga 23:59:59
  }

  String get nextMonth {
    final nextDate =
        DateTime(selectedDate.value.year, selectedDate.value.month + 1);
    return DateFormat('MMMM yyyy').format(nextDate);
  }

  String get selectedMonth =>
      DateFormat('MMMM yyyy').format(selectedDate.value);

  String get previousMonth {
    final prevDate =
        DateTime(selectedDate.value.year, selectedDate.value.month - 1);
    return DateFormat('MMMM yyyy').format(prevDate);
  }

  // Method untuk mengubah bulan
  void changeMonth(int delta) {
    final newMonth = selectedDate.value.month + delta;
    final newYear = selectedDate.value.year +
        (newMonth > 12
            ? 1
            : newMonth < 1
                ? -1
                : 0);

    // Update selectedDate ke bulan dan tahun baru
    selectedDate.value =
        DateTime(newYear, (newMonth % 12) == 0 ? 12 : newMonth % 12);

    // Setelah update bulan, ambil kembali transaksi dan kategori
    fetchTransactions();
    getCategories().listen((categories) {
      print("Categories for the selected month: $categories");
    });
  }

  // Fungsi untuk menghitung total pengeluaran berdasarkan kategori
  Stream<double> getTotalPengeluaran(String kategori) {
    return firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('kategori', isEqualTo: kategori)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .map((snapshot) {
      double total = 0.0;
      for (var doc in snapshot.docs) {
        var nominalString = doc['nominal'] as String;
        double nominal = double.tryParse(nominalString) ?? 0.0;
        total += nominal;
      }
      return total;
    });
  }

  Stream<List<String>> getCategories() {
    return firestore
        .collection('batas_pengeluaran')
        .where('user_id', isEqualTo: userId) // Filter berdasarkan user_id
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return doc['kategori'] as String;
      }).toList();
    });
  }

  // Fungsi untuk mengambil data transaksi dari Firestore

  void fetchTransactions() {
    if (userId == null) return; // If userId is null, stop

    try {
      firestore
          .collection('batas_pengeluaran')
          .where('user_id', isEqualTo: userId) // Filter by user_id
          .where('tanggal', isGreaterThanOrEqualTo: startOfMonth)
          .where('tanggal', isLessThanOrEqualTo: endOfMonth)
          .snapshots()
          .listen((snapshot) async {
        print("Jumlah data yang diambil: ${snapshot.docs.length}");

        // Fetch transaction data in real-time
        transactions.value = await Future.wait(snapshot.docs.map((doc) async {
          String category = doc['kategori'];

          // Get all expenditures from 'pengeluaran' collection based on category
          QuerySnapshot pengeluaranSnapshot = await firestore
              .collection('pengeluaran')
              .where('kategori', isEqualTo: category)
              .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
              .where('createdAt', isLessThanOrEqualTo: endOfMonth)
              .snapshots()
              .first;

          double totalNominal = 0;

          pengeluaranSnapshot.docs.forEach((pengeluaranDoc) {
            Map<String, dynamic> data =
                pengeluaranDoc.data() as Map<String, dynamic>;

            // Check if 'nominal' exists and is a valid number before parsing
            if (data.containsKey('nominal') && data['nominal'] != null) {
              try {
                totalNominal += double.parse(data['nominal'].toString());
              } catch (e) {
                print("Error parsing nominal: ${data['nominal']} - $e");
              }
            }
          });

          return {
            "date": DateFormat('dd-MM-yyyy').format(doc['tanggal'].toDate()),
            "amount": totalNominal,
            "category": category,
          };
        }).toList());
      });
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mendapatkan batas pengeluaran per kategori
  Future<double> getBatasPengeluaran(String category) async {
    try {
      var snapshot = await firestore
          .collection('batas_pengeluaran')
          .where('user_id', isEqualTo: userId)
          .where('kategori', isEqualTo: category)
          .where('tanggal', isGreaterThanOrEqualTo: startOfMonth)
          .where('tanggal', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['jumlah'] as double;
      } else {
        return 0.0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
      return 0.0;
    }
  }

  // Fungsi untuk menambahkan batas pengeluaran
  Future<void> addBatasPengeluaran(String kategori, double jumlah) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await firestore.collection('batas_pengeluaran').add({
          'kategori': kategori,
          'jumlah': jumlah,
          'tanggal': DateTime.now(), // Tambahkan createdAt
          'user_id': currentUser.uid,
        });
      } else {
        Get.snackbar('Gagal', 'Pengguna tidak terautentikasi.');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }

  Future<List<String>> getExistingCategories() async {
    try {
      var snapshot = await firestore
          .collection('batas_pengeluaran')
          .where('user_id', isEqualTo: userId)
          .where('tanggal', isGreaterThanOrEqualTo: startOfMonth)
          .where('tanggal', isLessThanOrEqualTo: endOfMonth)
          .get();

      return snapshot.docs.map((doc) => doc['kategori'] as String).toList();
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengambil kategori: $e');
      return [];
    }
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
    final controller = Get.find<BataspengeluaranController>();
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
        controller.selectedDates.value.isEmpty) {
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
          'tanggal': controller.selectedDates.value,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showSuccessAnimation(Get.context!);

        controller.nominalController.clear();
        controller.deskripsiController.clear();
        controller.selectedKategori.value = '';
        controller.selectedAkun.value = '';
        controller.selectedDates.value = '';
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

  Future<void> updateTransactionItem(String category, double newAmount) async {
    try {
      var snapshot = await firestore
          .collection('batas_pengeluaran')
          .where('user_id', isEqualTo: userId)
          .where('kategori', isEqualTo: category)
          .where('tanggal', isGreaterThanOrEqualTo: startOfMonth)
          .where('tanggal', isLessThanOrEqualTo: endOfMonth)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var docId = snapshot.docs.first.id;
        await firestore.collection('batas_pengeluaran').doc(docId).update({
          'jumlah': newAmount,
        });
        Get.snackbar('Success', 'Jumlah berhasil diperbarui.');
      } else {
        Get.snackbar('Error', 'Dokumen tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

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
}
