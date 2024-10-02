import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends GetxController {
  var username = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  var passwordVisible = false.obs;
  var confirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (password.value == confirmPassword.value) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.value,
          password: password.value,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': username.value,
          'email': email.value,
        });

        print("User registered successfully");
        Get.snackbar("Success", "Registered successfully");
      } on FirebaseAuthException catch (e) {
        print("Registration failed: ${e.message}");
        Get.snackbar("Error", e.message ?? "Registration failed");
      }
    } else {
      print("Passwords do not match");
      Get.snackbar("Error", "Passwords do not match");
    }
  }
}
