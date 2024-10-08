import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BataspengeluaranController extends GetxController {
  //TODO: Implement BataspengeluaranController

  var selectedDate = DateTime.now().obs;
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs; // Add category filtering

  String get selectedMonth =>
      DateFormat('MMMM yyyy').format(selectedDate.value);

  String get previousMonth {
    final prevDate =
        DateTime(selectedDate.value.year, selectedDate.value.month - 1);
    return DateFormat('MMMM yyyy').format(prevDate);
  }

  String get nextMonth {
    final nextDate =
        DateTime(selectedDate.value.year, selectedDate.value.month + 1);
    return DateFormat('MMMM yyyy').format(nextDate);
  }

  var transactions = [
    {
      "date": "2024-09-01",
      "description": "Grocery",
      "amount": "500000",
      "category": "Makanan"
    },
    {
      "date": "2024-09-10",
      "description": "Salary",
      "amount": "3500000",
      "category": "Income"
    },
    {
      "date": "2024-09-15",
      "description": "Rent",
      "amount": "1000000",
      "category": "Expense"
    },
  ].obs;

  var income = 0.obs;
  var expense = 0.obs;
  var balance = 0.obs;

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
  }

  // Group transactions by date with search filtering
  Map<String, List<Map<String, String>>> getGroupedTransactions() {
    Map<String, List<Map<String, String>>> groupedTransactions = {};

    for (var transaction in transactions) {
      String date = transaction['date']!;
      String category = transaction['category']!;

      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }

      bool matchesSearch = searchQuery.value.isEmpty ||
          transaction["description"]!
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      bool matchesCategory =
          selectedCategory.value.isEmpty || category == selectedCategory.value;

      if (matchesSearch && matchesCategory) {
        groupedTransactions[date]!.add(transaction);
      }
    }

    return groupedTransactions;
  }

  // Inisialisasi Firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fungsi untuk menambahkan batas pengeluaran
  Future<void> addBatasPengeluaran(String kategori, double jumlah) async {
    try {
      await firestore.collection('batas_pengeluaran').add({
        'kategori': kategori,
        'jumlah': jumlah,
        'tanggal': DateTime.now(),
      });
      Get.snackbar('Berhasil', 'Batas pengeluaran berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
    }
  }
}
