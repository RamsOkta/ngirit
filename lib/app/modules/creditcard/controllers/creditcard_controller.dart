import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditcardController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var creditCards =
      <Map<String, dynamic>>[].obs; // Menyimpan daftar kartu kredit

  @override
  void onInit() {
    super.onInit();
    fetchCreditCards(); // Panggil fungsi untuk mengambil data saat controller diinisialisasi
  }

  // Fungsi untuk mengambil data kartu kredit dari Firestore berdasarkan user_id
  void fetchCreditCards() async {
    try {
      // Mendapatkan user_id pengguna yang sedang login
      String? userId = auth.currentUser?.uid; // Pastikan pengguna sudah login

      if (userId != null) {
        QuerySnapshot snapshot = await firestore
            .collection('kartu_kredit')
            .where('user_id', isEqualTo: userId)
            .get();

        creditCards.assignAll(
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Error fetching credit cards: $e");
    }
  }
}
