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
    return nextMonth.subtract(Duration(days: 1));
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
    if (userId == null) return; // Jika userId null, hentikan

    try {
      firestore
          .collection('batas_pengeluaran')
          .where('user_id', isEqualTo: userId) // Filter berdasarkan user_id
          .where('tanggal', isGreaterThanOrEqualTo: startOfMonth)
          .where('tanggal', isLessThanOrEqualTo: endOfMonth)
          .snapshots()
          .listen((snapshot) async {
        print("Jumlah data yang diambil: ${snapshot.docs.length}");

        // Ambil data transaksi secara real-time
        transactions.value = await Future.wait(snapshot.docs.map((doc) async {
          String category = doc['kategori'];

          // Ambil semua pengeluaran dari koleksi 'pengeluaran' berdasarkan kategori
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
            if (data.containsKey('nominal')) {
              totalNominal += double.parse(data['nominal']);
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
        Get.snackbar('Berhasil', 'Batas pengeluaran berhasil ditambahkan.');
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

    if (controller.selectedKategori.isNotEmpty &&
        controller.selectedAkun.isNotEmpty &&
        controller.selectedDates.isNotEmpty) {
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
