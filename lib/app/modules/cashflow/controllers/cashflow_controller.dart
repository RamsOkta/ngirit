import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CashflowController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController pengeluaranController = TextEditingController();
  TextEditingController pendapatanController = TextEditingController();

  var income = <Map<String, dynamic>>[].obs; // Store detailed income data
  var expense = <Map<String, dynamic>>[].obs; // Store detailed expense data

  var totalIncome = 0.0.obs; // Total pemasukan
  var totalExpense = 0.0.obs; // Total pengeluaran
  var totalBalance = 0.0.obs;
  var totalExpenses = 0.0.obs; // Total pengeluaran
  var totalIncomes = 0.0.obs;
  var selectedDates = ''.obs;

  var selectedDate = DateTime.now().obs; // Selected date
  var searchQuery = ''.obs; // Search query
  var selectedCategories = <String>[].obs; // Selected filter categories
  var selectedAccounts = <String>[].obs; // Selected filter accounts

  String get userId => _auth.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchExpense();
    fetchIncome();
    fetchTotalIncome();
    fetchTotalExpense();
    fetchTotalIncomes();
    fetchTotalExpenses();
    fetchTotalBalance();
    listenToAccountUpdates();
    listenToCreditCardUpdates();

    // Listen for changes in total income and total expense
    ever(totalIncome, (_) => updateTotalBalance());
    ever(totalExpense, (_) => updateTotalBalance());
  }

  // Fungsi untuk mengambil data pengeluaran
  void fetchExpense() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      expense.value = snapshot.docs.map((doc) {
        return {
          'nominal': double.parse(doc['nominal'].toString()),
          'deskripsi': doc['deskripsi'],
          'kategori': doc['kategori'],
          'akun': doc['akun'],
          'tanggal': doc['tanggal'],
        };
      }).toList();
      calculateTotalExpense(); // Recalculate total expenses whenever new data is fetched
    }, onError: (e) {
      print('Error fetching expense: $e');
    });
  }

  // Fungsi untuk mengambil data pemasukan
  void fetchIncome() {
    _firestore
        .collection('pendapatan')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      income.value = snapshot.docs.map((doc) {
        return {
          'nominal': double.parse(doc['nominal'].toString()),
          'deskripsi': doc['deskripsi'],
          'kategori': doc['kategori'],
          'akun': doc['akun'],
          'tanggal': doc['tanggal'],
        };
      }).toList();
      calculateTotalIncome(); // Recalculate total income whenever new data is fetched
    }, onError: (e) {
      print('Error fetching income: $e');
    });
  }

  void calculateTotalExpense() {
    totalExpense.value = expense.fold(0, (sum, item) => sum + item['nominal']);
  }

  // Calculate total income
  void calculateTotalIncome() {
    totalIncome.value = income.fold(0, (sum, item) => sum + item['nominal']);
  }

  // Update total balance
  void updateTotalBalance() {
    totalBalance.value = saldo.value + totalIncomes.value - totalExpenses.value;
  }

  // Fungsi untuk berpindah ke bulan sebelumnya
  DateTime get startOfMonth =>
      DateTime(selectedDate.value.year, selectedDate.value.month, 1);

  // Get end of month
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
    fetchExpense();
    fetchIncome();
  }

// Fungsi untuk mengambil saldo dari akun dan menghitung total balance
  void fetchTotalBalance() {
    _firestore
        .collection('accounts')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((accountSnapshot) {
      if (accountSnapshot.docs.isNotEmpty) {
        int totalSaldo = 0;
        for (var accountDoc in accountSnapshot.docs) {
          totalSaldo += int.parse(accountDoc['saldo_awal'].toString());
        }
        totalBalance.value =
            totalSaldo + totalIncomes.value - totalExpenses.value;
      } else {
        print('No account found for user');
      }
    }, onError: (e) {
      print('Error listening to balance changes: $e');
    });
  }

  // Fetch total expenses
  void fetchTotalExpense() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      totalExpense.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'].toString()));
    }, onError: (e) {
      print('Error fetching expense: $e');
    });
  }

  void fetchTotalExpenses() {
    _firestore
        .collection('pengeluaran')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      totalExpenses.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'].toString()));
    }, onError: (e) {
      print('Error fetching expense: $e');
    });
  }

  void fetchTotalIncome() {
    _firestore
        .collection('pendapatan')
        .where('user_id', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .listen((snapshot) {
      totalIncome.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'].toString()));
    }, onError: (e) {
      print('Error fetching income: $e');
    });
  }

  void fetchTotalIncomes() {
    _firestore
        .collection('pendapatan')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      totalIncomes.value = snapshot.docs
          .fold(0, (sum, doc) => sum + int.parse(doc['nominal'].toString()));
    }, onError: (e) {
      print('Error fetching income: $e');
    });
  }

  // Fungsi untuk melakukan filter berdasarkan kategori dan akun
  List<Map<String, dynamic>> filterByCategoryAndAccount(
      List<Map<String, dynamic>> data) {
    if (selectedCategories.isNotEmpty) {
      data = data
          .where((item) => selectedCategories.contains(item['kategori']))
          .toList();
    }
    if (selectedAccounts.isNotEmpty) {
      data = data
          .where((item) => selectedAccounts.contains(item['akun']))
          .toList();
    }
    return data;
  }

  // Reactive lists for filtered data
  List<Map<String, dynamic>> get filteredExpenses {
    List<Map<String, dynamic>> filteredData =
        filterByCategoryAndAccount(expense.value);
    if (searchQuery.value.isEmpty) return filteredData;
    return filteredData
        .where((expense) => expense['deskripsi']
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> get filteredIncome {
    List<Map<String, dynamic>> filteredData =
        filterByCategoryAndAccount(income.value);
    if (searchQuery.value.isEmpty) return filteredData;
    return filteredData
        .where((incomeItem) => incomeItem['deskripsi']
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  // Method to update the search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Method to update the selected categories
  void updateSelectedCategories(List<String> categories) {
    selectedCategories.assignAll(categories);
  }

  // Method to update the selected accounts
  void updateSelectedAccounts(List<String> accounts) {
    selectedAccounts.assignAll(accounts);
  }

  var selectedIndex = 0.obs;
  var username = ''.obs;
  var saldo = 0.obs; // Default saldo 0
  var accounts = <Map<String, dynamic>>[].obs;
  var creditCards = <Map<String, dynamic>>[].obs;
  var selectedTab = 0.obs; // New list for credit cards
  var selectedAkun = ''.obs;
  var selectedKategori = ''.obs;
  var deskripsi = ''.obs; // Variabel untuk menyimpan deskripsi

  TextEditingController nominalController = TextEditingController();
  TextEditingController deskripsiController = TextEditingController();

  void onClose() {
    deskripsiController.dispose();
    nominalController.dispose(); // Dispose nominalController juga
    super.onClose();
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
    final controller = Get.find<CashflowController>();
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

  // Future<void> saveFormData(String nominal) async {
  //   final controller = Get.find<
  //       CashflowController>(); // Assuming CashflowController is being used
  //   String collection;

  //   // Determine the collection based on the selected tab
  //   switch (controller.selectedTab.value) {
  //     case 0:
  //       collection = 'pengeluaran';
  //       break;
  //     case 1:
  //       collection = 'pendapatan';
  //       break;
  //     default:
  //       collection = 'pengeluaran';
  //   }

  //   // Form validation to ensure all fields are filled
  //   if (nominal.isEmpty || nominal == '0,00') {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Nominal tidak boleh kosong atau nol",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //     return;
  //   }

  //   if (controller.deskripsi.value.isEmpty) {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Deskripsi tidak boleh kosong",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //     return;
  //   }

  //   if (controller.selectedKategori.value.isEmpty) {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Kategori tidak boleh kosong",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //     return;
  //   }

  //   if (controller.selectedAkun.value.isEmpty) {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Akun tidak boleh kosong",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //     return;
  //   }

  //   if (controller.selectedDates.value.isEmpty) {
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Tanggal tidak boleh kosong",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //     return;
  //   }

  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;

  //     if (user != null) {
  //       // Menghapus ',' dari nominal sebelum disimpan
  //       String sanitizedNominal = nominal.replaceAll(',', '');

  //       await FirebaseFirestore.instance.collection(collection).add({
  //         'user_id': user.uid,
  //         'nominal':
  //             sanitizedNominal, // Menggunakan sanitizedNominal tanpa koma
  //         'deskripsi': controller.deskripsi.value,
  //         'kategori': controller.selectedKategori.value,
  //         'akun': controller.selectedAkun.value,
  //         'tanggal': controller.selectedDates.value,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });

  //       // Show a success notification and close the modal dialog after saving
  //       Get.defaultDialog(
  //         title: "Berhasil",
  //         middleText: "Data berhasil disimpan ke $collection",
  //         textConfirm: "OK",
  //         confirmTextColor: Colors.white,
  //         onConfirm: () {
  //           Get.back(); // Close the success dialog
  //           // Close the form modal after successful save
  //         },
  //       );
  //       // Reset form inputs
  //       controller.nominalController.clear();
  //       controller.deskripsiController.clear();
  //       controller.selectedKategori.value = '';
  //       controller.selectedAkun.value = '';
  //       controller.selectedDates.value = '';
  //     }
  //   } catch (e) {
  //     // Show an error notification
  //     Get.defaultDialog(
  //       title: "Error",
  //       middleText: "Gagal menyimpan data ke $collection",
  //       textConfirm: "OK",
  //       confirmTextColor: Colors.white,
  //       onConfirm: () => Get.back(),
  //     );
  //   }
  // }

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

    deskripsi.value = ''; // Reset deskripsi
  }
}
