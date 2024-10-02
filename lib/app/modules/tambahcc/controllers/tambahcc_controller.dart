import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahccController extends GetxController {
  var namaKartu = ''.obs;
  var ikonKartu = ''.obs;
  var limitKredit = ''.obs;
  var tanggalMulai = ''.obs;
  var tanggalBerakhir = ''.obs;
  var akunPembayaran = ''.obs;
  var akunList = <Map<String, dynamic>>[].obs;
  var selectedIcon = Rx<String?>(null);
  var filteredIcons = <String>[].obs;

  List<String> icons = [
    'assets/icons/paypal.webp', // Bank BCA
    'assets/icons/paypal.webp', // Bank Mandiri
    'assets/icons/paypal.webp', // Bank BNI
    'assets/icons/paypal.webp', // Bank BRI
  ];

  List<String> iconLabels = [
    'Paypal',
    'Paypal',
    'Paypal',
    'Paypal',
  ];

  User? currentUser;

  @override
  void onInit() {
    super.onInit();
    currentUser = FirebaseAuth.instance.currentUser;
    filteredIcons.value = icons;

    if (currentUser != null) {
      loadAkunList();
    } else {
      Get.snackbar('Error', 'Pengguna tidak terautentikasi');
    }
  }

  void searchIcon(String query) {
    if (query.isEmpty) {
      filteredIcons.value = icons;
    } else {
      filteredIcons.value = icons.where((icon) {
        int index = icons.indexOf(icon);
        return iconLabels[index].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> loadAkunList() async {
    try {
      CollectionReference accounts =
          FirebaseFirestore.instance.collection('accounts');

      QuerySnapshot querySnapshot =
          await accounts.where('user_id', isEqualTo: currentUser!.uid).get();

      akunList.clear();

      for (var doc in querySnapshot.docs) {
        akunList.add({
          'id': doc.id,
          'nama_akun': doc['nama_akun'],
          'icon': doc['icon'],
          'saldo_awal': doc['saldo_awal'],
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat akun: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> simpanKartuKredit() async {
    // Periksa apakah namaKartu dan akunPembayaran diisi
    if (namaKartu.isEmpty || akunPembayaran.isEmpty) {
      Get.snackbar("Error", "Nama Kartu dan Akun Pembayaran harus diisi");
      return;
    }

    try {
      CollectionReference kartuKredit =
          FirebaseFirestore.instance.collection('kartu_kredit');

      // Menggunakan .value untuk mendapatkan nilai dari Rx
      await kartuKredit.add({
        'namaKartu': namaKartu.value,
        'ikonKartu': ikonKartu.value,
        'limitKredit':
            limitKredit.value, // Pastikan ini adalah string yang sesuai
        'tanggalMulai': tanggalMulai.value,
        'tanggalBerakhir': tanggalBerakhir.value,
        'akunPembayaran': akunPembayaran.value,
        'createdAt': FieldValue.serverTimestamp(),
        'user_id': currentUser!.uid,
      });

      Get.snackbar('Berhasil', 'Data kartu kredit berhasil disimpan',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan data: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  List<Map<String, dynamic>> showAkunList() {
    return akunList;
  }
}
