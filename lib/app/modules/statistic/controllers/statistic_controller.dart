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

  var totalIncome = 0.obs; // Total pemasukan
  var totalExpense = 0.obs; // Total pengeluaran
  var totalBalance = 0.obs; // Total saldo
  var pieChartData = <PieChartSectionData>[].obs;

  var selectedDate = DateTime.now().obs;

  // Ambil userId dari pengguna yang sedang login
  String get userId => _auth.currentUser?.uid ?? '';

  // Ambil bulan depan, sekarang, dan sebelumnya
  DateTime get startOfMonth =>
      DateTime(selectedDate.value.year, selectedDate.value.month, 1);
  DateTime get endOfMonth {
    final nextMonth =
        DateTime(selectedDate.value.year, selectedDate.value.month + 1, 1);
    return nextMonth.subtract(Duration(days: 1));
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

  // Method untuk mengambil data pemasukan
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
        'Transportasi': 0.0,
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
        title: '${categoryTotals['Makan']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: categoryTotals['Transportasi'] ?? 0.0,
        title: '${categoryTotals['Transportasi']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: categoryTotals['Belanja'] ?? 0.0,
        title: '${categoryTotals['Belanja']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.blue,
        value: categoryTotals['Hiburan'] ?? 0.0,
        title: '${categoryTotals['Hiburan']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: categoryTotals['Pendidikan'] ?? 0.0,
        title: '${categoryTotals['Pendidikan']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: categoryTotals['Rumah Tangga'] ?? 0.0,
        title: '${categoryTotals['Rumah Tangga']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.brown,
        value: categoryTotals['Investasi'] ?? 0.0,
        title: '${categoryTotals['Investasi']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.teal,
        value: categoryTotals['Kesehatan'] ?? 0.0,
        title: '${categoryTotals['Kesehatan']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.cyan,
        value: categoryTotals['Liburan'] ?? 0.0,
        title: '${categoryTotals['Liburan']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.pink,
        value: categoryTotals['Perbaikan Rumah'] ?? 0.0,
        title:
            '${categoryTotals['Perbaikan Rumah']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.lime,
        value: categoryTotals['Pakaian'] ?? 0.0,
        title: '${categoryTotals['Pakaian']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.indigo,
        value: categoryTotals['Internet'] ?? 0.0,
        title: '${categoryTotals['Internet']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: categoryTotals['Olahraga & Gym'] ?? 0.0,
        title:
            '${categoryTotals['Olahraga & Gym']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Colors.black,
        value: categoryTotals['Lainnya'] ?? 0.0,
        title: '${categoryTotals['Lainnya']?.toStringAsFixed(1) ?? '0'}%',
        radius: 50,
      ),
    ];
  }

  // Inisialisasi dan fetch data saat controller dibuat
  @override
  void onInit() {
    super.onInit();

    fetchIncome();
    fetchExpense();
    fetchTotalIncome();
    fetchTotalExpense();
    fetchExpenseByCategory();

    // Hitung ulang saldo ketika total pemasukan atau pengeluaran berubah
    everAll([totalIncome, totalExpense], (_) {
      fetchTotalBalance();
    });
  }
}
