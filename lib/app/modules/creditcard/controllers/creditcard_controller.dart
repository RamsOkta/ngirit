import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditcardController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var creditCards =
      <Map<String, dynamic>>[].obs; // Menyimpan daftar kartu kredit
  var isLoading =
      false.obs; // Untuk menampilkan loading ketika data sedang diproses

  @override
  void onInit() {
    super.onInit();
    fetchCreditCards(); // Panggil fungsi untuk mengambil data saat controller diinisialisasi
  }

  // Fungsi untuk mengambil data kartu kredit dari Firestore berdasarkan user_id
  void fetchCreditCards() async {
    try {
      isLoading.value = true; // Set isLoading menjadi true saat data diambil
      String? userId = auth.currentUser?.uid; // Pastikan pengguna sudah login

      if (userId != null) {
        QuerySnapshot snapshot = await firestore
            .collection('kartu_kredit')
            .where('user_id', isEqualTo: userId)
            .get();

        creditCards.assignAll(snapshot.docs.map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id, // Simpan ID dokumen untuk pengeditan
            }));
      }
    } catch (e) {
      print("Error fetching credit cards: $e");
    } finally {
      isLoading.value =
          false; // Set isLoading menjadi false setelah data diambil
    }
  }

  // Fungsi untuk mengedit data kartu kredit
  Future<void> editCreditCard(
      String cardId, Map<String, dynamic> newData) async {
    try {
      isLoading.value = true; // Set loading true ketika sedang mengedit data
      await firestore.collection('kartu_kredit').doc(cardId).update(newData);
      // Setelah data berhasil diupdate, refresh daftar kartu kredit
      fetchCreditCards();
    } catch (e) {
      print("Error updating credit card: $e");
    } finally {
      isLoading.value = false; // Set loading menjadi false setelah selesai
    }
  }

  // Fungsi untuk mengupdate limit kartu kredit
  Future<void> updateLimit(String cardId, String newLimit) async {
    // Cari kartu kredit berdasarkan cardId
    for (var card in creditCards) {
      if (card['id'] == cardId) {
        // Update limit kredit di Firestore
        await editCreditCard(
            cardId, {'limitKredit': newLimit}); // Memperbarui Firestore
        card['limitKredit'] = newLimit; // Update limit lokal
        creditCards.refresh(); // Beri tahu UI bahwa data telah berubah
        break;
      }
    }
  }

  // Fungsi untuk menghapus kartu kredit dari Firestore
  Future<void> deleteCard(String cardId) async {
    try {
      isLoading.value = true; // Set loading true saat sedang menghapus
      await firestore.collection('kartu_kredit').doc(cardId).delete();
      // Setelah dihapus, refresh daftar kartu kredit
      fetchCreditCards();
      print("Kartu kredit dengan ID $cardId telah dihapus.");
    } catch (e) {
      print("Error deleting credit card: $e");
    } finally {
      isLoading.value = false; // Set loading menjadi false setelah selesai
    }
  }
}
