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
    'assets/icons/bca.png', // Bank BCA
    'assets/icons/mandiri.png', // Bank Mandiri
    'assets/icons/bni.png', // Bank BNI
    'assets/icons/bri.png', // Bank BRI
    'assets/icons/cimb.png', // Bank CIMB Niaga
    'assets/icons/danamon.png', // Bank Danamon
    'assets/icons/permata.png', // Bank Permata
    'assets/icons/sinarmas.png', // Bank Sinarmas
    'assets/icons/mega.png', // Bank Mega
    'assets/icons/maybank.png', // Bank Maybank Indonesia
    'assets/icons/panin.png', // Panin Bank
    'assets/icons/ocbc.png', // Bank OCBC NISP
    'assets/icons/bukopin.png', // Bank Bukopin
    'assets/icons/hsbc.png', // HSBC Indonesia
    'assets/icons/standard_chartered.png', // Standard Chartered Bank Indonesia
    'assets/icons/citibank.png', // Citibank Indonesia
    'assets/icons/jenius.png', // Jenius (Bank BTPN)
    'assets/icons/jago.png', // Bank Jago
    'assets/icons/bsi.png', // Bank Syariah Indonesia
    'assets/icons/muamalat.png', // Bank Muamalat
  ];

  List<String> iconLabels = [
    'Bank BCA',
    'Bank Mandiri',
    'Bank BNI',
    'Bank BRI',
    'Bank CIMB Niaga',
    'Bank Danamon',
    'Bank Permata',
    'Bank Sinarmas',
    'Bank Mega',
    'Bank Maybank Indonesia',
    'Panin Bank',
    'Bank OCBC NISP',
    'Bank Bukopin',
    'HSBC Indonesia',
    'Standard Chartered Bank Indonesia',
    'Citibank Indonesia',
    'Jenius',
    'Bank Jago',
    'Bank Syariah Indonesia',
    'Bank Muamalat',
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
