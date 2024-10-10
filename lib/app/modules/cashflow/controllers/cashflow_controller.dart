import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CashflowController extends GetxController {
  var expenses = <Map<String, dynamic>>[].obs;
  var income = <Map<String, dynamic>>[].obs;

  final RxString previousMonth = ''.obs;

  final RxString selectedMonth = ''.obs;

  final RxString nextMonth = ''.obs;

  final RxDouble expense = 0.0.obs;

  final RxDouble balance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
    fetchIncome();
  }

  // Function to fetch expenses from Firestore
  Future<void> fetchExpenses() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('pengeluaran')
            .where('user_id', isEqualTo: user.uid)
            .get();

        expenses.assignAll(
          querySnapshot.docs
              .map((doc) => {
                    'nominal': doc['nominal'],
                    'deskripsi': doc['deskripsi'],
                    'kategori': doc['kategori'],
                    'akun': doc['akun'],
                    'tanggal': doc['tanggal'],
                  })
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch expenses');
    }
  }

  // Function to fetch income from Firestore
  Future<void> fetchIncome() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('pendapatan')
            .where('user_id', isEqualTo: user.uid)
            .get();

        income.assignAll(
          querySnapshot.docs
              .map((doc) => {
                    'nominal': doc['nominal'],
                    'deskripsi': doc['deskripsi'],
                    'kategori': doc['kategori'],
                    'akun': doc['akun'],
                    'tanggal': doc['tanggal'],
                  })
              .toList(),
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch income');
    }
  }

  Map<String, List<Map<String, String>>> getGroupedTransactions() {
    // Implement your logic to get grouped transactions

    return {};
  }

  void changeMonth(int offset) {
    // Implement your logic to change the month
  }

  void performSearch(String query) {
    // Implement your search logic here

    print('Searching for: $query');
  }

  void updateBalance(double newBalance) {
    balance.value = newBalance;
  }

  // Getter to calculate total expenses
  double get totalExpenses => expenses.fold(0, (sum, item) {
        double nominal = item['nominal'] is String
            ? double.parse(item['nominal'])
            : item['nominal'].toDouble();
        return sum + nominal;
      });

// Getter to calculate total income
  double get totalIncome => income.fold(0, (sum, item) {
        double nominal = item['nominal'] is String
            ? double.parse(item['nominal'])
            : item['nominal'].toDouble();
        return sum + nominal;
      });
}
