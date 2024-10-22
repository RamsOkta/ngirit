import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileController extends GetxController {
  var profilePictureUrl = ''.obs;
  var username = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        var userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          profilePictureUrl.value = userDoc.data()?['profilePictureUrl'] ?? '';
          username.value = userDoc.data()?['username'] ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'username': newUsername,
      });
      username.value = newUsername;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  Future<void> uploadProfilePicture({required bool fromCamera}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        User? user = _auth.currentUser;

        if (user != null) {
          Reference storageRef =
              _storage.ref().child('profilePictures/${user.uid}.jpg');
          UploadTask uploadTask = storageRef.putFile(imageFile);
          TaskSnapshot snapshot = await uploadTask;

          // Ensure upload is complete before getting the download URL
          String downloadUrl = await snapshot.ref.getDownloadURL();
          await _firestore.collection('users').doc(user.uid).update({
            'profilePictureUrl': downloadUrl,
          });

          profilePictureUrl.value = downloadUrl;
          Get.snackbar('Success', 'Profile picture updated successfully');
        }
      } else {
        Get.snackbar('Error', 'No image selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload profile picture: $e');
    }
  }
}
