import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  var profilePictureUrl = ''.obs;
  var username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          profilePictureUrl.value = userDoc.data()?['profilePictureUrl'] ?? '';
          username.value = userDoc.data()?['username'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data');
    }
  }
}
