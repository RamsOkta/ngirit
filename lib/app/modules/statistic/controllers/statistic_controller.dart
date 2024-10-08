import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StatisticController extends GetxController {
  //TODO: Implement StatisticController

  var income = [5000, 7000, 8000, 6000, 10000].obs; // Data pemasukan
  var expense = [4000, 6000, 5000, 4000, 7000].obs;

  var selectedDate = DateTime.now().obs;

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

  getGroupedTransactions() {}

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
  }
}
