import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TambahakunController extends GetxController {
  var namaAkun = ''.obs;
  var saldoAkun = ''.obs; // Ubah tipe menjadi String
  var selectedIcon = Rx<String?>(null); // Ubah ke String (path asset)
  var filteredIcons = <String>[].obs; // Ubah ke String (path asset)

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of available icons (Bank and Wallet icons from assets)
  List<String> icons = [
    'assets/icons/bca.webp', // Bank BCA
    'assets/icons/mandiri.svg', // Bank Mandiri
    'assets/icons/bni.jpg', // Bank BNI
    'assets/icons/bri.png', // Bank BRI
  ];

  // Daftar label untuk ikon bank
  List<String> iconLabels = [
    'Bank BCA',
    'Bank Mandiri',
    'Bank BNI',
    'Bank BRI',
    // Tambahkan label bank lainnya di sini
  ];

  @override
  void onInit() {
    super.onInit();
    // Set default filtered icons to show all icons
    filteredIcons.value = icons;
  }

  // Fungsi pencarian untuk memfilter ikon berdasarkan input pengguna
  void searchIcon(String query) {
    if (query.isEmpty) {
      // Tampilkan semua ikon jika pencarian kosong
      filteredIcons.value = icons;
    } else {
      // Filter ikon berdasarkan nama label (case insensitive)
      filteredIcons.value = icons.where((icon) {
        int index = icons.indexOf(icon);
        return iconLabels[index].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void tambahAkun() async {
    if (namaAkun.isNotEmpty && selectedIcon.value != null) {
      try {
        User? user = _auth.currentUser;

        if (user != null) {
          await _firestore.collection('accounts').add({
            'user_id': user.uid,
            'nama_akun': namaAkun.value,
            'saldo_awal': saldoAkun.value,
            'icon': selectedIcon.value, // Menyimpan path asset dari ikon
          });

          Get.snackbar("Sukses", "Akun berhasil ditambahkan");
        }
      } catch (e) {
        Get.snackbar("Error", "Terjadi kesalahan: $e");
      }
    } else {
      Get.snackbar("Error", "Lengkapi semua data!");
    }
  }
}
