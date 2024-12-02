import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatisticController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  var income = <double>[].obs;

  var expense = <double>[].obs;
  var tappedIndex = (-1).obs;
  var tooltipPosition = Offset.zero.obs;
  final GlobalKey stackKey = GlobalKey();
  var isExpanded = false.obs;

  var totalIncome = 0.obs; // Total pemasukan
  var totalExpense = 0.obs; // Total pengeluaran
  var totalBalance = 0.obs; // Total saldo
  var pieChartData = <PieChartSectionData>[].obs;
  var saldo = 0.obs; // Define saldo variable
  var selectedTab = 0.obs; // New list for credit cards
  var selectedAkun = ''.obs;
  var selectedKategori = ''.obs;
  var selectedDates = ''.obs;
  var deskripsi = ''.obs;
  var creditCards = <Map<String, dynamic>>[].obs;
  var accounts = <Map<String, dynamic>>[].obs;
  TextEditingController deskripsiController = TextEditingController();
  TextEditingController pengeluaranController = TextEditingController();
  TextEditingController pendapatanController = TextEditingController();
  TextEditingController nominalController = TextEditingController();

  var selectedDate = DateTime.now().obs;

  void onInit() {
    fetchTotalIncome();
    fetchTotalExpense();
    fetchTotalBalance();
    fetchIncome();
    fetchExpense();
    fetchExpenseByCategory();
    listenToAccountUpdates();
    listenToCreditCardUpdates();
    super.onInit();
  }

  // Ambil userId dari pengguna yang sedang login
  String get userId => _auth.currentUser?.uid ?? '';

  // Ambil bulan depan, sekarang, dan sebelumnya
  DateTime get startOfMonth =>
      DateTime(selectedDate.value.year, selectedDate.value.month, 1);
  DateTime get endOfMonth {
    final nextMonth =
        DateTime(selectedDate.value.year, selectedDate.value.month + 1, 1);
    return nextMonth.subtract(
        Duration(seconds: 1)); // Memastikan akhir bulan hingga 23:59:59
  }

  // Ambil bulan depan, sekarang, dan sebelumnya
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

  // Method to change the month
  void changeMonth(int delta) {
    final newMonth = selectedDate.value.month + delta;
    final newYear = selectedDate.value.year +
        (newMonth > 12
            ? 1
            : newMonth < 1
                ? -1
                : 0);
    selectedDate.value =
        DateTime(newYear, (newMonth % 12) == 0 ? 12 : newMonth % 12);

    fetchTotalIncome();
    fetchTotalExpense();
    fetchTotalBalance();
    fetchIncome();
    fetchExpense();
    fetchExpenseByCategory();
  }

  // Fetch total pemasukan dari Firestore berdasarkan createdAt (timestamp)
  void fetchTotalIncome() {
    _firestore
        .collection('pendapatan')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      totalIncome.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'] as String));
    }, onError: (e) {
      print('Error fetching income: $e');
    });
  }

  // Fetch total pengeluaran dari Firestore berdasarkan createdAt (timestamp)
  void fetchTotalExpense() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      totalExpense.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'] as String));
    }, onError: (e) {
      print('Error fetching expense: $e');
    });
  }

  Future<void> fetchTotalBalance() async {
    try {
      final accountSnapshot = await _firestore
          .collection('accounts')
          .where('user_id', isEqualTo: userId)
          .get(); // Mengambil semua akun berdasarkan user_id

      if (accountSnapshot.docs.isNotEmpty) {
        int totalSaldo = 0;
        for (var accountDoc in accountSnapshot.docs) {
          int saldoAwal = int.parse(accountDoc['saldo_awal'] as String);
          totalSaldo += saldoAwal;
          print("Saldo Awal dari akun: $saldoAwal");
        }

        totalBalance.value =
            totalSaldo + totalIncome.value - totalExpense.value;
        print("Total Balance: ${totalBalance.value}");
      } else {
        print('No account found for user');
      }
    } catch (e) {
      print('Error fetching balance: $e');
    }
  }

  // Method untuk mengambil data pemasukan secara real-time
  void fetchIncome() {
    _firestore
        .collection('pendapatan')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      // Ubah 'nominal' ke dalam format double
      List<double> incomeData = snapshot.docs
          .map((doc) => double.parse(doc['nominal'].toString()))
          .toList();

      // Simpan ke dalam variabel income
      income.value = incomeData;
    }, onError: (e) {
      print('Error fetching income: $e');
    });
  }

// Method untuk mengambil data pengeluaran secara real-time
  void fetchExpense() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      // Ubah 'nominal' ke dalam format double
      List<double> expenseData = snapshot.docs
          .map((doc) => double.parse(doc['nominal'].toString()))
          .toList();

      // Simpan ke dalam variabel expense
      expense.value = expenseData;
    }, onError: (e) {
      print('Error fetching expense: $e');
    });
  }

  void fetchExpenseByCategory() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      // Map untuk menyimpan total pengeluaran per kategori
      Map<String, double> categoryTotals = {
        'Makan': 0.0,
        'Transport': 0.0,
        'Belanja': 0.0,
        'Hiburan': 0.0,
        'Pendidikan': 0.0,
        'Rumah Tangga': 0.0,
        'Investasi': 0.0,
        'Kesehatan': 0.0,
        'Liburan': 0.0,
        'Perbaikan Rumah': 0.0,
        'Pakaian': 0.0,
        'Internet': 0.0,
        'Olahraga & Gym': 0.0,
        'Lainnya': 0.0,
      };

      // Loop melalui dokumen snapshot
      snapshot.docs.forEach((doc) {
        String category = doc['kategori'];
        double amount = double.parse(doc['nominal'].toString());

        // Tambahkan nominal ke kategori yang sesuai
        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        }
      });

      // Perbarui data pieChartData dengan data yang baru
      updatePieChartData(categoryTotals);
    }, onError: (e) {
      print('Error fetching expense by category: $e');
    });
  }

  void updatePieChartData(Map<String, double> categoryTotals) {
    // Ubah map data ke dalam bentuk yang sesuai untuk PieChart
    pieChartData.value = [
      PieChartSectionData(
        color: Colors.green,
        value: categoryTotals['Makan'] ?? 0.0,
        title: 'Makan', // Tampilkan nama kategori di title
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: categoryTotals['Transport'] ?? 0.0,
        title: 'Transport',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: categoryTotals['Belanja'] ?? 0.0,
        title: 'Belanja',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: categoryTotals['Hiburan'] ?? 0.0,
        title: 'Hiburan',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: categoryTotals['Pendidikan'] ?? 0.0,
        title: 'Pendidikan',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.teal,
        value: categoryTotals['Rumah Tangga'] ?? 0.0,
        title: 'Rumah Tangga',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.indigo,
        value: categoryTotals['Investasi'] ?? 0.0,
        title: 'Investasi',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.pink,
        value: categoryTotals['Kesehatan'] ?? 0.0,
        title: 'Kesehatan',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.amber,
        value: categoryTotals['Liburan'] ?? 0.0,
        title: 'Liburan',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.cyan,
        value: categoryTotals['Perbaikan Rumah'] ?? 0.0,
        title: 'Perbaikan Rumah',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.lime,
        value: categoryTotals['Pakaian'] ?? 0.0,
        title: 'Pakaian',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.brown,
        value: categoryTotals['Internet'] ?? 0.0,
        title: 'Internet',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: categoryTotals['Olahraga & Gym'] ?? 0.0,
        title: 'Olahraga & Gym',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.black,
        value: categoryTotals['Lainnya'] ?? 0.0,
        title: 'Lainnya',
        radius: 50,
      ),
    ];
  }

  void onClose() {
    deskripsiController.dispose();
    nominalController.dispose(); // Dispose nominalController juga
    super.onClose();
  }

  // Function to save form data to Firestor

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
    final controller = Get.find<StatisticController>();
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
}
